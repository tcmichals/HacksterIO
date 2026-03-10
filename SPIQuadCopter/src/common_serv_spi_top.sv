/**
 * common_serv_spi_top - SERV CPU + Peripheral System Wrapper
 *
 * This module combines:
 * 1. SERV RISC-V processor (bit-serial)
 * 2. 8KB instruction/data RAM
 * 3. wb_spisystem peripheral system (ENABLE_CPU_BUS=1)
 *
 * Used by Tang platform boards (Tang Nano 9K, TangPrimer25K).
 * The Arty-S7 would use wb_spisystem directly without this wrapper.
 *
 * Note: GPIO mux control allows external override of mux register.
 */

module common_serv_spi_top #(
    parameter USB_BAUD_RATE = 115200,
    parameter SERIAL_BAUD_RATE = 19200
) (
    // Clock and Reset
    input  logic clk,
    input  logic rst,
    
    // SPI Slave Interface
    input  logic spi_clk,
    input  logic spi_cs_n,
    input  logic spi_mosi,
    output logic spi_miso,
    
    // LED Outputs
    output logic led_1,
    output logic led_2,
    output logic led_3,
    output logic led_4,
    output logic led_5,
    
    // PWM Decoder Inputs
    input  logic pwm_ch0,
    input  logic pwm_ch1,
    input  logic pwm_ch2,
    input  logic pwm_ch3,
    input  logic pwm_ch4,
    input  logic pwm_ch5,
    
    // Motor Outputs
    inout  wire  motor1,
    inout  wire  motor2,
    inout  wire  motor3,
    inout  wire  motor4,
    
    // NeoPixel Output
    output logic neopixel,
    
    // Debug GPIO (32 bits for ILA debugging)
    output logic [31:0] debug_gpio,
    
    // SERV Debug Outputs (for ILA/GDB)
    output logic [31:0] debug_pc,      // Current program counter
    output logic        debug_pc_valid, // PC is valid (instruction fetch)
    
    // USB UART Interface
    input  logic usb_uart_rx,
    output logic usb_uart_tx,
    
    // GPIO Mux Control (optional external override)
    input  logic [2:0] gpio_mux_ctrl  // [0]=msp_mode, [2:1]=mux_ch
);

    // =========================================================================
    // SERV CPU Wishbone Bus Signals
    // =========================================================================
    logic [31:0] cpu_wb_adr;
    logic [31:0] cpu_wb_dat_m2s;
    logic [31:0] cpu_wb_dat_s2m;
    logic [3:0]  cpu_wb_sel;
    logic        cpu_wb_we;
    logic        cpu_wb_stb;
    logic        cpu_wb_cyc;
    logic        cpu_wb_ack;

    // SERV Memory Bus Signals
    logic [31:0] serv_mem_adr;
    logic [31:0] serv_mem_dat;
    logic [3:0]  serv_mem_sel;
    logic        serv_mem_we;
    logic        serv_mem_stb;
    logic [31:0] serv_mem_rdt;
    logic        serv_mem_ack;

    // =========================================================================
    // SERV RISC-V Core (Wishbone wrapper)
    // =========================================================================
    serv_wb_top u_serv (
        .i_clk(clk),
        .i_rst(rst),
        
        // External peripheral bus (to wb_spisystem)
        .o_wb_ext_adr(cpu_wb_adr),
        .o_wb_ext_dat(cpu_wb_dat_m2s),
        .o_wb_ext_sel(cpu_wb_sel),
        .o_wb_ext_we(cpu_wb_we),
        .o_wb_ext_stb(cpu_wb_stb),
        .o_wb_ext_cyc(cpu_wb_cyc),
        .i_wb_ext_rdt(cpu_wb_dat_s2m),
        .i_wb_ext_ack(cpu_wb_ack),
        
        // Memory bus (to RAM)
        .o_wb_mem_adr(serv_mem_adr),
        .o_wb_mem_dat(serv_mem_dat),
        .o_wb_mem_sel(serv_mem_sel),
        .o_wb_mem_we(serv_mem_we),
        .o_wb_mem_stb(serv_mem_stb),
        .i_wb_mem_rdt(serv_mem_rdt),
        .i_wb_mem_ack(serv_mem_ack),
        
        // Debug outputs for ILA/GDB
        .o_debug_pc(debug_pc),
        .o_debug_valid(debug_pc_valid)
    );

    // =========================================================================
    // Instruction/Data RAM (8KB)
    // =========================================================================
    wb_ram #(
        .DEPTH(8192),
        .MEMFILE("serv/firmware/firmware.mem")
    ) u_serv_ram (
        .i_clk(clk),
        .i_rst(rst),
        .i_wb_adr(serv_mem_adr),
        .i_wb_dat(serv_mem_dat),
        .i_wb_sel(serv_mem_sel),
        .i_wb_we(serv_mem_we),
        .i_wb_stb(serv_mem_stb),
        .o_wb_rdt(serv_mem_rdt),
        .o_wb_ack(serv_mem_ack)
    );

    // =========================================================================
    // Peripheral System (with CPU bus enabled)
    // =========================================================================
    wb_spisystem #(
        .ENABLE_CPU_BUS(1),
        .USB_BAUD_RATE(USB_BAUD_RATE),
        .SERIAL_BAUD_RATE(SERIAL_BAUD_RATE)
    ) u_wb_spisystem (
        .clk(clk),
        .rst(rst),
        
        // SPI Slave Interface
        .spi_clk(spi_clk),
        .spi_cs_n(spi_cs_n),
        .spi_mosi(spi_mosi),
        .spi_miso(spi_miso),
        
        // LED Outputs
        .led_1(led_1),
        .led_2(led_2),
        .led_3(led_3),
        .led_4(led_4),
        .led_5(led_5),
        
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
        
        // NeoPixel Output
        .neopixel(neopixel),
        
        // Debug GPIO
        .debug_gpio(debug_gpio),
        
        // USB UART
        .usb_uart_rx(usb_uart_rx),
        .usb_uart_tx(usb_uart_tx),
        
        // CPU Wishbone Bus
        .cpu_wb_adr_i(cpu_wb_adr),
        .cpu_wb_dat_i(cpu_wb_dat_m2s),
        .cpu_wb_dat_o(cpu_wb_dat_s2m),
        .cpu_wb_sel_i(cpu_wb_sel),
        .cpu_wb_we_i(cpu_wb_we),
        .cpu_wb_stb_i(cpu_wb_stb),
        .cpu_wb_cyc_i(cpu_wb_cyc),
        .cpu_wb_ack_o(cpu_wb_ack),
        
        // GPIO Mux Control
        .gpio_mux_ctrl(gpio_mux_ctrl),
        
        // External mux control (not used when ENABLE_CPU_BUS=1)
        .ext_mux_sel(1'b0),
        .ext_mux_ch(2'b0),
        .ext_msp_mode(1'b0)
    );

endmodule
