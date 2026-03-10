/**
 * DSHOT Output Testbench
 * 
 * Tests:
 * 1. DSHOT150 protocol timing (T0H, T1H, bit periods)
 * 2. Frame generation with CRC calculation
 * 3. Waveform decoding and validation
 * 4. CRC verification on decoded frames
 */

`timescale 1ps/1ps  // Use picosecond resolution for accurate 72MHz timing
`define SIMULATION

module dshot_tb;

    // Clock parameters - Must match DUT clockFrequency
    localparam CLK_FREQ_HZ = 54_000_000;
    localparam CLK_PERIOD = 18519; // 54 MHz = 18.519ns = 18519ps
    
    // DSHOT150 timing (in ps now!)
    localparam DSHOT150_BIT_PERIOD = 6670000;  // 6.67us = 6,670,000ps
    localparam DSHOT150_T0H = 2500000;         // 2.5us = 2,500,000ps
    localparam DSHOT150_T1H = 5000000;         // 5.0us = 5,000,000ps
    localparam TOLERANCE = 300000;             // ±300ns = 300,000ps tolerance
    
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
    
    // Test tracking
    integer tests_run;
    integer errors;
    integer timing_errors;
    integer crc_errors;
    
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
    
    // Function to calculate DSHOT CRC
    // CRC = (payload ^ (payload >> 4) ^ (payload >> 8)) & 0x0F
    function [3:0] calculate_crc;
        input [11:0] payload;  // 11-bit throttle + 1-bit telemetry
        begin
            calculate_crc = (payload ^ (payload >> 4) ^ (payload >> 8)) & 4'h0F;
        end
    endfunction
    
    // Function to create DSHOT frame
    // Returns 16-bit frame: throttle[15:5] + telemetry[4] + crc[3:0]
    function [15:0] create_dshot_frame;
        input [10:0] throttle;   // 11-bit throttle (0-2047)
        input telemetry;         // 1-bit telemetry request
        reg [11:0] payload;
        reg [3:0] crc;
        begin
            payload = {throttle, telemetry};
            crc = calculate_crc(payload);
            create_dshot_frame = {payload, crc};
        end
    endfunction
    
    // Function to verify DSHOT frame CRC
    function verify_crc;
        input [15:0] frame;
        reg [11:0] payload;
        reg [3:0] expected_crc;
        reg [3:0] actual_crc;
        begin
            payload = frame[15:4];
            actual_crc = frame[3:0];
            expected_crc = calculate_crc(payload);
            verify_crc = (actual_crc == expected_crc);
        end
    endfunction
    
    // Task to send DSHOT value
    task send_dshot_value;
        input [15:0] value;
        begin
            @(posedge clk);
            dshot_value = value;
            write = 1;
            @(posedge clk);
            write = 0;
            @ (posedge clk);
            // Don't wait here - let the decode task handle edge detection
        end
    endtask
    
    
    // Task to measure pulse width and decode bit value
    task measure_and_decode_bit;
        output bit_value;
        output timeout_occurred;
        integer start_time;
        integer pulse_width;
        begin
            bit_value = 0;
            timeout_occurred = 0;
            
            // Wait for rising edge
            @(posedge pwm);
            start_time = $time;
            
            // Wait for falling edge
            @(negedge pwm);
            pulse_width = $time - start_time;
            
            // Decode bit based on pulse width
            if (pulse_width >= (DSHOT150_T0H + DSHOT150_T1H) / 2) begin
                bit_value = 1;
            end else begin
                bit_value = 0;
            end
            
            // Validate timing
            if (bit_value == 1) begin
                if ((pulse_width < (DSHOT150_T1H - TOLERANCE)) || 
                    (pulse_width > (DSHOT150_T1H + TOLERANCE))) begin
                    $display("      ERROR: T1H out of range: %0d ps (expected %0d ±%0d)",
                             pulse_width, DSHOT150_T1H, TOLERANCE);
                    timing_errors = timing_errors + 1;
                end
            end else begin
                if ((pulse_width < (DSHOT150_T0H - TOLERANCE)) || 
                    (pulse_width > (DSHOT150_T0H + TOLERANCE))) begin
                    $display("      ERROR: T0H out of range: %0d ps (expected %0d ±%0d)",
                             pulse_width, DSHOT150_T0H, TOLERANCE);
                    timing_errors = timing_errors + 1;
                end
            end
        end
    endtask
    
    // Task to decode entire DSHOT frame (16 bits)
    task decode_dshot_frame;
        output [15:0] decoded_frame;
        output decode_failed;
        integer i;
        reg bit_val;
        reg timeout;
        begin
            decoded_frame = 16'h0000;
            decode_failed = 0;
            for (i = 0; i < 16; i = i + 1) begin
                measure_and_decode_bit(bit_val, timeout);
                decoded_frame = {decoded_frame[14:0], bit_val};
            end
        end
    endtask
    
    // Task to test a complete DSHOT frame
    task test_dshot_frame;
        input [10:0] throttle;
        input telemetry;
        input [127:0] test_name;  // String description (increased size)
        reg [15:0] sent_frame;
        reg [15:0] decoded_frame;
        reg [10:0] decoded_throttle;
        reg decoded_telemetry;
        reg [3:0] decoded_crc;
        reg decode_failed;
        begin
            $display("\n--- %0s ---", test_name);
            tests_run = tests_run + 1;
            
            // Create frame with CRC
            sent_frame = create_dshot_frame(throttle, telemetry);
            $display("Throttle: %0d, Telemetry: %0b", throttle, telemetry);
            $display("Sent frame: 0x%04X (payload: 0x%03X, CRC: 0x%01X)", 
                     sent_frame, sent_frame[15:4], sent_frame[3:0]);
            
            // Send frame
            send_dshot_value(sent_frame);
            
            // Decode received frame
            decode_dshot_frame(decoded_frame, decode_failed);
            
            // Parse decoded frame
            decoded_throttle = decoded_frame[15:5];
            decoded_telemetry = decoded_frame[4];
            decoded_crc = decoded_frame[3:0];
            
            $display("Decoded frame: 0x%04X (payload: 0x%03X, CRC: 0x%01X)",
                     decoded_frame, decoded_frame[15:4], decoded_frame[3:0]);
            
            // Verify frame matches
            if (decoded_frame !== sent_frame) begin
                $display("FAIL: Frame mismatch!");
                $display("      Expected: 0x%04X", sent_frame);
                $display("      Received: 0x%04X", decoded_frame);
                errors = errors + 1;
            end else begin
                $display("PASS: Frame matched");
            end
            
            // Verify CRC
            if (!verify_crc(decoded_frame)) begin
                $display("FAIL: CRC invalid!");
                crc_errors = crc_errors + 1;
                errors = errors + 1;
            end else begin
                $display("PASS: CRC valid");
            end
            
            // Wait for frame to complete + guard time
            #360000000;  // 360us total
        end
    endtask
    
    
    // Main test sequence
    initial begin
        $display("\n=== DSHOT Output Testbench ===");
        $display("Clock: %0d MHz", CLK_FREQ_HZ/1_000_000);
        $display("DSHOT150 Bit Period: %0d us", DSHOT150_BIT_PERIOD/1_000_000);
        $display("DSHOT150 T0H: %0.2f us, T1H: %0.2f us", 
                 DSHOT150_T0H/1_000_000.0, DSHOT150_T1H/1_000_000.0);
        
        // Initialize
        tests_run = 0;
        errors = 0;
        timing_errors = 0;
        crc_errors = 0;
        reset = 1;
        dshot_value = 16'h0;
        write = 0;
        bit_count = 0;
        
        repeat(10) @(posedge clk);
        reset = 0;
        repeat(10) @(posedge clk);
        
        // Test 1: Motor stop (throttle = 0)
        test_dshot_frame(11'd0, 1'b0, "Test 1: Motor stop");
        
        // Test 2: Minimum throttle (48)
        test_dshot_frame(11'd48, 1'b0, "Test 2: Min throttle");
        
        // Test 3: Mid throttle (1000)
        test_dshot_frame(11'd1000, 1'b0, "Test 3: Mid throttle (1000)");
        
        // Test 4: Max throttle (2047)
        test_dshot_frame(11'd2047, 1'b0, "Test 4: Max throttle (2047)");
        
        // Test 5: Throttle with telemetry request
        test_dshot_frame(11'd1500, 1'b1, "Test 5: Throttle 1500 + telemetry");
        
        // Test 6: Special command - ESC info (6)
        test_dshot_frame(11'd6, 1'b0, "Test 6: ESC info command");
        
        // Test 7: Special command - Spin direction reversed (21)
        test_dshot_frame(11'd21, 1'b0, "Test 7: Spin direction reversed");
        
        // Test 8: All ones in throttle bits
        test_dshot_frame(11'd2047, 1'b1, "Test 8: All ones pattern");
        
        // Summary
        $display("\n=== Test Summary ===");
        $display("Tests run: %0d", tests_run);
        $display("Total errors: %0d", errors);
        $display("  - Timing errors: %0d", timing_errors);
        $display("  - CRC errors: %0d", crc_errors);
        
        if (errors == 0) begin
            $display("\n*** All tests PASSED ***");
        end else begin
            $display("\n*** FAILED with %0d errors ***", errors);
        end
        
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
