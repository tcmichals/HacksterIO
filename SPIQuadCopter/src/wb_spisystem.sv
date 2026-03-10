/**
 * wb_spisystem - Wishbone Peripheral System with SPI Interface
 * 
 * This module contains all flight controller peripherals accessible via:
 * 1. SPI slave interface (always enabled) at base address 0x0000_xxxx
 * 2. Optional CPU Wishbone bus at base address 0x4000_xxxx (when ENABLE_CPU_BUS=1)
 *
 * The module is platform-agnostic and can be integrated into:
 * - Tang Nano 9K (with SERV CPU)
 * - TangPrimer25k (with SERV CPU)  
 * - Arty-S7-50 (GPIO mux control only, no CPU)
 *
 * Peripheral Address Maps:
 *
 * SPI Wishbone Bus (0x0000_xxxx):
 *   0x0000: Version register (R)
 *   0x0100: LED Controller (RW)
 *   0x0200: PWM Decoder (R) 
 *   0x0300: DSHOT Controller (RW, direct access)
 *   0x0400: NeoPixel Controller (RW)
 *   0x0500: Mux Mirror (R) - shadow of mux control
 *
 * CPU Wishbone Bus (0x4000_xxxx, optional when ENABLE_CPU_BUS=1):
 *   0x40000100: Debug GPIO (RW)
 *   0x40000200: Timer (R/W)
 *   0x40000700: Serial/DSHOT Mux (RW)
 *   0x40000800: USB UART (RW)
 *   0x40000900: ESC UART (RW)
 *
 * Architecture Notes:
 * - DSHOT controller accessible only via SPI bus (no arbiter)
 * - CPU controls mux via register or external GPIO inputs
 * - Serial/DSHOT mux selects between ESC UART and DSHOT on motor pins
 * - When ENABLE_CPU_BUS=0, mux controlled by external GPIO inputs
 */

