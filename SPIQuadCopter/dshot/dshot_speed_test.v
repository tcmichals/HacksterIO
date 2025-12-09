/**
 * DSHOT Multi-Speed Test
 * 
 * Tests DSHOT150, DSHOT300, and DSHOT600 modes
 */

`timescale 1ps/1ps
`define SIMULATION

module dshot_speed_test;

    // Clock parameters
    localparam CLK_FREQ_HZ = 72_000_000;
    localparam CLK_PERIOD = 13889; // 72 MHz = 13.889ns = 13889ps
    
    // Test signals
    reg         clk;
    reg         reset;
    reg  [15:0] dshot_value;
    reg  [15:0] dshot_mode;
    reg         write;
    wire        pwm;
    wire        ready;
    
    // Measurement variables
    integer high_time;
    integer low_time;
    integer start_time;
    
    // Instantiate DUT
    dshot_output #(
        .clockFrequency(CLK_FREQ_HZ)
    ) dut (
        .i_clk(clk),
        .i_reset(reset),
        .i_dshot_value(dshot_value),
        .i_dshot_mode(dshot_mode),
        .i_write(write),
        .o_pwm(pwm),
        .o_ready(ready)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // Task to send DSHOT value
    task send_dshot_value;
        input [15:0] value;
        begin
            // Wait for ready signal
            while (!ready) @(posedge clk);
            $display("  Ready signal detected, sending value 0x%04X at time %0t", value, $time);
            dshot_value = value;
            write = 1;
            @(posedge clk);
            write = 0;
            $display("  Write strobe completed at time %0t", $time);
        end
    endtask
    
    // Task to measure a single pulse
    task measure_pulse;
        output integer high_ns;
        output integer low_ns;
        begin
            // Wait for rising edge
            @(posedge pwm);
            start_time = $time;
            
            // Wait for falling edge
            @(negedge pwm);
            high_ns = $time - start_time;
            
            // Calculate low time (rest of bit period)
            @(posedge pwm or $time > ($time + 10000000)); // Timeout or next pulse
            if (pwm) begin
                low_ns = $time - start_time - high_ns;
            end else begin
                low_ns = 0; // Last bit, no more pulses
            end
        end
    endtask
    
    // Task to check timing
    task check_timing;
        input integer measured_high;
        input integer expected_high;
        input integer tolerance;
        input bit_value;
        input [79:0] mode_name;
        begin
            if ((measured_high >= (expected_high - tolerance)) && 
                (measured_high <= (expected_high + tolerance))) begin
                $display("  ✓ PASS [%s]: Bit %0d, HIGH=%0d ps (expected %0d ±%0d ps)", 
                         mode_name, bit_value, measured_high, expected_high, tolerance);
            end else begin
                $display("  ✗ FAIL [%s]: Bit %0d, HIGH=%0d ps, expected %0d ps (±%0d ps)",
                         mode_name, bit_value, measured_high, expected_high, tolerance);
            end
        end
    endtask
    
    // Main test sequence
    initial begin
        $display("\n========================================");
        $display("DSHOT Multi-Speed Test");
        $display("Clock: %0d MHz", CLK_FREQ_HZ/1_000_000);
        $display("========================================\n");
        
        // Initialize
        reset = 1;
        dshot_value = 16'h0;
        dshot_mode = 16'd150;
        write = 0;
        
        repeat(10) @(posedge clk);
        reset = 0;
        repeat(10) @(posedge clk);
        
        //=============================================
        // Test 1: DSHOT150
        //=============================================
        $display("--- Test 1: DSHOT150 Mode ---");
        dshot_mode = 16'd150;
        
        // Test bit "0" (all zeros frame)
        $display("\nTesting DSHOT150 Bit '0':");
        send_dshot_value(16'h0000);
        repeat(2) @(posedge clk);
        
        // Measure first 3 bits
        repeat(3) begin
            measure_pulse(high_time, low_time);
            check_timing(high_time, 2500000, 200000, 0, "DSHOT150");
        end
        
        // No need to wait - send_dshot_value will wait for ready signal
        
        // Test bit "1" (all ones frame)
        $display("\nTesting DSHOT150 Bit '1':");
        send_dshot_value(16'hFFFF);
        repeat(2) @(posedge clk);
        
        // Measure first 3 bits
        repeat(3) begin
            measure_pulse(high_time, low_time);
            check_timing(high_time, 5000000, 200000, 1, "DSHOT150");
        end
        
        //=============================================
        // Test 2: DSHOT300
        //=============================================
        $display("\n--- Test 2: DSHOT300 Mode ---");
        dshot_mode = 16'd300;
        
        // Test bit "0"
        $display("\nTesting DSHOT300 Bit '0':");
        send_dshot_value(16'h0000);
        repeat(2) @(posedge clk);
        
        // Measure first 3 bits (T0H = 1.25us = 1,250,000ps)
        repeat(3) begin
            measure_pulse(high_time, low_time);
            check_timing(high_time, 1250000, 150000, 0, "DSHOT300");
        end
        
        // Test bit "1"
        $display("\nTesting DSHOT300 Bit '1':");
        send_dshot_value(16'hFFFF);
        repeat(2) @(posedge clk);
        
        // Measure first 3 bits (T1H = 2.50us = 2,500,000ps)
        repeat(3) begin
            measure_pulse(high_time, low_time);
            check_timing(high_time, 2500000, 150000, 1, "DSHOT300");
        end
        
        //=============================================
        // Test 3: DSHOT600
        //=============================================
        $display("\n--- Test 3: DSHOT600 Mode ---");
        dshot_mode = 16'd600;
        
        // Test bit "0"
        $display("\nTesting DSHOT600 Bit '0':");
        send_dshot_value(16'h0000);
        repeat(2) @(posedge clk);
        
        // Measure first 3 bits (T0H = 0.625us = 625,000ps)
        repeat(3) begin
            measure_pulse(high_time, low_time);
            check_timing(high_time, 625000, 100000, 0, "DSHOT600");
        end
        
        // Test bit "1"
        $display("\nTesting DSHOT600 Bit '1':");
        send_dshot_value(16'hFFFF);
        repeat(2) @(posedge clk);
        
        // Measure first 3 bits (T1H = 1.25us = 1,250,000ps)
        repeat(3) begin
            measure_pulse(high_time, low_time);
            check_timing(high_time, 1250000, 100000, 1, "DSHOT600");
        end
        
        //=============================================
        // Test 4: Mode switching
        //=============================================
        $display("\n--- Test 4: Dynamic Mode Switching ---");
        
        // Switch from 600 back to 150
        dshot_mode = 16'd150;
        $display("\nSwitched to DSHOT150:");
        send_dshot_value(16'h5555); // Alternating pattern
        repeat(2) @(posedge clk);
        
        measure_pulse(high_time, low_time);
        check_timing(high_time, 2500000, 200000, 0, "DSHOT150");
        measure_pulse(high_time, low_time);
        check_timing(high_time, 5000000, 200000, 1, "DSHOT150");
        
        $display("\n========================================");
        $display("All Speed Tests Complete!");
        $display("========================================\n");
        
        #100000;
        $finish;
    end
    
    // Timeout watchdog
    initial begin
        #5_000_000_000;  // 5ms timeout
        $display("\n=== ERROR: Testbench timeout ===");
        $finish;
    end

endmodule
