`default_nettype none
`timescale 1ns / 1ps

/**
 * MSP Response Transmitter
 * 
 * Takes response payload, adds MSP framing ($M>), computes checksum,
 * and streams bytes to UART TX.
 * 
 * Pipeline stage 3: Response transmission
 */
module msp_tx #(
    parameter MAX_PAYLOAD = 16
) (
    input  wire        clk,
    input  wire        rst,
    
    // Response input from msp_responder - packed array for yosys compatibility
    input  wire [7:0]  resp_cmd,
    input  wire [7:0]  resp_len,
    input  wire [MAX_PAYLOAD*8-1:0] resp_payload,
    input  wire        resp_valid,
    output reg         resp_ready,
    
    // UART TX interface
    output reg  [7:0]  tx_data,
    output reg         tx_valid,
    input  wire        tx_ready,
    
    // Status
    output wire        busy
);

    // State machine - using localparams for iverilog compatibility
    localparam [2:0]
        S_IDLE      = 3'd0,
        S_TX_DOLLAR = 3'd1,
        S_TX_M      = 3'd2,
        S_TX_ARROW  = 3'd3,
        S_TX_LEN    = 3'd4,
        S_TX_CMD    = 3'd5,
        S_TX_DATA   = 3'd6,
        S_TX_CRC    = 3'd7;
    
    reg [2:0] state;
    
    // Latched response data - packed array for yosys compatibility
    reg [7:0] cmd_reg;
    reg [7:0] len_reg;
    reg [MAX_PAYLOAD*8-1:0] payload_reg;
    reg [7:0] payload_idx;
    reg [7:0] checksum;
    
    assign busy = (state != S_IDLE);
    
    // Helper: wait for tx_ready, then send byte and advance state
    reg tx_pending;
    
    always_ff @(posedge clk) begin
        if (rst) begin
            state <= S_IDLE;
            resp_ready <= 1'b1;
            tx_data <= 8'd0;
            tx_valid <= 1'b0;
            tx_pending <= 1'b0;
            cmd_reg <= 8'd0;
            len_reg <= 8'd0;
            payload_reg <= {(MAX_PAYLOAD*8){1'b0}};
            payload_idx <= 8'd0;
            checksum <= 8'd0;
        end else begin
            // Clear tx_valid after accepted
            if (tx_valid && tx_ready)
                tx_valid <= 1'b0;
            
            case (state)
                S_IDLE: begin
                    resp_ready <= 1'b1;
                    tx_pending <= 1'b0;
                    
                    if (resp_valid) begin
                        resp_ready <= 1'b0;
                        cmd_reg <= resp_cmd;
                        len_reg <= resp_len;
                        // Latch payload array (direct packed array copy)
                        payload_reg <= resp_payload;
                        payload_idx <= 8'd0;
                        checksum <= 8'd0;
                        state <= S_TX_DOLLAR;
                    end
                end
                
                S_TX_DOLLAR: begin
                    if (tx_ready && !tx_valid) begin
                        tx_data <= 8'h24;  // '$'
                        tx_valid <= 1'b1;
                        state <= S_TX_M;
                    end
                end
                
                S_TX_M: begin
                    if (tx_ready && !tx_valid) begin
                        tx_data <= 8'h4D;  // 'M'
                        tx_valid <= 1'b1;
                        state <= S_TX_ARROW;
                    end
                end
                
                S_TX_ARROW: begin
                    if (tx_ready && !tx_valid) begin
                        tx_data <= 8'h3E;  // '>'
                        tx_valid <= 1'b1;
                        state <= S_TX_LEN;
                    end
                end
                
                S_TX_LEN: begin
                    if (tx_ready && !tx_valid) begin
                        tx_data <= len_reg;
                        tx_valid <= 1'b1;
                        checksum <= len_reg;
                        state <= S_TX_CMD;
                    end
                end
                
                S_TX_CMD: begin
                    if (tx_ready && !tx_valid) begin
                        tx_data <= cmd_reg;
                        tx_valid <= 1'b1;
                        checksum <= checksum ^ cmd_reg;
                        if (len_reg == 8'd0)
                            state <= S_TX_CRC;
                        else
                            state <= S_TX_DATA;
                    end
                end
                
                S_TX_DATA: begin
                    if (tx_ready && !tx_valid) begin
                        tx_data <= payload_reg[payload_idx*8 +: 8];
                        tx_valid <= 1'b1;
                        checksum <= checksum ^ payload_reg[payload_idx*8 +: 8];
                        payload_idx <= payload_idx + 8'd1;
                        if (payload_idx + 8'd1 >= len_reg)
                            state <= S_TX_CRC;
                    end
                end
                
                S_TX_CRC: begin
                    if (tx_ready && !tx_valid) begin
                        tx_data <= checksum;
                        tx_valid <= 1'b1;
                        state <= S_IDLE;
                    end
                end
                
                default: state <= S_IDLE;
            endcase
        end
    end

endmodule
