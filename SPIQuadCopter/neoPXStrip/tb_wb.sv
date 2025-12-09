
`default_nettype none
`timescale 1 ns / 1 ns

module tb_wb();

    localparam DATA_WIDTH = 32;                  // width of data bus in bits (8, 16, 32, or 64)
    localparam ADDR_WIDTH = 32;                  // width of address bus in bits
    localparam SELECT_WIDTH = (DATA_WIDTH/8);     // width of word select bus (1, 2, 4, or 8)

    reg clk = 1;
    reg reset = 0;

    reg [DATA_WIDTH-1:0]   wb_dat_i = 32'h33;   // DAT_I() data in
    reg [ADDR_WIDTH-1:0]   wb_adr_i= 32'h33;   // ADR_I() address
    wire [DATA_WIDTH-1:0]   wb_dat_o;   // DAT_O() data out
    reg                      wb_we_i=0;    // WE_I write enable input
    reg   [SELECT_WIDTH-1:0] wb_sel_i=0;   // SEL_I() select input
    reg                      wb_stb_i=0;   // STB_I strobe input
     wire                    wb_ack_o;   // ACK_O acknowledge output
     wire                    wb_err_o;   // ERR_O error output
     wire                    wb_rty_o;   // RTY_O retry output
    reg                      wb_cyc_i=1;   // CYC_I cycle input


wb_neoPx dut(
    .i_clk(clk),
    .i_rst(reset),
    .wb_adr_i(wb_adr_i),
    .wb_dat_i(wb_dat_i),
    .wb_dat_o(wb_dat_o),
    .wb_we_i(wb_we_i), 
    .wb_sel_i(wb_sel_i),
    .wb_stb_i(wb_stb_i),
    .wb_ack_o(wb_ack_o),
    .wb_err_o(wb_err_o),
    .wb_rty_o(wb_rty_o),
    .wb_cyc_i(wb_cyc_i),
    .m_axis_data(),
    .m_axis_valid(),
    .s_axis_ready(1'b1) );
    

always begin
    #1 begin
        clk =!clk;
    end
end



initial begin
    $dumpfile("tb_wb.vcd");
    $dumpvars(0,tb_wb);
    @(posedge clk); 

    @(posedge clk); 
    wb_cyc_i = 0;
    wb_we_i = 0;
    wb_stb_i = 0;


    wb_adr_i = 32'h0000_0020; 
    @(posedge clk);
    wb_cyc_i = 1;
    wb_we_i = 1;
    wb_stb_i =1;
    @(posedge clk)
        wb_cyc_i = 0;
        wb_we_i = 0;
        wb_stb_i =0;
    


    
    #100000 $display("done");
        $finish;

end    



endmodule