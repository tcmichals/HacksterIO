

`default_nettype none
`timescale 1 ns / 1 ns

module tb_sendRegAXIS();

reg reset;
reg clk;
reg send_write =0 ;
reg [31:0] led_val =32'h8000_0000;
wire led_clk, led_data, tready;
reg tvalid = 1;


sendRegAXIS send(
        .i_clk(clk),
        .i_reset(reset),

        .s_axis_data(led_val),
        .s_axis_tvalid(tvalid),
        .s_axis_tready(tready),
        .o_led_clk(led_clk),
        .o_led_data(led_data));

initial begin

    reset = 1'b1;
    clk = 0;
    $dumpfile("tb_sendRegAXIS.vcd");
	$dumpvars(0,tb_sendRegAXIS);

    #50  reset = 0;
    #1000000 $finish;
    
end

always  #5 clk = ~clk;

always @(posedge clk) begin
   
    if (tready && !reset) begin
        tvalid <= 0;
        led_val <= led_val + 1'b1;
        $display("sending");
    end
    else 
        tvalid <= 1;

        

 
end


endmodule