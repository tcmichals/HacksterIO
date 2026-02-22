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

    // Debug signal muxing - select via DEBUG_SEL parameter
    always_comb begin
        case (DEBUG_SEL)
            3'd0: begin // Default: original debug from core (pc_rx_valid, msp_tx_valid, msp_active)
                o_debug_0 = 1'b0;
                o_debug_1 = 1'b0;
                o_debug_2 = 1'b0;
            end
            3'd1: begin // Power-On Reset diagnosis
                o_debug_0 = 1'b0;
                o_debug_1 = 1'b0;
                o_debug_2 = 1'b0;
            end
            3'd2: begin // Reset counter progress (active-low when counting done)
                o_debug_0 = 1'b0;
                o_debug_1 = 1'b0;
                o_debug_2 = 1'b0;
            end
            3'd3: begin // Raw UART RX pin monitoring
                o_debug_0 = 1'b0;
                o_debug_1 = 1'b0;
                o_debug_2 = 1'b0;
            end
            3'd4: begin // UART RX byte-level tracing (NEW)
                o_debug_0 = 1'b0;
                o_debug_1 = 1'b0;
                o_debug_2 = 1'b0;
            end
            3'd5: begin // MSP RX state machine debug
                o_debug_0 = 1'b0;
                o_debug_1 = 1'b0;
                o_debug_2 = 1'b0;
            end
            3'd6: begin // MSP RX with timeout and rx_valid
                o_debug_0 = 1'b0;
                o_debug_1 = 1'b0;
                o_debug_2 = 1'b0;
            end
            default: begin
                o_debug_0 = 1'b0;
                o_debug_1 = 1'b0;
                o_debug_2 = 1'b0;
            end
        endcase
    end

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

    // Instantiate SERV RISC-V core (Wishbone wrapper)
    serv_wb_top u_serv (
        .i_clk(clk_72m),
        .i_rst(sys_reset),
        .o_wb_adr(wb_adr),
        .o_wb_dat(wb_dat_m2s),
        .o_wb_sel(wb_sel),
        .o_wb_we(wb_we),
        .o_wb_stb(wb_stb),
        .i_wb_rdt(wb_dat_s2m),
        .i_wb_ack(wb_ack)
        // Add other connections as required by your SoC design
    );

endmodule
