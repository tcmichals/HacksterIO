// Wishbone Mode Register for Protocol Switching
`default_nettype none

module mode_reg #(
    parameter WB_ADDR = 32'h40000700
)(
    input  wire        i_clk,
    input  wire        i_rst,
    // Wishbone
    input  wire [31:0] i_wb_adr,
    input  wire [31:0] i_wb_dat,
    input  wire        i_wb_we,
    input  wire        i_wb_stb,
    output wire        o_wb_ack,
    output reg  [1:0]  o_mode
);
    reg ack = 0;
    assign o_wb_ack = ack;

    always @(posedge i_clk) begin
        if (i_rst) begin
            o_mode <= 2'b00; // Default: DSHOT
            ack <= 0;
        end else begin
            ack <= 0;
            if (i_wb_stb && i_wb_we && i_wb_adr == WB_ADDR) begin
                o_mode <= i_wb_dat[1:0];
                ack <= 1;
            end
        end
    end
endmodule

`default_nettype wire
