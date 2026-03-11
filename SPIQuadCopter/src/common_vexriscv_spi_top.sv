/**
 * common_vexriscv_spi_top - VexRiscv CPU + Peripheral System Wrapper
 *
 * This module combines:
 * 1. VexRiscv RISC-V processor (RV32IMC)
 * 2. 32KB instruction/data RAM
 * 3. wb_spisystem peripheral system (ENABLE_CPU_BUS=1)
 *
 * Used by Tang Nano 20K and Arty S7-50 platforms.
 *
 * Note: GPIO mux control allows external override of mux register.
 */

module common_vexriscv_spi_top #(
    parameter USB_BAUD_RATE = 115200,
    parameter SERIAL_BAUD_RATE = 19200,
    parameter RAM_DEPTH = 8192,                          // 32KB (8192 x 4 bytes)
    parameter FIRMWARE_FILE = "firmware/firmware.mem"    // Path to firmware
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
    
    // CPU Debug Outputs (for ILA/GDB)
    output logic [31:0] debug_pc,      // Current program counter
    output logic        debug_pc_valid, // PC is valid (instruction fetch)
    
    // USB UART Interface
    input  logic usb_uart_rx,
    output logic usb_uart_tx,
    
    // GPIO Mux Control (optional external override)
    input  logic [2:0] gpio_mux_ctrl  // [0]=msp_mode, [2:1]=mux_ch
);

    // =========================================================================
    // VexRiscv CPU Wishbone Bus Signals (to peripherals)
    // =========================================================================
    logic [31:0] cpu_wb_adr;
    logic [31:0] cpu_wb_dat_m2s;
    logic [31:0] cpu_wb_dat_s2m;
    logic [3:0]  cpu_wb_sel;
    logic        cpu_wb_we;
    logic        cpu_wb_stb;
    logic        cpu_wb_cyc;
    logic        cpu_wb_ack;

    // VexRiscv Instruction Bus (iBus) - Wishbone
    logic [31:0] ibus_adr;
    logic [31:0] ibus_dat_r;
    logic        ibus_cyc;
    logic        ibus_stb;
    logic        ibus_ack;
    logic        ibus_err;
    
    // VexRiscv Data Bus (dBus) - Wishbone
    logic [31:0] dbus_adr;
    logic [31:0] dbus_dat_w;
    logic [31:0] dbus_dat_r;
    logic [3:0]  dbus_sel;
    logic        dbus_we;
    logic        dbus_cyc;
    logic        dbus_stb;
    logic        dbus_ack;
    logic        dbus_err;

    // =========================================================================
    // VexRiscv Core
    // =========================================================================
    // VexRiscv with Wishbone interface (generated from SpinalHDL)
    // Configuration: RV32IMC, no MMU, no caches (minimal)
    
    VexRiscv u_vexriscv (
        .clk(clk),
        .reset(rst),
        
        // Instruction Bus (Wishbone)
        .iBusWishbone_CYC(ibus_cyc),
        .iBusWishbone_STB(ibus_stb),
        .iBusWishbone_ACK(ibus_ack),
        .iBusWishbone_WE(),           // iBus is read-only
        .iBusWishbone_ADR(ibus_adr),
        .iBusWishbone_DAT_MISO(ibus_dat_r),
        .iBusWishbone_DAT_MOSI(),
        .iBusWishbone_SEL(),
        .iBusWishbone_ERR(ibus_err),
        .iBusWishbone_CTI(),
        .iBusWishbone_BTE(),
        
        // Data Bus (Wishbone)
        .dBusWishbone_CYC(dbus_cyc),
        .dBusWishbone_STB(dbus_stb),
        .dBusWishbone_ACK(dbus_ack),
        .dBusWishbone_WE(dbus_we),
        .dBusWishbone_ADR(dbus_adr),
        .dBusWishbone_DAT_MISO(dbus_dat_r),
        .dBusWishbone_DAT_MOSI(dbus_dat_w),
        .dBusWishbone_SEL(dbus_sel),
        .dBusWishbone_ERR(dbus_err),
        .dBusWishbone_CTI(),
        .dBusWishbone_BTE(),
        
        // Interrupts
        .timerInterrupt(1'b0),
        .externalInterrupt(1'b0),
        .softwareInterrupt(1'b0),
        
        // Debug Interface (directly directly directly directly directly directly directly directly directly directly directly directly directly directly directly directly directly directly directly directly directly directly directly directly directly directly directly directly directly directly directly directly directly directly directly directly directly directly directly directly directly -)
        .debug_bus_cmd_valid(1'b0),
        .debug_bus_cmd_ready(),
        .debug_bus_cmd_payload_wr(1'b0),
        .debug_bus_cmd_payload_address(8'h0),
        .debug_bus_cmd_payload_data(32'h0),
        .debug_bus_rsp_data(),
        .debug_resetOut(),
        .debugReset(1'b0)
    );
    
    // Debug PC output (directly from directly instruction directly directly directly bus directly directly directly directly address)
    assign debug_pc = ibus_adr;
    assign debug_pc_valid = ibus_cyc & ibus_stb & ibus_ack;

    // =========================================================================
    // Memory Map Decoder
    // =========================================================================
    // Memory map:
    //   0x00000000 - 0x00007FFF : RAM (32KB)
    //   0x40000000 - 0x400FFFFF : Peripherals (via wb_spisystem)
    //
    // iBus only accesses RAM (code fetch)
    // dBus accesses both RAM (data) and peripherals
    
    localparam RAM_BASE = 32'h0000_0000;
    localparam RAM_SIZE = RAM_DEPTH * 4;  // bytes
    localparam PERIPH_BASE = 32'h4000_0000;
    
    wire dbus_sel_ram    = (dbus_adr < RAM_SIZE);
    wire dbus_sel_periph = (dbus_adr[31:28] == 4'h4);
    
    // =========================================================================
    // RAM Interface (shared iBus/dBus with arbiter)
    // =========================================================================
    logic [31:0] ram_adr;
    logic [31:0] ram_dat_w;
    logic [31:0] ram_dat_r;
    logic [3:0]  ram_sel;
    logic        ram_we;
    logic        ram_stb;
    logic        ram_ack;
    
    // Simple arbiter: dBus has priority (read-modify-write needs atomicity)
    logic ibus_grant;
    assign ibus_grant = ibus_cyc & ibus_stb & ~(dbus_cyc & dbus_stb & dbus_sel_ram);
    
    always_comb begin
        if (dbus_cyc & dbus_stb & dbus_sel_ram) begin
            // dBus accessing RAM
            ram_adr   = dbus_adr;
            ram_dat_w = dbus_dat_w;
            ram_sel   = dbus_sel;
            ram_we    = dbus_we;
            ram_stb   = 1'b1;
        end else if (ibus_grant) begin
            // iBus accessing RAM (instruction fetch)
            ram_adr   = ibus_adr;
            ram_dat_w = 32'h0;
            ram_sel   = 4'hF;
            ram_we    = 1'b0;
            ram_stb   = 1'b1;
        end else begin
            ram_adr   = 32'h0;
            ram_dat_w = 32'h0;
            ram_sel   = 4'h0;
            ram_we    = 1'b0;
            ram_stb   = 1'b0;
        end
    end
    
    // Route RAM read data and ACK
    assign ibus_dat_r = ram_dat_r;
    assign ibus_ack   = ibus_grant & ram_ack;
    assign ibus_err   = 1'b0;
    
    // dBus gets RAM data when accessing RAM
    wire dbus_ram_ack = (dbus_cyc & dbus_stb & dbus_sel_ram) ? ram_ack : 1'b0;

    // =========================================================================
    // Instruction/Data RAM (32KB)
    // =========================================================================
    wb_ram #(
        .DEPTH(RAM_DEPTH),
        .MEMFILE(FIRMWARE_FILE)
    ) u_ram (
        .i_clk(clk),
        .i_rst(rst),
        .i_wb_adr(ram_adr),
        .i_wb_dat(ram_dat_w),
        .i_wb_sel(ram_sel),
        .i_wb_we(ram_we),
        .i_wb_stb(ram_stb),
        .o_wb_rdt(ram_dat_r),
        .o_wb_ack(ram_ack)
    );

    // =========================================================================
    // Peripheral Bus Connection
    // =========================================================================
    // dBus to peripheral bus (when accessing peripheral space)
    assign cpu_wb_adr     = dbus_adr;
    assign cpu_wb_dat_m2s = dbus_dat_w;
    assign cpu_wb_sel     = dbus_sel;
    assign cpu_wb_we      = dbus_we;
    assign cpu_wb_stb     = dbus_stb & dbus_sel_periph;
    assign cpu_wb_cyc     = dbus_cyc & dbus_sel_periph;
    
    // dBus read data mux
    assign dbus_dat_r = dbus_sel_periph ? cpu_wb_dat_s2m : ram_dat_r;
    assign dbus_ack   = dbus_sel_periph ? cpu_wb_ack : dbus_ram_ack;
    assign dbus_err   = 1'b0;

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
        .ext_mux_ch(2'b00)
    );

endmodule
