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
 *   PC/BLHeliSuite → USB UART (USB_BAUD_RATE) → Hardware Bridge → Serial (SERIAL_BAUD_RATE) → ESC
 *   No software intervention needed - pure hardware passthrough with baud rate conversion.
 *
 * DSHOT Mode (mux_sel=1):
 *   DSHOT controller drives motors, passthrough bridge disabled.
 *
 * See SYSTEM_OVERVIEW.md for full documentation.
 */

module tang9k_top #(
    parameter USB_BAUD_RATE = 115200,
    parameter SERIAL_BAUD_RATE = 19200,
    parameter [2:0] DEBUG_SEL = 3'd5  // MSP RX state machine debug
) (
    // System Clock and Reset
    input  logic i_clk,
    
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
    output logic o_led_6,    
    
    // USB UART Interface (for BLHeli passthrough to PC)
    input  logic i_usb_uart_rx,
    output logic o_usb_uart_tx,
    
    // PWM Decoder Inputs (6 channels)
    input  logic i_pwm_ch0,
    input  logic i_pwm_ch1,
    input  logic i_pwm_ch2,
    input  logic i_pwm_ch3,
    input  logic i_pwm_ch4,
    input  logic i_pwm_ch5,

    // DSHOT Motor Outputs (4 channels)
    // Bidirectional for Serial Passthrough support
    inout  wire  o_motor1,
    inout  wire  o_motor2,
    inout  wire  o_motor3,
    inout  wire  o_motor4,

    // NeoPixel Output
    output logic o_neopixel,

    // Debug probe pins
    output logic o_debug_0,
    output logic o_debug_1,
    output logic o_debug_2
    // Debug mode is now set by parameter DEBUG_SEL at compile time
);

    // Clock and Reset Signals
    logic clk_72m;
    logic pll_locked;
    logic sys_reset;
    
    // PLL instantiation: 27 MHz -> 72 MHz
    pll_27m_to_72m u_pll_72m (
        .clkin(i_clk),
        .clk72(clk_72m),
        .locked(pll_locked)
    );

    // =========================================================================
    // Synchronize pll_locked to 27 MHz domain (2-stage synchronizer)
    // pll_locked is an asynchronous status signal - must be synchronized!
    // =========================================================================
    logic pll_locked_meta = 1'b0;
    logic pll_locked_sync = 1'b0;
    always_ff @(posedge i_clk) begin
        pll_locked_meta <= pll_locked;
        pll_locked_sync <= pll_locked_meta;
    end

    // =========================================================================
    // Power-On Reset Generation (using 27 MHz input clock, NOT PLL output!)
    // =========================================================================
    // Reset counter runs on input clock which is always available
    logic [19:0] rst_cnt_27m;  // 2^20 / 27MHz = ~38ms reset
    logic por_reset_27m;
    
    always_ff @(posedge i_clk) begin
        if (!pll_locked_sync) begin
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
    
    // Synchronize reset to 72 MHz domain (2-stage synchronizer)
    // NOTE: pll_locked status is already incorporated into por_reset_27m,
    // so we don't need a separate pll_locked synchronizer for 72MHz domain
    // Initialize to '1' (reset active) for safe POR
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
    
    assign sys_reset = sys_reset_sync;

    // Debug GPIO output signals (declared before use)
    logic [2:0] debug_gpio_out;

    // Debug GPIO directly controls o_debug pins (via wb_debug_gpio peripheral)
    assign o_debug_0 = debug_gpio_out[0];
    assign o_debug_1 = debug_gpio_out[1];
    assign o_debug_2 = debug_gpio_out[2];

    // =========================================================================
    // 1-second heartbeat on LED6 (runs on 27 MHz input clock - no timing impact)
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
                heartbeat_led_27m <= ~heartbeat_led_27m;  // Toggle every 0.5s = 1Hz blink
            end else begin
                heartbeat_cnt_27m <= heartbeat_cnt_27m + 25'd1;
            end
        end
    end
    
    assign o_led_6 = ~heartbeat_led_27m;  // Active-low LED

    // =========================================================================
    // Wishbone Bus Signals (from SERV to peripherals)
    // =========================================================================
    logic [31:0] wb_adr;
    logic [31:0] wb_dat_m2s;
    logic [31:0] wb_dat_s2m;
    logic [3:0]  wb_sel;
    logic        wb_we;
    logic        wb_stb;
    logic        wb_cyc;
    logic        wb_ack;

    // SERV instruction/data memory bus signals
    logic [31:0] serv_mem_adr;
    logic [31:0] serv_mem_dat;
    logic [3:0]  serv_mem_sel;
    logic        serv_mem_we;
    logic        serv_mem_stb;
    logic [31:0] serv_mem_rdt;
    logic        serv_mem_ack;

    // =========================================================================
    // SERV Wishbone Mux Slave Port Signals (4-port mux)
    // =========================================================================
    // Slave 0: Debug GPIO @ 0x40000100
    logic [31:0] serv_s0_adr, serv_s0_dat_i, serv_s0_dat_o;
    logic [3:0]  serv_s0_sel;
    logic        serv_s0_we, serv_s0_stb, serv_s0_ack, serv_s0_cyc;
    
    // Slave 1: DSHOT Controller (via arbiter) @ 0x40000400
    logic [31:0] serv_s1_adr, serv_s1_dat_i, serv_s1_dat_o;
    logic [3:0]  serv_s1_sel;
    logic        serv_s1_we, serv_s1_stb, serv_s1_ack, serv_s1_cyc;
    logic        serv_s1_err, serv_s1_rty;
    
    // Slave 2: Serial/DSHOT Mux @ 0x40000700
    logic [31:0] serv_s2_adr, serv_s2_dat_i, serv_s2_dat_o;
    logic [3:0]  serv_s2_sel;
    logic        serv_s2_we, serv_s2_stb, serv_s2_ack, serv_s2_cyc;
    logic        mux_sel;
    logic [1:0]  mux_ch;
    logic        msp_mode;

    // Slave 3: USB UART @ 0x40000800
    logic [31:0] serv_s3_adr, serv_s3_dat_i, serv_s3_dat_o;
    logic [3:0]  serv_s3_sel;
    logic        serv_s3_we, serv_s3_stb, serv_s3_ack, serv_s3_cyc;
    logic        usb_uart_tx_wire;

    // Slave 4: ESC UART @ 0x40000900
    logic [31:0] serv_s4_adr, serv_s4_dat_i, serv_s4_dat_o;
    logic [3:0]  serv_s4_sel;
    logic        serv_s4_we, serv_s4_stb, serv_s4_ack, serv_s4_cyc;
    logic        esc_uart_tx, esc_uart_rx, esc_uart_tx_active;

    // =========================================================================
    // DSHOT Arbiter signals (shared between SERV and SPI buses)
    // =========================================================================
    logic [31:0] dshot_adr, dshot_dat_i, dshot_dat_o;
    logic [3:0]  dshot_sel;
    logic        dshot_we, dshot_stb, dshot_ack, dshot_cyc;
    logic        motor1_dshot, motor2_dshot, motor3_dshot, motor4_dshot;

    // =========================================================================
    // Standalone peripheral signals (SPI bus - not yet connected)
    // =========================================================================
    logic [3:0]  led_out;

    // =========================================================================
    // SPI Slave and SPI-WB Master signals
    // =========================================================================
    logic [7:0]  spi_rx_data, spi_tx_data;
    logic        spi_rx_valid, spi_tx_valid, spi_tx_ready;
    logic        spi_miso_out;
    logic        spi_cs_n_sync;  // Synchronized CS from spi_slave for spi_wb_master
    
    // SPI Wishbone Master signals
    logic [31:0] spi_wb_adr, spi_wb_dat_m2s, spi_wb_dat_s2m;
    logic [3:0]  spi_wb_sel;
    logic        spi_wb_we, spi_wb_stb, spi_wb_cyc, spi_wb_ack, spi_wb_err;
    
    // SPI WB Mux slave port signals (6 slaves per SYSTEM_OVERVIEW.md)
    // Slave 0: Version @ 0x0000
    logic [31:0] spi_s0_adr, spi_s0_dat_i, spi_s0_dat_o;
    logic [3:0]  spi_s0_sel;
    logic        spi_s0_we, spi_s0_stb, spi_s0_ack, spi_s0_cyc;
    
    // Slave 1: LED Controller @ 0x0100
    logic [31:0] spi_s1_adr, spi_s1_dat_i, spi_s1_dat_o;
    logic [3:0]  spi_s1_sel;
    logic        spi_s1_we, spi_s1_stb, spi_s1_ack, spi_s1_cyc;
    
    // Slave 2: PWM Decoder @ 0x0200
    logic [31:0] spi_s2_adr, spi_s2_dat_i, spi_s2_dat_o;
    logic [3:0]  spi_s2_sel;
    logic        spi_s2_we, spi_s2_stb, spi_s2_ack, spi_s2_cyc;
    
    // Slave 3: DSHOT (via arbiter) @ 0x0300
    logic [31:0] spi_s3_adr, spi_s3_dat_i, spi_s3_dat_o;
    logic [3:0]  spi_s3_sel;
    logic        spi_s3_we, spi_s3_stb, spi_s3_ack, spi_s3_cyc;
    logic        spi_s3_err, spi_s3_rty;
    
    // Slave 4: NeoPixel @ 0x0400
    logic [31:0] spi_s4_adr, spi_s4_dat_i, spi_s4_dat_o;
    logic [3:0]  spi_s4_sel;
    logic        spi_s4_we, spi_s4_stb, spi_s4_ack, spi_s4_cyc;
    
    // Slave 5: Mux Mirror (read-only) @ 0x0500
    logic [31:0] spi_s5_adr, spi_s5_dat_i, spi_s5_dat_o;
    logic [3:0]  spi_s5_sel;
    logic        spi_s5_we, spi_s5_stb, spi_s5_ack, spi_s5_cyc;
    
    // NeoPixel output signal
    logic neopixel_out;

    // Instantiate SERV RISC-V core (Wishbone wrapper)
    // SERV core Wishbone interface (external bus)
    serv_wb_top u_serv (
        .i_clk(clk_72m),
        .i_rst(sys_reset),
        .o_wb_ext_adr(wb_adr),
        .o_wb_ext_dat(wb_dat_m2s),
        .o_wb_ext_sel(wb_sel),
        .o_wb_ext_we(wb_we),
        .o_wb_ext_stb(wb_stb),
        .o_wb_ext_cyc(wb_cyc),
        .i_wb_ext_rdt(wb_dat_s2m),
        .i_wb_ext_ack(wb_ack),
        // Memory bus connected to instruction RAM
        .o_wb_mem_adr(serv_mem_adr),
        .o_wb_mem_dat(serv_mem_dat),
        .o_wb_mem_sel(serv_mem_sel),
        .o_wb_mem_we(serv_mem_we),
        .o_wb_mem_stb(serv_mem_stb),
        .i_wb_mem_rdt(serv_mem_rdt),
        .i_wb_mem_ack(serv_mem_ack),
        .o_debug_pc(),
        .o_debug_valid()
    );

    // =========================================================================
    // Instruction/Data RAM for SERV CPU
    // 8KB RAM initialized with firmware mem (32-bit word format)
    // =========================================================================
    wb_ram #(
        .DEPTH(8192),
        .MEMFILE("serv/firmware/firmware.mem")
    ) u_serv_ram (
        .i_clk(clk_72m),
        .i_rst(sys_reset),
        .i_wb_adr(serv_mem_adr),
        .i_wb_dat(serv_mem_dat),
        .i_wb_sel(serv_mem_sel),
        .i_wb_we(serv_mem_we),
        .i_wb_stb(serv_mem_stb),
        .o_wb_rdt(serv_mem_rdt),
        .o_wb_ack(serv_mem_ack)
    );

    // =========================================================================
    // Wishbone 5-port Mux - connects SERV ext bus to peripherals
    // Address Map:
    //   0x40000100: Debug GPIO
    //   0x40000400: DSHOT Controller (via arbiter, shared with SPI)
    //   0x40000700: Serial/DSHOT Mux
    //   0x40000800: USB UART (MSP)
    //   0x40000900: ESC UART (BLHeli 19200 baud)
    // =========================================================================
    wb_mux_5 #(
        .DATA_WIDTH(32),
        .ADDR_WIDTH(32),
        .SELECT_WIDTH(4)
    ) u_wb_mux_5_serv (
        .clk(clk_72m),
        .rst(sys_reset),
        
        // Master (from SERV CPU)
        .wbm_adr_i(wb_adr),
        .wbm_dat_i(wb_dat_m2s),
        .wbm_dat_o(wb_dat_s2m),
        .wbm_we_i(wb_we),
        .wbm_sel_i(wb_sel),
        .wbm_stb_i(wb_stb),
        .wbm_ack_o(wb_ack),
        .wbm_err_o(),
        .wbm_rty_o(),
        .wbm_cyc_i(wb_cyc),
        
        // Slave 0: Debug GPIO (0x40000100)
        .wbs0_adr_o(serv_s0_adr),
        .wbs0_dat_i(serv_s0_dat_i),
        .wbs0_dat_o(serv_s0_dat_o),
        .wbs0_we_o(serv_s0_we),
        .wbs0_sel_o(serv_s0_sel),
        .wbs0_stb_o(serv_s0_stb),
        .wbs0_ack_i(serv_s0_ack),
        .wbs0_err_i(1'b0),
        .wbs0_rty_i(1'b0),
        .wbs0_cyc_o(serv_s0_cyc),
        .wbs0_addr(32'h40000100),
        .wbs0_addr_msk(32'hFFFFFF00),
        
        // Slave 1: DSHOT Controller via arbiter (0x40000400)
        .wbs1_adr_o(serv_s1_adr),
        .wbs1_dat_i(serv_s1_dat_i),
        .wbs1_dat_o(serv_s1_dat_o),
        .wbs1_we_o(serv_s1_we),
        .wbs1_sel_o(serv_s1_sel),
        .wbs1_stb_o(serv_s1_stb),
        .wbs1_ack_i(serv_s1_ack),
        .wbs1_err_i(serv_s1_err),
        .wbs1_rty_i(serv_s1_rty),
        .wbs1_cyc_o(serv_s1_cyc),
        .wbs1_addr(32'h40000400),
        .wbs1_addr_msk(32'hFFFFFF00),
        
        // Slave 2: Serial/DSHOT Mux (0x40000700)
        .wbs2_adr_o(serv_s2_adr),
        .wbs2_dat_i(serv_s2_dat_i),
        .wbs2_dat_o(serv_s2_dat_o),
        .wbs2_we_o(serv_s2_we),
        .wbs2_sel_o(serv_s2_sel),
        .wbs2_stb_o(serv_s2_stb),
        .wbs2_ack_i(serv_s2_ack),
        .wbs2_err_i(1'b0),
        .wbs2_rty_i(1'b0),
        .wbs2_cyc_o(serv_s2_cyc),
        .wbs2_addr(32'h40000700),
        .wbs2_addr_msk(32'hFFFFFF00),
        
        // Slave 3: USB UART (0x40000800)
        .wbs3_adr_o(serv_s3_adr),
        .wbs3_dat_i(serv_s3_dat_i),
        .wbs3_dat_o(serv_s3_dat_o),
        .wbs3_we_o(serv_s3_we),
        .wbs3_sel_o(serv_s3_sel),
        .wbs3_stb_o(serv_s3_stb),
        .wbs3_ack_i(serv_s3_ack),
        .wbs3_err_i(1'b0),
        .wbs3_rty_i(1'b0),
        .wbs3_cyc_o(serv_s3_cyc),
        .wbs3_addr(32'h40000800),
        .wbs3_addr_msk(32'hFFFFFF00),
        
        // Slave 4: ESC UART (0x40000900)
        .wbs4_adr_o(serv_s4_adr),
        .wbs4_dat_i(serv_s4_dat_i),
        .wbs4_dat_o(serv_s4_dat_o),
        .wbs4_we_o(serv_s4_we),
        .wbs4_sel_o(serv_s4_sel),
        .wbs4_stb_o(serv_s4_stb),
        .wbs4_ack_i(serv_s4_ack),
        .wbs4_err_i(1'b0),
        .wbs4_rty_i(1'b0),
        .wbs4_cyc_o(serv_s4_cyc),
        .wbs4_addr(32'h40000900),
        .wbs4_addr_msk(32'hFFFFFF00)
    );

    // =========================================================================
    // DSHOT Arbiter - allows both SERV and SPI buses to access DSHOT
    // Master 0: SERV bus (higher priority for MSP motor testing)
    // Master 1: SPI bus (not yet connected - tied off)
    // =========================================================================
    wb_arbiter_2 #(
        .DATA_WIDTH(32),
        .ADDR_WIDTH(32),
        .SELECT_WIDTH(4),
        .ARB_TYPE_ROUND_ROBIN(0),
        .ARB_LSB_HIGH_PRIORITY(1)
    ) u_dshot_arbiter (
        .clk(clk_72m),
        .rst(sys_reset),
        
        // Master 0: SERV bus DSHOT port
        .wbm0_adr_i(serv_s1_adr),
        .wbm0_dat_i(serv_s1_dat_o),
        .wbm0_dat_o(serv_s1_dat_i),
        .wbm0_we_i(serv_s1_we),
        .wbm0_sel_i(serv_s1_sel),
        .wbm0_stb_i(serv_s1_stb),
        .wbm0_ack_o(serv_s1_ack),
        .wbm0_err_o(serv_s1_err),
        .wbm0_rty_o(serv_s1_rty),
        .wbm0_cyc_i(serv_s1_cyc),
        
        // Master 1: SPI bus DSHOT port (slave 3 @ 0x0300)
        .wbm1_adr_i(spi_s3_adr),
        .wbm1_dat_i(spi_s3_dat_o),
        .wbm1_dat_o(spi_s3_dat_i),
        .wbm1_we_i(spi_s3_we),
        .wbm1_sel_i(spi_s3_sel),
        .wbm1_stb_i(spi_s3_stb),
        .wbm1_ack_o(spi_s3_ack),
        .wbm1_err_o(spi_s3_err),
        .wbm1_rty_o(spi_s3_rty),
        .wbm1_cyc_i(spi_s3_cyc),
        
        // Slave: DSHOT Controller
        .wbs_adr_o(dshot_adr),
        .wbs_dat_i(dshot_dat_i),
        .wbs_dat_o(dshot_dat_o),
        .wbs_we_o(dshot_we),
        .wbs_sel_o(dshot_sel),
        .wbs_stb_o(dshot_stb),
        .wbs_ack_i(dshot_ack),
        .wbs_err_i(1'b0),
        .wbs_rty_i(1'b0),
        .wbs_cyc_o(dshot_cyc)
    );

    // =========================================================================
    // Debug GPIO peripheral (fast digital outputs for logic analyzer/scope)
    // Address: 0x40000100 - OUT, 0x04 - SET, 0x08 - CLR, 0x0C - TGL
    // =========================================================================
    wb_debug_gpio #(
        .GPIO_WIDTH(3)
    ) u_debug_gpio (
        .clk(clk_72m),
        .rst(sys_reset),
        .wb_adr_i(serv_s0_adr),
        .wb_dat_i(serv_s0_dat_o),
        .wb_dat_o(serv_s0_dat_i),
        .wb_we_i(serv_s0_we),
        .wb_stb_i(serv_s0_stb),
        .wb_cyc_i(serv_s0_cyc),
        .wb_ack_o(serv_s0_ack),
        .gpio_out(debug_gpio_out)
    );

    // =========================================================================
    // USB UART peripheral (for MSP communication)
    // Address: 0x40000800 - TX/RX data, 0x40000804 - status
    // =========================================================================
    wb_usb_uart #(
        .CLK_FREQ(54_000_000),
        .BAUD(115200)
    ) u_usb_uart (
        .clk(clk_72m),
        .rst(sys_reset),
        .wb_adr_i(serv_s3_adr),
        .wb_dat_i(serv_s3_dat_o),
        .wb_dat_o(serv_s3_dat_i),
        .wb_we_i(serv_s3_we),
        .wb_stb_i(serv_s3_stb),
        .wb_ack_o(serv_s3_ack),
        .uart_rx(i_usb_uart_rx),
        .uart_tx(usb_uart_tx_wire)
    );

    // =========================================================================
    // ESC UART peripheral (for BLHeli configuration, 19200 baud half-duplex)
    // Address: 0x40000900 - TX/RX data, 0x40000904 - status
    // Connected to motor pins via wb_serial_dshot_mux
    // =========================================================================
    wb_esc_uart #(
        .CLK_FREQ_HZ(54_000_000)
    ) u_esc_uart (
        .clk(clk_72m),
        .rst(sys_reset),
        .wb_adr_i(serv_s4_adr[3:0]),
        .wb_dat_i(serv_s4_dat_o),
        .wb_dat_o(serv_s4_dat_i),
        .wb_we_i(serv_s4_we),
        .wb_stb_i(serv_s4_stb),
        .wb_cyc_i(serv_s4_cyc),
        .wb_ack_o(serv_s4_ack),
        .tx_out(esc_uart_tx),
        .rx_in(esc_uart_rx),
        .tx_active(esc_uart_tx_active)
    );

    // =========================================================================
    // DSHOT Controller (via arbiter - shared SERV and SPI access)
    // =========================================================================
    wb_dshot_controller #(
        .CLK_FREQ_HZ(54_000_000),
        .GUARD_TIME(13500),
        .DEFAULT_MODE(150)
    ) u_dshot_ctrl (
        .wb_clk_i(clk_72m),
        .wb_rst_i(sys_reset),
        .wb_dat_i(dshot_dat_o),
        .wb_adr_i(dshot_adr),
        .wb_we_i(dshot_we),
        .wb_sel_i(dshot_sel),
        .wb_stb_i(dshot_stb),
        .wb_cyc_i(dshot_cyc),
        .wb_dat_o(dshot_dat_i),
        .wb_ack_o(dshot_ack),
        .wb_stall_o(),
        .motor1_o(motor1_dshot),
        .motor2_o(motor2_dshot),
        .motor3_o(motor3_dshot),
        .motor4_o(motor4_dshot),
        .dshot_tx(),
        .motor1_ready(),
        .motor2_ready(),
        .motor3_ready(),
        .motor4_ready()
    );

    // =========================================================================
    // SPI Slave Interface
    // =========================================================================
    spi_slave #(
        .DATA_WIDTH(8)
    ) u_spi_slave (
        .i_clk(clk_72m),
        .i_rst(sys_reset),
        .i_sclk(i_spi_clk),
        .i_cs_n(i_spi_cs_n),
        .i_mosi(i_spi_mosi),
        .o_miso(spi_miso_out),
        .o_rx_data(spi_rx_data),
        .o_data_valid(spi_rx_valid),
        .i_tx_data(spi_tx_data),
        .i_tx_valid(spi_tx_valid),
        .o_tx_ready(spi_tx_ready),
        .o_busy(),
        .o_cs_n_sync(spi_cs_n_sync)
    );
    
    assign o_spi_miso = spi_miso_out;

    // =========================================================================
    // SPI to Wishbone Bridge
    // Protocol: [cmd][len 2B LE][addr 4B LE][data/pad][0xDA]
    // =========================================================================
    spi_wb_master #(
        .WB_ADDR_WIDTH(32),
        .WB_DATA_WIDTH(32)
    ) u_spi_wb_master (
        .clk(clk_72m),
        .rst(sys_reset),
        .spi_rx_valid(spi_rx_valid),
        .spi_rx_data(spi_rx_data),
        .spi_tx_valid(spi_tx_valid),
        .spi_tx_data(spi_tx_data),
        .spi_tx_ready(spi_tx_ready),
        .spi_cs_n(spi_cs_n_sync),  // Use synchronized CS from spi_slave
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
    // SPI Wishbone Mux (6 slaves)
    // Address Map:
    //   0x0000: Version (R)
    //   0x0100: LED Controller (RW)
    //   0x0200: PWM Decoder (R)
    //   0x0300: DSHOT (RW, via arbiter)
    //   0x0400: NeoPixel (RW)
    //   0x0500: Mux Mirror (R)
    // =========================================================================
    wb_mux_6 #(
        .DATA_WIDTH(32),
        .ADDR_WIDTH(32),
        .SELECT_WIDTH(4)
    ) u_wb_mux_6_spi (
        .clk(clk_72m),
        .rst(sys_reset),
        
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
        
        // Slave 3: DSHOT via arbiter (0x0300)
        .wbs3_adr_o(spi_s3_adr),
        .wbs3_dat_i(spi_s3_dat_i),
        .wbs3_dat_o(spi_s3_dat_o),
        .wbs3_we_o(spi_s3_we),
        .wbs3_sel_o(spi_s3_sel),
        .wbs3_stb_o(spi_s3_stb),
        .wbs3_ack_i(spi_s3_ack),
        .wbs3_err_i(spi_s3_err),
        .wbs3_rty_i(spi_s3_rty),
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
        
        // Slave 5: Mux Mirror (0x0500, read-only)
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
    // Version Register (SPI bus, read-only)
    // Address: 0x0000
    // =========================================================================
    wb_version u_wb_version (
        .i_clk(clk_72m),
        .i_rst(sys_reset),
        .wb_adr_i(spi_s0_adr[3:0]),
        .wb_dat_i(spi_s0_dat_o),
        .wb_dat_o(spi_s0_dat_i),
        .wb_we_i(spi_s0_we),
        .wb_stb_i(spi_s0_stb),
        .wb_ack_o(spi_s0_ack),
        .wb_cyc_i(spi_s0_cyc)
    );

    // =========================================================================
    // LED Controller (SPI bus)
    // Address: 0x0100
    // =========================================================================
    wb_led_controller #(
        .LED_WIDTH(4)
    ) u_led_ctrl (
        .clk(clk_72m),
        .rst(sys_reset),
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
    
    assign o_led_1 = ~led_out[0];  // Active-low LEDs
    assign o_led_2 = ~led_out[1];
    assign o_led_3 = ~led_out[2];
    assign o_led_4 = ~led_out[3];
    assign o_led_5 = 1'b1;  // Off (active-low)

    // =========================================================================
    // PWM Decoder (SPI bus, read-only)
    // Address: 0x0200
    // =========================================================================
    pwmdecoder_wb #(
        .clockFreq(54_000_000)
    ) u_pwm_decoder (
        .i_clk(clk_72m),
        .i_rst(sys_reset),
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
        .i_pwm_0(i_pwm_ch0),
        .i_pwm_1(i_pwm_ch1),
        .i_pwm_2(i_pwm_ch2),
        .i_pwm_3(i_pwm_ch3),
        .i_pwm_4(i_pwm_ch4),
        .i_pwm_5(i_pwm_ch5)
    );

    // =========================================================================
    // NeoPixel Controller (SPI bus)
    // Address: 0x0400
    // =========================================================================
    wb_neoPx #(
        .CLK_FREQ_HZ(54_000_000)
    ) u_neopixel (
        .i_clk(clk_72m),
        .i_rst(sys_reset),
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
    
    assign o_neopixel = neopixel_out;

    // =========================================================================
    // Mux Mirror (SPI bus, read-only shadow of mux register)
    // Address: 0x0500
    // Returns: {29'b0, mux_ch[1:0], mux_sel}
    // =========================================================================
    assign spi_s5_dat_i = {29'b0, mux_ch, mux_sel};
    assign spi_s5_ack = spi_s5_stb & spi_s5_cyc;

    // =========================================================================
    // Serial/DSHOT Mux
    // Address: 0x40000700
    // Routes ESC UART or DSHOT to motor pins based on mux_sel
    // =========================================================================
    wb_serial_dshot_mux #(
        .CLK_FREQ_HZ(54_000_000)
    ) u_serial_mux (
        .wb_clk_i(clk_72m),
        .wb_rst_i(sys_reset),
        .wb_dat_i(serv_s2_dat_o),
        .wb_adr_i(serv_s2_adr),
        .wb_we_i(serv_s2_we),
        .wb_sel_i(serv_s2_sel),
        .wb_stb_i(serv_s2_stb),
        .wb_cyc_i(serv_s2_cyc),
        .wb_dat_o(serv_s2_dat_i),
        .wb_ack_o(serv_s2_ack),
        .wb_stall_o(),
        .mux_sel(mux_sel),
        .mux_ch(mux_ch),
        .msp_mode(msp_mode),
        .pc_rx_data(8'b0),
        .pc_rx_valid(1'b0),
        .pad_motor({o_motor4, o_motor3, o_motor2, o_motor1}),
        .dshot_in({motor4_dshot, motor3_dshot, motor2_dshot, motor1_dshot}),
        .serial_tx_i(esc_uart_tx),
        .serial_oe_i(esc_uart_tx_active),
        .serial_rx_o(esc_uart_rx)
    );

    // USB UART TX output
    assign o_usb_uart_tx = usb_uart_tx_wire;

endmodule
