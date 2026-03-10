/**
 * Arty S7-50 Top Module
 *
 * Board-specific wrapper for Arty S7-50 with:
 * - PLL: External (Vivado Clock Wizard provides 80 MHz)
 * - Reset generation (sync + POR)
 * - Heartbeat LED
 * - common_serv_spi_top (SERV + RAM + wb_spisystem)
 * - 32-bit debug bus for ILA
 * - SERV PC output for ILA debugging
 *
 * Same architecture as Tang Nano 20K - only PLL and pins differ.
 * JTAG via FTDI FT2232H for Vivado/OpenOCD debugging.
 */

module arty_s7_spi_copter_top #(
    parameter USB_BAUD_RATE = 115200,
    parameter SERIAL_BAUD_RATE = 19200
) (
    // System Clock (80 MHz from Vivado Clock Wizard)
    input  wire        clk_80m,
    
    // PLL Locked signal (from Clock Wizard)
    input  wire        pll_locked,
    
    // Reset Button (active-low, directly from board)
    input  wire        reset_n,
    
    // SPI Slave Interface
    input  wire        spi_clk,
    input  wire        spi_cs_n,
    input  wire        spi_mosi,
    output wire        spi_miso,
    
    // LED Outputs (accent LEDs on Arty S7)
    output wire        led0,
    output wire        led1,
    output wire        led2,
    output wire        led3,
    output wire        led_heartbeat,  // LED4 for heartbeat
    
    // USB UART Interface
    input  wire        usb_uart_rx,
    output wire        usb_uart_tx,
    
    // PWM Decoder Inputs (from Pmod or header)
    input  wire        pwm_ch0,
    input  wire        pwm_ch1,
    input  wire        pwm_ch2,
    input  wire        pwm_ch3,
    input  wire        pwm_ch4,
    input  wire        pwm_ch5,

    // DSHOT Motor Outputs (bidirectional for serial passthrough)
    inout  wire        motor1,
    inout  wire        motor2,
    inout  wire        motor3,
    inout  wire        motor4,
    
    // Debug outputs (directly accessible for ILA probing)
    (* mark_debug = "true" *) output wire [31:0] debug_gpio,
    (* mark_debug = "true" *) output wire [31:0] debug_pc,
    (* mark_debug = "true" *) output wire        debug_pc_valid
);

    // =========================================================================
    // Reset Synchronizer
    // =========================================================================
    reg [2:0] reset_sync;
    wire sys_reset;
    
    always @(posedge clk_80m or negedge reset_n) begin
        if (!reset_n) begin
            reset_sync <= 3'b111;
        end else if (!pll_locked) begin
            reset_sync <= 3'b111;
        end else begin
            reset_sync <= {reset_sync[1:0], 1'b0};
        end
    end
    
    assign sys_reset = reset_sync[2];

    // =========================================================================
    // Heartbeat LED (1 Hz blink)
    // 80 MHz / 40M = 2 Hz (toggle every 0.5s for 1 Hz blink)
    // =========================================================================
    reg [25:0] heartbeat_cnt;
    reg heartbeat_led;
    
    always @(posedge clk_80m) begin
        if (sys_reset) begin
            heartbeat_cnt <= 26'd0;
            heartbeat_led <= 1'b0;
        end else begin
            if (heartbeat_cnt >= 26'd39_999_999) begin  // 0.5s at 80MHz
                heartbeat_cnt <= 26'd0;
                heartbeat_led <= ~heartbeat_led;
            end else begin
                heartbeat_cnt <= heartbeat_cnt + 26'd1;
            end
        end
    end
    
    assign led_heartbeat = heartbeat_led;

    // =========================================================================
    // Unused LED (5th LED from common_serv_spi_top)
    // =========================================================================
    wire led_5_unused;
    wire neopixel_unused;  // NeoPixel not used on Arty S7

    // =========================================================================
    // System Integration (SERV + RAM + Peripherals)
    // Same module as Tang - 90% code sharing
    // =========================================================================
    common_serv_spi_top #(
        .USB_BAUD_RATE(USB_BAUD_RATE),
        .SERIAL_BAUD_RATE(SERIAL_BAUD_RATE)
    ) u_system (
        .clk(clk_80m),
        .rst(sys_reset),
        
        // SPI Slave Interface
        .spi_clk(spi_clk),
        .spi_cs_n(spi_cs_n),
        .spi_mosi(spi_mosi),
        .spi_miso(spi_miso),
        
        // LED Outputs
        .led_1(led0),
        .led_2(led1),
        .led_3(led2),
        .led_4(led3),
        .led_5(led_5_unused),
        
        // PWM Decoder Inputs
        .pwm_ch0(pwm_ch0),
        .pwm_ch1(pwm_ch1),
        .pwm_ch2(pwm_ch2),
        .pwm_ch3(pwm_ch3),
        .pwm_ch4(pwm_ch4),
        .pwm_ch5(pwm_ch5),
        
        // Motor Outputs
        .motor1(motor1),
        .motor2(motor2),
        .motor3(motor3),
        .motor4(motor4),
        
        // NeoPixel Output (not used on Arty S7)
        .neopixel(neopixel_unused),
        
        // Debug GPIO (32-bit for ILA)
        .debug_gpio(debug_gpio),
        
        // SERV Debug (for ILA - trace PC execution)
        .debug_pc(debug_pc),
        .debug_pc_valid(debug_pc_valid),
        
        // USB UART
        .usb_uart_rx(usb_uart_rx),
        .usb_uart_tx(usb_uart_tx),
        
        // GPIO Mux Control (firmware controlled via Wishbone, tie off external input)
        .gpio_mux_ctrl(3'b0)
    );

endmodule
