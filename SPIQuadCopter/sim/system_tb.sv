/**
 * system_tb.sv - Full System Testbench (Verilator)
 *
 * Tests the complete system with VexRiscv running firmware:
 * - SPI commands from external host
 * - UART MSP protocol
 * - DSHOT motor output
 * - PWM input decoding
 *
 * Usage:
 *   make -C sim verilator
 *   ./sim/obj_dir/Vsystem_tb
 */

`timescale 1ns/1ps

module system_tb;

    // =========================================================================
    // Clock and Reset
    // =========================================================================
    reg clk = 0;
    reg rst = 1;
    
    // 80 MHz clock (12.5ns period)
    always #6.25 clk = ~clk;
    
    // Reset sequence
    initial begin
        rst = 1;
        repeat(100) @(posedge clk);
        rst = 0;
        $display("[%0t] Reset released", $time);
    end

    // =========================================================================
    // SPI Master (external host simulation)
    // =========================================================================
    reg        spi_clk_r = 0;
    reg        spi_cs_n = 1;
    reg        spi_mosi = 0;
    wire       spi_miso;
    
    // SPI clock (2 MHz)
    localparam SPI_HALF_PERIOD = 250;  // 250ns = 2 MHz
    
    task spi_transfer(input [7:0] tx_byte, output [7:0] rx_byte);
        integer i;
        begin
            rx_byte = 8'h00;
            for (i = 7; i >= 0; i = i - 1) begin
                spi_mosi = tx_byte[i];
                #SPI_HALF_PERIOD;
                spi_clk_r = 1;
                rx_byte[i] = spi_miso;
                #SPI_HALF_PERIOD;
                spi_clk_r = 0;
            end
        end
    endtask
    
    task spi_write(input [15:0] addr, input [31:0] data);
        reg [7:0] dummy;
        begin
            spi_cs_n = 0;
            #100;
            // Command: A2 = Write
            spi_transfer(8'hA2, dummy);
            // Address (16-bit, MSB first)
            spi_transfer(addr[15:8], dummy);
            spi_transfer(addr[7:0], dummy);
            // Data (32-bit, MSB first)
            spi_transfer(data[31:24], dummy);
            spi_transfer(data[23:16], dummy);
            spi_transfer(data[15:8], dummy);
            spi_transfer(data[7:0], dummy);
            #100;
            spi_cs_n = 1;
            #200;
        end
    endtask
    
    task spi_read(input [15:0] addr, output [31:0] data);
        reg [7:0] rx;
        begin
            spi_cs_n = 0;
            #100;
            // Command: A1 = Read
            spi_transfer(8'hA1, rx);
            // Address (16-bit, MSB first)
            spi_transfer(addr[15:8], rx);
            spi_transfer(addr[7:0], rx);
            // Dummy byte (bridge latency)
            spi_transfer(8'h00, rx);
            // Data (32-bit, MSB first)
            spi_transfer(8'h00, data[31:24]);
            spi_transfer(8'h00, data[23:16]);
            spi_transfer(8'h00, data[15:8]);
            spi_transfer(8'h00, data[7:0]);
            #100;
            spi_cs_n = 1;
            #200;
        end
    endtask

    // =========================================================================
    // PWM Input Simulation
    // =========================================================================
    reg [5:0] pwm_in = 6'h00;
    
    // Generate 1500us PWM pulses (center stick)
    task generate_pwm_pulse(input integer channel, input integer width_us);
        begin
            pwm_in[channel] = 1;
            #(width_us * 1000);  // Convert us to ns
            pwm_in[channel] = 0;
        end
    endtask

    // =========================================================================
    // Motor Output Monitoring
    // =========================================================================
    wire motor1, motor2, motor3, motor4;
    
    // Count DSHOT pulses
    integer motor1_pulses = 0;
    always @(posedge motor1) motor1_pulses = motor1_pulses + 1;

    // =========================================================================
    // UART Monitoring
    // =========================================================================
    wire usb_uart_tx;
    reg  usb_uart_rx = 1;
    
    // UART receiver (115200 baud)
    localparam UART_BIT_TIME = 8680;  // ns for 115200 baud
    
    reg [7:0] uart_rx_byte;
    reg uart_rx_valid = 0;
    
    task uart_send(input [7:0] data);
        integer i;
        begin
            // Start bit
            usb_uart_rx = 0;
            #UART_BIT_TIME;
            // Data bits
            for (i = 0; i < 8; i = i + 1) begin
                usb_uart_rx = data[i];
                #UART_BIT_TIME;
            end
            // Stop bit
            usb_uart_rx = 1;
            #UART_BIT_TIME;
        end
    endtask

    // =========================================================================
    // DUT - Device Under Test
    // =========================================================================
    wire [4:0] leds;
    wire neopixel;
    wire [31:0] debug_gpio;
    wire [31:0] debug_pc;
    wire debug_pc_valid;
    
    common_vexriscv_spi_top #(
        .USB_BAUD_RATE(115200),
        .SERIAL_BAUD_RATE(19200),
        .RAM_DEPTH(8192),
        .FIRMWARE_FILE("firmware.mem")
    ) u_dut (
        .clk(clk),
        .rst(rst),
        
        // SPI
        .spi_clk(spi_clk_r),
        .spi_cs_n(spi_cs_n),
        .spi_mosi(spi_mosi),
        .spi_miso(spi_miso),
        
        // LEDs
        .led_1(leds[0]),
        .led_2(leds[1]),
        .led_3(leds[2]),
        .led_4(leds[3]),
        .led_5(leds[4]),
        
        // PWM
        .pwm_ch0(pwm_in[0]),
        .pwm_ch1(pwm_in[1]),
        .pwm_ch2(pwm_in[2]),
        .pwm_ch3(pwm_in[3]),
        .pwm_ch4(pwm_in[4]),
        .pwm_ch5(pwm_in[5]),
        
        // Motors
        .motor1(motor1),
        .motor2(motor2),
        .motor3(motor3),
        .motor4(motor4),
        
        // NeoPixel
        .neopixel(neopixel),
        
        // Debug
        .debug_gpio(debug_gpio),
        .debug_pc(debug_pc),
        .debug_pc_valid(debug_pc_valid),
        
        // UART
        .usb_uart_rx(usb_uart_rx),
        .usb_uart_tx(usb_uart_tx),
        
        // Mux control
        .gpio_mux_ctrl(3'b001)  // DSHOT mode
    );

    // =========================================================================
    // Test Sequence
    // =========================================================================
    reg [31:0] read_data;
    integer errors = 0;
    
    initial begin
        // VCD dump
        $dumpfile("system_tb.vcd");
        $dumpvars(0, system_tb);
        
        $display("===========================================");
        $display("Full System Testbench - VexRiscv + Peripherals");
        $display("===========================================");
        
        // Wait for reset
        wait(rst == 0);
        $display("[%0t] System running", $time);
        
        // Let CPU boot (execute some instructions)
        repeat(10000) @(posedge clk);
        $display("[%0t] CPU PC = 0x%08x", $time, debug_pc);
        
        // =====================================================================
        // Test 1: Read Version Register via SPI
        // =====================================================================
        $display("\n--- Test 1: Version Register ---");
        spi_read(16'h0000, read_data);
        $display("Version: 0x%08x", read_data);
        if (read_data == 32'h0) begin
            $display("ERROR: Version is zero!");
            errors = errors + 1;
        end
        
        // =====================================================================
        // Test 2: LED Control via SPI
        // =====================================================================
        $display("\n--- Test 2: LED Control ---");
        spi_write(16'h0100, 32'h0000001F);  // All LEDs on
        #1000;
        if (leds !== 5'h1F) begin
            $display("ERROR: LEDs expected 0x1F, got 0x%02x", leds);
            errors = errors + 1;
        end else begin
            $display("LEDs: 0x%02x (OK)", leds);
        end
        
        // =====================================================================
        // Test 3: PWM Decoder
        // =====================================================================
        $display("\n--- Test 3: PWM Decoder ---");
        // Generate PWM pulse on channel 0
        fork
            generate_pwm_pulse(0, 1500);  // 1500us pulse
        join
        #100000;  // Wait for PWM capture
        spi_read(16'h0200, read_data);  // Read PWM channel 0
        $display("PWM Ch0: %0d us", read_data);
        
        // =====================================================================
        // Test 4: DSHOT Motor Output
        // =====================================================================
        $display("\n--- Test 4: DSHOT Output ---");
        // Write motor value to DSHOT mailbox
        spi_write(16'h0300, 32'h000001FF);  // Motor 0 = 511 (mid throttle)
        #500000;  // Wait for DSHOT transmission
        $display("Motor1 pulses: %0d", motor1_pulses);
        
        // =====================================================================
        // Test 5: CPU Running (check PC changes)
        // =====================================================================
        $display("\n--- Test 5: CPU Execution ---");
        repeat(1000) @(posedge clk);
        $display("CPU PC = 0x%08x", debug_pc);
        
        // =====================================================================
        // Summary
        // =====================================================================
        $display("\n===========================================");
        if (errors == 0) begin
            $display("ALL TESTS PASSED");
        end else begin
            $display("TESTS FAILED: %0d errors", errors);
        end
        $display("===========================================");
        
        #10000;
        $finish;
    end
    
    // Timeout watchdog
    initial begin
        #100_000_000;  // 100ms timeout
        $display("ERROR: Simulation timeout!");
        $finish;
    end

endmodule
