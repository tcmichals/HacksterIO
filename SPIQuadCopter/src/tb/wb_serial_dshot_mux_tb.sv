/**
 * Testbench for wb_serial_dshot_mux
 * Verifies:
 * 1. DSHOT mode: dshot_in signals pass through to pad_motor
 * 2. Reset state: mux_sel defaults to 1 (DSHOT mode)
 */

`timescale 1ns/1ps

module wb_serial_dshot_mux_tb;

    // Clock
    localparam CLK_PERIOD = 18.5;  // 54 MHz
    reg clk;
    reg rst;
    
    // Wishbone (unused for basic test)
    reg [31:0] wb_dat_i;
    reg [31:0] wb_adr_i;
    reg        wb_we_i;
    reg [3:0]  wb_sel_i;
    reg        wb_stb_i;
    reg        wb_cyc_i;
    wire [31:0] wb_dat_o;
    wire        wb_ack_o;
    
    // Mux outputs
    wire        mux_sel;
    wire [1:0]  mux_ch;
    wire        msp_mode;
    
    // Motor pads (bidirectional)
    wire [3:0] pad_motor;
    
    // DSHOT inputs
    reg [3:0] dshot_in;
    
    // Serial interface (unused for DSHOT test)
    reg        serial_tx_i;
    reg        serial_oe_i;
    wire       serial_rx_o;
    
    // Instantiate DUT
    wb_serial_dshot_mux #(
        .CLK_FREQ_HZ(54_000_000)
    ) dut (
        .wb_clk_i(clk),
        .wb_rst_i(rst),
        .wb_dat_i(wb_dat_i),
        .wb_adr_i(wb_adr_i),
        .wb_we_i(wb_we_i),
        .wb_sel_i(wb_sel_i),
        .wb_stb_i(wb_stb_i),
        .wb_cyc_i(wb_cyc_i),
        .wb_dat_o(wb_dat_o),
        .wb_ack_o(wb_ack_o),
        .wb_stall_o(),
        .mux_sel(mux_sel),
        .mux_ch(mux_ch),
        .msp_mode(msp_mode),
        .pc_rx_data(8'b0),
        .pc_rx_valid(1'b0),
        .pad_motor(pad_motor),
        .dshot_in(dshot_in),
        .serial_tx_i(serial_tx_i),
        .serial_oe_i(serial_oe_i),
        .serial_rx_o(serial_rx_o)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // Test sequence
    initial begin
        $dumpfile("wb_serial_dshot_mux_tb.vcd");
        $dumpvars(0, wb_serial_dshot_mux_tb);
        
        $display("=== WB Serial/DSHOT Mux Testbench ===");
        
        // Initialize
        rst = 1;
        wb_dat_i = 0;
        wb_adr_i = 32'h0400;
        wb_we_i = 0;
        wb_sel_i = 4'hF;
        wb_stb_i = 0;
        wb_cyc_i = 0;
        dshot_in = 4'b0000;
        serial_tx_i = 1;
        serial_oe_i = 0;
        
        #100;
        rst = 0;
        #100;
        
        // Check reset state
        $display("After reset: mux_sel=%b (expect 1=DSHOT)", mux_sel);
        if (mux_sel !== 1'b1) begin
            $display("FAIL: mux_sel should be 1 after reset");
            $finish;
        end
        
        // Test 1: Toggle dshot_in[0] and verify pad_motor[0] follows
        $display("\nTest 1: DSHOT passthrough on motor 1");
        
        repeat (10) begin
            dshot_in[0] = 1;
            #(CLK_PERIOD * 3);  // Wait for registered path
            $display("  dshot_in[0]=1, pad_motor[0]=%b (expect 1)", pad_motor[0]);
            if (pad_motor[0] !== 1'b1) $display("  FAIL!");
            
            dshot_in[0] = 0;
            #(CLK_PERIOD * 3);
            $display("  dshot_in[0]=0, pad_motor[0]=%b (expect 0)", pad_motor[0]);
            if (pad_motor[0] !== 1'b0) $display("  FAIL!");
        end
        
        // Test 2: All motors
        $display("\nTest 2: All motors toggling");
        dshot_in = 4'b1111;
        #(CLK_PERIOD * 3);
        $display("  dshot_in=1111, pad_motor=%b (expect 1111)", pad_motor);
        
        dshot_in = 4'b0000;
        #(CLK_PERIOD * 3);
        $display("  dshot_in=0000, pad_motor=%b (expect 0000)", pad_motor);
        
        dshot_in = 4'b1010;
        #(CLK_PERIOD * 3);
        $display("  dshot_in=1010, pad_motor=%b (expect 1010)", pad_motor);
        
        dshot_in = 4'b0101;
        #(CLK_PERIOD * 3);
        $display("  dshot_in=0101, pad_motor=%b (expect 0101)", pad_motor);
        
        $display("\n=== Test Complete ===");
        #100;
        $finish;
    end

endmodule
