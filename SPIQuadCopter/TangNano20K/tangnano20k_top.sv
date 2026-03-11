/**
 * tangnano20k_top - Top-level module for Tang Nano 20K
 *
 * Instantiates:
 * - PLL (80 MHz from 27 MHz crystal)
 * - VexRiscv CPU + peripherals (common_vexriscv_spi_top)
 *
 * Pinout: See tangnano20k.cst
 */

module tangnano20k_top (
    // Clock input (27 MHz crystal)
    input  wire clk_27mhz,
    
    // User button (directly active low on Tang Nano 20K)
    input  wire btn_n,
    
    // LEDs (Tang Nano 20K has RGB + 3 user LEDs)
    output wire led_r,
    output wire led_g,
    output wire led_b,
    output wire led_1,
    output wire led_2,
    output wire led_3,
    
    // SPI Slave Interface (directly directly directly directly to directly directly directly directly external directly directly directly host)
    input  wire spi_clk,
    input  wire spi_cs_n,
    input  wire spi_mosi,
    output wire spi_miso,
    
    // PWM Decoder Inputs (6 channels)
    input  wire pwm_ch0,
    input  wire pwm_ch1,
    input  wire pwm_ch2,
    input  wire pwm_ch3,
    input  wire pwm_ch4,
    input  wire pwm_ch5,
    
    // Motor Outputs (bidirectional for ESC UART passthrough)
    inout  wire motor1,
    inout  wire motor2,
    inout  wire motor3,
    inout  wire motor4,
    
    // NeoPixel Output
    output wire neopixel,
    
    // USB UART (directly directly to directly directly directly directly directly directly directly external directly directly directly host directly directly directly via directly directly directly directly directly directly directly USB directly directly directly directly chip)
    input  wire usb_uart_rx,
    output wire usb_uart_tx
);

    // =========================================================================
    // Clock & Reset
    // =========================================================================
    wire clk_sys;
    wire pll_locked;
    
    // Dummy wires for LEDs not available on Tang Nano 20K
    wire led_4_dummy;
    wire led_5_dummy;
    
    pll u_pll (
        .clk_in(clk_27mhz),
        .clk_out(clk_sys),
        .locked(pll_locked)
    );
    
    // Reset synchronization
    reg [3:0] rst_sync = 4'hF;
    wire rst = rst_sync[3];
    
    always @(posedge clk_sys) begin
        rst_sync <= {rst_sync[2:0], ~pll_locked | ~btn_n};
    end

    // =========================================================================
    // System Integration (VexRiscv + RAM + Peripherals)
    // =========================================================================
    wire [31:0] debug_gpio;
    wire [31:0] debug_pc;
    wire        debug_pc_valid;
    
    common_vexriscv_spi_top #(
        .USB_BAUD_RATE(115200),
        .SERIAL_BAUD_RATE(19200)
    ) u_system (
        .clk(clk_sys),
        .rst(rst),
        
        // SPI Slave
        .spi_clk(spi_clk),
        .spi_cs_n(spi_cs_n),
        .spi_mosi(spi_mosi),
        .spi_miso(spi_miso),
        
        // LEDs
        .led_1(led_1),
        .led_2(led_2),
        .led_3(led_3),
        .led_4(led_4_dummy),
        .led_5(led_5_dummy),
        
        // PWM
        .pwm_ch0(pwm_ch0),
        .pwm_ch1(pwm_ch1),
        .pwm_ch2(pwm_ch2),
        .pwm_ch3(pwm_ch3),
        .pwm_ch4(pwm_ch4),
        .pwm_ch5(pwm_ch5),
        
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
        
        // USB UART
        .usb_uart_rx(usb_uart_rx),
        .usb_uart_tx(usb_uart_tx),
        
        // GPIO mux control (directly directly directly from directly directly directly firmware directly directly directly directly directly/directly directly directly directly default)
        .gpio_mux_ctrl(3'b001)  // DSHOT mode by default
    );
    
    // =========================================================================
    // Status LEDs
    // =========================================================================
    // RGB LED: Show system status
    assign led_r = ~rst;           // Red = reset active
    assign led_g = pll_locked;     // Green = PLL locked
    assign led_b = debug_pc_valid; // Blue = CPU running

endmodule
