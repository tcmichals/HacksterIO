`default_nettype none
`timescale 1 ns / 1 ns

/**
 * MSP (Multiwii Serial Protocol) Handler for FC Protocol Responses
 * Strictly sequential state machine to prevent race conditions and duplicate headers.
 */

module msp_handler #(
    parameter CLK_FREQ_HZ = 72_000_000
) (
    input  wire        clk,
    input  wire        rst,
    
    // PC Interface (Byte-Parallel, usually 115200)
    input  wire [7:0]  pc_rx_data,
    input  wire        pc_rx_valid,
    output reg  [7:0]  pc_tx_data,
    output reg         pc_tx_valid,
    input  wire        pc_tx_ready,
    
    // Status
    output wire        active,
    
    // Version information
    input  wire [7:0]  fc_version_major,
    input  wire [7:0]  fc_version_minor,
    input  wire [7:0]  fc_version_patch,
    input  wire [31:0] api_version,
    input  wire [31:0] fc_variant
);

    // MSP Command IDs
    localparam MSP_API_VERSION     = 1;
    localparam MSP_FC_VARIANT      = 2;
    localparam MSP_FC_VERSION      = 3;
    localparam MSP_BOARD_INFO      = 4;
    localparam MSP_BUILD_INFO      = 5;
    localparam MSP_NAME            = 10;
    localparam MSP_IDENT           = 100;
    localparam MSP_STATUS          = 101;
    localparam MSP_SET_PASSTHROUGH = 245;
    
    typedef enum logic [3:0] {
        STATE_IDLE,
        STATE_HEADER_M,
        STATE_DIRECTION,
        STATE_LENGTH,
        STATE_COMMAND,
        STATE_PAYLOAD,
        STATE_CHECKSUM,
        STATE_RESPOND,
        STATE_TX_DOLLAR,
        STATE_TX_M,
        STATE_TX_ARROW,
        STATE_TX_LEN,
        STATE_TX_CMD,
        STATE_TX_PAYLOAD,
        STATE_TX_CRC
    } state_t;
    
    state_t state;
    reg [7:0] msp_command;
    reg [7:0] msp_length;
    reg [7:0] msp_checksum;
    reg [7:0] payload_idx;
    
    // BRAM for Response Payload
    logic [5:0] resp_ram_addr;
    logic [7:0] resp_ram_din;
    logic       resp_ram_we;
    logic [7:0] resp_ram_dout;
    
    shared_buffer_ram #(.ADDR_WIDTH(6)) u_resp_ram (
        .clk(clk), .addr(resp_ram_addr), .din(resp_ram_din), .we(resp_ram_we), .dout(resp_ram_dout)
    );

    reg [7:0] response_len_reg;
    reg [7:0] fill_idx;
    
    // Registered activity
    reg active_reg;
    assign active = active_reg;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= STATE_IDLE;
            msp_command <= 0;
            msp_length <= 0;
            msp_checksum <= 0;
            payload_idx <= 0;
            pc_tx_valid <= 0;
            pc_tx_data <= 0;
            response_len_reg <= 0;
            fill_idx <= 0;
            resp_ram_we <= 0;
            resp_ram_addr <= 0;
            active_reg <= 0;
        end else begin
            resp_ram_we <= 0;
            active_reg <= (state != STATE_IDLE) || (pc_rx_valid && pc_rx_data == 8'h24);

            if (pc_tx_ready && pc_tx_valid) pc_tx_valid <= 0;

            case (state)
                STATE_IDLE: begin
                    if (pc_rx_valid && pc_rx_data == 8'h24) begin
                        state <= STATE_HEADER_M;
                        msp_checksum <= 0;
                    end
                end
                
                STATE_HEADER_M: begin
                    if (pc_rx_valid) begin
                        if (pc_rx_data == 8'h4D) state <= STATE_DIRECTION;
                        else state <= STATE_IDLE;
                    end
                end
                
                STATE_DIRECTION: begin
                    if (pc_rx_valid) begin
                        if (pc_rx_data == 8'h3C) state <= STATE_LENGTH;
                        else state <= STATE_IDLE;
                    end
                end
                
                STATE_LENGTH: begin
                    if (pc_rx_valid) begin
                        msp_length   <= pc_rx_data;
                        msp_checksum <= pc_rx_data;
                        state        <= STATE_COMMAND;
                    end
                end
                
                STATE_COMMAND: begin
                    if (pc_rx_valid) begin
                        msp_command  <= pc_rx_data;
                        msp_checksum <= msp_checksum ^ pc_rx_data;
                        payload_idx  <= 0;
                        if (msp_length == 0) state <= STATE_CHECKSUM;
                        else state <= STATE_PAYLOAD;
                    end
                end
                
                STATE_PAYLOAD: begin
                    if (pc_rx_valid) begin
                        msp_checksum <= msp_checksum ^ pc_rx_data;
                        payload_idx <= payload_idx + 1;
                        if (payload_idx + 1 >= msp_length) state <= STATE_CHECKSUM;
                    end
                end
                
                STATE_CHECKSUM: begin
                    if (pc_rx_valid) begin
                        if (pc_rx_data == msp_checksum) begin
                            state <= STATE_RESPOND;
                            fill_idx <= 0;
                        end else state <= STATE_IDLE;
                    end
                end
                
                STATE_RESPOND: begin
                    case (msp_command)
                        MSP_API_VERSION: begin
                            response_len_reg <= 3;
                            case (fill_idx)
                                0: begin resp_ram_addr <= 0; resp_ram_din <= 8'h01; resp_ram_we <= 1; fill_idx <= 1; end
                                1: begin resp_ram_addr <= 1; resp_ram_din <= api_version[7:0]; resp_ram_we <= 1; fill_idx <= 2; end
                                2: begin resp_ram_addr <= 2; resp_ram_din <= api_version[15:8]; resp_ram_we <= 1; fill_idx <= 3; end
                                3: begin state <= STATE_TX_DOLLAR; end
                            endcase
                        end
                        MSP_FC_VARIANT: begin
                            response_len_reg <= 4;
                            resp_ram_addr <= fill_idx[5:0]; resp_ram_we <= 1;
                            case (fill_idx)
                                0: begin resp_ram_din <= fc_variant[7:0]; fill_idx <= 1; end
                                1: begin resp_ram_din <= fc_variant[15:8]; fill_idx <= 2; end
                                2: begin resp_ram_din <= fc_variant[23:16]; fill_idx <= 3; end
                                3: begin resp_ram_din <= fc_variant[31:24]; fill_idx <= 4; end
                                4: begin resp_ram_we <= 0; state <= STATE_TX_DOLLAR; end
                            endcase
                        end
                        MSP_IDENT: begin
                            response_len_reg <= 7;
                            resp_ram_addr <= fill_idx[5:0]; resp_ram_we <= 1;
                            case (fill_idx)
                                0: begin resp_ram_din <= 8'h01; fill_idx <= 1; end
                                1: begin resp_ram_din <= 8'h00; fill_idx <= 2; end
                                2: begin resp_ram_din <= 8'h00; fill_idx <= 3; end
                                3: begin resp_ram_din <= 8'h00; fill_idx <= 4; end
                                4: begin resp_ram_din <= 8'h00; fill_idx <= 5; end
                                5: begin resp_ram_din <= 8'h00; fill_idx <= 6; end
                                6: begin resp_ram_din <= 8'h00; fill_idx <= 7; end
                                7: begin resp_ram_we <= 0; state <= STATE_TX_DOLLAR; end
                            endcase
                        end
                        MSP_STATUS: begin
                            response_len_reg <= 10;
                            resp_ram_addr <= fill_idx[5:0]; resp_ram_we <= 1;
                            case (fill_idx)
                                10: begin resp_ram_we <= 0; state <= STATE_TX_DOLLAR; end
                                default: begin resp_ram_din <= 8'h00; fill_idx <= fill_idx + 1; end
                            endcase
                        end
                        MSP_SET_PASSTHROUGH: begin response_len_reg <= 0; state <= STATE_TX_DOLLAR; end
                        default: begin state <= STATE_IDLE; end
                    endcase
                end

                STATE_TX_DOLLAR: begin
                    if (pc_tx_ready && !pc_tx_valid) begin
                        pc_tx_data <= 8'h24; pc_tx_valid <= 1; state <= STATE_TX_M;
                    end
                end
                STATE_TX_M: begin
                    if (pc_tx_ready && !pc_tx_valid) begin
                        pc_tx_data <= 8'h4D; pc_tx_valid <= 1; state <= STATE_TX_ARROW;
                    end
                end
                STATE_TX_ARROW: begin
                    if (pc_tx_ready && !pc_tx_valid) begin
                        pc_tx_data <= 8'h3E; pc_tx_valid <= 1; state <= STATE_TX_LEN;
                    end
                end
                STATE_TX_LEN: begin
                    if (pc_tx_ready && !pc_tx_valid) begin
                        pc_tx_data <= response_len_reg; pc_tx_valid <= 1; 
                        msp_checksum <= response_len_reg; state <= STATE_TX_CMD;
                    end
                end
                STATE_TX_CMD: begin
                    if (pc_tx_ready && !pc_tx_valid) begin
                        pc_tx_data <= msp_command; pc_tx_valid <= 1;
                        msp_checksum <= msp_checksum ^ msp_command;
                        payload_idx <= 0; resp_ram_addr <= 0;
                        if (response_len_reg == 0) state <= STATE_TX_CRC;
                        else state <= STATE_TX_PAYLOAD;
                    end
                end
                STATE_TX_PAYLOAD: begin
                    if (pc_tx_ready && !pc_tx_valid) begin
                        pc_tx_data <= resp_ram_dout; pc_tx_valid <= 1;
                        msp_checksum <= msp_checksum ^ resp_ram_dout;
                        payload_idx <= payload_idx + 1;
                        resp_ram_addr <= payload_idx + 1;
                        if (payload_idx + 1 >= response_len_reg) state <= STATE_TX_CRC;
                    end
                end
                STATE_TX_CRC: begin
                    if (pc_tx_ready && !pc_tx_valid) begin
                        pc_tx_data <= msp_checksum; pc_tx_valid <= 1; state <= STATE_IDLE;
                    end
                end
            endcase
        end
    end
endmodule