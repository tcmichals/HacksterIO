// Simple Wishbone UART (TX only, 8N1) with status register
`default_nettype none

module simple_uart #(
    parameter WB_ADDR = 32'h40000100,
    parameter CLK_FREQ = 10000000, // 10 MHz
    parameter BAUD = 115200
)(
    input  wire        i_clk,
    input  wire        i_rst,
    // Wishbone
    input  wire [31:0] i_wb_adr,
    input  wire [31:0] i_wb_dat,
    input  wire        i_wb_we,
    input  wire        i_wb_stb,
    output reg  [31:0] o_wb_dat,
    output wire        o_wb_ack,
    // UART
    output reg         o_uart_tx
);
    localparam ADDR_TX     = WB_ADDR;        // Write: TX data
    localparam ADDR_STATUS = WB_ADDR + 4;    // Read: bit0=TX ready (not busy)
    
    localparam CLKS_PER_BIT = CLK_FREQ / BAUD;
    reg [15:0] clk_cnt = 0;
    reg [3:0] bit_idx = 0;
    reg [9:0] shifter = 10'b1111111111;
    reg busy = 0;
    reg ack = 0;

    assign o_wb_ack = ack;

    always @(posedge i_clk) begin
        if (i_rst) begin
            busy <= 0;
            clk_cnt <= 0;
            bit_idx <= 0;
            shifter <= 10'b1111111111;
            ack <= 0;
            o_uart_tx <= 1'b1;
            o_wb_dat <= 32'b0;
        end else begin
            ack <= 0;
            
            // Wishbone read: status register
            if (i_wb_stb && !i_wb_we && i_wb_adr == ADDR_STATUS) begin
                o_wb_dat <= {31'b0, ~busy};  // bit0 = TX ready
                ack <= 1;
            end
            
            // Wishbone write: TX data
            if (i_wb_stb && i_wb_we && i_wb_adr == ADDR_TX && !busy) begin
                shifter <= {1'b1, i_wb_dat[7:0], 1'b0}; // stop, data, start
                busy <= 1;
                clk_cnt <= 0;
                bit_idx <= 0;
                ack <= 1;
            end
            
            // UART TX logic
            if (busy) begin
                if (clk_cnt == CLKS_PER_BIT-1) begin
                    clk_cnt <= 0;
                    o_uart_tx <= shifter[0];
                    shifter <= {1'b1, shifter[9:1]};
                    bit_idx <= bit_idx + 1;
                    if (bit_idx == 9) busy <= 0;
                end else begin
                    clk_cnt <= clk_cnt + 1;
                end
            end else begin
                o_uart_tx <= 1'b1;
            end
        end
    end
endmodule

`default_nettype wire
