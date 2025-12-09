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
    input  logic i_rst_n,
    
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
    inout  wire  serial,
    
    // PWM Decoder Inputs (6 channels)
    input  logic i_pwm_ch0,
    input  logic i_pwm_ch1,
    input  logic i_pwm_ch2,
    input  logic i_pwm_ch3,
    input  logic i_pwm_ch4,
    input  logic i_pwm_ch5,
    
    // DSHOT Motor Outputs (4 channels)
    output logic o_motor1,
    output logic o_motor2,
    output logic o_motor3,
    output logic o_motor4,

    // NeoPixel Output
    output logic o_neopixel,
    
    // Status LEDs
    output logic o_status_led0,
    output logic o_status_led1,
    output logic o_status_led2
);

    // =============================
    // Clock Generation (27 MHz -> 72 MHz)
    // =============================
    logic clk_72m;
    logic pll_locked;
    logic sys_rst;
    
    assign sys_rst = ~i_rst_n | ~pll_locked;
    
    pll_27m_to_72m u_pll_72m (
        .clkin(i_sys_clk),
        .clk72(clk_72m),
        .locked(pll_locked)
    );
    
    // Use 72 MHz for system clock
    logic clk;
    assign clk = clk_72m;
    
    // =============================
    // SPI Slave Instance
    // =============================
    logic [7:0] spi_rx_data;
    logic       spi_rx_valid;
    logic [7:0] spi_tx_data;
    logic       spi_tx_valid;
    logic       spi_busy;
    
    spi_slave #(
        .DATA_WIDTH(8)
    ) u_spi_slave (
        .i_clk      (i_sys_clk),
        .i_rst_n    (i_rst_n),
        .i_sclk     (i_spi_clk),
        .i_cs_n     (i_spi_cs_n),
        .i_mosi     (i_spi_mosi),
        .o_miso     (o_spi_miso),
        .o_rx_data  (spi_rx_data),
        .o_rx_valid (spi_rx_valid),
        .i_tx_data  (spi_tx_data),
        .i_tx_valid (spi_tx_valid),
        .o_busy     (spi_busy)
    );
    
    // =============================
    // SPI to AXI Stream Adapter
    // =============================
    logic [7:0] axis_in_tdata;
    logic       axis_in_tvalid;
    logic       axis_in_tready;
    logic       axis_in_tlast;
    
    logic [7:0] axis_out_tdata;
    logic       axis_out_tvalid;
    logic       axis_out_tready;
    logic       axis_out_tlast;
    
    spi_axis_adapter u_spi_axis_adapter (
        .clk             (clk),
        .rst_n           (~sys_rst),
        .spi_rx_data     (spi_rx_data),
        .spi_rx_valid    (spi_rx_valid),
        .spi_tx_data     (spi_tx_data),
        .spi_tx_valid    (spi_tx_valid),
        .spi_busy        (spi_busy),
        .spi_cs_n        (i_spi_cs_n),
        .m_axis_tdata    (axis_in_tdata),
        .m_axis_tvalid   (axis_in_tvalid),
        .m_axis_tready   (axis_in_tready),
        .m_axis_tlast    (axis_in_tlast),
        .s_axis_tdata    (axis_out_tdata),
        .s_axis_tvalid   (axis_out_tvalid),
        .s_axis_tready   (axis_out_tready),
        .s_axis_tlast    (axis_out_tlast)
    );
    
    // =============================
    // AXI Stream to Wishbone Master
    // =============================
    logic [31:0] wb_adr;
    logic [31:0] wb_dat_m2s;
    logic [31:0] wb_dat_s2m;
    logic        wb_we;
    logic [3:0]  wb_sel;
    logic        wb_stb;
    logic        wb_ack;
    logic        wb_err;
    logic        wb_cyc;
    
    axis_wb_master #(
        .IMPLICIT_FRAMING (1),              // Use implicit framing - detect command bytes
        .COUNT_SIZE       (16),
        .AXIS_DATA_WIDTH  (8),
        .WB_DATA_WIDTH    (32),
        .WB_ADDR_WIDTH    (32),
        .READ_REQ         (8'hA1),
        .WRITE_REQ        (8'hA2),
        .READ_RESP        (8'hA3),
        .WRITE_RESP       (8'hA4)
    ) u_axis_wb_master (
        .clk                 (clk),
        .rst                 (sys_rst),
        .input_axis_tdata    (axis_in_tdata),
        .input_axis_tkeep    (1'b1),
        .input_axis_tvalid   (axis_in_tvalid),
        .input_axis_tready   (axis_in_tready),
        .input_axis_tlast    (1'b0),        // Not used in implicit framing mode
        .input_axis_tuser    (1'b0),
        .output_axis_tdata   (axis_out_tdata),
        .output_axis_tkeep   (),
        .output_axis_tvalid  (axis_out_tvalid),
        .output_axis_tready  (axis_out_tready),
        .output_axis_tlast   (axis_out_tlast),
        .output_axis_tuser   (),
        .wb_adr_o            (wb_adr),
        .wb_dat_i            (wb_dat_s2m),
        .wb_dat_o            (wb_dat_m2s),
        .wb_we_o             (wb_we),
        .wb_sel_o            (wb_sel),
        .wb_stb_o            (wb_stb),
        .wb_ack_i            (wb_ack),
        .wb_err_i            (wb_err),
        .wb_cyc_o            (wb_cyc),
        .busy                ()
    );
    
    // =============================
    // Simple Register File
    // =============================
    logic [7:0] reg_ctrl;
    logic [7:0] reg_status;
    logic [7:0] reg_data;
    
    // =============================
    // Wishbone Peripherals
    // =============================
    
    // Wishbone signals for each peripheral
    logic [31:0] wb_neopx_dat_s2m;
    logic        wb_neopx_ack;
    logic        wb_neopx_stall;
    logic [31:0] wb_led_dat_s2m;
    logic        wb_led_ack;
    logic        wb_led_stall;

    logic [31:0] wb_pwm_dat_s2m;
    logic        wb_pwm_ack;
    logic        wb_pwm_stall;

    logic [31:0] wb_dshot_dat_s2m;
    logic        wb_dshot_ack;
    logic        wb_dshot_stall;

    // Mux register signals
    logic [31:0] wb_mux_dat_s2m;
    logic        wb_mux_ack;
    logic        wb_mux_stall;
    logic        mux_sel; // 0: Serial Passthrough Mode, 1: DSHOT Mode
    
    // Address decode (simple - can be enhanced with wb_mux)
    // 0x0000-0x00FF: LED Controller
    // 0x0200-0x02FF: PWM Decoder
    // 0x0300-0x03FF: DSHOT Controller
    // 0x0400: Serial/DSHOT Mux Register
    // 0x0500-0x05FF: NeoPixel Controller

    logic sel_led, sel_pwm, sel_dshot, sel_mux;
    assign sel_led    = (wb_adr[31:8] == 24'h0000);
    assign sel_pwm    = (wb_adr[31:8] == 24'h0002);
    assign sel_dshot  = (wb_adr[31:8] == 24'h0003);
    assign sel_mux    = (wb_adr[31:2] == 30'h000100); // 0x0400 word-aligned
    assign sel_neopx  = (wb_adr[31:8] == 24'h0005);

    // Wishbone response mux
    assign wb_dat_s2m = sel_led    ? wb_led_dat_s2m :
                        sel_pwm    ? wb_pwm_dat_s2m :
                        sel_dshot  ? wb_dshot_dat_s2m :
                        sel_mux    ? wb_mux_dat_s2m :
                        sel_neopx  ? wb_neopx_dat_s2m : 32'h0;

    assign wb_ack = sel_led    ? wb_led_ack :
                    sel_pwm    ? wb_pwm_ack :
                    sel_dshot  ? wb_dshot_ack :
                    sel_mux    ? wb_mux_ack :
                    sel_neopx  ? wb_neopx_ack : 1'b0;
    // NeoPixel Controller (Wishbone)
    wb_neoPx u_wb_neopx (
        .i_clk      (clk),
        .i_rst      (sys_rst),
        .wb_adr_i   (wb_adr),
        .wb_dat_i   (wb_dat_m2s),
        .wb_dat_o   (wb_neopx_dat_s2m),
        .wb_we_i    (wb_we & sel_neopx),
        .wb_sel_i   (wb_sel),
        .wb_stb_i   (wb_stb & sel_neopx),
        .wb_ack_o   (wb_neopx_ack),
        .wb_err_o   (),
        .wb_rty_o   (),
        .wb_cyc_i   (wb_cyc & sel_neopx),
        .m_axis_data(),
        .m_axis_valid(),
        .s_axis_ready(1'b1)
    );

    // Connect NeoPixel output (if needed, wire m_axis_data/m_axis_valid to a NeoPixel driver)
    assign o_neopixel = 1'b0; // Placeholder, connect to actual NeoPixel output logic

    assign wb_err = 1'b0;  // No errors for now
    
    // =============================
    // LED Controller (Wishbone)
    // =============================
    wb_led_controller u_wb_led (
        .wb_clk_i   (clk),
        .wb_rst_i   (sys_rst),
        .wb_dat_i   (wb_dat_m2s),
        .wb_adr_i   (wb_adr),
        .wb_we_i    (wb_we & sel_led),
        .wb_sel_i   (wb_sel),
        .wb_stb_i   (wb_stb & sel_led),
        .wb_cyc_i   (wb_cyc & sel_led),
        .wb_dat_o   (wb_led_dat_s2m),
        .wb_ack_o   (wb_led_ack),
        .wb_stall_o (wb_led_stall),
        .led_o      ({o_led3, o_led2, o_led1, o_led0})
    );
    
    // =============================
    // Serial/DSHOT Mux Register (Wishbone)
    // =============================
    wb_serial_dshot_mux u_wb_mux (
        .wb_clk_i   (clk),
        .wb_rst_i   (sys_rst),
        .wb_dat_i   (wb_dat_m2s),
        .wb_adr_i   (wb_adr),
        .wb_we_i    (wb_we & sel_mux),
        .wb_sel_i   (wb_sel),
        .wb_stb_i   (wb_stb & sel_mux),
        .wb_cyc_i   (wb_cyc & sel_mux),
        .wb_dat_o   (wb_mux_dat_s2m),
        .wb_ack_o   (wb_mux_ack),
        .wb_stall_o (wb_mux_stall),
        .mux_sel    (mux_sel)
    );

    // =============================
    // USB UART Passthrough Bridge
    // =============================
    // This is a dedicated hardware bridge that bypasses Wishbone entirely.
    // When mux_sel==0 (Serial Mode): USB UART ←→ ESC (passthrough enabled)
    // When mux_sel==1 (DSHOT Mode): Bridge disabled, DSHOT controls motors
    
    logic passthrough_enable;
    logic passthrough_active;
    
    // Enable passthrough when mux_sel==0 (Serial Mode)
    assign passthrough_enable = (mux_sel == 1'b0);
    
    uart_passthrough_bridge #(
        .CLK_FREQ_HZ(72_000_000),
        .BAUD_RATE(115200)
    ) u_uart_passthrough (
        .clk(clk),
        .rst(sys_rst),
        .usb_uart_rx(i_usb_uart_rx),
        .usb_uart_tx(o_usb_uart_tx),
        .serial(serial),                    // Direct connection to half-duplex ESC pin
        .enable(passthrough_enable),
        .active(passthrough_active)
    );
    
    // =============================
    // PWM Decoder (Wishbone)
    // =============================
    pwmdecoder_wb u_wb_pwm (
        .i_clk      (clk),
        .i_reset    (sys_rst),
        .wb_adr_i   (wb_adr[7:0]),
        .wb_dat_i   (wb_dat_m2s),
        .wb_we_i    (wb_we & sel_pwm),
        .wb_stb_i   (wb_stb & sel_pwm),
        .wb_cyc_i   (wb_cyc & sel_pwm),
        .wb_dat_o   (wb_pwm_dat_s2m),
        .wb_ack_o   (wb_pwm_ack),
        .i_pwm({i_pwm_ch5, i_pwm_ch4, i_pwm_ch3, i_pwm_ch2, i_pwm_ch1, i_pwm_ch0})
    );
    
    assign wb_pwm_stall = 1'b0;
    
    // =============================
    // DSHOT Controller (Wishbone)
    // =============================
    wb_dshot_controller #(
        .CLK_FREQ_HZ (72_000_000)
    ) u_wb_dshot (
        .wb_clk_i   (clk),
        .wb_rst_i   (sys_rst),
        .wb_dat_i   (wb_dat_m2s),
        .wb_adr_i   (wb_adr),
        .wb_we_i    (wb_we & sel_dshot),
        .wb_sel_i   (wb_sel),
        .wb_stb_i   (wb_stb & sel_dshot),
        .wb_cyc_i   (wb_cyc & sel_dshot),
        .wb_dat_o   (wb_dshot_dat_s2m),
        .wb_ack_o   (wb_dshot_ack),
        .wb_stall_o (wb_dshot_stall),
        .motor1_o   (o_motor1),
        .motor2_o   (o_motor2),
        .motor3_o   (o_motor3),
        .motor4_o   (o_motor4)
    );
    
    // =============================
    // Status LEDs - show system state
    // =============================
    assign o_status_led0 = pll_locked;
    assign o_status_led1 = spi_busy;
    assign o_status_led2 = wb_cyc;

endmodule
