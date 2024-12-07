`timescale 1ns/ 100 ps
`default_nettype none

module tb_sendRegblinktLEDBar();

localparam DATA_WIDTH = 32;                  // width of data bus in bits (8, 16, 32, or 64)
localparam ADDR_WIDTH = 32;                  // width of address bus in bits
localparam SELECT_WIDTH = (DATA_WIDTH/8);     // width of word select bus (1, 2, 4, or 8)


reg reset;
reg clk;
reg [ADDR_WIDTH-1:0]    o_wb_adr=0;
reg [DATA_WIDTH-1:0]    o_wb_dat= 32'h11223344;
wire [DATA_WIDTH-1:0]   i_wb_dat;   
reg                     o_wb_we=0;   
reg [SELECT_WIDTH-1:0]  o_wb_sel=0;   
reg                    o_wb_stb=0;
wire                    i_wb_ack; 
wire                    i_wb_err; 
wire                    i_wb_rty;   
reg                     o_wb_cyc=0;   

wire o_led_clk, o_led_data;

reg [4:0] counter =0;
reg write_state =0;



blinktLEDBar dut
(   
    .i_clk(clk),
    .i_rst(reset),

     // master side
    .wb_adr_i(o_wb_adr),   // ADR_I() address
    .wb_dat_i(o_wb_dat),   // DAT_I() data in
    .wb_dat_o(i_wb_dat),   // DAT_O() data out
    .wb_we_i(o_wb_we),    // WE_I write enable input
    .wb_sel_i(o_wb_sel),   // SEL_I() select input
    .wb_stb_i(o_wb_stb),   // STB_I strobe input
    .wb_ack_o(i_wb_ack),   // ACK_O acknowledge output
    .wb_err_o(i_wb_err),   // ERR_O error output
    .wb_rty_o(i_wb_rty),   // RTY_O retry output
    .wb_cyc_i(o_wb_cyc),   // CYC_I cycle input

    .o_led_clk(o_led_clk),
    .o_led_data(o_led_data));

initial begin

    reset = 1'b1;
    clk = 0;
    $dumpfile("tb_sendRegblinktLEDBar.vcd");
	$dumpvars(0,tb_sendRegblinktLEDBar);

    $display ("reset done");
    #50  reset = 0;
    #100000 $finish;
    
end

always  #2 clk = ~clk;

always @(posedge clk ) begin
    
    if ( reset) begin
    end
    else begin

        if (write_state == 0)  begin
            o_wb_we <= 1;
            o_wb_cyc <= 1;
            o_wb_stb <= 1'b1;
            o_wb_adr  <= counter;
            write_state <= 1;
 
        end
        else if (write_state) begin
            if (i_wb_ack) begin
                write_state <= 0;
                o_wb_we <= 0;
                o_wb_cyc <= 0;
                o_wb_stb <= 0;
                counter <= counter + 1'b1;
                o_wb_dat <= o_wb_dat + 1'b1;
            end
        end

    end


end



endmodule

