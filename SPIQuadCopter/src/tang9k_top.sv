/**
 * Tang Nano 9K Top Module
 *
 * Board-specific wrapper for Tang Nano 9K with:
 * - PLL: 27 MHz input -> 54 MHz system clock
 * - Reset generation (POR + optional button)
 * - Heartbeat LED (LED6, 1 Hz blink)
 * - common_serv_spi_top (SERV + RAM + wb_spisystem)
 *
 * See docs/SYSTEM_OVERVIEW.md for architecture details.
 *
 * GPIO Mux Control:
 * - Can be controlled by external GPIO pins for testing/development
 * - [0] = MSP mode (0=DSHOT, 1=UART passthrough)
 * - [2:1] = Motor channel select (0-3)
 */

module tang9k_top #(
    parameter USB_BAUD_RATE = 115200,
    parameter SERIAL_BAUD_RATE = 19200
) (
    // System Clock (27 MHz crystal)
    input  logic i_clk,
    
    // Optional Reset Button (if available)
    input  logic i_reset_n,
    
    // SPI Slave Interface
    input  logic i_spi_clk,
    input  logic i_spi_cs_n,
    input  logic i_spi_mosi,
    output logic o_spi_miso,
    
    // LED Outputs
    output logic o_led_1,
    output logic o_led_2,
    output logic o_led_3,
    output logic o_led_4,
    output logic o_led_5,
    output logic o_led_6,    // Heartbeat LED
    
    // USB UART Interface
    input  logic i_usb_uart_rx,
    output logic o_usb_uart_tx,
    
    // PWM Decoder Inputs (6 channels)
    input  logic i_pwm_ch0,
    input  logic i_pwm_ch1,
    input  logic i_pwm_ch2,
    input  logic i_pwm_ch3,
    input  logic i_pwm_ch4,
    input  logic i_pwm_ch5,

    // DSHOT Motor Outputs (4 channels, bidirectional for serial passthrough)
    inout  wire  o_motor1,
    inout  wire  o_motor2,
    inout  wire  o_motor3,
    inout  wire  o_motor4,

    // NeoPixel Output
    output logic o_neopixel,

    // Debug GPIO pins
    output logic o_debug_0,
    output logic o_debug_1,
    output logic o_debug_2,
    
    // GPIO Mux Control (optional external override)
    input  logic i_mux_msp_mode,   // MSP/passthrough mode
    input  logic i_mux_ch0,        // Motor channel bit 0
    input  logic i_mux_ch1         // Motor channel bit 1
);

    // =========================================================================
    // PLL: 27 MHz -> 54 MHz
    // =========================================================================
    logic clk_72m;
    logic pll_locked;
    
    pll_gowin_27m u_pll (
        .clkin(i_clk),
        .clkout(clk_72m),
        .locked(pll_locked)
    );

    // =========================================================================
    // Synchronize PLL lock signal to input clock domain
    // =========================================================================
    logic pll_locked_meta = 1'b0;
    logic pll_locked_sync = 1'b0;
    
    always_ff @(posedge i_clk) begin
        pll_locked_meta <= pll_locked;
        pll_locked_sync <= pll_locked_meta;
    end

    // =========================================================================
    // Power-On Reset Generation (input clock domain)
    // Combines PLL lock + optional reset button
    // =========================================================================
    logic [19:0] rst_cnt_27m;  // 2^20 / 27MHz = ~38ms reset
    logic por_reset_27m;
    logic reset_req_27m;
    
    // Reset request: PLL not locked OR button pressed (active-low)
    assign reset_req_27m = !pll_locked_sync | !i_reset_n;
    
    always_ff @(posedge i_clk) begin
        if (reset_req_27m) begin
            rst_cnt_27m <= 20'd0;
            por_reset_27m <= 1'b1;
        end else begin
            if (rst_cnt_27m < 20'hFFFFF) begin
                rst_cnt_27m <= rst_cnt_27m + 20'd1;
                por_reset_27m <= 1'b1;
            end else begin
                por_reset_27m <= 1'b0;
            end
        end
    end
    
    // =========================================================================
    // Synchronize reset to system clock domain (54 MHz)
    // =========================================================================
    logic sys_reset_meta = 1'b1;
    logic sys_reset_sync = 1'b1;
    
    always_ff @(posedge clk_72m or posedge por_reset_27m) begin
        if (por_reset_27m) begin
            sys_reset_meta <= 1'b1;
            sys_reset_sync <= 1'b1;
        end else begin
            sys_reset_meta <= 1'b0;
            sys_reset_sync <= sys_reset_meta;
        end
    end

    // =========================================================================
    // Heartbeat LED (1 Hz blink on LED6, runs on 27 MHz)
    // =========================================================================
    logic [24:0] heartbeat_cnt_27m;
    logic heartbeat_led_27m;
    
    always_ff @(posedge i_clk) begin
        if (!pll_locked) begin
            heartbeat_cnt_27m <= 25'd0;
            heartbeat_led_27m <= 1'b0;
        end else begin
            if (heartbeat_cnt_27m >= 25'd13_499_999) begin  // 0.5s at 27MHz
                heartbeat_cnt_27m <= 25'd0;
                heartbeat_led_27m <= ~heartbeat_led_27m;  // Toggle every 0.5s
            end else begin
                heartbeat_cnt_27m <= heartbeat_cnt_27m + 25'd1;
            end
        end
    end
    
    assign o_led_6 = ~heartbeat_led_27m;  // Active-low LED

    // =========================================================================
    // Debug GPIO Signals (32-bit from core, only lower 3 bits routed to pins)
    // =========================================================================
    logic [31:0] debug_gpio;
    
    // Route USB UART signals to debug pins for logic analyzer
    //   debug_0: firmware-controlled (heartbeat)
    //   debug_1: USB RX (data FROM PC to FPGA)
    //   debug_2: USB TX (data FROM FPGA to PC)
    assign o_debug_0 = debug_gpio[0];
    assign o_debug_1 = i_usb_uart_rx;  // USB RX line
    assign o_debug_2 = o_usb_uart_tx;  // USB TX line

    // =========================================================================
    // System Integration (SERV + RAM + Peripherals)
    // =========================================================================
    common_serv_spi_top #(
        .USB_BAUD_RATE(USB_BAUD_RATE),
        .SERIAL_BAUD_RATE(SERIAL_BAUD_RATE)
    ) u_system (
        .clk(clk_72m),
        .rst(sys_reset_sync),
        
        // SPI Slave Interface
        .spi_clk(i_spi_clk),
        .spi_cs_n(i_spi_cs_n),
        .spi_mosi(i_spi_mosi),
        .spi_miso(o_spi_miso),
        
        // LED Outputs (1-5)
        .led_1(o_led_1),
        .led_2(o_led_2),
        .led_3(o_led_3),
        .led_4(o_led_4),
        .led_5(o_led_5),
        
        // PWM Decoder Inputs
        .pwm_ch0(i_pwm_ch0),
        .pwm_ch1(i_pwm_ch1),
        .pwm_ch2(i_pwm_ch2),
        .pwm_ch3(i_pwm_ch3),
        .pwm_ch4(i_pwm_ch4),
        .pwm_ch5(i_pwm_ch5),
        
        // Motor Outputs
        .motor1(o_motor1),
        .motor2(o_motor2),
        .motor3(o_motor3),
        .motor4(o_motor4),
        
        // NeoPixel Output
        .neopixel(o_neopixel),
        
        // Debug GPIO
        .debug_gpio(debug_gpio),
        
        // SERV Debug (not routed on Tang 9K - limited pins)
        .debug_pc(),
        .debug_pc_valid(),
        
        // USB UART
        .usb_uart_rx(i_usb_uart_rx),
        .usb_uart_tx(o_usb_uart_tx),
        
        // GPIO Mux Control
        .gpio_mux_ctrl({i_mux_ch1, i_mux_ch0, i_mux_msp_mode})
    );

endmodule
