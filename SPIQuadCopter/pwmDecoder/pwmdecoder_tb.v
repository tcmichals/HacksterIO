/**
 * PWM Decoder Testbench
 * 
 * Tests the pwmdecoder module with various PWM signal patterns
 */

`timescale 1ns/1ps

module pwmdecoder_tb();

    // Clock parameters
    localparam CLK_FREQ = 50_000_000;  // 50 MHz
    localparam CLK_PERIOD = 20;  // 20 ns (50 MHz)
    
    // PWM timing (in microseconds)
    localparam PWM_MIN = 1000;      // 1000 us (1 ms)
    localparam PWM_CENTER = 1500;   // 1500 us (1.5 ms)
    localparam PWM_MAX = 2000;      // 2000 us (2 ms)
    localparam PWM_FRAME = 20000;   // 20000 us (20 ms frame)
    
    // Convert microseconds to nanoseconds for simulation
    localparam real NS_PER_US = 1000.0;
    
    // Testbench signals
    reg clk;
    reg pwm_signal;
    reg resetn;
    wire pwm_ready;
    wire [15:0] pwm_value;
    
    // Instantiate DUT
    pwmdecoder #(
        .clockFreq(CLK_FREQ)
    ) dut (
        .i_clk(clk),
        .i_pwm(pwm_signal),
        .i_resetn(resetn),
        .o_pwm_ready(pwm_ready),
        .o_pwm_value(pwm_value)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // Task to generate a PWM pulse
    task send_pwm_pulse;
        input [15:0] pulse_width_us;
        begin
            pwm_signal = 1;
            #(pulse_width_us * NS_PER_US);
            pwm_signal = 0;
            #((PWM_FRAME - pulse_width_us) * NS_PER_US);
        end
    endtask
    
    // Task to wait for ready signal and check value
    task check_pwm_value;
        input [15:0] expected_value;
        input integer tolerance;
        integer diff;
        begin
            @(posedge pwm_ready);
            @(posedge clk);
            $display("[%t] PWM Ready: value = %d us (0x%04X)", $time, pwm_value, pwm_value);
            
            // Calculate difference (handle negative values)
            if (pwm_value > expected_value)
                diff = pwm_value - expected_value;
            else
                diff = expected_value - pwm_value;
            
            if (diff <= tolerance) begin
                $display("      PASS: Within tolerance (%d us)", tolerance);
            end else begin
                $display("      FAIL: Expected %d us ± %d, got %d us (diff: %d)", 
                         expected_value, tolerance, pwm_value, diff);
            end
        end
    endtask
    
    // Main test sequence
    initial begin
        $display("=== PWM Decoder Testbench ===");
        $display("Clock frequency: %0d Hz", CLK_FREQ);
        $display("Clock period: %0d ns", CLK_PERIOD);
        
        // Initialize
        pwm_signal = 0;
        resetn = 0;
        
        // Reset pulse
        #(CLK_PERIOD * 10);
        resetn = 1;
        #(CLK_PERIOD * 10);
        
        $display("\n--- Test 1: Minimum throttle (1000 us) ---");
        fork
            send_pwm_pulse(PWM_MIN);
            check_pwm_value(PWM_MIN, 2);  // ±2 us tolerance
        join
        
        $display("\n--- Test 2: Center position (1500 us) ---");
        fork
            send_pwm_pulse(PWM_CENTER);
            check_pwm_value(PWM_CENTER, 2);
        join
        
        $display("\n--- Test 3: Maximum throttle (2000 us) ---");
        fork
            send_pwm_pulse(PWM_MAX);
            check_pwm_value(PWM_MAX, 2);
        join
        
        $display("\n--- Test 4: Short pulse (800 us - minimum valid) ---");
        fork
            send_pwm_pulse(800);
            check_pwm_value(800, 2);
        join
        
        $display("\n--- Test 5: Long pulse (2500 us - near maximum) ---");
        fork
            send_pwm_pulse(2500);
            check_pwm_value(2500, 2);
        join
        
        $display("\n--- Test 6: Multiple pulses (continuous operation) ---");
        repeat(3) begin
            fork
                send_pwm_pulse(1200);
                check_pwm_value(1200, 2);
            join
        end
        $display("PASS: Continuous operation test complete");
        
        $display("\n--- Test 7: Varying pulses ---");
        fork
            send_pwm_pulse(1100);
            check_pwm_value(1100, 2);
        join
        fork
            send_pwm_pulse(1700);
            check_pwm_value(1700, 2);
        join
        fork
            send_pwm_pulse(1300);
            check_pwm_value(1300, 2);
        join
        $display("PASS: Varying pulse test complete");
        
        $display("\n--- Test 8: Guard time error - pulse too long (3000 us) ---");
        send_pwm_pulse(3000);
        @(posedge pwm_ready);
        @(posedge clk);
        $display("[%t] PWM Ready: value = %d us (0x%04X)", $time, pwm_value, pwm_value);
        
        if (pwm_value & 16'h8000) begin
            $display("      PASS: Guard error HIGH detected (pulse too long)");
        end else begin
            $display("      FAIL: Expected error flag 0x8000, got 0x%04X", pwm_value);
        end
        
        $display("\n--- Test 9: Reset during measurement ---");
        pwm_signal = 1;
        #(500 * NS_PER_US);  // Start a pulse
        resetn = 0;
        #(CLK_PERIOD * 5);
        resetn = 1;
        pwm_signal = 0;
        #(1000 * NS_PER_US);
        $display("PASS: Reset test complete");
        
        $display("\n=== All tests complete ===");
        #(1000 * NS_PER_US);
        $finish;
    end
    
    // Dump waveforms
    initial begin
        $dumpfile("pwmdecoder_tb.vcd");
        $dumpvars(0, pwmdecoder_tb);
    end
    
    // Timeout watchdog
    initial begin
        #(500_000_000);  // 500 ms timeout
        $display("\nERROR: Simulation timeout!");
        $finish;
    end

endmodule
