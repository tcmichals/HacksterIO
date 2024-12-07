module tb_middle();

reg clk=0;
reg rst=0;

reg [7:0] s_axis_tdata=0;
reg s_axis_tvalid =0;
wire s_axis_tready;

wire [7:0] m_axis_tdata;
wire m_axis_tvalid;
reg m_axis_tready = 1;


middle dut (
    .i_clk(clk),
    .i_rst(rst),

    // AXIS input
    .s_axis_tdata(s_axis_tdata),
    .s_axis_tvalid(s_axis_tvalid),
    .s_axis_tready(s_axis_tready),

    //AXIS output
    .m_axis_tdata(m_axis_tdata),
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tready(m_axis_tvalid),

    .o_led(),
    .o_led_clk(),
    .o_led_data());


always  #1 clk = ~clk;

initial begin

    rst = 1'b1;
    clk = 0;
    $dumpfile("tb_middle.vcd");
	$dumpvars(0,tb_middle);

    $display ("reset done");
    #50  rst = 0;

    // Write 
     @(posedge clk); 
        s_axis_tdata = 8'hA2;
        s_axis_tvalid = 1'b1;
      @(posedge clk); 
        s_axis_tvalid = 1'b0;

 /*  #1  @(posedge clk); 
        s_axis_tdata = 8'hFF;
        s_axis_tvalid = 1'b1;
    #1  @(posedge clk); 
        s_axis_tvalid = 1'b0;

*/
    // Address
    #1  @(posedge clk); 
        s_axis_tdata = 8'h0;
        s_axis_tvalid = 1'b1;
    #1  @(posedge clk); 
        s_axis_tvalid = 1'b0;

    #1  @(posedge clk); 
        s_axis_tvalid = 1'b1;
    #1  @(posedge clk); 
        s_axis_tvalid = 1'b0;

    #1  @(posedge clk); 
        s_axis_tvalid = 1'b1;
    #1  @(posedge clk); 
        s_axis_tvalid = 1'b0;

    #1  @(posedge clk); 
        s_axis_tvalid = 1'b1;
    #1  @(posedge clk); 
        s_axis_tvalid = 1'b0;

    //Count
    #1  @(posedge clk); 
        s_axis_tvalid = 1'b1;
    #1  @(posedge clk); 
        s_axis_tvalid = 1'b0;

    #1  @(posedge clk);
     s_axis_tdata = 8'h4; 
        s_axis_tvalid = 1'b1;
    #1  @(posedge clk); 
        s_axis_tvalid = 1'b0;

    //LED 
    #1  @(posedge clk); 
        s_axis_tdata = 8'h11;
        s_axis_tvalid = 1'b1;
    #1  @(posedge clk); 
        s_axis_tvalid = 1'b0;

    #1  @(posedge clk); 
        s_axis_tdata = 8'h22;
        s_axis_tvalid = 1'b1;
    #1  @(posedge clk); 
        s_axis_tvalid = 1'b0;

    #1  @(posedge clk); 
      s_axis_tdata = 8'h33;
        s_axis_tvalid = 1'b1;
    #1  @(posedge clk); 
        s_axis_tvalid = 1'b0;

    #1  @(posedge clk); 
          s_axis_tdata = 8'h44;
        s_axis_tvalid = 1'b1;
    #1  @(posedge clk); 
        s_axis_tvalid = 1'b0;

    #1  @(posedge clk); 
          s_axis_tdata = 8'h0;
        s_axis_tvalid = 1'b1;
    #1  @(posedge clk); 
        s_axis_tvalid = 1'b0;

    #100000 $finish;
    
end




endmodule