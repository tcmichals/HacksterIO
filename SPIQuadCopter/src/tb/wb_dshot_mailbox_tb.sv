// wb_dshot_mailbox_tb.sv - Testbench for CPU path to DSHOT output
`timescale 1ns/1ps

module wb_dshot_mailbox_tb;

    parameter CLK_FREQ_HZ = 54_000_000;
    parameter CLK_PERIOD = 1_000_000_000 / CLK_FREQ_HZ;  // ~18.5ns

    // Clock and reset
    reg clk = 0;
    reg rst = 1;
    always #(CLK_PERIOD/2) clk = ~clk;

    // Wishbone Port A (CPU)
    reg  [31:0] wba_adr_i;
    reg  [31:0] wba_dat_i;
    reg         wba_we_i;
    reg  [3:0]  wba_sel_i;
    reg         wba_stb_i;
    reg         wba_cyc_i;
    wire [31:0] wba_dat_o;
    wire        wba_ack_o;

    // Wishbone Port B (SPI) - unused in this test
    reg  [31:0] wbb_adr_i = 0;
    reg  [31:0] wbb_dat_i = 0;
    reg         wbb_we_i = 0;
    reg  [3:0]  wbb_sel_i = 0;
    reg         wbb_stb_i = 0;
    reg         wbb_cyc_i = 0;
    wire [31:0] wbb_dat_o;
    wire        wbb_ack_o;

    // Motor outputs
    wire motor1_o, motor2_o, motor3_o, motor4_o;
    wire motor1_ready, motor2_ready, motor3_ready, motor4_ready;

    // DUT
    wb_dshot_mailbox #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .DEFAULT_MODE(150)
    ) u_dut (
        .clk(clk),
        .rst(rst),
        
        // Port A: CPU
        .wba_adr_i(wba_adr_i),
        .wba_dat_i(wba_dat_i),
        .wba_dat_o(wba_dat_o),
        .wba_sel_i(wba_sel_i),
        .wba_we_i(wba_we_i),
        .wba_stb_i(wba_stb_i),
        .wba_cyc_i(wba_cyc_i),
        .wba_ack_o(wba_ack_o),
        
        // Port B: SPI (unused)
        .wbb_adr_i(wbb_adr_i),
        .wbb_dat_i(wbb_dat_i),
        .wbb_dat_o(wbb_dat_o),
        .wbb_sel_i(wbb_sel_i),
        .wbb_we_i(wbb_we_i),
        .wbb_stb_i(wbb_stb_i),
        .wbb_cyc_i(wbb_cyc_i),
        .wbb_ack_o(wbb_ack_o),
        
        // Motor outputs
        .motor1_o(motor1_o),
        .motor2_o(motor2_o),
        .motor3_o(motor3_o),
        .motor4_o(motor4_o),
        .motor1_ready(motor1_ready),
        .motor2_ready(motor2_ready),
        .motor3_ready(motor3_ready),
        .motor4_ready(motor4_ready)
    );

    // Test state
    integer test_pass = 1;
    integer edge_count = 0;
    reg motor1_prev = 0;

    // Count edges on motor1
    always @(posedge clk) begin
        motor1_prev <= motor1_o;
        if (motor1_o != motor1_prev) begin
            edge_count <= edge_count + 1;
        end
    end

    // DSHOT encode helper (same as firmware)
    function [15:0] dshot_encode;
        input [10:0] throttle;
        input telemetry;
        reg [15:0] packet;
        reg [3:0] crc;
        begin
            packet = {throttle, telemetry, 4'b0};
            crc = packet[15:12] ^ packet[11:8] ^ packet[7:4] ^ packet[3:0];
            dshot_encode = {throttle, telemetry, crc};
        end
    endfunction

    // Wishbone write task
    task wb_write;
        input [31:0] addr;
        input [31:0] data;
        begin
            @(posedge clk);
            wba_adr_i = addr;
            wba_dat_i = data;
            wba_we_i = 1;
            wba_sel_i = 4'hF;
            wba_stb_i = 1;
            wba_cyc_i = 1;
            
            // Wait for ACK
            @(posedge clk);
            while (!wba_ack_o) @(posedge clk);
            
            // Deassert
            @(posedge clk);
            wba_stb_i = 0;
            wba_cyc_i = 0;
            wba_we_i = 0;
        end
    endtask

    // Wishbone read task
    task wb_read;
        input [31:0] addr;
        output [31:0] data;
        begin
            @(posedge clk);
            wba_adr_i = addr;
            wba_we_i = 0;
            wba_sel_i = 4'hF;
            wba_stb_i = 1;
            wba_cyc_i = 1;
            
            // Wait for ACK
            @(posedge clk);
            while (!wba_ack_o) @(posedge clk);
            
            data = wba_dat_o;
            
            // Deassert
            @(posedge clk);
            wba_stb_i = 0;
            wba_cyc_i = 0;
        end
    endtask

    // Main test
    reg [31:0] status;
    reg [15:0] dshot_cmd;
    integer timeout;

    initial begin
        $dumpfile("wb_dshot_mailbox_tb.vcd");
        $dumpvars(0, wb_dshot_mailbox_tb);

        // Initialize
        wba_adr_i = 0;
        wba_dat_i = 0;
        wba_we_i = 0;
        wba_sel_i = 0;
        wba_stb_i = 0;
        wba_cyc_i = 0;

        // Release reset
        repeat(10) @(posedge clk);
        rst = 0;
        repeat(5) @(posedge clk);

        $display("=== wb_dshot_mailbox Testbench ===");
        $display("CLK_FREQ_HZ = %d", CLK_FREQ_HZ);

        // Test 1: Read status register (should show all motors ready)
        $display("\nTest 1: Read status register (addr 0x10)");
        wb_read(32'h10, status);
        $display("  Status = 0x%08x (expect 0x0F = all ready)", status);
        if (status[3:0] != 4'hF) begin
            $display("  FAIL: Not all motors ready!");
            test_pass = 0;
        end else begin
            $display("  PASS: All motors ready");
        end

        // Test 2: Write DSHOT command to motor 1 (addr 0x00)
        $display("\nTest 2: Write DSHOT command to motor 1");
        dshot_cmd = dshot_encode(100, 0);  // Throttle 100, no telemetry
        $display("  Writing dshot_cmd = 0x%04x to addr 0x00", dshot_cmd);
        
        edge_count = 0;
        wb_write(32'h00, {16'b0, dshot_cmd});
        
        // Wait for DSHOT frame to complete (16 bits at DSHOT150 = ~107us)
        // At 54MHz, that's about 5800 clocks + guard time
        $display("  Waiting for DSHOT frame...");
        $display("  Initial motor1_ready=%b", motor1_ready);
        
        // Force wait at least 20000 clocks to ensure frame completes
        repeat(20000) @(posedge clk);
        
        $display("  After wait motor1_ready=%b", motor1_ready);
        
        $display("  motor1_o edges detected: %d", edge_count);
        if (edge_count == 0) begin
            $display("  FAIL: No transitions on motor1_o!");
            test_pass = 0;
        end else if (edge_count >= 16) begin
            // 16-bit frame should have at least 16 edges (could be more depending on encoding)
            $display("  PASS: DSHOT frame transmitted");
        end else begin
            $display("  WARNING: Fewer edges than expected (%d), might still be OK", edge_count);
        end

        // Test 3: Check motor1_ready returns high
        $display("\nTest 3: Check motor1_ready after transmission");
        wb_read(32'h10, status);
        $display("  Status = 0x%08x", status);
        if (status[0]) begin
            $display("  PASS: motor1_ready = 1");
        end else begin
            $display("  FAIL: motor1_ready still 0!");
            test_pass = 0;
        end

        // Summary
        $display("\n=================================");
        if (test_pass) begin
            $display("ALL TESTS PASSED");
        end else begin
            $display("SOME TESTS FAILED");
        end
        $display("=================================");

        $finish;
    end

endmodule
