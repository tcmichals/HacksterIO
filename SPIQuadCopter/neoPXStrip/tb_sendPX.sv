`timescale 1ns / 1ps

// Define LED_TYPE here - change to 1 for SK6812, 0 for WS2812
`define TEST_SK6812 0

module tb_sendPx;

    // --- Test Parameters ---
    localparam CLK_FREQ_HZ = 72_000_000;
    localparam CLK_PERIOD  = 13.888; 
    localparam IS_SK6812 = (`TEST_SK6812 != 0);
    
    // Timing Specs
    localparam real WS2812_T0H = 400.0;
    localparam real WS2812_T1H = 800.0;
    localparam real SK6812_T0H = 300.0;
    localparam real SK6812_T1H = 600.0;
    localparam real TOLERANCE  = 150.0;

    // --- Signals ---
    reg         clk;
    reg         rst;
    reg [31:0]  s_axis_tdata;
    reg         s_axis_tvalid;
    reg         s_axis_tlast;
    wire        s_axis_tready;
    wire        o_serial;

    // --- Verification Variables ---
    integer error_count = 0;
    reg [31:0] captured_pixel;
    reg [7:0]  c_g, c_r, c_b, c_w; 
    reg [7:0]  e_g, e_r, e_b, e_w; 
    integer    bit_count = 0;
    integer    pixel_count = 0;
    realtime   rising_edge, pulse_width;
    realtime   T0H_NOM, T1H_NOM;  // Current test's nominal values
    integer    bits_to_send;      // 24 for WS2812, 32 for SK6812
    string     led_type_str;

    // --- UUT Instance - Generated based on TEST_SK6812 ---
    generate
        if (IS_SK6812) begin : sk6812_gen
            sendPx_axis_flexible #(
                .CLK_FREQ_HZ(CLK_FREQ_HZ),
                .LED_TYPE("SK6812")
            ) uut (
                .axis_aclk(clk),
                .axis_reset(rst),
                .s_axis_tdata(s_axis_tdata),
                .s_axis_tvalid(s_axis_tvalid),
                .s_axis_tlast(s_axis_tlast),
                .s_axis_tready(s_axis_tready),
                .o_serial(o_serial)
            );
        end else begin : ws2812_gen
            sendPx_axis_flexible #(
                .CLK_FREQ_HZ(CLK_FREQ_HZ),
                .LED_TYPE("WS2812")
            ) uut (
                .axis_aclk(clk),
                .axis_reset(rst),
                .s_axis_tdata(s_axis_tdata),
                .s_axis_tvalid(s_axis_tvalid),
                .s_axis_tlast(s_axis_tlast),
                .s_axis_tready(s_axis_tready),
                .o_serial(o_serial)
            );
        end
    endgenerate

    // --- Clock Generation ---
    always #(CLK_PERIOD/2) clk = (clk === 1'b0);

    initial begin
        // VCD dumping disabled to minimize USB disk I/O
        // $dumpfile("sendPx_waves.vcd");
        // $dumpvars(0, tb_sendPx);
    end

    // --- Timing & Bit Collector with Dynamic Thresholds ---
    always @(posedge o_serial) begin
        rising_edge = $realtime;
        @(negedge o_serial);
        pulse_width = $realtime - rising_edge;
        
        // Determine bit value and validate timing based on current LED type
        if (pulse_width > ((T0H_NOM + T1H_NOM) / 2)) begin
            captured_pixel[31 - bit_count] = 1'b1;
            if (pulse_width < (T1H_NOM - TOLERANCE) || pulse_width > (T1H_NOM + TOLERANCE)) begin
                $display("[TIME ERR] Bit %0d: Logic 1 pulse width %.1f ns (expected %.1f ± %.1f ns)", 
                    bit_count, pulse_width, T1H_NOM, TOLERANCE);
                error_count = error_count + 1;
            end
        end else begin
            captured_pixel[31 - bit_count] = 1'b0;
            if (pulse_width < (T0H_NOM - TOLERANCE) || pulse_width > (T0H_NOM + TOLERANCE)) begin
                $display("[TIME ERR] Bit %0d: Logic 0 pulse width %.1f ns (expected %.1f ± %.1f ns)", 
                    bit_count, pulse_width, T0H_NOM, TOLERANCE);
                error_count = error_count + 1;
            end
        end
        
        bit_count = bit_count + 1;
    end

    // --- Comprehensive Verification Task ---
    task verify_pixel(input [31:0] expected_data);
        begin
            {e_g, e_r, e_b, e_w} = expected_data;
            wait(bit_count == bits_to_send);
            
            // For WS2812 (24-bit), only check RGB channels
            if (bits_to_send == 24) begin
                captured_pixel = captured_pixel & 32'hFFFFFF00;  // Mask to 24 bits
            end
            
            {c_g, c_r, c_b, c_w} = captured_pixel;

            $display("\n[CHECK] Pixel %0d Verified at Time %0t", pixel_count, $realtime);
            $display("        Channel | Expected | Captured | Status");
            $display("        --------|----------|----------|-------");
            $display("        GREEN   |    %02h    |    %02h    | %s", e_g, c_g, (e_g === c_g) ? "PASS" : "FAIL");
            $display("        RED     |    %02h    |    %02h    | %s", e_r, c_r, (e_r === c_r) ? "PASS" : "FAIL");
            $display("        BLUE    |    %02h    |    %02h    | %s", e_b, c_b, (e_b === c_b) ? "PASS" : "FAIL");
            if (bits_to_send == 32)
                $display("        WHITE   |    %02h    |    %02h    | %s", e_w, c_w, (e_w === c_w) ? "PASS" : "FAIL");

            // For WS2812, only compare RGB (24 bits); for SK6812, compare all 32 bits
            if (bits_to_send == 24) begin
                if (captured_pixel[31:8] !== expected_data[31:8]) begin
                    error_count = error_count + 1;
                    $display("        Data mismatch: expected 0x%06h, got 0x%06h", expected_data[31:8], captured_pixel[31:8]);
                end
            end else begin
                if (captured_pixel !== expected_data) begin
                    error_count = error_count + 1;
                    $display("        Data mismatch: expected 0x%08h, got 0x%08h", expected_data, captured_pixel);
                end
            end
            
            bit_count = 0;
            pixel_count = pixel_count + 1;
            captured_pixel = 0;
        end
    endtask

    // --- Main Test Procedure ---
    initial begin
        // Set LED type string for display
        led_type_str = IS_SK6812 ? "SK6812" : "WS2812";
        
        // Set timing thresholds based on LED type
        if (IS_SK6812) begin
            T0H_NOM = SK6812_T0H;
            T1H_NOM = SK6812_T1H;
            bits_to_send = 32;
        end else begin
            T0H_NOM = WS2812_T0H;
            T1H_NOM = WS2812_T1H;
            bits_to_send = 24;
        end
        
        $display("\n========================================");
        $display("  Testing %s (%0d-bit mode)", led_type_str, bits_to_send);
        $display("========================================");
        
        clk = 0; rst = 1; s_axis_tdata = 0; s_axis_tvalid = 0; s_axis_tlast = 0;
        #(CLK_PERIOD * 10);
        rst = 0;
        #(CLK_PERIOD * 5);

        // Test Case 1: Complex Color
        $display("\nTest 1: Complex Color (0xAABBCCDD)");
        fork
            begin
                wait(s_axis_tready); @(posedge clk);
                s_axis_tdata <= 32'hAABBCCDD; s_axis_tvalid <= 1; s_axis_tlast <= 1;
                @(posedge clk);
                while (!s_axis_tready) @(posedge clk);
                s_axis_tvalid <= 0; s_axis_tlast <= 0;
            end
            verify_pixel(32'hAABBCCDD);
        join

        // Test Case 2: Primary Colors (Red)
        $display("\nTest 2: Primary Color - Red (0x00FF0000)");
        fork
            begin
                wait(s_axis_tready); @(posedge clk);
                s_axis_tdata <= 32'h00FF0000; s_axis_tvalid <= 1; s_axis_tlast <= 1;
                @(posedge clk);
                while (!s_axis_tready) @(posedge clk);
                s_axis_tvalid <= 0; s_axis_tlast <= 0;
            end
            verify_pixel(32'h00FF0000);
        join

        // Test Case 3: Primary Colors (Green)
        $display("\nTest 3: Primary Color - Green (0xFF000000)");
        fork
            begin
                wait(s_axis_tready); @(posedge clk);
                s_axis_tdata <= 32'hFF000000; s_axis_tvalid <= 1; s_axis_tlast <= 1;
                @(posedge clk);
                while (!s_axis_tready) @(posedge clk);
                s_axis_tvalid <= 0; s_axis_tlast <= 0;
            end
            verify_pixel(32'hFF000000);
        join

        // Test Case 4: Primary Colors (Blue)
        $display("\nTest 4: Primary Color - Blue (0x0000FF00)");
        fork
            begin
                wait(s_axis_tready); @(posedge clk);
                s_axis_tdata <= 32'h0000FF00; s_axis_tvalid <= 1; s_axis_tlast <= 1;
                @(posedge clk);
                while (!s_axis_tready) @(posedge clk);
                s_axis_tvalid <= 0; s_axis_tlast <= 0;
            end
            verify_pixel(32'h0000FF00);
        join

        // Test Case 5: White Channel Only (SK6812 only)
        if (IS_SK6812) begin
            $display("\nTest 5: White Channel Only (0x000000FF)");
            fork
                begin
                    wait(s_axis_tready); @(posedge clk);
                    s_axis_tdata <= 32'h000000FF; s_axis_tvalid <= 1; s_axis_tlast <= 1;
                    @(posedge clk);
                    while (!s_axis_tready) @(posedge clk);
                    s_axis_tvalid <= 0; s_axis_tlast <= 0;
                end
                verify_pixel(32'h000000FF);
            join
        end

        // Test Case 6: Multi-Pixel Sequence (2 pixels)
        $display("\nTest 6: Multi-Pixel Sequence");
        fork
            begin
                wait(s_axis_tready); @(posedge clk);
                s_axis_tdata <= 32'hFF0000AA; s_axis_tvalid <= 1; s_axis_tlast <= 0;
                @(posedge clk);
                while (!s_axis_tready) @(posedge clk);
                s_axis_tvalid <= 0;
                
                wait(s_axis_tready); @(posedge clk);
                s_axis_tdata <= 32'h00FF00BB; s_axis_tvalid <= 1; s_axis_tlast <= 1;
                @(posedge clk);
                while (!s_axis_tready) @(posedge clk);
                s_axis_tvalid <= 0; s_axis_tlast <= 0;
            end
            begin
                verify_pixel(32'hFF0000AA);
                verify_pixel(32'h00FF00BB);
            end
        join

        // Wait for Latch after last pixel (shortened)
        #30000;
        
        $display("\n========================================");
        if (error_count == 0) 
            $display("  %s: ALL TESTS PASSED", led_type_str);
        else 
            $display("  %s: FAILED (%0d Errors)", led_type_str, error_count);
        $display("========================================\n");
        $finish;
    end

endmodule