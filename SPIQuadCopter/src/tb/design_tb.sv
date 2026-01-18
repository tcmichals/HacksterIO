`timescale 1ns/1ps

module design_tb();

    // System clock for design: drive 72 MHz (half period 7ns)
    reg i_clk = 0;
    always #7 i_clk = ~i_clk;

    // SPI master signals
    logic i_sclk = 0;
    logic spi_cs_n = 1; // active LOW (asserted = 0)
    logic spi_mosi = 0;
    logic spi_miso;

    // LEDs and status (map to top-level LED outputs)
    wire o_led0, o_led1, o_led2, o_led3;
    wire o_neopixel;
    
    // PWM Inputs
    reg pwm_ch0 = 0;
    
    // Motor Outputs
    wire o_motor1;

    // Transaction temp variables
    reg [31:0] tmp32;
    reg [31:0] readback;
    logic [31:0] pixel_data;
    // Local testbench temporaries
    integer led_i;
    reg [31:0] expected;
    
    // DSHOT Monitor variables
    reg [15:0] dshot_frame;
    reg dshot_monitor_active = 0;
    // Control verbose output via plusarg +VERBOSE
    bit tb_verbose = 0;

    // Instantiate the top-level module tang9k_top
    tang9k_top dut (
        .i_clk        (i_clk),
        .i_spi_clk    (i_sclk),
        .i_spi_cs_n   (spi_cs_n),
        .i_spi_mosi   (spi_mosi),
        .o_spi_miso   (spi_miso),

        // Map first four top LEDs to testbench LED wires
        .o_led_1      (o_led0),
        .o_led_2      (o_led1),
        .o_led_3      (o_led2),
        .o_led_4      (o_led3),

        .i_usb_uart_rx(1'b1),
        .o_usb_uart_tx(),

        .i_pwm_ch0    (pwm_ch0),
        .i_pwm_ch1    (1'b0),
        .i_pwm_ch2    (1'b0),
        .i_pwm_ch3    (1'b0),
        .i_pwm_ch4    (1'b0),
        .i_pwm_ch5    (1'b0),

        .o_motor1     (o_motor1),
        .o_motor2     (),
        .o_motor3     (),
        .o_motor4     (),

        .o_neopixel   (o_neopixel),
        .o_debug_0    (),
        .o_debug_1    (),
        .o_debug_2    ()
    );

    // DSHOT Monitor Task
    task monitor_dshot;
        integer i;
        time t_start, t_high;
        reg [15:0] captured_frame;
        begin
            forever begin
                // Wait for idle low
                wait (o_motor1 == 0);
                // Wait for start of frame
                wait (o_motor1 == 1);
                t_start = $time;
                captured_frame = 0;
                dshot_monitor_active = 1;
                
                for (i = 15; i >= 0; i = i - 1) begin
                    // We are at rising edge. Wait for falling edge to measure high time.
                    wait (o_motor1 == 0);
                    t_high = $time - t_start;
                    
                    // DSHOT150: 0 is ~2.5us (2500ns), 1 is ~5.0us (5000ns)
                    // Threshold: 3750ns
                    if (t_high > 3750) 
                        captured_frame[i] = 1;
                    else
                        captured_frame[i] = 0;
                        
                    // Wait for next bit rising edge (except last bit)
                    if (i > 0) begin
                        wait (o_motor1 == 1);
                        t_start = $time;
                    end
                end
                
                dshot_monitor_active = 0;
                $display("[DSHOT Monitor] Captured Frame: 0x%04x (Throttle: %0d, Telemetry: %b, CRC: %0x)", 
                    captured_frame, captured_frame[15:5], captured_frame[4], captured_frame[3:0]);
            end
        end
    endtask

    // PWM Stimulus Task
    task generate_pwm_pulse(input integer width_us);
        begin
            pwm_ch0 = 1;
            #(width_us * 1000); // Pulse width
            pwm_ch0 = 0;
            #(50 * 1000);       // Short wait
        end
    endtask

    // Simple reset + initialize
    // Support running individual tests via plusargs: +TEST_LED +TEST_MUX +TEST_DSHOT +TEST_PWM +TEST_VERSION +TEST_NEOPIXEL
    function bit run_test_from_plusarg(input string name);
        begin
            run_test_from_plusarg = $test$plusargs({"TEST_", name});
        end
    endfunction

    initial begin
        // Determine whether any TEST_* plusargs are present; if so run only those tests.
        bit any_test_plusarg;
        $dumpfile("tb_design.vcd");
        $dumpvars(0, design_tb);

        // Set verbose flag from plusarg +VERBOSE
        tb_verbose = $test$plusargs("VERBOSE");

        // Fork monitors
        fork
            monitor_dshot();
        join_none
        any_test_plusarg = $test$plusargs("TEST_LED") || $test$plusargs("TEST_MUX") || $test$plusargs("TEST_DSHOT") || $test$plusargs("TEST_PWM") || $test$plusargs("TEST_VERSION") || $test$plusargs("TEST_NEOPIXEL");

        // --- Test 1: LED Controller ---
        if (!any_test_plusarg || $test$plusargs("TEST_LED")) begin
            if (tb_verbose) $display("\n[TEST 1] LED Controller (per-LED writes)");
            // We'll set LED1, LED2, LED3 individually (bits 0,1,2) and read back after each write.
            for (led_i = 0; led_i < 3; led_i = led_i + 1) begin
                expected = (32'h1 << led_i);
                if (tb_verbose) $display("Setting LED %0d -> 0x%02x", led_i+1, expected[3:0]);
                spi_wb_transaction(0, 32'h0000, expected, tmp32);
                // Read back
                spi_wb_transaction(1, 32'h0000, 32'h0, readback);
                // concise result output
                if (readback[3:0] & expected[3:0]) begin
                    $display("TEST LED %0d: PASS", led_i+1);
                end else begin
                    $display("TEST LED %0d: FAIL (read=0x%01x expected=0x%01x)", led_i+1, readback[3:0], expected[3:0]);
                end
            end
        end

        // --- Test 2: Mux Controller ---
        if (!any_test_plusarg || $test$plusargs("TEST_MUX")) begin
            if (tb_verbose) $display("\n[TEST 2] Mux Switch to DSHOT");
            spi_wb_transaction(0, 32'h0400, 32'h00000001, tmp32); // Set Mux to 1 (DSHOT)
            spi_wb_transaction(1, 32'h0400, 32'h0, readback);
            $display("TEST MUX: Readback Mux register: 0x%08x", readback);
        end
        
        // --- Test 3: DSHOT Controller ---
        if (!any_test_plusarg || $test$plusargs("TEST_DSHOT")) begin
            if (tb_verbose) $display("\n[TEST 3] DSHOT Motor 1 Output");
            // Write 48 (Minimal Throttle 0) -> Frame 0x60? 48 << 1 = 96.
            spi_wb_transaction(0, 32'h0300, 32'h00000030, tmp32); 
            
            // Wait for DSHOT frame transmission
            #150000;
        end
        
        // --- Test 4: PWM Decoder ---
        if (!any_test_plusarg || $test$plusargs("TEST_PWM")) begin
            if (tb_verbose) $display("\n[TEST 4] PWM Decoder Input");
            // Generate a 1500us PWM pulse
            if (tb_verbose) $display("Generating 1500us PWM pulse on CH0...");
            generate_pwm_pulse(1500);
            
            // Read back Address 0x0200 (Channel 0)
            spi_wb_transaction(1, 32'h0200, 32'h0, readback);
            $display("TEST PWM: Readback PWM Ch0: %d (Expected ~1500)", readback);
            
            // 1480-1520 covers slight simulation clock mismatches (71.4MHz vs 72MHz)
            if (readback > 1450 && readback < 1550) 
                $display("TEST PWM: PASS (value %d)", readback);
            else begin
                $display("TEST PWM: FAIL (value %d)", readback);
                if (tb_verbose) $display("Debug: %x", readback);
            end
        end

        // --- Test 5: Version Module ---
        if (!any_test_plusarg || $test$plusargs("TEST_VERSION")) begin
            if (tb_verbose) $display("\n[TEST 5] Version Module Readback");
            // Read Address 0x0600
            spi_wb_transaction(1, 32'h0600, 32'h0, readback);
            if (readback == 32'hDEADBEEF) 
                $display("TEST VERSION: PASS");
            else 
                $display("TEST VERSION: FAIL (0x%x)", readback);
        end
        
        // --- Test 6: NeoPixel Controller ---
        if (!any_test_plusarg || $test$plusargs("TEST_NEOPIXEL")) begin
            if (tb_verbose) $display("\n[TEST 6] NeoPixel Controller (Address 0x0500)");
            // Write 0x00AABBCC to Pixel 0
            spi_wb_transaction(0, 32'h0500, 32'h00AABBCC, tmp32); 
            
            // Trigger Update (Write to offset 0x20)
            // Use fork/join to start monitor BEFORE the pulse could possibly be missed
            if (tb_verbose) $display("Monitoring NeoPixel Output...");
            fork
                monitor_neopixel(pixel_data);
                begin
                    #100; // Small delay
                    spi_wb_transaction(0, 32'h0520, 32'h00000001, tmp32);
                end
            join
            
            // Expected: 0xAABBCC (24 bits)
            // Note: sendPx now sends 24 bits (MSB first).
            if (pixel_data == 32'h00AABBCC) 
                $display("TEST NEOPIXEL: PASS (0x%06x)", pixel_data[23:0]);
            else 
                $display("TEST NEOPIXEL: FAIL (0x%06x)", pixel_data[23:0]);
        end

        // --- End of Tests ---
        #5000;
        $display("\ndesign_tb finished");
        $finish;
    end

    // NeoPixel Monitor Task
    task monitor_neopixel(output logic [31:0] data);
        integer bit_idx;
        time t_rise, t_fall, width;
        begin
            data = 0;
            // Wait for 24 bits (sendPx sends 24 bits now)
            for (bit_idx = 23; bit_idx >= 0; bit_idx = bit_idx - 1) begin
                // Wait for rising edge
                @(posedge o_neopixel);
                t_rise = $time;
                
                // Wait for falling edge
                @(negedge o_neopixel);
                t_fall = $time;
                
                width = t_fall - t_rise;
                
                // 72MHz T0H = 388ns, T1H = 791ns
                // Threshold ~600ns
                if (width > 600) begin // > 600ns
                    // It's a '1'
                    data[bit_idx] = 1'b1;
                end else begin
                    // It's a '0'
                    data[bit_idx] = 1'b0;
                end
            end
        end
    endtask

    // Include shared TB comms (send_spi_byte, spi_wb_transaction)
`include "src/tb/lib/tb_comm.sv"

endmodule

