`default_nettype none
`timescale 1 ns / 1 ns

/**
 * 4-Way Interface Handler
 * 
 * Implements the Betaflight-style 4-way interface for BLHeli configuration.
 * Optimized for timing at 72MHz.
 */

module four_way_handler #(
    parameter CLK_FREQ_HZ = 72_000_000
) (
    input  logic clk,
    input  logic rst,

    // USB UART Interface (Byte-parallel)
    input  logic [7:0] uart_rx_data,
    input  logic       uart_rx_valid,
    output logic [7:0] uart_tx_data,
    output logic       uart_tx_valid,
    input  logic       uart_tx_ready,

    // ESC Interface (Byte-parallel to bridge)
    output logic [7:0] esc_tx_data,
    output logic       esc_tx_valid,
    input  logic       esc_tx_ready,
    input  logic [7:0] esc_rx_data,
    input  logic       esc_rx_valid,

    output logic       active,
    output logic       exit_session
);

    typedef enum logic [3:0] {
        STATE_IDLE,
        STATE_COMMAND,
        STATE_ADDR1,
        STATE_ADDR2,
        STATE_LENGTH,
        STATE_PAYLOAD,
        STATE_CRC_IN1,
        STATE_CRC_IN2,
        STATE_PROCESS,
        STATE_FORWARD_TO_ESC,
        STATE_WAIT_ESC_RESP,
        STATE_CALC_OUT_CRC,
        STATE_SEND_HEADER,
        STATE_SEND_CMD,
        STATE_SEND_ADDR1,
        STATE_SEND_ADDR2,
        STATE_SEND_LEN,
        STATE_SEND_PAYLOAD,
        STATE_SEND_ACK,
        STATE_SEND_CRC1,
        STATE_SEND_CRC2
    } state_t;

    state_t state;
    logic [7:0] cmd;
    logic [15:0] addr;
    logic [7:0] length;
    
    // RAM Interface
    logic [6:0] ram_addr;
    logic [7:0] ram_din;
    logic       ram_we;
    logic [7:0] ram_dout;
    
    shared_buffer_ram #(
        .ADDR_WIDTH(7) // 128 bytes
    ) u_buffer (
        .clk(clk),
        .addr(ram_addr),
        .din(ram_din),
        .we(ram_we),
        .dout(ram_dout)
    );
    
    // Register RAM output for timing
    logic [7:0] ram_dout_reg;
    always_ff @(posedge clk) ram_dout_reg <= ram_dout;

    logic [6:0] payload_idx;
    logic [15:0] crc_received;
    
    // Response status
    logic [7:0] resp_length;
    logic [7:0] resp_ack;
    
    // Registered active signal
    logic active_int;
    always_ff @(posedge clk) begin
        if (rst) active_int <= 0;
        else active_int <= (state != STATE_IDLE) || (uart_rx_valid && uart_rx_data == 8'h2F);
    end
    assign active = active_int;

    // Sequential CRC16-XMODEM
    logic [15:0] crc_accum;
    logic [7:0]  crc_in_byte;
    logic        crc_trigger;
    logic [3:0]  crc_bit_idx;
    logic        crc_busy;

    always_ff @(posedge clk) begin
        if (rst) begin
            crc_accum <= 0;
            crc_bit_idx <= 0;
            crc_busy <= 0;
        end else if (crc_trigger) begin
            crc_accum <= crc_accum ^ (crc_in_byte << 8);
            crc_bit_idx <= 8;
            crc_busy <= 1;
        end else if (crc_busy) begin
            if (crc_accum & 16'h8000)
                crc_accum <= (crc_accum << 1) ^ 16'h1021;
            else
                crc_accum <= (crc_accum << 1);
            
            if (crc_bit_idx == 1)
                crc_busy <= 0;
            else
                crc_bit_idx <= crc_bit_idx - 1'b1;
        end
    end

    logic [20:0] watchdog; // Reduced from 24 to help timing
    localparam WATCHDOG_TIMEOUT = 1000000; // ~14ms at 72MHz
    
    logic [17:0] esc_timer;
    localparam ESC_IDLE_TIMEOUT = CLK_FREQ_HZ / 1000; // 1ms idle detect

    always_ff @(posedge clk) begin
        if (rst) begin
            state <= STATE_IDLE;
            uart_tx_valid <= 0;
            esc_tx_valid <= 0;
            watchdog <= 0;
            ram_we <= 1'b0;
            esc_timer <= 0;
            exit_session <= 0;
            crc_trigger <= 0;
            ram_addr <= 0;
        end else begin
            ram_we <= 1'b0;
            exit_session <= 0;
            crc_trigger <= 0;
            
            // Watchdog (Reduced logic depth)
            if (uart_rx_valid || esc_rx_valid || (uart_tx_ready && uart_tx_valid) || (esc_tx_ready && esc_tx_valid))
                watchdog <= 0;
            else if (!watchdog[20])
                watchdog <= watchdog + 1'b1;
            
            if (watchdog[20] && state != STATE_IDLE)
                state <= STATE_IDLE;

            // Timer for ESC response
            if (state == STATE_WAIT_ESC_RESP) begin
                if (esc_rx_valid) esc_timer <= 0;
                else if (esc_timer < ESC_IDLE_TIMEOUT) esc_timer <= esc_timer + 1'b1;
            end else esc_timer <= 0;

            // Byte Clear Logic
            if (uart_tx_ready && uart_tx_valid) uart_tx_valid <= 0;
            if (esc_tx_ready && esc_tx_valid)   esc_tx_valid <= 0;

            case (state)
                STATE_IDLE: begin
                    if (uart_rx_valid && uart_rx_data == 8'h2F) begin
                        state <= STATE_COMMAND;
                        crc_accum <= 0;
                        crc_in_byte <= 8'h2F;
                        crc_trigger <= 1;
                    end
                end

                STATE_COMMAND: begin
                    if (!crc_busy && !crc_trigger && uart_rx_valid) begin
                        cmd <= uart_rx_data;
                        crc_in_byte <= uart_rx_data;
                        crc_trigger <= 1;
                        state <= STATE_ADDR1;
                    end
                end

                STATE_ADDR1: begin
                    if (!crc_busy && !crc_trigger && uart_rx_valid) begin 
                        addr[15:8] <= uart_rx_data; 
                        crc_in_byte <= uart_rx_data;
                        crc_trigger <= 1;
                        state <= STATE_ADDR2; 
                    end
                end

                STATE_ADDR2: begin
                    if (!crc_busy && !crc_trigger && uart_rx_valid) begin 
                        addr[7:0] <= uart_rx_data; 
                        crc_in_byte <= uart_rx_data;
                        crc_trigger <= 1;
                        state <= STATE_LENGTH; 
                    end
                end

                STATE_LENGTH: begin
                    if (!crc_busy && !crc_trigger && uart_rx_valid) begin
                        length <= uart_rx_data;
                        crc_in_byte <= uart_rx_data;
                        crc_trigger <= 1;
                        payload_idx <= 0;
                        state <= STATE_PAYLOAD;
                    end
                end

                STATE_PAYLOAD: begin
                    if (!crc_busy && !crc_trigger) begin
                        if (payload_idx == length) begin
                            state <= STATE_CRC_IN1;
                        end else if (uart_rx_valid) begin
                            ram_addr <= payload_idx;
                            ram_din <= uart_rx_data;
                            ram_we <= 1;
                            crc_in_byte <= uart_rx_data;
                            crc_trigger <= 1;
                            payload_idx <= payload_idx + 1'b1;
                        end
                    end
                end

                STATE_CRC_IN1: begin
                    if (uart_rx_valid) begin crc_received[15:8] <= uart_rx_data; state <= STATE_CRC_IN2; end
                end

                STATE_CRC_IN2: begin
                    if (uart_rx_valid) begin
                        crc_received[7:0] <= uart_rx_data;
                        if (crc_accum == {crc_received[15:8], uart_rx_data}) begin
                            state <= STATE_PROCESS;
                        end else begin
                            state <= STATE_IDLE;
                        end
                    end
                end

                STATE_PROCESS: begin
                    case (cmd)
                        8'h30: begin resp_ack <= 8'h00; resp_length <= 0; state <= STATE_CALC_OUT_CRC; end
                        8'h32: begin resp_ack <= 8'h00; resp_length <= 6; state <= STATE_CALC_OUT_CRC; end // InterfaceGetName
                        8'h33: begin resp_ack <= 8'h00; resp_length <= 1; state <= STATE_CALC_OUT_CRC; end // InterfaceGetVersion
                        8'h35, 8'h37, 8'h38, 8'h39, 8'h3A, 8'h3B, 8'h3C, 8'h3D, 8'h3E: begin 
                            payload_idx <= 0; ram_addr <= 0; state <= STATE_FORWARD_TO_ESC; 
                        end
                        8'h34: begin exit_session <= 1; state <= STATE_IDLE; end
                        default: begin resp_ack <= 8'h01; resp_length <= 0; state <= STATE_CALC_OUT_CRC; end
                    endcase
                end

                STATE_FORWARD_TO_ESC: begin
                    if (esc_tx_ready && !esc_tx_valid) begin
                        esc_tx_data <= ram_dout_reg;
                        esc_tx_valid <= 1;
                        if (payload_idx + 1'b1 == (length == 0 ? 1 : length)) begin
                            state <= STATE_WAIT_ESC_RESP;
                            payload_idx <= 0;
                            ram_addr <= 0;
                        end else begin
                            payload_idx <= payload_idx + 1'b1;
                            ram_addr <= payload_idx + 1'b1;
                        end
                    end
                end

                STATE_WAIT_ESC_RESP: begin
                    if (esc_rx_valid) begin
                        ram_addr <= payload_idx;
                        ram_din <= esc_rx_data;
                        ram_we <= 1;
                        payload_idx <= payload_idx + 1'b1;
                    end
                    if (payload_idx > 0 && (esc_timer == ESC_IDLE_TIMEOUT || payload_idx == 127)) begin
                         resp_length <= payload_idx;
                         resp_ack <= 8'h00; 
                         state <= STATE_CALC_OUT_CRC;
                    end
                end

                STATE_CALC_OUT_CRC: begin
                    state <= STATE_SEND_HEADER;
                    crc_accum <= 0;
                    crc_in_byte <= 8'h2E;
                    crc_trigger <= 1;
                    payload_idx <= 0;
                    ram_addr <= 0;
                end

                STATE_SEND_HEADER: begin
                    if (!crc_busy && !crc_trigger) begin
                        crc_in_byte <= cmd; crc_trigger <= 1; state <= STATE_SEND_CMD;
                    end
                end

                STATE_SEND_CMD: begin
                    if (!crc_busy && !crc_trigger) begin
                        crc_in_byte <= addr[15:8]; crc_trigger <= 1; state <= STATE_SEND_ADDR1;
                    end
                end

                STATE_SEND_ADDR1: begin
                    if (!crc_busy && !crc_trigger) begin
                        crc_in_byte <= addr[7:0]; crc_trigger <= 1; state <= STATE_SEND_ADDR2;
                    end
                end

                STATE_SEND_ADDR2: begin
                    if (!crc_busy && !crc_trigger) begin
                        crc_in_byte <= resp_length; crc_trigger <= 1; state <= STATE_SEND_LEN;
                    end
                end

                STATE_SEND_LEN: begin
                    if (!crc_busy && !crc_trigger) begin
                        if (payload_idx < resp_length) begin
                            crc_in_byte <= (cmd == 8'h32 ? (payload_idx == 0 ? "T" : payload_idx == 1 ? "9" : payload_idx == 2 ? "K" : payload_idx == 3 ? "-" : payload_idx == 4 ? "F" : "C") :
                                            cmd == 8'h33 ? 8'h01 : ram_dout_reg);
                            crc_trigger <= 1;
                            payload_idx <= payload_idx + 1'b1;
                            ram_addr <= payload_idx + 1'b1;
                        end else begin
                            crc_in_byte <= resp_ack; crc_trigger <= 1; state <= STATE_SEND_ACK;
                        end
                    end
                end

                STATE_SEND_ACK: begin
                    if (!crc_busy && !crc_trigger) begin
                        state <= STATE_SEND_CRC1;
                        payload_idx <= 0;
                        ram_addr <= 0;
                        uart_tx_data <= 8'h2E;
                        uart_tx_valid <= 1;
                    end
                end

                STATE_SEND_CRC1: begin
                    if (uart_tx_ready && !uart_tx_valid) begin
                        uart_tx_data <= cmd; uart_tx_valid <= 1; state <= STATE_SEND_CRC2;
                    end
                end
                
                STATE_SEND_CRC2: begin
                    if (uart_tx_ready && !uart_tx_valid) begin
                        case (payload_idx)
                            0: begin uart_tx_data <= addr[15:8]; payload_idx <= 1; end
                            1: begin uart_tx_data <= addr[7:0]; payload_idx <= 2; end
                            2: begin uart_tx_data <= resp_length; payload_idx <= 3; end
                            3: begin 
                                if (payload_idx - 3 < resp_length) begin
                                    uart_tx_data <= (cmd == 8'h32 ? (payload_idx - 3 == 0 ? "T" : payload_idx - 3 == 1 ? "9" : payload_idx - 3 == 2 ? "K" : payload_idx - 3 == 3 ? "-" : payload_idx - 3 == 4 ? "F" : "C") :
                                                     cmd == 8'h33 ? 8'h01 : ram_dout_reg);
                                    payload_idx <= payload_idx + 1'b1;
                                    ram_addr <= (payload_idx - 3) + 1'b1;
                                end else begin
                                    uart_tx_data <= resp_ack; payload_idx <= 126; // Special
                                end
                            end
                            126: begin uart_tx_data <= crc_accum[15:8]; payload_idx <= 127; end
                            127: begin uart_tx_data <= crc_accum[7:0]; state <= STATE_IDLE; end
                        endcase
                        uart_tx_valid <= 1;
                    end
                end
            endcase
        end
    end
endmodule
