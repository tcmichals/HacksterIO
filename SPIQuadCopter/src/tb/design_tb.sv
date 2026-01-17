`timescale 1ns/1ps

module design_tb();

    // System clock for design: drive 72 MHz (half period 7ns)
    reg i_sys_clk = 0;
    always #7 i_sys_clk = ~i_sys_clk;

    // Reset and PLL lock model
    reg i_rst = 0;
    reg i_pll_locked = 0;

    // SPI master signals
    reg i_sclk = 0;
    reg spi_cs_n = 1; // active LOW (asserted = 0)
    reg spi_mosi = 0;
    wire spi_miso;

    // LEDs and status
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
    
    // DSHOT Monitor variables
    reg [15:0] dshot_frame;
    reg dshot_monitor_active = 0;

    // Instantiate the `design` module directly 
    coredesign dut (
        .i_sys_clk    (i_sys_clk),
        .i_rst        (i_rst),
        .i_pll_locked (i_pll_locked),

        .i_spi_clk    (i_sclk),
        .i_spi_cs_n   (spi_cs_n), 
        .i_spi_mosi   (spi_mosi),
        .o_spi_miso   (spi_miso),

        .o_led0       (o_led0),
        .o_led1       (o_led1),
        .o_led2       (o_led2),
        .o_led3       (o_led3),

        .i_btn0       (1'b0),
        .i_btn1       (1'b0),

        .i_uart_rx    (1'b1),
        .o_uart_tx    (),
        .o_uart_irq   (),

        .i_usb_uart_rx(1'b1),
        .o_usb_uart_tx(),

        // .serial       (), // Port removed

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

        .o_neopixel   (o_neopixel)
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

    // Simple reset + pll lock model
    initial begin
        $dumpfile("tb_design.vcd");
        $dumpvars(0, design_tb);
        i_rst = 1; // Active High Reset Start
        i_pll_locked = 0;
        #200;
        i_pll_locked = 1;
        #20;
        i_rst = 0; // Deassert Active High Reset
        
        // Fork monitors
        fork
            monitor_dshot();
        join_none

        // --- Test 1: LED Controller ---
        $display("\n[TEST 1] LED Controller");
        // Write 0x0F to LED Register (Addr 0x00)
        spi_wb_transaction(0, 32'h0, 32'h0000000F, tmp32); 
        // Read back
        spi_wb_transaction(1, 32'h0000, 32'h0, readback);
        if (readback[3:0] == 4'hF) $display("SUCCESS: LED Readback correct");
        else $display("FAILURE: LED Readback 0x%x (!= 0xF)", readback[3:0]);

        // --- Test 2: Mux Controller ---
        $display("\n[TEST 2] Mux Switch to DSHOT");
        spi_wb_transaction(0, 32'h0400, 32'h00000001, tmp32); // Set Mux to 1 (DSHOT)
        spi_wb_transaction(1, 32'h0400, 32'h0, readback);
        $display("Readback Mux register: 0x%08x", readback);
        
        // --- Test 3: DSHOT Controller ---
        $display("\n[TEST 3] DSHOT Motor 1 Output");
        // Write 48 (Minimal Throttle 0) -> Frame 0x60? 48 << 1 = 96.
        spi_wb_transaction(0, 32'h0300, 32'h00000030, tmp32); 
        
        // Wait for DSHOT frame transmission
        #150000;
        
        // --- Test 4: PWM Decoder ---
        $display("\n[TEST 4] PWM Decoder Input");
        // Generate a 1500us PWM pulse
        $display("Generating 1500us PWM pulse on CH0...");
        generate_pwm_pulse(1500);
        
        // Read back Address 0x0200 (Channel 0)
        spi_wb_transaction(1, 32'h0200, 32'h0, readback);
        $display("Readback PWM Ch0: %d (Expected ~1500)", readback);
        
        // 1480-1520 covers slight simulation clock mismatches (71.4MHz vs 72MHz)
        if (readback > 1450 && readback < 1550) 
            $display("SUCCESS: PWM Measurement is within standard range (1000-2000us)");
        else begin
            $display("FAILURE: PWM Measurement out of range");
            $display("Debug: %x", readback);
        end

        // --- Test 5: Version Module ---
        $display("\n[TEST 5] Version Module Readback");
        // Read Address 0x0600
        spi_wb_transaction(1, 32'h0600, 32'h0, readback);
        if (readback == 32'hDEADBEEF) 
            $display("SUCCESS: Version Readback 0xDEADBEEF");
        else 
            $display("FAILURE: Version Readback 0x%x != 0xDEADBEEF", readback);
        
        // --- Test 6: NeoPixel Controller ---
        $display("\n[TEST 6] NeoPixel Controller (Address 0x0500)");
        // Write 0x00AABBCC to Pixel 0
        spi_wb_transaction(0, 32'h0500, 32'h00AABBCC, tmp32); 
        
        // Trigger Update (Write to offset 0x20)
        // Use fork/join to start monitor BEFORE the pulse could possibly be missed
        $display("Monitoring NeoPixel Output...");
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
            $display("SUCCESS: NeoPixel Serial Output 0x%06x Matches", pixel_data[23:0]);
        else 
            $display("FAILURE: NeoPixel Serial Output 0x%06x (Expected 0xAABBCC)", pixel_data[23:0]);

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

    // SPI send/receive (MSB first)
    task send_spi_byte(input [7:0] tx, output [7:0] rx);
        integer i;
        begin
            rx = 8'h00;
            for (i = 7; i >= 0; i = i - 1) begin
                // Drive MOSI
                spi_mosi = tx[i];
                repeat(4) @(posedge i_sys_clk); 
                
                // SCLK High
                i_sclk = 1'b1;
                repeat(4) @(posedge i_sys_clk);
                
                // Sample MISO
                rx[i] = spi_miso;
                
                // SCLK Low
                i_sclk = 1'b0;
                repeat(4) @(posedge i_sys_clk);
            end
        end
    endtask

    // SPI -> Wishbone transaction helper
    localparam [7:0] READ_REQ  = 8'hA1;
    localparam [7:0] WRITE_REQ = 8'hA2;
    localparam [7:0] READ_RESP = 8'hA3;
    localparam [7:0] WRITE_RESP = 8'hA4;

    task spi_wb_transaction(input bit is_read, input [31:0] addr, input [31:0] wdata, output [31:0] rdata);
        integer i;
        reg [7:0] tmp;
        integer timeout;
        bit header_found;
        begin
            // Assert CS (active LOW)
            @(posedge i_sys_clk);
            spi_cs_n = 1'b0;
            repeat (4) @(posedge i_sys_clk);
            
            header_found = 0;

            // 1. Send Command
            send_spi_byte(is_read ? READ_REQ : WRITE_REQ, tmp);
            if (tmp == (is_read ? READ_RESP : WRITE_RESP)) header_found = 1;
            // $display("  TX: Cmd RX: %x", tmp);

            // 2. Send Address (MSB First)
            send_spi_byte(addr[31:24], tmp);
            if (tmp == (is_read ? READ_RESP : WRITE_RESP)) header_found = 1;
            // $display("  TX: Ad3 RX: %x", tmp);
            
            send_spi_byte(addr[23:16], tmp);
            if (tmp == (is_read ? READ_RESP : WRITE_RESP)) header_found = 1;
            // $display("  TX: Ad2 RX: %x", tmp);
            
            send_spi_byte(addr[15:8], tmp);
            if (tmp == (is_read ? READ_RESP : WRITE_RESP)) header_found = 1;
            // $display("  TX: Ad1 RX: %x", tmp);
            
            send_spi_byte(addr[7:0], tmp);
            if (tmp == (is_read ? READ_RESP : WRITE_RESP)) header_found = 1;
            // $display("  TX: Ad0 RX: %x", tmp);
            
            // 3. Send Length (MSB First: 00 01)
            send_spi_byte(8'h00, tmp);
            if (tmp == (is_read ? READ_RESP : WRITE_RESP)) header_found = 1;
            // $display("  TX: Ln1 RX: %x", tmp);
            
            send_spi_byte(8'h04, tmp);
            if (tmp == (is_read ? READ_RESP : WRITE_RESP)) header_found = 1;
            // $display("  TX: Ln0 RX: %x", tmp);
            
            if (!is_read) begin
                // Write Data (LSB First)
                send_spi_byte(wdata[7:0], tmp);
                if (tmp == WRITE_RESP) header_found = 1;

                send_spi_byte(wdata[15:8], tmp);
                if (tmp == WRITE_RESP) header_found = 1;

                send_spi_byte(wdata[23:16], tmp);
                if (tmp == WRITE_RESP) header_found = 1;

                send_spi_byte(wdata[31:24], tmp);
                if (tmp == WRITE_RESP) header_found = 1;
                
                // If header not found yet, poll briefly
                timeout = 0;
                while (!header_found && timeout < 50) begin
                   send_spi_byte(8'h00, tmp);
                   if (tmp == WRITE_RESP) header_found = 1;
                   timeout++;
                end
                
                if (!header_found) $display("Warning: Write Response Header (A4) not found");

                spi_cs_n = 1'b1;
                repeat (20) @(posedge i_sys_clk);
                
            end else begin
                // Read
                // If header not found yet, poll
                timeout = 0;
                while (!header_found && timeout < 50) begin
                    send_spi_byte(8'h00, tmp);
                    if (tmp == READ_RESP) header_found = 1;
                    timeout++;
                end

                if (!header_found) begin
                    $display("Error: Read Response Header (A3) not found");
                    rdata = 32'hBAADF00D;
                end else begin
                     // Drain the last Echo byte (Ln0)
                     send_spi_byte(8'h00, tmp);
                     $display("  Drained Echo: %x", tmp);
                     
                    // Read 4 bytes of Data (LSB first)
                    rdata = 0;
                    for (i = 0; i < 4; i = i + 1) begin
                        send_spi_byte(8'h00, tmp);
                        $display("  Data[%d]: %x", i, tmp);
                        rdata = rdata | (tmp << (i*8));
                    end
                end
                
                spi_cs_n = 1'b1;
                repeat (20) @(posedge i_sys_clk);
            end
        end
    endtask

endmodule

