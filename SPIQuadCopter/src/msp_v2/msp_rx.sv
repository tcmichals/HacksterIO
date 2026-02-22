`default_nettype none
`timescale 1ns / 1ps

/**
 * MSP Packet Receiver
 * 
 * Receives bytes from UART, buffers into packet, validates MSP header.
 * Outputs complete packet when valid MSP frame is received.
 * 
 * Pipeline stage 1: Byte reception and buffering
 */
module msp_rx #(
    parameter MAX_PAYLOAD = 16
) (
    input  wire        clk,
    input  wire        rst,
    
    // UART RX interface
    input  wire [7:0]  rx_data,
    input  wire        rx_valid,
    
    // Packet output - packed array for yosys compatibility
    output reg  [7:0]  pkt_cmd,
    output reg  [7:0]  pkt_len,
    output reg  [MAX_PAYLOAD*8-1:0] pkt_payload,
    output reg         pkt_valid,      // Pulse when packet ready
    output reg         pkt_error,      // Pulse on checksum/framing error
    input  wire        pkt_ready,      // Downstream ready for next packet
    
    // Debug outputs (registered for timing)
    output reg  [2:0]  dbg_state,
    output reg         dbg_timeout
);

    // State machine - using localparams for iverilog compatibility
    localparam [2:0]
        S_IDLE      = 3'd0,
        S_WAIT_M    = 3'd1,
        S_WAIT_DIR  = 3'd2,
        S_WAIT_LEN  = 3'd3,
        S_WAIT_CMD  = 3'd4,
        S_WAIT_DATA = 3'd5,
        S_WAIT_CRC  = 3'd6,
        S_OUTPUT    = 3'd7;
    
    reg [2:0] state;
    
    reg [7:0] payload_idx;
    reg [7:0] expected_len;
    reg [7:0] checksum;
    reg [7:0] cmd_reg;
    
    // Timeout counter (reset if no byte for ~10ms at 72MHz)
    // Use registered comparison to break timing path
    localparam TIMEOUT_CYCLES = 720_000;  // 10ms
    reg [19:0] timeout_cnt;
    reg timeout;  // Registered for timing
    
    always_ff @(posedge clk) begin
        if (rst) begin
            state <= S_IDLE;
            pkt_valid <= 1'b0;
            pkt_error <= 1'b0;
            pkt_cmd <= 8'd0;
            pkt_len <= 8'd0;
            pkt_payload <= {(MAX_PAYLOAD*8){1'b0}};
            timeout <= 1'b0;;
            payload_idx <= 8'd0;
            expected_len <= 8'd0;
            checksum <= 8'd0;
            cmd_reg <= 8'd0;
            timeout_cnt <= 20'd0;
            dbg_state <= 3'd0;
            dbg_timeout <= 1'b0;
        end else begin
            // Default: clear pulse outputs
            pkt_valid <= 1'b0;
            pkt_error <= 1'b0;
            
            // Pre-compute state checks to reduce logic depth
            // Active = receiving packet (not IDLE, not OUTPUT)
            // Timeout only matters when active
            
            // Timeout handling - simplified for timing
            if (state == S_IDLE || state == S_OUTPUT) begin
                timeout_cnt <= 20'd0;
                timeout <= 1'b0;
            end else if (rx_valid) begin
                timeout_cnt <= 20'd0;
                timeout <= 1'b0;
            end else if (!timeout) begin
                timeout_cnt <= timeout_cnt + 20'd1;
                if (timeout_cnt == TIMEOUT_CYCLES[19:0])
                    timeout <= 1'b1;
            end
            
            // Timeout resets state (simplified condition)
            if (timeout && state != S_IDLE && state != S_OUTPUT) begin
                state <= S_IDLE;
                pkt_error <= 1'b1;
            end else begin
                case (state)
                    S_IDLE: begin
                        if (rx_valid && rx_data == 8'h24) begin  // '$'
                            state <= S_WAIT_M;
                            checksum <= 8'd0;
                        end
                    end
                    
                    S_WAIT_M: begin
                        if (rx_valid) begin
                            if (rx_data == 8'h4D)  // 'M'
                                state <= S_WAIT_DIR;
                            else
                                state <= S_IDLE;
                        end
                    end
                    
                    S_WAIT_DIR: begin
                        if (rx_valid) begin
                            if (rx_data == 8'h3C) begin  // '<' (command to FC)
                                state <= S_WAIT_LEN;
                            end else begin
                                state <= S_IDLE;  // '>' or other = not for us
                            end
                        end
                    end
                    
                    S_WAIT_LEN: begin
                        if (rx_valid) begin
                            expected_len <= rx_data;
                            checksum <= rx_data;
                            payload_idx <= 8'd0;
                            state <= S_WAIT_CMD;
                        end
                    end
                    
                    S_WAIT_CMD: begin
                        if (rx_valid) begin
                            cmd_reg <= rx_data;
                            checksum <= checksum ^ rx_data;
                            if (expected_len == 8'd0)
                                state <= S_WAIT_CRC;
                            else
                                state <= S_WAIT_DATA;
                        end
                    end
                    
                    S_WAIT_DATA: begin
                        if (rx_valid) begin
                            // Store byte in packed array using bit slicing
                            if (payload_idx < MAX_PAYLOAD)
                                pkt_payload[payload_idx*8 +: 8] <= rx_data;
                            checksum <= checksum ^ rx_data;
                            payload_idx <= payload_idx + 8'd1;
                            if (payload_idx + 8'd1 >= expected_len)
                                state <= S_WAIT_CRC;
                        end
                    end
                    
                    S_WAIT_CRC: begin
                        if (rx_valid) begin
                            if (rx_data == checksum) begin
                                // Valid packet
                                pkt_cmd <= cmd_reg;
                                pkt_len <= expected_len;
                                state <= S_OUTPUT;
                            end else begin
                                // CRC error
                                pkt_error <= 1'b1;
                                state <= S_IDLE;
                            end
                        end
                    end
                    
                    S_OUTPUT: begin
                        pkt_valid <= 1'b1;
                        if (pkt_ready)
                            state <= S_IDLE;
                    end
                    
                    default: state <= S_IDLE;
                endcase
            end
        end
        
        // Registered debug outputs (break timing paths)
        dbg_state <= state;
        dbg_timeout <= timeout;
    end

endmodule
