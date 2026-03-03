/**
 * arty_s7_spi_copter_top.v - Simple Top-Level for Arty S7
 * 
 * Pure Verilog top-level that instantiates wb_spisystem_wrapper.
 * Can be used directly in Vivado (not compatible with OSS CAD Suite).
 * 
 * Configuration:
 *   - No CPU Wishbone bus (ENABLE_CPU_BUS=0)
 *   - Mux controlled by 3 GPIO inputs (connect to your processor)
 *   - All peripherals accessible via SPI
 * 
 * To use in Vivado:
 *   1. Add this file as top module
 *   2. Add all source files from project (wb_spisystem.sv, spi_slave.sv, etc.)
 *   3. Create XDC constraints file for pin mapping
 *   4. Synthesize and implement
 */

module arty_s7_spi_copter_top #(
    parameter CLK_FREQ_HZ = 80_000_000  // System clock frequency (MUST match Clock Wizard output!)
) (
    // System Clock (frequency set by CLK_FREQ_HZ parameter)
    input  wire        clk,
    input  wire        reset_n,        // Active-low reset button
    
    // SPI Slave Interface (connect to external SPI master or Pmod)
    input  wire        spi_clk,
    input  wire        spi_cs_n,
    input  wire        spi_mosi,
    output wire        spi_miso,
    
    // Mux Control (3 bits from GPIO)
//    input  wire [2:0]  gpio_mux_ctrl,   // [0]=MSP mode, [2:1]=motor channel
    
    // ESC UART (connect to your processor's UART for BLHeli passthrough)
    input  wire        esc_uart_tx,    // UART TX from processor
    output wire        esc_uart_rx,    // UART RX to processor
    input  wire        esc_uart_tx_en, // TX enable (high when transmitting)
    
    // LED Outputs (use 4 LEDs on Arty-S7)
    output wire        led0,
    output wire        led1,
    output wire        led2,
    output wire        led3,
    
    // PWM Decoder Inputs (map to Pmod connector)
    input  wire        pwm_ch0,
    input  wire        pwm_ch1,
    input  wire        pwm_ch2,
    input  wire        pwm_ch3,
    input  wire        pwm_ch4,
    input  wire        pwm_ch5,
    
    // DSHOT Motor Outputs (bidirectional)
    inout  wire        motor1,
    inout  wire        motor2,
    inout  wire        motor3,
    inout  wire        motor4,
    
    // NeoPixel Output
    output wire        neopixel,
    
    // Debug Outputs (optional, can connect to Pmod for logic analyzer)
    output wire        debug0,
    output wire        debug1,
    output wire        debug2,

    input wire [2:0]      mux_for_esc
);

    // =========================================================================
    // Clock and Reset
    // =========================================================================
    wire sys_clk;
    wire sys_reset;
    
    // Use 100 MHz clock directly (or add MMCM/PLL for different frequency)
    assign sys_clk = clk;
    
    // Reset synchronizer (2-stage)
    reg reset_sync_1;
    reg reset_sync_2;

    // GPIO synchronizer (2-stage for metastability protection)
    reg [2:0] gpio_sync_1;
    reg [2:0] gpio_sync_2;

    always @(posedge sys_clk or negedge reset_n) begin
        if (!reset_n) begin
            gpio_sync_1 <= 3'b0;
            gpio_sync_2 <= 3'b0;
        end else begin
            gpio_sync_1 <= mux_for_esc;  // First stage - may go metastable
            gpio_sync_2 <= gpio_sync_1;  // Second stage - stable output
        end
    end

    always @(posedge sys_clk or negedge reset_n) begin
        if (!reset_n) begin
            reset_sync_1 <= 1'b1;
            reset_sync_2 <= 1'b1;
        end else begin
            reset_sync_1 <= 1'b0;
            reset_sync_2 <= reset_sync_1;
        end
    end
    
    assign sys_reset = reset_sync_2;

    // =========================================================================
    // Unused LED outputs (only using 4 of 5 LEDs)
    // =========================================================================
    wire led5_unused;

    // =========================================================================
    // Wishbone SPI System (all peripherals integrated)
    // =========================================================================
    wb_spisystem #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),   // Use top-level parameter
        .ENABLE_CPU_BUS(0)           // No CPU bus, GPIO mux control only
    ) u_wb_spisystem (
        // Clock and Reset
        .clk(sys_clk),
        .rst(sys_reset),
        
        // SPI Slave Interface
        .spi_clk(spi_clk),
        .spi_cs_n(spi_cs_n),
        .spi_mosi(spi_mosi),
        .spi_miso(spi_miso),
        
        // External Mux Control (from GPIO)
        .ext_mux_sel(1'b1),              // DSHOT mode (MSP will override when active)
        .ext_mux_ch(gpio_sync_2[2:1]),   // Motor channel from GPIO[2:1] - synchronized
        .ext_msp_mode(gpio_sync_2[0]),   // MSP/passthrough mode from GPIO[0] - synchronized
        
        // ESC UART (from processor)
        .ext_esc_uart_tx(esc_uart_tx),
        .ext_esc_uart_rx(esc_uart_rx),
        .ext_esc_uart_tx_en(esc_uart_tx_en),
        
        // USB UART (tied off - handled in Block Designer)
        .usb_uart_rx(1'b1),  // UART idle high
        .usb_uart_tx(),      // Unconnected
        
        // CPU Wishbone Bus (tie off when ENABLE_CPU_BUS=0)
        .cpu_wb_adr_i(32'h0),
        .cpu_wb_dat_i(32'h0),
        .cpu_wb_dat_o(),
        .cpu_wb_sel_i(4'h0),
        .cpu_wb_we_i(1'b0),
        .cpu_wb_stb_i(1'b0),
        .cpu_wb_cyc_i(1'b0),
        .cpu_wb_ack_o(),
        
        // LED Outputs
        .led_1(led0),
        .led_2(led1),
        .led_3(led2),
        .led_4(led3),
        .led_5(led5_unused),
        
        // PWM Decoder Inputs
        .pwm_ch0(pwm_ch0),
        .pwm_ch1(pwm_ch1),
        .pwm_ch2(pwm_ch2),
        .pwm_ch3(pwm_ch3),
        .pwm_ch4(pwm_ch4),
        .pwm_ch5(pwm_ch5),
        
        // DSHOT Motor Outputs
        .motor1(motor1),
        .motor2(motor2),
        .motor3(motor3),
        .motor4(motor4),
        
        // NeoPixel Output
        .neopixel(neopixel),
        
        // Debug Outputs
        .debug_gpio({debug2, debug1, debug0})
    );

endmodule
