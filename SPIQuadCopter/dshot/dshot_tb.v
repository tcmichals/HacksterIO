/**
 * DSHOT Output Testbench
 * 
 * Tests DSHOT150 protocol timing and frame generation
 */

`timescale 1ps/1ps  // Use picosecond resolution for accurate 72MHz timing
`define SIMULATION

module dshot_tb;

    // Clock parameters - Updated for 72MHz PLL
    localparam CLK_FREQ_HZ = 72_000_000;
    localparam CLK_PERIOD = 13889; // 72 MHz = 13.889ns = 13889ps
    
    // DSHOT150 timing (in ps now!)
    localparam DSHOT150_BIT_PERIOD = 6670000;  // 6.67us = 6,670,000ps
    localparam DSHOT150_T0H = 2500000;         // 2.5us = 2,500,000ps
    localparam DSHOT150_T1H = 5000000;         // 5.0us = 5,000,000ps
    localparam TOLERANCE = 300000;             // ±300ns = 300,000ps tolerance (increased for 72MHz)
    
    // Test signals
    reg         clk;
    reg         reset;
    reg  [15:0] dshot_value;
    reg         write;
    wire        pwm;
    
    // Measurement variables
    integer bit_count;
    integer high_time;
    integer low_time;
    reg [15:0] received_frame;
    
    // Instantiate DUT
    dshot_output #(
        .clockFrequency(CLK_FREQ_HZ)
    ) dut (
        .i_clk(clk),
        .i_reset(reset),
        .i_dshot_value(dshot_value),
        .i_dshot_mode(16'd150),  // Test with DSHOT150 (can be changed to 300 or 600)
        .i_write(write),
        .o_pwm(pwm),
        .o_ready()  // Not used in this test
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
            @(posedge clk);
            dshot_value = value;
            write = 1;
            $display("       [%t] write=1, dshot_value=0x%04X", $time, value);
            @(posedge clk);
            write = 0;
            $display("       [%t] write=0", $time);
            // Give module a few clocks to start
            repeat(5) @(posedge clk);
            $display("       [%t] PWM output: %b", $time, pwm);
        end
    endtask
    
    // Task to measure pulse width
    task measure_pulse;
        output integer high_ns;
        output integer low_ns;
        integer start_time;
        begin
            high_ns = 0;
            low_ns = 0;
            
            // Wait for rising edge
            @(posedge pwm);
            start_time = $time;
            
            // Wait for falling edge
            @(negedge pwm);
            high_ns = $time - start_time;
            
            // Calculate low time (rest of bit period)
            low_ns = DSHOT150_BIT_PERIOD - high_ns;
        end
    endtask
    
    // Task to check if bit timing is valid
    task check_bit_timing;
        input integer high_ns;
        input integer low_ns;
        input bit_value;
        integer expected_high;
        integer pass_check;
        begin
            expected_high = (bit_value) ? DSHOT150_T1H : DSHOT150_T0H;
            
            pass_check = 1;
            if ((high_ns < (expected_high - TOLERANCE)) || 
                (high_ns > (expected_high + TOLERANCE))) begin
                $display("      FAIL: High time %0d ns, expected %0d ns (±%0d ns)",
                         high_ns, expected_high, TOLERANCE);
                pass_check = 0;
            end
            
            if (pass_check)
                $display("      PASS: Bit %0d, high=%0d ns, low=%0d ns",
                         bit_value, high_ns, low_ns);
        end
    endtask
    
    // Main test sequence
    initial begin
        $display("\n=== DSHOT Output Testbench ===");
        $display("Clock: %0d MHz", CLK_FREQ_HZ/1_000_000);
        $display("DSHOT150 Bit Period: %0d ns", DSHOT150_BIT_PERIOD);
        
        // Initialize
        reset = 1;
        dshot_value = 16'h0;
        write = 0;
        bit_count = 0;
        
        repeat(10) @(posedge clk);
        reset = 0;
        repeat(10) @(posedge clk);
        
        // Test 1: Send all zeros (16'h0000)
        $display("\n--- Test 1: All zeros (0x0000) ---");
        send_dshot_value(16'h0000);
        $display("[%t] Sent DSHOT value: 0x0000", $time);
        $display("[%t] Waiting for transmission to start...", $time);
        
        // Wait for first edge with timeout
        fork : wait_for_transmission
            begin
                @(posedge pwm or negedge pwm);
                $display("[%t] PWM activity detected!", $time);
            end
            begin
                #(DSHOT150_BIT_PERIOD * 5);
                $display("[%t] WARNING: No PWM activity after 5 bit periods", $time);
                $display("       PWM level is: %b", pwm);
                disable wait_for_transmission;
            end
        join
        
        // Only measure if we saw activity
        if (pwm !== 1'bx) begin
            // Measure first few bits
            repeat(4) begin
                measure_pulse(high_time, low_time);
                check_bit_timing(high_time, low_time, 0);
            end
        end else begin
            $display("       SKIP: No PWM output detected");
        end
        
        // Wait for frame to complete AND guard time
        // Full frame = 16 bits × 6.67µs = 106.72µs = 106,720,000 ps
        // Guard time = 250µs = 250,000,000 ps
        // Total wait = 356,720,000 ps
        #360000000;  // Wait for full transmission + guard time
        
        // Test 2: Send all ones (16'hFFFF)
        $display("\n--- Test 2: All ones (0xFFFF) ---");
        send_dshot_value(16'hFFFF);
        $display("[%t] Sent DSHOT value: 0xFFFF", $time);
        
        // Measure first few bits
        repeat(4) begin
            measure_pulse(high_time, low_time);
            check_bit_timing(high_time, low_time, 1);
        end
        
        // Wait for frame to complete AND guard time
        #360000000;  // Wait for full transmission (107µs) + guard time (250µs)
        
        // Test 3: Alternating pattern (16'hAAAA)
        $display("\n--- Test 3: Alternating pattern (0xAAAA) ---");
        send_dshot_value(16'hAAAA);
        $display("[%t] Sent DSHOT value: 0xAAAA", $time);
        
        // Measure first 8 bits (simplified to avoid complex loops)
        measure_pulse(high_time, low_time);
        check_bit_timing(high_time, low_time, 1);
        measure_pulse(high_time, low_time);
        check_bit_timing(high_time, low_time, 0);
        measure_pulse(high_time, low_time);
        check_bit_timing(high_time, low_time, 1);
        measure_pulse(high_time, low_time);
        check_bit_timing(high_time, low_time, 0);
        measure_pulse(high_time, low_time);
        check_bit_timing(high_time, low_time, 1);
        measure_pulse(high_time, low_time);
        check_bit_timing(high_time, low_time, 0);
        measure_pulse(high_time, low_time);
        check_bit_timing(high_time, low_time, 1);
        measure_pulse(high_time, low_time);
        check_bit_timing(high_time, low_time, 0);
        
        // Wait for frame to complete
        #(DSHOT150_BIT_PERIOD * 5);
        
        // Test 4: Typical throttle value with CRC
        // Throttle = 1000 (11 bits), telemetry = 0, CRC placeholder
        $display("\n--- Test 4: Typical frame (throttle=1000) ---");
        send_dshot_value(16'b0111110100000000);  // 1000 << 5 = 0x7D00
        $display("[%t] Sent DSHOT value: 0x7D00", $time);
        
        // Just verify transmission starts
        measure_pulse(high_time, low_time);
        if (high_time > 0) begin
            $display("      PASS: Frame transmission started");
        end else begin
            $display("      FAIL: No frame detected");
        end
        
        // Wait for completion
        #(DSHOT150_BIT_PERIOD * 20);
        
        // Test 5: Multiple rapid writes (guard time test)
        $display("\n--- Test 5: Guard time test ---");
        send_dshot_value(16'h1234);
        $display("[%t] Sent DSHOT value: 0x1234", $time);
        #100;  // Try to write again immediately
        send_dshot_value(16'h5678);
        $display("[%t] Sent DSHOT value: 0x5678", $time);
        $display("      INFO: Second write should be ignored due to guard time");
        
        #(DSHOT150_BIT_PERIOD * 20);
        
        $display("\n=== All tests complete ===");
        $finish;
    end
    
    // Dump waveforms
    initial begin
        $dumpfile("dshot_tb.vcd");
        $dumpvars(0, dshot_tb);
    end
    
    // Timeout watchdog - prevent infinite hangs
    initial begin
        #10_000_000_000;  // 10ms timeout (in picoseconds)
        $display("\n=== ERROR: Testbench timeout after 10ms ===");
        $display("    The testbench took too long to complete.");
        $display("    Check for hanging @() statements or infinite loops.");
        $finish;
    end

endmodule
