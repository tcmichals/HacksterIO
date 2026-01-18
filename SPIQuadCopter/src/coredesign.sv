/**
 * design
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
/* the clock is 72 Mhz */
module coredesign #(
    parameter CLK_FREQ_HZ = 72_000_000
) (
    // System Clock and Reset
    input  logic  i_sys_clk,
    input  logic  i_rst,
    // PLL locked indicator from top-level PLL
    input  logic  i_pll_locked,
    
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
    output logic o_led4, 
    

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
    inout  wire o_motor1,
    inout  wire o_motor2,
    inout  wire o_motor3,
    inout  wire o_motor4,

    // NeoPixel Output
    output logic o_neopixel,
    // Debug probe: mirrors SPI byte-ready (exposed to top-level as `o_debug`)
    output logic o_debug_0,
    output logic o_debug_1,
    output logic o_debug_2
    
);

    // System reset driven from external PLL lock
    logic sys_rst;

    assign sys_rst = i_rst | ~i_pll_locked;

    
    // =============================
    // SPI Slave Instance
    // =============================
    logic [7:0] spi_rx_data;
    logic       spi_rx_valid;
    logic [7:0] spi_tx_data;
    logic       spi_tx_valid;
    logic       spi_busy;
    
    logic       spi_tx_ready;
    logic       spi_cs_n_synced; // New wire for synchronized CS
    
    spi_slave #(
        .DATA_WIDTH(8)
    ) u_spi_slave (
        .i_clk      (i_sys_clk),
        .i_rst      (sys_rst),
        .i_sclk     (i_spi_clk),
        .i_cs_n     (i_spi_cs_n),
        .i_mosi     (i_spi_mosi),
        .o_miso     (o_spi_miso),
        .o_rx_data  (spi_rx_data),
        .o_data_valid (spi_rx_valid),
        .i_tx_data  (spi_tx_data),
        .i_tx_valid (spi_tx_valid),
        .o_tx_ready (spi_tx_ready), 
        .o_busy     (spi_busy),
        .o_cs_n_sync(spi_cs_n_synced)
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
        .clk             (i_sys_clk),
        .rst             (sys_rst),
        .spi_rx_data     (spi_rx_data),
        .spi_rx_valid    (spi_rx_valid),
        .spi_tx_data     (spi_tx_data),
        .spi_tx_valid    (spi_tx_valid),
        .spi_busy        (spi_busy),
        .spi_cs_n        (i_spi_cs_n),
        .spi_tx_ready    (spi_tx_ready),

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
    
    // AXI->Wishbone master reset and busy indicator
    logic axis_master_rst;
    logic axis_master_busy;
    // Gate master reset: assert reset when system reset OR when SPI CS is inactive
    // and the master is idle. This avoids aborting in-flight transactions.
    // USES SYNCED CS to avoid glitches
    assign axis_master_rst = sys_rst | (spi_cs_n_synced); // & ~axis_master_busy);

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
        .clk                 (i_sys_clk),
        .rst                 (axis_master_rst),
        .input_axis_tdata    (axis_in_tdata),
        .input_axis_tkeep    (),
        .input_axis_tvalid   (axis_in_tvalid),
        .input_axis_tready   (axis_in_tready),
        .input_axis_tlast    (1'b0),        // Not used in implicit framing mode
        .input_axis_tuser    (),
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
        .busy                (axis_master_busy)
    );


    // (axis_master_rst and axis_master_busy declared above)
    
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

    // Version Module signals
    logic [31:0] wb_ver_dat_s2m;
    logic        wb_ver_ack;

    // Mux register signals
    logic [31:0] wb_mux_dat_s2m;
    logic        wb_mux_ack;
    logic        wb_mux_stall;
    logic        mux_sel; // 0: Serial Passthrough Mode, 1: DSHOT Mode
    
    // Use generated Wishbone multiplexer (6 slaves)
    // slaves: 0=LED, 1=PWM, 2=DSHOT, 3=Serial/DSHOT Mux, 4=NeoPixel, 5=Version

    // Mux-to-slave wires (outputs from mux to each slave)
    logic [31:0] wbs0_adr_o, wbs1_adr_o, wbs2_adr_o, wbs3_adr_o, wbs4_adr_o, wbs5_adr_o;
    logic [31:0] wbs0_dat_o, wbs1_dat_o, wbs2_dat_o, wbs3_dat_o, wbs4_dat_o, wbs5_dat_o;
    logic        wbs0_we_o,  wbs1_we_o,  wbs2_we_o,  wbs3_we_o,  wbs4_we_o,  wbs5_we_o;
    logic [3:0]  wbs0_sel_o, wbs1_sel_o, wbs2_sel_o, wbs3_sel_o, wbs4_sel_o, wbs5_sel_o;
    logic        wbs0_stb_o, wbs1_stb_o, wbs2_stb_o, wbs3_stb_o, wbs4_stb_o, wbs5_stb_o;
    logic        wbs0_cyc_o, wbs1_cyc_o, wbs2_cyc_o, wbs3_cyc_o, wbs4_cyc_o, wbs5_cyc_o;

    // Master-side response from mux
    logic [31:0] wb_m_dat_s2m;
    logic        wb_m_ack;

    // Instantiate generated mux
    wb_mux_6 u_wb_mux_6 (
        .clk           (i_sys_clk),
        .rst           (sys_rst),
        .wbm_adr_i     (wb_adr),
        .wbm_dat_i     (wb_dat_m2s),
        .wbm_dat_o     (wb_m_dat_s2m),
        .wbm_we_i      (wb_we),
        .wbm_sel_i     (wb_sel),
        .wbm_stb_i     (wb_stb),
        .wbm_ack_o     (wb_m_ack),
        .wbm_err_o     (wb_err),
        .wbm_rty_o     (),
        .wbm_cyc_i     (wb_cyc),

        // slave 0 (LED)
        .wbs0_adr_o    (wbs0_adr_o),
        .wbs0_dat_i    (wb_led_dat_s2m),
        .wbs0_dat_o    (wbs0_dat_o),
        .wbs0_we_o     (wbs0_we_o),
        .wbs0_sel_o    (wbs0_sel_o),
        .wbs0_stb_o    (wbs0_stb_o),
        .wbs0_ack_i    (wb_led_ack),
        .wbs0_err_i    (1'b0),
        .wbs0_rty_i    (1'b0),
        .wbs0_cyc_o    (wbs0_cyc_o),
        .wbs0_addr     (32'h00000000),
        .wbs0_addr_msk (32'hffffff00),

        // slave 1 (PWM)
        .wbs1_adr_o    (wbs1_adr_o),
        .wbs1_dat_i    (wb_pwm_dat_s2m),
        .wbs1_dat_o    (wbs1_dat_o),
        .wbs1_we_o     (wbs1_we_o),
        .wbs1_sel_o    (wbs1_sel_o),
        .wbs1_stb_o    (wbs1_stb_o),
        .wbs1_ack_i    (wb_pwm_ack),
        .wbs1_err_i    (1'b0),
        .wbs1_rty_i    (1'b0),
        .wbs1_cyc_o    (wbs1_cyc_o),
        .wbs1_addr     (32'h00000200),
        .wbs1_addr_msk (32'hffffff00),
        
        // slave 2 (DSHOT)
        .wbs2_adr_o    (wbs2_adr_o),
        .wbs2_dat_i    (wb_dshot_dat_s2m),
        .wbs2_dat_o    (wbs2_dat_o),
        .wbs2_we_o     (wbs2_we_o),
        .wbs2_sel_o    (wbs2_sel_o),
        .wbs2_stb_o    (wbs2_stb_o),
        .wbs2_ack_i    (wb_dshot_ack),
        .wbs2_err_i    (1'b0),
        .wbs2_rty_i    (1'b0),
        .wbs2_cyc_o    (wbs2_cyc_o),
        .wbs2_addr     (32'h00000300),
        .wbs2_addr_msk (32'hffffff00),

        // slave 3 (MUX REG)
        .wbs3_adr_o    (wbs3_adr_o),
        .wbs3_dat_i    (wb_mux_dat_s2m),
        .wbs3_dat_o    (wbs3_dat_o),
        .wbs3_we_o     (wbs3_we_o),
        .wbs3_sel_o    (wbs3_sel_o),
        .wbs3_stb_o    (wbs3_stb_o),
        .wbs3_ack_i    (wb_mux_ack),
        .wbs3_err_i    (1'b0),
        .wbs3_rty_i    (1'b0),
        .wbs3_cyc_o    (wbs3_cyc_o),
        .wbs3_addr     (32'h00000400),
        .wbs3_addr_msk (32'hffffff00),

        // slave 4 (NeoPixel)
        .wbs4_adr_o    (wbs4_adr_o),
        .wbs4_dat_i    (wb_neopx_dat_s2m),
        .wbs4_dat_o    (wbs4_dat_o),
        .wbs4_we_o     (wbs4_we_o),
        .wbs4_sel_o    (wbs4_sel_o),
        .wbs4_stb_o    (wbs4_stb_o),
        .wbs4_ack_i    (wb_neopx_ack),
        .wbs4_err_i    (1'b0),
        .wbs4_rty_i    (1'b0),
        .wbs4_cyc_o    (wbs4_cyc_o),
        .wbs4_addr     (32'h00000500),
        .wbs4_addr_msk (32'hffffff00),
        
        // slave 5 (Version)
        .wbs5_adr_o    (wbs5_adr_o),
        .wbs5_dat_i    (wb_ver_dat_s2m),
        .wbs5_dat_o    (wbs5_dat_o), // open
        .wbs5_we_o     (wbs5_we_o),
        .wbs5_sel_o    (wbs5_sel_o),
        .wbs5_stb_o    (wbs5_stb_o),
        .wbs5_ack_i    (wb_ver_ack),
        .wbs5_err_i    (1'b0),
        .wbs5_rty_i    (1'b0),
        .wbs5_cyc_o    (wbs5_cyc_o),
        .wbs5_addr     (32'h00000600),
        .wbs5_addr_msk (32'hffffff00)
    );

    // Version Module Instance
    wb_version u_wb_version (
        .i_clk(i_sys_clk),
        .i_rst(sys_rst),
        .wb_adr_i(wbs5_adr_o),
        .wb_dat_i(wbs5_dat_o),
        .wb_dat_o(wb_ver_dat_s2m),
        .wb_we_i(wbs5_we_o),
        .wb_stb_i(wbs5_stb_o),
        .wb_ack_o(wb_ver_ack),
        .wb_cyc_i(wbs5_cyc_o)
    );


    // Connect master response signals from mux back to axis_wb_master
    assign wb_dat_s2m = wb_m_dat_s2m;
    assign wb_ack = wb_m_ack;

    // Debug: trace wishbone master transactions and mux selection
    always_ff @(posedge i_sys_clk) begin
        if (wb_stb && wb_cyc) begin
            $display("WB_MASTER: adr=%08x dat=%08x we=%b sel=%b stb=%b cyc=%b", wb_adr, wb_dat_m2s, wb_we, wb_sel, wb_stb, wb_cyc);
            if (wbs0_stb_o) $display("  MUX->SLAVE0 (LED): adr=%08x dat=%08x we=%b sel=%b stb=%b cyc=%b ack=%b", wbs0_adr_o, wbs0_dat_o, wbs0_we_o, wbs0_sel_o, wbs0_stb_o, wbs0_cyc_o, wb_led_ack);
            if (wbs1_stb_o) $display("  MUX->SLAVE1 (PWM): adr=%08x dat=%08x we=%b sel=%b stb=%b cyc=%b ack=%b", wbs1_adr_o, wbs1_dat_o, wbs1_we_o, wbs1_sel_o, wbs1_stb_o, wbs1_cyc_o, wb_pwm_ack);
            if (wbs2_stb_o) $display("  MUX->SLAVE2 (DSHOT): adr=%08x dat=%08x we=%b sel=%b stb=%b cyc=%b ack=%b", wbs2_adr_o, wbs2_dat_o, wbs2_we_o, wbs2_sel_o, wbs2_stb_o, wbs2_cyc_o, wb_dshot_ack);
            if (wbs3_stb_o) $display("  MUX->SLAVE3 (MUXREG): adr=%08x dat=%08x we=%b sel=%b stb=%b cyc=%b ack=%b", wbs3_adr_o, wbs3_dat_o, wbs3_we_o, wbs3_sel_o, wbs3_stb_o, wbs3_cyc_o, wb_mux_ack);
            if (wbs4_stb_o) $display("  MUX->SLAVE4 (NEOPX): adr=%08x dat=%08x we=%b sel=%b stb=%b cyc=%b ack=%b", wbs4_adr_o, wbs4_dat_o, wbs4_we_o, wbs4_sel_o, wbs4_stb_o, wbs4_cyc_o, wb_neopx_ack);
            if (wbs5_stb_o) $display("  MUX->SLAVE5 (VER):   adr=%08x dat=%08x we=%b sel=%b stb=%b cyc=%b ack=%b rdat=%08x", wbs5_adr_o, wbs5_dat_o, wbs5_we_o, wbs5_sel_o, wbs5_stb_o, wbs5_cyc_o, wb_ver_ack, wb_ver_dat_s2m);
            if (wbs1_stb_o) $display("  MUX->SLAVE1 (PWM):   adr=%08x dat=%08x we=%b sel=%b stb=%b cyc=%b ack=%b rdat=%08x", wbs1_adr_o, wbs1_dat_o, wbs1_we_o, wbs1_sel_o, wbs1_stb_o, wbs1_cyc_o, wb_pwm_ack, wb_pwm_dat_s2m);
        end
    end


    wb_neoPx #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ)
    ) u_wb_neopx (
        .i_clk      (i_sys_clk),
        .i_rst      (sys_rst),
        .wb_adr_i   (wbs4_adr_o),
        .wb_dat_i   (wbs4_dat_o),
        .wb_dat_o   (wb_neopx_dat_s2m),
        .wb_we_i    (wbs4_we_o),
        .wb_sel_i   (wbs4_sel_o),
        .wb_stb_i   (wbs4_stb_o),
        .wb_ack_o   (wb_neopx_ack),
        .wb_err_o   (),
        .wb_rty_o   (),
        .wb_cyc_i   (wbs4_cyc_o),
        .o_serial(o_neopixel)

    );



    // Connect NeoPixel output (if needed, wire m_axis_data/m_axis_valid to a NeoPixel driver)
    
    // =============================
    // LED Controller (Wishbone) - slave 0 on mux
    // =============================
    wb_led_controller #(
        .LED_WIDTH(5),
        .LED_POLARITY(0) // Active Low
    ) u_wb_led (
        .clk        (i_sys_clk),
        .rst        (sys_rst),
        .wbs_dat_i  (wbs0_dat_o),
        .wbs_adr_i  (wbs0_adr_o),
        .wbs_we_i   (wbs0_we_o),
        .wbs_sel_i  (wbs0_sel_o),
        .wbs_stb_i  (wbs0_stb_o),
        .wbs_cyc_i  (wbs0_cyc_o),
        .wbs_dat_o  (wb_led_dat_s2m),
        .wbs_ack_o  (wb_led_ack),
        .led_out    ({o_led4, o_led3, o_led2, o_led1, o_led0})
    );
    
    // DSHOT Motor Signals (Internal)
    logic dshot_motor1, dshot_motor2, dshot_motor3, dshot_motor4;
    
    // Serial Bridge Signals (Internal)
    logic serial_tx_out;
    logic serial_tx_oe;
    logic serial_rx_in;
    
    // =============================
    // Serial/DSHOT Mux Register (Wishbone) - slave 3 on mux
    // =============================
    // Controls whether motor pins are driven by DSHOT controller or Serial Bridge
    logic [1:0] mux_ch; // Selected channel for passthrough
    
    wb_serial_dshot_mux u_wb_mux (
        .wb_clk_i   (i_sys_clk),
        .wb_rst_i   (sys_rst),
        .wb_dat_i   (wbs3_dat_o),
        .wb_adr_i   (wbs3_adr_o),
        .wb_we_i    (wbs3_we_o),
        .wb_sel_i   (wbs3_sel_o),
        .wb_stb_i   (wbs3_stb_o),
        .wb_cyc_i   (wbs3_cyc_o),
        .wb_dat_o   (wb_mux_dat_s2m),
        .wb_ack_o   (wb_mux_ack),
        .wb_stall_o (wb_mux_stall),
        .mux_sel    (mux_sel),
        .mux_ch     (mux_ch),
        
        // Physical Pads
        .pad_motor  ({o_motor4, o_motor3, o_motor2, o_motor1}),
        
        // Inputs
        .dshot_in   ({dshot_motor4, dshot_motor3, dshot_motor2, dshot_motor1}),
        .serial_tx_i(serial_tx_out),
        .serial_oe_i(serial_tx_oe),
        .serial_rx_o(serial_rx_in)
    );

    // =============================
    // USB UART Passthrough Bridge
    // =============================
    logic passthrough_enable;
    logic passthrough_active;
    
    // Enable passthrough when mux_sel==0 (Serial Mode)
    assign passthrough_enable = (mux_sel == 1'b0);
    
    uart_passthrough_bridge #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .BAUD_RATE(115200)
    ) u_uart_passthrough (
        .clk(i_sys_clk),
        .rst(sys_rst),
        .usb_uart_rx(i_usb_uart_rx),
        .usb_uart_tx(o_usb_uart_tx),
        
        // Split Serial Interface connecting to Mux
        .serial_tx_out(serial_tx_out),
        .serial_tx_oe(serial_tx_oe),
        .serial_rx_in(serial_rx_in),
        
        .enable(passthrough_enable),
        .active(passthrough_active)
    );
    
    // =============================
    // PWM Decoder (Wishbone) - slave 1 on mux
    // =============================
    pwmdecoder_wb #(
        .clockFreq(CLK_FREQ_HZ)
    ) u_wb_pwm (
        .i_clk      (i_sys_clk),
        .i_rst      (sys_rst),
        .wb_adr_i   (wbs1_adr_o[7:0]),
        .wb_dat_i   (wbs1_dat_o),
        .wb_we_i    (wbs1_we_o),
        .wb_stb_i   (wbs1_stb_o),
        .wb_cyc_i   (wbs1_cyc_o),
        .wb_dat_o   (wb_pwm_dat_s2m),
        .wb_ack_o   (wb_pwm_ack),
        .i_pwm_5(i_pwm_ch5),
        .i_pwm_4(i_pwm_ch4),
        .i_pwm_3(i_pwm_ch3),
        .i_pwm_2(i_pwm_ch2),
        .i_pwm_1(i_pwm_ch1),
        .i_pwm_0(i_pwm_ch0)

       // .i_pwm({i_pwm_ch5, i_pwm_ch4, i_pwm_ch3, i_pwm_ch2, i_pwm_ch1, i_pwm_ch0})
    );
    
    assign wb_pwm_stall = 1'b0;
    
    // =============================
    // DSHOT Controller (Wishbone) - slave 2 on mux
    // =============================
    wb_dshot_controller #(
        .CLK_FREQ_HZ (CLK_FREQ_HZ)
    ) u_wb_dshot (
        .wb_clk_i   (i_sys_clk),
        .wb_rst_i   (sys_rst),
        .wb_dat_i   (wbs2_dat_o),
        .wb_adr_i   (wbs2_adr_o),
        .wb_we_i    (wbs2_we_o),
        .wb_sel_i   (wbs2_sel_o),
        .wb_stb_i   (wbs2_stb_o),
        .wb_cyc_i   (wbs2_cyc_o),
        .wb_dat_o   (wb_dshot_dat_s2m),
        .wb_ack_o   (wb_dshot_ack),
        .wb_stall_o (wb_dshot_stall),
        .motor1_o   (dshot_motor1),
        .motor2_o   (dshot_motor2),
        .motor3_o   (dshot_motor3),
        .motor4_o   (dshot_motor4)
    );
    
    // Status LEDs removed; no local assignments

endmodule
