/**
 * Tang9K Top Module
 *
 * System Architecture:
 * - All peripherals accessible via SPI slave interface, bridged to Wishbone bus using axis_wb_master.
 * - Peripherals: LED Controller, PWM Decoder, DSHOT Controller, NeoPixel Controller.
 * - USB UART Passthrough Bridge (hardware, bypasses Wishbone) for BLHeli ESC configuration.
 * - Serial/DSHOT mux register selects between passthrough mode and DSHOT motor control.
 * - NeoPixel stream timing verified for WS2812 at 72 MHz clock.
 *
 * Wishbone Address Map:
 *   0x0000-0x00FF: LED Controller
 *   0x0200-0x02FF: PWM Decoder
 *   0x0300-0x03FF: DSHOT Controller
 *   0x0400: Serial/DSHOT Mux Register (0=Passthrough, 1=DSHOT)
 *   0x0500-0x05FF: NeoPixel Controller
 *
 * BLHeli Passthrough Mode (mux_sel=0):
 *   PC/BLHeliSuite → USB UART (pins 19-20) → Hardware Bridge → Serial (pin 25) → ESC
 *   No software intervention needed - pure hardware passthrough at 115200 baud.
 *
 * DSHOT Mode (mux_sel=1):
 *   DSHOT controller drives motors, passthrough bridge disabled.
 *
 * See SYSTEM_OVERVIEW.md for full documentation.
 */

module tang9k_top (
    // System Clock and Reset
    input  logic i_sys_clk,
    input  logic i_rst,
    
    // SPI Slave Interface
    input  logic i_spi_clk,
    input  logic i_spi_cs_n,
    input  logic i_spi_mosi,
    output logic o_spi_miso,
    
    // LED Outputs
    output logic o_led0,
    output logic o_led1,
    output logic o_led2,
    output logic o_led3,
    
    // Button Inputs
    input  logic i_btn0,
    input  logic i_btn1,
    
    // UART Interface (optional debug/console)
    input  logic i_uart_rx,
    output logic o_uart_tx,
    output logic o_uart_irq,
    
    // USB UART Interface (for BLHeli passthrough to PC)
    input  logic i_usb_uart_rx,
    output logic o_usb_uart_tx,
    
    // Half-Duplex Serial (BLHeli ESC configuration)
    // inout  wire  serial, // Removed (Using motor pins)
    
    // PWM Decoder Inputs (6 channels)
    input  logic i_pwm_ch0,
    input  logic i_pwm_ch1,
    input  logic i_pwm_ch2,
    input  logic i_pwm_ch3,
    input  logic i_pwm_ch4,
    input  logic i_pwm_ch5,
    
    // DSHOT Motor Outputs (4 channels)
    // Bidirectional for Serial Passthrough support
    inout  wire o_motor1,
    inout  wire o_motor2,
    inout  wire o_motor3,
    inout  wire o_motor4,

    // NeoPixel Output
    output logic o_neopixel,
    
    // Status LEDs
    output logic o_status_led0,
    output logic o_status_led1,
    output logic o_status_led2
    ,
    // Expose PLL locked to top-level
    output logic o_pll_locked
);

    // Clock generation inside top: instantiate PLL and expose lock
    logic clk_72m;
    logic pll_locked;

    pll_27m_to_72m u_pll_72m (
        .clkin(i_sys_clk),
        .clk72(clk_72m),
        .locked(pll_locked)
    );

    assign o_pll_locked = pll_locked;

    coredesign u_design (
    .i_sys_clk    (clk_72m),
    .i_rst        (i_rst),
    .i_pll_locked (pll_locked),

    .i_spi_clk    (i_spi_clk),
    .i_spi_cs_n   (i_spi_cs_n),
    .i_spi_mosi   (i_spi_mosi),
    .o_spi_miso   (o_spi_miso),

    .o_led0       (o_led0),
    .o_led1       (o_led1),
    .o_led2       (o_led2),
    .o_led3       (o_led3),

    .i_btn0       (i_btn0),
    .i_btn1       (i_btn1),

    .i_uart_rx    (i_uart_rx),
    .o_uart_tx    (o_uart_tx),
    .o_uart_irq   (o_uart_irq),

    .i_usb_uart_rx(i_usb_uart_rx),
    .o_usb_uart_tx(o_usb_uart_tx),

    .i_pwm_ch0    (i_pwm_ch0),
    .i_pwm_ch1    (i_pwm_ch1),
    .i_pwm_ch2    (i_pwm_ch2),
    .i_pwm_ch3    (i_pwm_ch3),
    .i_pwm_ch4    (i_pwm_ch4),
    .i_pwm_ch5    (i_pwm_ch5),

    .o_motor1     (o_motor1),
    .o_motor2     (o_motor2),
    .o_motor3     (o_motor3),
    .o_motor4     (o_motor4),

    .o_neopixel   (o_neopixel),

    .o_status_led1(o_status_led1),
    .o_status_led2(o_status_led2)
);

    // Drive top-level status LED0 with PLL lock
    assign o_status_led0 = pll_locked;

endmodule
