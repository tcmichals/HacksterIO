module tb_mux();

localparam  ADDR_WIDTH = 32,
            DATA_WIDTH = 32;


reg clk=0;
reg rst=0;
reg [ADDR_WIDTH-1:0]   wbm_adr_i= 32'hFF00_0000; 

reg [ADDR_WIDTH-1:0]   wbs0_addr= 32'h0000_0000; 
reg [ADDR_WIDTH-1:0]   wbs0_addr_msk= 32'hFFFF_FF00; 

reg [ADDR_WIDTH-1:0]   wbs1_addr= 32'h0000_0100; 
reg [ADDR_WIDTH-1:0]   wbs1_addr_msk= 32'hFFFF_FF00; 

reg [ADDR_WIDTH-1:0]   wbs2_addr= 32'h0000_0200; 
reg [ADDR_WIDTH-1:0]   wbs2_addr_msk= 32'hFFFF_FF00; 


wire wbs0_match = ~|((wbm_adr_i ^ wbs0_addr) & wbs0_addr_msk);
wire wbs1_match = ~|((wbm_adr_i ^ wbs1_addr) & wbs1_addr_msk);
wire wbs2_match = ~|((wbm_adr_i ^ wbs2_addr) & wbs2_addr_msk);



always  #1 clk = ~clk;

always @(posedge clk) begin

    if ( wbs0_match  &  ( wbs1_match | wbs2_match))
        $display("Error wbs0_match");

    if ( wbs1_match  &  ( wbs0_match | wbs2_match))
        $display("Error wbs1_match");

    if ( wbs2_match  &  ( wbs1_match | wbs0_match))
        $display("Error wbs2_match");


    wbm_adr_i <= wbm_adr_i +4'hF0;


end
initial begin

    rst = 1'b1;
    clk = 0;
    //$dumpfile("tb_mux.vcd");
	//$dumpvars(0,tb_mux);

    $display ("reset done");
    #50  rst = 0;

    @(posedge clk); 
    #10000000 $finish;

end    


endmodule

