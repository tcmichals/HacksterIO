`timescale 1ns/1ps

module wb_version_tb();

    reg clk = 0;
    reg rst = 0;
    
    // Wishbone Signals
    reg [31:0] wb_adr_i = 0;
    reg [31:0] wb_dat_i = 0;
    wire [31:0] wb_dat_o;
    reg wb_we_i = 0;
    reg wb_stb_i = 0;
    reg wb_cyc_i = 0;
    wire wb_ack_o;

    always #5 clk = ~clk; // 100MHz

    wb_version dut (
        .i_clk(clk),
        .i_rst(rst),
        .wb_adr_i(wb_adr_i),
        .wb_dat_i(wb_dat_i),
        .wb_dat_o(wb_dat_o),
        .wb_we_i(wb_we_i),
        .wb_stb_i(wb_stb_i),
        .wb_ack_o(wb_ack_o),
        .wb_cyc_i(wb_cyc_i)
    );

    initial begin
        $dumpfile("wb_version_tb.vcd");
        $dumpvars(0, wb_version_tb);
        
        // Reset
        rst = 1;
        #20;
        rst = 0;
        #20;

        $display("Starting wb_version Test");
        
        // Test Read
        @(posedge clk);
        wb_cyc_i = 1;
        wb_stb_i = 1;
        wb_we_i = 0;
        wb_adr_i = 32'h100;
        
        wait(wb_ack_o);
        if (wb_dat_o === 32'hDEADBEEF) 
            $display("SUCCESS: Read 0x%x", wb_dat_o);
        else 
            $display("FAILURE: Read 0x%x != 0xDEADBEEF", wb_dat_o);
            
        @(posedge clk);
        wb_cyc_i = 0;
        wb_stb_i = 0;
        
        #50;
        $finish;
    end

endmodule
