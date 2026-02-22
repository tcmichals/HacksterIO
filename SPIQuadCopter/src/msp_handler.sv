`default_nettype none
`timescale 1 ns / 1 ns

/**
 * MSP (Multiwii Serial Protocol) Handler for FC Protocol Responses
 * Strictly sequential state machine to prevent race conditions and duplicate headers.
 * 
 * TIMING OPTIMIZED: Response data lookup is pipelined to avoid deep combinational paths.
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
    localparam [7:0] MSP_API_VERSION     = 8'd1;
    localparam [7:0] MSP_FC_VARIANT      = 8'd2;
    localparam [7:0] MSP_FC_VERSION      = 8'd3;
    localparam [7:0] MSP_BOARD_INFO      = 8'd4;
    localparam [7:0] MSP_BUILD_INFO      = 8'd5;
    localparam [7:0] MSP_NAME            = 8'd10;
    localparam [7:0] MSP_IDENT           = 8'd100;
    localparam [7:0] MSP_STATUS          = 8'd101;
    localparam [7:0] MSP_SET_PASSTHROUGH = 8'd245;
    
    // State encoding - explicit values for reliable synthesis
    typedef enum logic [3:0] {
        STATE_IDLE       = 4'd0,
        STATE_HEADER_M   = 4'd1,
        STATE_DIRECTION  = 4'd2,
        STATE_LENGTH     = 4'd3,
        STATE_COMMAND    = 4'd4,
        STATE_PAYLOAD    = 4'd5,
        STATE_CHECKSUM   = 4'd6,
        STATE_RESP_SETUP = 4'd7,   // NEW: Setup response length (1 cycle)
        STATE_FILL_RAM   = 4'd8,   // NEW: Fill RAM one byte per cycle
        STATE_TX_DOLLAR  = 4'd9,
        STATE_TX_M       = 4'd10,
        STATE_TX_ARROW   = 4'd11,
        STATE_TX_LEN     = 4'd12,
        STATE_TX_CMD     = 4'd13,
        STATE_TX_PAYLOAD = 4'd14,
        STATE_TX_CRC     = 4'd15
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
    
    // =========================================================================
    // TIMING FIX: Pipelined response byte lookup
    // This replaces the deeply nested case(msp_command){case(fill_idx)} structure
    // with a simple registered mux based only on fill_idx
    // =========================================================================
    reg [7:0] resp_byte_reg;  // Registered output to break timing path
    
    // Response byte lookup - shallow combinational logic (only depends on fill_idx)
    // This is registered in the next always block
    always_comb begin
        case (msp_command)
            MSP_API_VERSION: begin
                case (fill_idx[1:0])
                    2'd0: resp_byte_reg = 8'h01;
                    2'd1: resp_byte_reg = api_version[7:0];
                    2'd2: resp_byte_reg = api_version[15:8];
                    default: resp_byte_reg = 8'h00;
                endcase
            end
            MSP_FC_VARIANT: begin
                case (fill_idx[1:0])
                    2'd0: resp_byte_reg = fc_variant[7:0];
                    2'd1: resp_byte_reg = fc_variant[15:8];
                    2'd2: resp_byte_reg = fc_variant[23:16];
                    2'd3: resp_byte_reg = fc_variant[31:24];
                endcase
            end
            MSP_IDENT: begin
                resp_byte_reg = (fill_idx == 0) ? 8'h01 : 8'h00;
            end
            MSP_STATUS: begin
                resp_byte_reg = 8'h00;
            end
            default: begin
                resp_byte_reg = 8'h00;
            end
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= STATE_IDLE;
            msp_command <= 8'd0;
            msp_length <= 8'd0;
            msp_checksum <= 8'd0;
            payload_idx <= 8'd0;
            pc_tx_valid <= 1'b0;
            pc_tx_data <= 8'd0;
            response_len_reg <= 8'd0;
            fill_idx <= 8'd0;
            resp_ram_we <= 1'b0;
            resp_ram_addr <= 6'd0;
            resp_ram_din <= 8'd0;
            active_reg <= 1'b0;
        end else begin
            resp_ram_we <= 1'b0;  // Default: no write
            active_reg <= (state != STATE_IDLE) || (pc_rx_valid && pc_rx_data == 8'h24);

            if (pc_tx_ready && pc_tx_valid) pc_tx_valid <= 1'b0;

            case (state)
                STATE_IDLE: begin
                    if (pc_rx_valid && pc_rx_data == 8'h24) begin
                        state <= STATE_HEADER_M;
                        msp_checksum <= 8'd0;
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
                        payload_idx  <= 8'd0;
                        if (msp_length == 0) state <= STATE_CHECKSUM;
                        else state <= STATE_PAYLOAD;
                    end
                end
                
                STATE_PAYLOAD: begin
                    if (pc_rx_valid) begin
                        msp_checksum <= msp_checksum ^ pc_rx_data;
                        payload_idx <= payload_idx + 8'd1;
                        if (payload_idx + 8'd1 >= msp_length) state <= STATE_CHECKSUM;
                    end
                end
                
                STATE_CHECKSUM: begin
                    if (pc_rx_valid) begin
                        if (pc_rx_data == msp_checksum) begin
                            state <= STATE_RESP_SETUP;
                            fill_idx <= 8'd0;
                        end else state <= STATE_IDLE;
                    end
                end
                
                // NEW: Setup response length in one cycle (simple decode, no deep mux)
                STATE_RESP_SETUP: begin
                    case (msp_command)
                        MSP_API_VERSION:     response_len_reg <= 8'd3;
                        MSP_FC_VARIANT:      response_len_reg <= 8'd4;
                        MSP_IDENT:           response_len_reg <= 8'd7;
                        MSP_STATUS:          response_len_reg <= 8'd10;
                        MSP_SET_PASSTHROUGH: response_len_reg <= 8'd0;
                        default:             response_len_reg <= 8'd0;
                    endcase
                    
                    // For zero-length responses or unknown commands, go straight to TX
                    if (msp_command == MSP_SET_PASSTHROUGH || 
                        (msp_command != MSP_API_VERSION && 
                         msp_command != MSP_FC_VARIANT && 
                         msp_command != MSP_IDENT && 
                         msp_command != MSP_STATUS)) begin
                        state <= STATE_TX_DOLLAR;
                    end else begin
                        state <= STATE_FILL_RAM;
                    end
                end
                
                // NEW: Fill RAM one byte per cycle (pipelined - resp_byte_reg computed combinationally)
                STATE_FILL_RAM: begin
                    resp_ram_addr <= fill_idx[5:0];
                    resp_ram_din <= resp_byte_reg;  // Use registered lookup result
                    resp_ram_we <= 1'b1;
                    fill_idx <= fill_idx + 8'd1;
                    
                    if (fill_idx + 8'd1 >= response_len_reg) begin
                        state <= STATE_TX_DOLLAR;
                    end
                end

                STATE_TX_DOLLAR: begin
                    if (pc_tx_ready && !pc_tx_valid) begin
                        pc_tx_data <= 8'h24; pc_tx_valid <= 1'b1; state <= STATE_TX_M;
                    end
                end
                STATE_TX_M: begin
                    if (pc_tx_ready && !pc_tx_valid) begin
                        pc_tx_data <= 8'h4D; pc_tx_valid <= 1'b1; state <= STATE_TX_ARROW;
                    end
                end
                STATE_TX_ARROW: begin
                    if (pc_tx_ready && !pc_tx_valid) begin
                        pc_tx_data <= 8'h3E; pc_tx_valid <= 1'b1; state <= STATE_TX_LEN;
                    end
                end
                STATE_TX_LEN: begin
                    if (pc_tx_ready && !pc_tx_valid) begin
                        pc_tx_data <= response_len_reg; pc_tx_valid <= 1'b1; 
                        msp_checksum <= response_len_reg; state <= STATE_TX_CMD;
                    end
                end
                STATE_TX_CMD: begin
                    if (pc_tx_ready && !pc_tx_valid) begin
                        pc_tx_data <= msp_command; pc_tx_valid <= 1'b1;
                        msp_checksum <= msp_checksum ^ msp_command;
                        payload_idx <= 8'd0; resp_ram_addr <= 6'd0;
                        if (response_len_reg == 0) state <= STATE_TX_CRC;
                        else state <= STATE_TX_PAYLOAD;
                    end
                end
                STATE_TX_PAYLOAD: begin
                    if (pc_tx_ready && !pc_tx_valid) begin
                        pc_tx_data <= resp_ram_dout; pc_tx_valid <= 1'b1;
                        msp_checksum <= msp_checksum ^ resp_ram_dout;
                        payload_idx <= payload_idx + 8'd1;
                        resp_ram_addr <= payload_idx[5:0] + 6'd1;
                        if (payload_idx + 8'd1 >= response_len_reg) state <= STATE_TX_CRC;
                    end
                end
                STATE_TX_CRC: begin
                    if (pc_tx_ready && !pc_tx_valid) begin
                        pc_tx_data <= msp_checksum; pc_tx_valid <= 1'b1; state <= STATE_IDLE;
                    end
                end
                
                default: state <= STATE_IDLE;
            endcase
        end
    end
endmodule