module wb_spisystem #(
    parameter CLK_FREQ_HZ = 54_000_000, 
    parameter ENABLE_CPU_BUS = 1,  // 1=Tang (SERV), 0=Arty-S7 (GPIO only)
    parameter USB_BAUD_RATE = 115200,
    parameter SERIAL_BAUD_RATE = 19200 
) (
    // Clock and Reset
    input  logic clk,
    input  logic rst,
    
    // SPI Slave Interface (always enabled)
    input  logic spi_clk,
    input  logic spi_cs_n,
    input  logic spi_mosi,
    output logic spi_miso,
    
    // LED Outputs (4 controllable + 1 fixed)
    output logic led_1,
    output logic led_2,
    output logic led_3,
    output logic led_4,
    output logic led_5, 
    
    // PWM Decoder Inputs (6 channels)
    input  logic pwm_ch0,
    input  logic pwm_ch1,
    input  logic pwm_ch2,
    input  logic pwm_ch3,
    input  logic pwm_ch4,
    input  logic pwm_ch5,
    
    // Motor Outputs (bidirectional for serial passthrough)
    inout  wire  motor1,
    inout  wire  motor2,
    inout  wire  motor3,
    inout  wire  motor4,
    
    // NeoPixel Output
    output logic neopixel,
    
    // Debug GPIO (32 bits for ILA debugging)
    output logic [31:0] debug_gpio,
    
    // USB UART Interface 
    input  logic usb_uart_rx,
    output logic usb_uart_tx,
    
    // CPU Wishbone Bus Master (optional, when ENABLE_CPU_BUS=1)
    input  logic [31:0] cpu_wb_adr_i,
    input  logic [31:0] cpu_wb_dat_i,
    output logic [31:0] cpu_wb_dat_o,
    input  logic [3:0]  cpu_wb_sel_i,
    input  logic        cpu_wb_we_i,
    input  logic        cpu_wb_stb_i,
    input  logic        cpu_wb_cyc_i,
    output logic        cpu_wb_ack_o,
    
    // GPIO Mux Control (when ENABLE_CPU_BUS=1, as alternative to register)
    input  logic [2:0]  gpio_mux_ctrl,    // [0]=msp_mode, [2:1]=mux_ch
    
    // External Mux Control (when ENABLE_CPU_BUS=0, Arty-S7 mode)
    input  logic        ext_mux_sel,      // 0=Serial, 1=DSHOT
    input  logic [1:0]  ext_mux_ch,       // ESC channel select
    input  logic        ext_msp_mode,     // MSP mode enable
    
    // External ESC UART (when ENABLE_CPU_BUS=0, from processor)
    input  logic        ext_esc_uart_tx,      // TX from processor
    output logic        ext_esc_uart_rx,      // RX to processor  
    input  logic        ext_esc_uart_tx_en    // TX enable (for half-duplex)
);

    // =========================================================================
    // Internal Signals
    // =========================================================================
    
    // SPI Slave to Wishbone Bridge signals
    logic [7:0]  spi_rx_data, spi_tx_data;
    logic        spi_rx_valid, spi_tx_valid, spi_tx_ready;
    logic        spi_cs_n_sync;
    
    // SPI Wishbone Master signals
    logic [31:0] spi_wb_adr, spi_wb_dat_m2s, spi_wb_dat_s2m;
    logic [3:0]  spi_wb_sel;
    logic        spi_wb_we, spi_wb_stb, spi_wb_cyc, spi_wb_ack, spi_wb_err;
    
    // CPU Wishbone Mux slave ports (6 slaves - includes DSHOT mailbox and Timer)
    logic [31:0] cpu_s0_adr, cpu_s0_dat_i, cpu_s0_dat_o;
    logic [3:0]  cpu_s0_sel;
    logic        cpu_s0_we, cpu_s0_stb, cpu_s0_ack, cpu_s0_cyc;
    
    logic [31:0] cpu_s1_adr, cpu_s1_dat_i, cpu_s1_dat_o;
    logic [3:0]  cpu_s1_sel;
    logic        cpu_s1_we, cpu_s1_stb, cpu_s1_ack, cpu_s1_cyc;
    
    logic [31:0] cpu_s2_adr, cpu_s2_dat_i, cpu_s2_dat_o;
    logic [3:0]  cpu_s2_sel;
    logic        cpu_s2_we, cpu_s2_stb, cpu_s2_ack, cpu_s2_cyc;
    
    logic [31:0] cpu_s3_adr, cpu_s3_dat_i, cpu_s3_dat_o;
    logic [3:0]  cpu_s3_sel;
    logic        cpu_s3_we, cpu_s3_stb, cpu_s3_ack, cpu_s3_cyc;
    
    logic [31:0] cpu_s4_adr, cpu_s4_dat_i, cpu_s4_dat_o;
    logic [3:0]  cpu_s4_sel;
    logic        cpu_s4_we, cpu_s4_stb, cpu_s4_ack, cpu_s4_cyc;
    
    logic [31:0] cpu_s5_adr, cpu_s5_dat_i, cpu_s5_dat_o;
    logic [3:0]  cpu_s5_sel;
    logic        cpu_s5_we, cpu_s5_stb, cpu_s5_ack, cpu_s5_cyc;
    
    // SPI Wishbone Mux slave ports (6 slaves)
    logic [31:0] spi_s0_adr, spi_s0_dat_i, spi_s0_dat_o;
    logic [3:0]  spi_s0_sel;
    logic        spi_s0_we, spi_s0_stb, spi_s0_ack, spi_s0_cyc;
    
    logic [31:0] spi_s1_adr, spi_s1_dat_i, spi_s1_dat_o;
    logic [3:0]  spi_s1_sel;
    logic        spi_s1_we, spi_s1_stb, spi_s1_ack, spi_s1_cyc;
    
    logic [31:0] spi_s2_adr, spi_s2_dat_i, spi_s2_dat_o;
    logic [3:0]  spi_s2_sel;
    logic        spi_s2_we, spi_s2_stb, spi_s2_ack, spi_s2_cyc;
    
    logic [31:0] spi_s3_adr, spi_s3_dat_i, spi_s3_dat_o;
    logic [3:0]  spi_s3_sel;
    logic        spi_s3_we, spi_s3_stb, spi_s3_ack, spi_s3_cyc;
    
    logic [31:0] spi_s4_adr, spi_s4_dat_i, spi_s4_dat_o;
    logic [3:0]  spi_s4_sel;
    logic        spi_s4_we, spi_s4_stb, spi_s4_ack, spi_s4_cyc;
    
    logic [31:0] spi_s5_adr, spi_s5_dat_i, spi_s5_dat_o;
    logic [3:0]  spi_s5_sel;
    logic        spi_s5_we, spi_s5_stb, spi_s5_ack, spi_s5_cyc;
    
    // DSHOT signals (direct from SPI bus, no arbiter)
    logic        motor1_dshot, motor2_dshot, motor3_dshot, motor4_dshot;
    
    // Peripheral signals
    logic [4:0]  led_out;
    logic        neopixel_out;
    logic [31:0] debug_gpio_out;
    
    // Serial/DSHOT Mux signals
    logic        mux_sel;
    logic [1:0]  mux_ch;
    logic        msp_mode;
    logic        esc_uart_tx, esc_uart_rx, esc_uart_tx_active;
    logic        usb_uart_tx_wire;

    // =========================================================================
    // SPI Slave Interface
    // =========================================================================
    spi_slave #(
        .DATA_WIDTH(8)
    ) u_spi_slave (
        .i_clk(clk),
        .i_rst(rst),
        .i_sclk(spi_clk),
        .i_cs_n(spi_cs_n),
        .i_mosi(spi_mosi),
        .o_miso(spi_miso),
        .o_rx_data(spi_rx_data),
        .o_data_valid(spi_rx_valid),
        .i_tx_data(spi_tx_data),
        .i_tx_valid(spi_tx_valid),
        .o_tx_ready(spi_tx_ready),
        .o_busy(),
        .o_cs_n_sync(spi_cs_n_sync)
    );

    // =========================================================================
    // SPI to Wishbone Bridge
    // =========================================================================
    spi_slave_wb_bridge #(
        .WB_ADDR_WIDTH(32),
        .WB_DATA_WIDTH(32)
    ) u_spi_slave_wb_bridge (
        .clk(clk),
        .rst(rst),
        .spi_rx_valid(spi_rx_valid),
        .spi_rx_data(spi_rx_data),
        .spi_tx_valid(spi_tx_valid),
        .spi_tx_data(spi_tx_data),
        .spi_tx_ready(spi_tx_ready),
        .spi_cs_n(spi_cs_n_sync),
        .wb_adr_o(spi_wb_adr),
        .wb_dat_o(spi_wb_dat_m2s),
        .wb_dat_i(spi_wb_dat_s2m),
        .wb_we_o(spi_wb_we),
        .wb_sel_o(spi_wb_sel),
        .wb_stb_o(spi_wb_stb),
        .wb_ack_i(spi_wb_ack),
        .wb_err_i(spi_wb_err),
        .wb_cyc_o(spi_wb_cyc),
        .busy()
    );

    // =========================================================================
    // CPU Wishbone Mux (6 slaves) - only instantiated when ENABLE_CPU_BUS=1
    // =========================================================================
    generate
        if (ENABLE_CPU_BUS) begin : gen_cpu_mux
            wb_mux_6 #(
                .DATA_WIDTH(32),
                .ADDR_WIDTH(32),
                .SELECT_WIDTH(4)
            ) u_wb_mux_6_cpu (
                .clk(clk),
                .rst(rst),
                
                // Master (from CPU)
                .wbm_adr_i(cpu_wb_adr_i),
                .wbm_dat_i(cpu_wb_dat_i),
                .wbm_dat_o(cpu_wb_dat_o),
                .wbm_we_i(cpu_wb_we_i),
                .wbm_sel_i(cpu_wb_sel_i),
                .wbm_stb_i(cpu_wb_stb_i),
                .wbm_ack_o(cpu_wb_ack_o),
                .wbm_err_o(),
                .wbm_rty_o(),
                .wbm_cyc_i(cpu_wb_cyc_i),
                
                // Slave 0: Debug GPIO (0x40000100)
                .wbs0_adr_o(cpu_s0_adr),
                .wbs0_dat_i(cpu_s0_dat_i),
                .wbs0_dat_o(cpu_s0_dat_o),
                .wbs0_we_o(cpu_s0_we),
                .wbs0_sel_o(cpu_s0_sel),
                .wbs0_stb_o(cpu_s0_stb),
                .wbs0_ack_i(cpu_s0_ack),
                .wbs0_err_i(1'b0),
                .wbs0_rty_i(1'b0),
                .wbs0_cyc_o(cpu_s0_cyc),
                .wbs0_addr(32'h40000100),
                .wbs0_addr_msk(32'hFFFFFF00),
                
                // Slave 1: DSHOT Mailbox Port A (0x40000300)
                .wbs1_adr_o(cpu_s1_adr),
                .wbs1_dat_i(cpu_s1_dat_i),
                .wbs1_dat_o(cpu_s1_dat_o),
                .wbs1_we_o(cpu_s1_we),
                .wbs1_sel_o(cpu_s1_sel),
                .wbs1_stb_o(cpu_s1_stb),
                .wbs1_ack_i(cpu_s1_ack),
                .wbs1_err_i(1'b0),
                .wbs1_rty_i(1'b0),
                .wbs1_cyc_o(cpu_s1_cyc),
                .wbs1_addr(32'h40000300),
                .wbs1_addr_msk(32'hFFFFFF00),
                
                // Slave 2: Serial/DSHOT Mux (0x40000400)
                .wbs2_adr_o(cpu_s2_adr),
                .wbs2_dat_i(cpu_s2_dat_i),
                .wbs2_dat_o(cpu_s2_dat_o),
                .wbs2_we_o(cpu_s2_we),
                .wbs2_sel_o(cpu_s2_sel),
                .wbs2_stb_o(cpu_s2_stb),
                .wbs2_ack_i(cpu_s2_ack),
                .wbs2_err_i(1'b0),
                .wbs2_rty_i(1'b0),
                .wbs2_cyc_o(cpu_s2_cyc),
                .wbs2_addr(32'h40000400),
                .wbs2_addr_msk(32'hFFFFFF00),
                
                // Slave 3: USB UART (0x40000800)
                .wbs3_adr_o(cpu_s3_adr),
                .wbs3_dat_i(cpu_s3_dat_i),
                .wbs3_dat_o(cpu_s3_dat_o),
                .wbs3_we_o(cpu_s3_we),
                .wbs3_sel_o(cpu_s3_sel),
                .wbs3_stb_o(cpu_s3_stb),
                .wbs3_ack_i(cpu_s3_ack),
                .wbs3_err_i(1'b0),
                .wbs3_rty_i(1'b0),
                .wbs3_cyc_o(cpu_s3_cyc),
                .wbs3_addr(32'h40000800),
                .wbs3_addr_msk(32'hFFFFFF00),
                
                // Slave 4: ESC UART (0x40000900)
                .wbs4_adr_o(cpu_s4_adr),
                .wbs4_dat_i(cpu_s4_dat_i),
                .wbs4_dat_o(cpu_s4_dat_o),
                .wbs4_we_o(cpu_s4_we),
                .wbs4_sel_o(cpu_s4_sel),
                .wbs4_stb_o(cpu_s4_stb),
                .wbs4_ack_i(cpu_s4_ack),
                .wbs4_err_i(1'b0),
                .wbs4_rty_i(1'b0),
                .wbs4_cyc_o(cpu_s4_cyc),
                .wbs4_addr(32'h40000900),
                .wbs4_addr_msk(32'hFFFFFF00),
                
                // Slave 5: Timer (0x40000200)
                .wbs5_adr_o(cpu_s5_adr),
                .wbs5_dat_i(cpu_s5_dat_i),
                .wbs5_dat_o(cpu_s5_dat_o),
                .wbs5_we_o(cpu_s5_we),
                .wbs5_sel_o(cpu_s5_sel),
                .wbs5_stb_o(cpu_s5_stb),
                .wbs5_ack_i(cpu_s5_ack),
                .wbs5_err_i(1'b0),
                .wbs5_rty_i(1'b0),
                .wbs5_cyc_o(cpu_s5_cyc),
                .wbs5_addr(32'h40000200),
                .wbs5_addr_msk(32'hFFFFFF00)
            );
        end else begin : gen_no_cpu_mux
            // When no CPU bus, tie off all outputs and use external GPIO mux control
            assign cpu_wb_dat_o = 32'h0;
            assign cpu_wb_ack_o = 1'b0;
            
            // Tie off internal CPU bus signals
            assign cpu_s0_adr = 32'h0;
            assign cpu_s0_dat_o = 32'h0;
            assign cpu_s0_sel = 4'h0;
            assign cpu_s0_we = 1'b0;
            assign cpu_s0_stb = 1'b0;
            assign cpu_s0_cyc = 1'b0;
            
            assign cpu_s1_adr = 32'h0;
            assign cpu_s1_dat_o = 32'h0;
            assign cpu_s1_sel = 4'h0;
            assign cpu_s1_we = 1'b0;
            assign cpu_s1_stb = 1'b0;
            assign cpu_s1_cyc = 1'b0;
            
            assign cpu_s2_adr = 32'h0;
            assign cpu_s2_dat_o = 32'h0;
            assign cpu_s2_sel = 4'h0;
            assign cpu_s2_we = 1'b0;
            assign cpu_s2_stb = 1'b0;
            assign cpu_s2_cyc = 1'b0;
            
            assign cpu_s3_adr = 32'h0;
            assign cpu_s3_dat_o = 32'h0;
            assign cpu_s3_sel = 4'h0;
            assign cpu_s3_we = 1'b0;
            assign cpu_s3_stb = 1'b0;
            assign cpu_s3_cyc = 1'b0;
            
            assign cpu_s4_adr = 32'h0;
            assign cpu_s4_dat_o = 32'h0;
            assign cpu_s4_sel = 4'h0;
            assign cpu_s4_we = 1'b0;
            assign cpu_s4_stb = 1'b0;
            assign cpu_s4_cyc = 1'b0;
            
            assign cpu_s5_adr = 32'h0;
            assign cpu_s5_dat_o = 32'h0;
            assign cpu_s5_sel = 4'h0;
            assign cpu_s5_we = 1'b0;
            assign cpu_s5_stb = 1'b0;
            assign cpu_s5_cyc = 1'b0;
            
            // Use external GPIO mux control instead
            assign mux_sel = ext_mux_sel;
            assign mux_ch = ext_mux_ch;
            assign msp_mode = ext_msp_mode;
        end
    endgenerate

    // =========================================================================
    // SPI Wishbone Mux (6 slaves)
    // =========================================================================
    wb_mux_6 #(
        .DATA_WIDTH(32),
        .ADDR_WIDTH(32),
        .SELECT_WIDTH(4)
    ) u_wb_mux_6_spi (
        .clk(clk),
        .rst(rst),
        
        // Master (from SPI-WB bridge)
        .wbm_adr_i(spi_wb_adr),
        .wbm_dat_i(spi_wb_dat_m2s),
        .wbm_dat_o(spi_wb_dat_s2m),
        .wbm_we_i(spi_wb_we),
        .wbm_sel_i(spi_wb_sel),
        .wbm_stb_i(spi_wb_stb),
        .wbm_ack_o(spi_wb_ack),
        .wbm_err_o(spi_wb_err),
        .wbm_rty_o(),
        .wbm_cyc_i(spi_wb_cyc),
        
        // Slave 0: Version (0x0000)
        .wbs0_adr_o(spi_s0_adr),
        .wbs0_dat_i(spi_s0_dat_i),
        .wbs0_dat_o(spi_s0_dat_o),
        .wbs0_we_o(spi_s0_we),
        .wbs0_sel_o(spi_s0_sel),
        .wbs0_stb_o(spi_s0_stb),
        .wbs0_ack_i(spi_s0_ack),
        .wbs0_err_i(1'b0),
        .wbs0_rty_i(1'b0),
        .wbs0_cyc_o(spi_s0_cyc),
        .wbs0_addr(32'h00000000),
        .wbs0_addr_msk(32'hFFFFFF00),
        
        // Slave 1: LED Controller (0x0100)
        .wbs1_adr_o(spi_s1_adr),
        .wbs1_dat_i(spi_s1_dat_i),
        .wbs1_dat_o(spi_s1_dat_o),
        .wbs1_we_o(spi_s1_we),
        .wbs1_sel_o(spi_s1_sel),
        .wbs1_stb_o(spi_s1_stb),
        .wbs1_ack_i(spi_s1_ack),
        .wbs1_err_i(1'b0),
        .wbs1_rty_i(1'b0),
        .wbs1_cyc_o(spi_s1_cyc),
        .wbs1_addr(32'h00000100),
        .wbs1_addr_msk(32'hFFFFFF00),
        
        // Slave 2: PWM Decoder (0x0200)
        .wbs2_adr_o(spi_s2_adr),
        .wbs2_dat_i(spi_s2_dat_i),
        .wbs2_dat_o(spi_s2_dat_o),
        .wbs2_we_o(spi_s2_we),
        .wbs2_sel_o(spi_s2_sel),
        .wbs2_stb_o(spi_s2_stb),
        .wbs2_ack_i(spi_s2_ack),
        .wbs2_err_i(1'b0),
        .wbs2_rty_i(1'b0),
        .wbs2_cyc_o(spi_s2_cyc),
        .wbs2_addr(32'h00000200),
        .wbs2_addr_msk(32'hFFFFFF00),
        
        // Slave 3: DSHOT (direct) (0x0300)
        .wbs3_adr_o(spi_s3_adr),
        .wbs3_dat_i(spi_s3_dat_i),
        .wbs3_dat_o(spi_s3_dat_o),
        .wbs3_we_o(spi_s3_we),
        .wbs3_sel_o(spi_s3_sel),
        .wbs3_stb_o(spi_s3_stb),
        .wbs3_ack_i(spi_s3_ack),
        .wbs3_err_i(1'b0),
        .wbs3_rty_i(1'b0),
        .wbs3_cyc_o(spi_s3_cyc),
        .wbs3_addr(32'h00000300),
        .wbs3_addr_msk(32'hFFFFFF00),
        
        // Slave 4: NeoPixel (0x0400)
        .wbs4_adr_o(spi_s4_adr),
        .wbs4_dat_i(spi_s4_dat_i),
        .wbs4_dat_o(spi_s4_dat_o),
        .wbs4_we_o(spi_s4_we),
        .wbs4_sel_o(spi_s4_sel),
        .wbs4_stb_o(spi_s4_stb),
        .wbs4_ack_i(spi_s4_ack),
        .wbs4_err_i(1'b0),
        .wbs4_rty_i(1'b0),
        .wbs4_cyc_o(spi_s4_cyc),
        .wbs4_addr(32'h00000400),
        .wbs4_addr_msk(32'hFFFFFF00),
        
        // Slave 5: Mux Mirror (0x0500)
        .wbs5_adr_o(spi_s5_adr),
        .wbs5_dat_i(spi_s5_dat_i),
        .wbs5_dat_o(spi_s5_dat_o),
        .wbs5_we_o(spi_s5_we),
        .wbs5_sel_o(spi_s5_sel),
        .wbs5_stb_o(spi_s5_stb),
        .wbs5_ack_i(spi_s5_ack),
        .wbs5_err_i(1'b0),
        .wbs5_rty_i(1'b0),
        .wbs5_cyc_o(spi_s5_cyc),
        .wbs5_addr(32'h00000500),
        .wbs5_addr_msk(32'hFFFFFF00)
    );

    // =========================================================================
    // Peripheral Instantiations
    // =========================================================================

    // Version Register (SPI bus)
    wb_version u_wb_version (
        .i_clk(clk),
        .i_rst(rst),
        .wb_adr_i(spi_s0_adr[3:0]),
        .wb_dat_i(spi_s0_dat_o),
        .wb_dat_o(spi_s0_dat_i),
        .wb_we_i(spi_s0_we),
        .wb_stb_i(spi_s0_stb),
        .wb_ack_o(spi_s0_ack),
        .wb_cyc_i(spi_s0_cyc)
    );

    // LED Controller (SPI bus)
    wb_led_controller #(
        .LED_WIDTH(5)
    ) u_led_ctrl (
        .clk(clk),
        .rst(rst),
        .wbs_adr_i(spi_s1_adr),
        .wbs_dat_i(spi_s1_dat_o),
        .wbs_dat_o(spi_s1_dat_i),
        .wbs_we_i(spi_s1_we),
        .wbs_sel_i(4'b1111),
        .wbs_stb_i(spi_s1_stb),
        .wbs_cyc_i(spi_s1_cyc),
        .wbs_ack_o(spi_s1_ack),
        .wbs_err_o(),
        .wbs_rty_o(),
        .led_out(led_out)
    );
    
    // LED outputs (active-low)
    assign led_1 = ~led_out[0];
    assign led_2 = ~led_out[1];
    assign led_3 = ~led_out[2];
    assign led_4 = ~led_out[3];
    assign led_5 = ~led_out[4];  // Wishbone controlled

    // PWM Decoder (SPI bus)
    pwmdecoder_wb #(
        .clockFreq(CLK_FREQ_HZ)
    ) u_pwm_decoder (
        .i_clk(clk),
        .i_rst(rst),
        .wb_adr_i(spi_s2_adr),
        .wb_dat_i(spi_s2_dat_o),
        .wb_dat_o(spi_s2_dat_i),
        .wb_we_i(spi_s2_we),
        .wb_sel_i(spi_s2_sel),
        .wb_stb_i(spi_s2_stb),
        .wb_cyc_i(spi_s2_cyc),
        .wb_ack_o(spi_s2_ack),
        .wb_err_o(),
        .wb_rty_o(),
        .i_pwm_0(pwm_ch0),
        .i_pwm_1(pwm_ch1),
        .i_pwm_2(pwm_ch2),
        .i_pwm_3(pwm_ch3),
        .i_pwm_4(pwm_ch4),
        .i_pwm_5(pwm_ch5)
    );

    // DSHOT Mailbox (dual-port: Port A for CPU, Port B for SPI)
    wb_dshot_mailbox #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .DEFAULT_MODE(150)
    ) u_dshot_mailbox (
        .clk(clk),
        .rst(rst),
        
        // Port A: CPU (SERV)
        .wba_adr_i(cpu_s1_adr),
        .wba_dat_i(cpu_s1_dat_o),
        .wba_dat_o(cpu_s1_dat_i),
        .wba_sel_i(cpu_s1_sel),
        .wba_we_i(cpu_s1_we),
        .wba_stb_i(cpu_s1_stb),
        .wba_cyc_i(cpu_s1_cyc),
        .wba_ack_o(cpu_s1_ack),
        
        // Port B: SPI
        .wbb_adr_i(spi_s3_adr),
        .wbb_dat_i(spi_s3_dat_o),
        .wbb_dat_o(spi_s3_dat_i),
        .wbb_sel_i(spi_s3_sel),
        .wbb_we_i(spi_s3_we),
        .wbb_stb_i(spi_s3_stb),
        .wbb_cyc_i(spi_s3_cyc),
        .wbb_ack_o(spi_s3_ack),
        
        // Motor outputs
        .motor1_o(motor1_dshot),
        .motor2_o(motor2_dshot),
        .motor3_o(motor3_dshot),
        .motor4_o(motor4_dshot),
        .motor1_ready(),
        .motor2_ready(),
        .motor3_ready(),
        .motor4_ready()
    );

    // NeoPixel Controller (SPI bus)
    wb_neoPx #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ)
    ) u_neopixel (
        .i_clk(clk),
        .i_rst(rst),
        .wb_adr_i(spi_s4_adr),
        .wb_dat_i(spi_s4_dat_o),
        .wb_dat_o(spi_s4_dat_i),
        .wb_we_i(spi_s4_we),
        .wb_sel_i(spi_s4_sel),
        .wb_stb_i(spi_s4_stb),
        .wb_cyc_i(spi_s4_cyc),
        .wb_ack_o(spi_s4_ack),
        .wb_err_o(),
        .wb_rty_o(),
        .o_serial(neopixel_out)
    );
    
    assign neopixel = neopixel_out;

    // Mux Mirror (SPI bus, read-only shadow of mux register)
    assign spi_s5_dat_i = {29'b0, mux_ch, mux_sel};
    assign spi_s5_ack = spi_s5_stb & spi_s5_cyc;

    // =========================================================================
    // CPU Bus Peripherals (only when ENABLE_CPU_BUS=1)
    // =========================================================================
    generate
        if (ENABLE_CPU_BUS) begin : gen_cpu_peripherals
            // Debug GPIO (32-bit for ILA debugging)
            wb_debug_gpio #(
                .GPIO_WIDTH(32)
            ) u_debug_gpio (
                .clk(clk),
                .rst(rst),
                .wb_adr_i(cpu_s0_adr),
                .wb_dat_i(cpu_s0_dat_o),
                .wb_dat_o(cpu_s0_dat_i),
                .wb_we_i(cpu_s0_we),
                .wb_stb_i(cpu_s0_stb),
                .wb_cyc_i(cpu_s0_cyc),
                .wb_ack_o(cpu_s0_ack),
                .gpio_out(debug_gpio_out)
            );
            
            // Serial/DSHOT Mux (CPU bus controlled)
            wb_serial_dshot_mux #(
                .CLK_FREQ_HZ(CLK_FREQ_HZ)
            ) u_serial_mux (
                .wb_clk_i(clk),
                .wb_rst_i(rst),
                .wb_dat_i(cpu_s2_dat_o),
                .wb_adr_i(cpu_s2_adr),
                .wb_we_i(cpu_s2_we),
                .wb_sel_i(cpu_s2_sel),
                .wb_stb_i(cpu_s2_stb),
                .wb_cyc_i(cpu_s2_cyc),
                .wb_dat_o(cpu_s2_dat_i),
                .wb_ack_o(cpu_s2_ack),
                .wb_stall_o(),
                .mux_sel(mux_sel),
                .mux_ch(mux_ch),
                .msp_mode(msp_mode),
                .pc_rx_data(8'b0),
                .pc_rx_valid(1'b0),
                .pad_motor({motor4, motor3, motor2, motor1}),
                .dshot_in({motor4_dshot, motor3_dshot, motor2_dshot, motor1_dshot}),
                .serial_tx_i(esc_uart_tx),
                .serial_oe_i(esc_uart_tx_active),
                .serial_rx_o(esc_uart_rx)
            );
            
            // USB UART
            wb_usb_uart #(
                .CLK_FREQ(CLK_FREQ_HZ),
                .BAUD(USB_BAUD_RATE)
            ) u_usb_uart (
                .clk(clk),
                .rst(rst),
                .wb_adr_i(cpu_s3_adr),
                .wb_dat_i(cpu_s3_dat_o),
                .wb_dat_o(cpu_s3_dat_i),
                .wb_we_i(cpu_s3_we),
                .wb_stb_i(cpu_s3_stb),
                .wb_ack_o(cpu_s3_ack),
                .uart_rx(usb_uart_rx),
                .uart_tx(usb_uart_tx_wire)
            );
            
            // ESC UART
            wb_esc_uart #(
                .CLK_FREQ_HZ(CLK_FREQ_HZ)
            ) u_esc_uart (
                .clk(clk),
                .rst(rst),
                .wb_adr_i(cpu_s4_adr[3:0]),
                .wb_dat_i(cpu_s4_dat_o),
                .wb_dat_o(cpu_s4_dat_i),
                .wb_we_i(cpu_s4_we),
                .wb_stb_i(cpu_s4_stb),
                .wb_cyc_i(cpu_s4_cyc),
                .wb_ack_o(cpu_s4_ack),
                .tx_out(esc_uart_tx),
                .rx_in(esc_uart_rx),
                .tx_active(esc_uart_tx_active)
            );
            
            // Timer (free-running counter for DSHOT auto-repeat timing)
            wb_timer #(
                .CLK_FREQ_HZ(CLK_FREQ_HZ)
            ) u_timer (
                .clk(clk),
                .rst(rst),
                .wb_adr_i(cpu_s5_adr),
                .wb_dat_i(cpu_s5_dat_o),
                .wb_dat_o(cpu_s5_dat_i),
                .wb_sel_i(cpu_s5_sel),
                .wb_we_i(cpu_s5_we),
                .wb_stb_i(cpu_s5_stb),
                .wb_cyc_i(cpu_s5_cyc),
                .wb_ack_o(cpu_s5_ack)
            );
            
            // Tie off external output (not used in CPU mode)
            assign ext_esc_uart_rx = 1'b1;  // Idle high (UART idle state)
        end else begin : gen_no_cpu_peripherals
            // When no CPU bus, tie off internal UARTs
            assign debug_gpio_out = 32'b0;
            assign usb_uart_tx_wire = 1'b1;  // Idle high
            
            // Use external ESC UART for motor mux
            assign esc_uart_tx = ext_esc_uart_tx;
            assign esc_uart_tx_active = ext_esc_uart_tx_en;
            assign ext_esc_uart_rx = esc_uart_rx;
            
            assign cpu_s0_dat_i = 32'h0;
            assign cpu_s0_ack = 1'b0;
            assign cpu_s1_dat_i = 32'h0;
            assign cpu_s1_ack = 1'b0;
            assign cpu_s2_dat_i = 32'h0;
            assign cpu_s2_ack = 1'b0;
            assign cpu_s3_dat_i = 32'h0;
            assign cpu_s3_ack = 1'b0;
            assign cpu_s4_dat_i = 32'h0;
            assign cpu_s4_ack = 1'b0;
            assign cpu_s5_dat_i = 32'h0;
            assign cpu_s5_ack = 1'b0;
            
            // Create simple GPIO-controlled mux for external processor
            wb_serial_dshot_mux #(
                .CLK_FREQ_HZ(CLK_FREQ_HZ)
            ) u_external_mux (
                .wb_clk_i(clk),
                .wb_rst_i(rst),
                .wb_dat_i(32'h0),
                .wb_adr_i(32'h0),
                .wb_we_i(1'b0),
                .wb_sel_i(4'h0),
                .wb_stb_i(1'b0),
                .wb_cyc_i(1'b0),
                .wb_dat_o(),
                .wb_ack_o(),
                .wb_stall_o(),
                .mux_sel(mux_sel),
                .mux_ch(mux_ch),
                .msp_mode(msp_mode),
                .pc_rx_data(8'b0),
                .pc_rx_valid(1'b0),
                .pad_motor({motor4, motor3, motor2, motor1}),
                .dshot_in({motor4_dshot, motor3_dshot, motor2_dshot, motor1_dshot}),
                .serial_tx_i(esc_uart_tx),
                .serial_oe_i(esc_uart_tx_active),
                .serial_rx_o(esc_uart_rx)
            );
        end
    endgenerate

    // Output assignments
    assign debug_gpio = debug_gpio_out;
    assign usb_uart_tx = usb_uart_tx_wire;

endmodule
