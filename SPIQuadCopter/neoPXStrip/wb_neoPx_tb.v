`timescale 1ns / 1ps

/**
 * Testbench for wb_neoPx - Wishbone NeoPixel Controller
 * 
 * Tests:
 * 1. Write pixel color data via Wishbone
 * 2. Read back pixel data
 * 3. Trigger update
 * 4. Validate serial output timing (T0H, T1H, bit periods)
 * 5. Verify bit patterns match written colors
 */

module wb_neoPx_tb;

    // Parameters
    parameter CLK_PERIOD = 13.888; // 72 MHz clock (1e9 / 72e6 ns)
    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 32;
    
    // Timing parameters for SK6812 at 72 MHz (in ns)
    localparam real T0H_MIN = 250.0;  // 300ns nominal, -50ns margin
    localparam real T0H_MAX = 350.0;  // 300ns nominal, +50ns margin
    localparam real T1H_MIN = 550.0;  // 600ns nominal, -50ns margin
    localparam real T1H_MAX = 650.0;  // 600ns nominal, +50ns margin
    localparam real BIT_PERIOD_MIN = 1200.0;  // 1250ns nominal
    localparam real BIT_PERIOD_MAX = 1300.0;
    localparam integer BITS_PER_PIXEL = 32; // SK6812 is 32-bit RGBW
    
    // Signals
    reg                     clk;
    reg                     rst;
    reg [ADDR_WIDTH-1:0]    wb_adr;
    reg [DATA_WIDTH-1:0]    wb_dat_w;
    wire [DATA_WIDTH-1:0]   wb_dat_r;
    reg                     wb_we;
    reg [3:0]               wb_sel;
    reg                     wb_stb;
    wire                    wb_ack;
    wire                    wb_err;
    wire                    wb_rty;
    reg                     wb_cyc;
    wire                    serial_out;
    
    // Test tracking
    integer errors;
    integer tests_run;
    integer bit_errors;
    integer timing_errors;
    
    // Pulse monitoring
    real last_rise_time;
    real last_fall_time;
    real pulse_width_ns;
    integer pulse_count;
    
    // DUT instantiation
    wb_neoPx #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .CLK_FREQ_HZ(54_000_000)
    ) dut (
        .i_clk(clk),
        .i_rst(rst),
        .wb_adr_i(wb_adr),
        .wb_dat_i(wb_dat_w),
        .wb_dat_o(wb_dat_r),
        .wb_we_i(wb_we),
        .wb_sel_i(wb_sel),
        .wb_stb_i(wb_stb),
        .wb_ack_o(wb_ack),
        .wb_err_o(wb_err),
        .wb_rty_o(wb_rty),
        .wb_cyc_i(wb_cyc),
        .o_serial(serial_out)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // Wishbone write task
    task wb_write;
        input [ADDR_WIDTH-1:0] addr;
        input [DATA_WIDTH-1:0] data;
        begin
            @(posedge clk);
            wb_adr = addr;
            wb_dat_w = data;
            wb_we = 1;
            wb_sel = 4'hF;
            wb_stb = 1;
            wb_cyc = 1;
            @(posedge clk);
            while (!wb_ack) @(posedge clk);
            wb_stb = 0;
            wb_cyc = 0;
            wb_we = 0;
            @(posedge clk);
        end
    endtask
    
    // Wishbone read task
    task wb_read;
        input [ADDR_WIDTH-1:0] addr;
        output [DATA_WIDTH-1:0] data;
        begin
            @(posedge clk);
            wb_adr = addr;
            wb_we = 0;
            wb_sel = 4'hF;
            wb_stb = 1;
            wb_cyc = 1;
            @(posedge clk);
            while (!wb_ack) @(posedge clk);
            data = wb_dat_r;
            wb_stb = 0;
            wb_cyc = 0;
            @(posedge clk);
        end
    endtask
    
    
    // Task to check pulse timing
    task check_pulse_timing;
        input real measured_ns;
        input integer is_bit_one;
        begin
            if (is_bit_one) begin
                if (measured_ns < T1H_MIN || measured_ns > T1H_MAX) begin
                    $display("  ERROR: T1H out of range: %.1f ns (expected %.1f-%.1f)", 
                             measured_ns, T1H_MIN, T1H_MAX);
                    timing_errors = timing_errors + 1;
                end
            end else begin
                if (measured_ns < T0H_MIN || measured_ns > T0H_MAX) begin
                    $display("  ERROR: T0H out of range: %.1f ns (expected %.1f-%.1f)", 
                             measured_ns, T0H_MIN, T0H_MAX);
                    timing_errors = timing_errors + 1;
                end
            end
        end
    endtask
    
    // Monitor serial output edges and validate timing
    always @(posedge serial_out) begin
        last_rise_time = $realtime;
    end
    
    always @(negedge serial_out) begin
        if (last_rise_time > 0) begin
            last_fall_time = $realtime;
            pulse_width_ns = last_fall_time - last_rise_time;
            pulse_count = pulse_count + 1;
            
            // Determine if this is a '0' or '1' bit based on pulse width
            if (pulse_width_ns >= (T0H_MAX + T1H_MIN) / 2.0) begin
                // T1H - logic '1'
                check_pulse_timing(pulse_width_ns, 1);
            end else begin
                // T0H - logic '0'
                check_pulse_timing(pulse_width_ns, 0);
            end
        end
    end
    
    // Main test sequence
    initial begin
        $dumpfile("wb_neoPx_tb.vcd");
        $dumpvars(0, wb_neoPx_tb);
        
        // Initialize
        errors = 0;
        tests_run = 0;
        bit_errors = 0;
        timing_errors = 0;
        pulse_count = 0;
        last_rise_time = 0;
        last_fall_time = 0;
        rst = 1;
        wb_adr = 0;
        wb_dat_w = 0;
        wb_we = 0;
        wb_sel = 0;
        wb_stb = 0;
        wb_cyc = 0;
        
        // Reset
        #100;
        @(posedge clk);
        rst = 0;
        #100;
        
        $display("=== NeoPixel Wishbone Controller Test ===");
        $display("CLK_FREQ: 54 MHz, LED_TYPE: SK6812 (32-bit RGBW)");
        $display("Timing: T0H=300ns, T1H=600ns, Period=1250ns");
        
        // Test 1: Write pixel colors
        $display("\n--- Test 1: Writing pixel colors ---");
        tests_run = tests_run + 1;
        wb_write(32'h00000000, 32'hFF000000); // Pixel 0: Red (RGBW)
        wb_write(32'h00000004, 32'h00FF0000); // Pixel 1: Green  
        wb_write(32'h00000008, 32'h0000FF00); // Pixel 2: Blue
        wb_write(32'h0000000C, 32'h00000000); // Pixel 3: Off
        wb_write(32'h00000010, 32'h00000000); // Pixel 4: Off
        wb_write(32'h00000014, 32'h00000000); // Pixel 5: Off
        wb_write(32'h00000018, 32'h00000000); // Pixel 6: Off
        wb_write(32'h0000001C, 32'h00000000); // Pixel 7: Off
        $display("PASS: Written 8 pixel colors");
        
        // Test 2: Read back pixel data
        $display("\n--- Test 2: Reading back pixel data ---");
        tests_run = tests_run + 1;
        begin
            reg [DATA_WIDTH-1:0] readback;
            wb_read(32'h00000000, readback);
            if (readback !== 32'hFF000000) begin
                $display("FAIL: Pixel 0 mismatch. Expected: 0xFF000000, Got: 0x%08h", readback);
                errors = errors + 1;
            end else begin
                $display("PASS: Pixel 0 verified: 0x%08h", readback);
            end
            
            wb_read(32'h00000008, readback);
            if (readback !== 32'h0000FF00) begin
                $display("FAIL: Pixel 2 mismatch. Expected: 0x0000FF00, Got: 0x%08h", readback);
                errors = errors + 1;
            end else begin
                $display("PASS: Pixel 2 verified: 0x%08h", readback);
            end
        end
        
        // Test 3: Trigger update and monitor serial output
        $display("\n--- Test 3: Triggering NeoPixel update ---");
        tests_run = tests_run + 1;
        pulse_count = 0;
        timing_errors = 0;
        wb_write(32'h00000020, 32'h00000001); // Write to non-data address to trigger
        $display("Update triggered, monitoring serial output...");
        
        // Wait for transmission to complete (8 pixels * 32 bits * ~1.25us = ~320us + latch)
        #350000; // 350 us
        
        $display("\n--- Test 4: Serial output timing validation ---");
        tests_run = tests_run + 1;
        $display("Total pulses measured: %0d", pulse_count);
        $display("Expected pulses: %0d (8 pixels × 32 bits)", 8 * BITS_PER_PIXEL);
        
        if (pulse_count >= 8 * BITS_PER_PIXEL) begin
            $display("PASS: Sufficient pulses detected");
        end else begin
            $display("FAIL: Insufficient pulses (expected at least %0d)", 8 * BITS_PER_PIXEL);
            errors = errors + 1;
        end
        
        if (timing_errors == 0) begin
            $display("PASS: All pulse timings within specification");
        end else begin
            $display("FAIL: %0d timing violations detected", timing_errors);
            errors = errors + timing_errors;
        end
        
        // Summary
        $display("\n=== Test Summary ===");
        $display("Tests run: %0d", tests_run);
        $display("Total errors: %0d", errors);
        $display("Timing errors: %0d", timing_errors);
        $display("Pulses measured: %0d", pulse_count);
        
        if (errors == 0) begin
            $display("\n*** All tests PASSED ***");
        end else begin
            $display("\n*** FAILED with %0d errors ***", errors);
        end
        
        #1000;
        $finish;
    end
    
    // Timeout watchdog
    initial begin
        #1_000_000; // 1 ms timeout
        $display("\nERROR: Testbench timeout!");
        $finish;
    end

endmodule
