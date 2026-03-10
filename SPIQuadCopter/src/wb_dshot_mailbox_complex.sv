/**
 * wb_dshot_mailbox - Dual-Port DSHOT Controller with Mailbox Arbitration
 *
 * This module provides DSHOT motor control accessible from two independent
 * Wishbone masters (CPU and SPI) without conflicts.
 *
 * Uses motor_mailbox_sv for FIFO-based arbitration (Port B/SPI has priority).
 *
 * Register Map (same for both ports):
 *   0x00: MOTOR1 [15:0] - DSHOT value (throttle[15:5] + telemetry[4] + CRC[3:0])
 *   0x04: MOTOR2 [15:0]
 *   0x08: MOTOR3 [15:0]
 *   0x0C: MOTOR4 [15:0]
 *   0x10: STATUS [3:0] - Ready bits (read-only)
 *   0x14: CONFIG [15:0] - DSHOT mode (150, 300, 600)
 *   0x18: AUTO_INTERVAL [31:0] - Auto-repeat interval in clock cycles (0=disabled)
 *                                Default: 108000 (~2ms at 54MHz)
 *
 * Features:
 *   - Zero-latency reads from both ports
 *   - FIFO-based write arbitration (Port B/SPI has priority)
 *   - Automatic dispatch to per-motor DSHOT encoders
 *   - Runtime DSHOT mode selection
 *   - Auto-repeat: Hardware automatically resends last values at interval
 */

`default_nettype none

module wb_dshot_mailbox #(
    parameter CLK_FREQ_HZ = 54_000_000,
    parameter DEFAULT_MODE = 150,
    parameter DEFAULT_AUTO_INTERVAL = 108_000  // ~2ms at 54MHz (0=disabled)
) (
    input  wire        clk,
    input  wire        rst,

    // Port A: Wishbone Slave (for CPU/SERV)
    input  wire [31:0] wba_adr_i,
    input  wire [31:0] wba_dat_i,
    output wire [31:0] wba_dat_o,
    input  wire [3:0]  wba_sel_i,
    input  wire        wba_we_i,
    input  wire        wba_stb_i,
    input  wire        wba_cyc_i,
    output wire        wba_ack_o,

    // Port B: Wishbone Slave (for SPI bridge)
    input  wire [31:0] wbb_adr_i,
    input  wire [31:0] wbb_dat_i,
    output reg  [31:0] wbb_dat_o,
    input  wire [3:0]  wbb_sel_i,
    input  wire        wbb_we_i,
    input  wire        wbb_stb_i,
    input  wire        wbb_cyc_i,
    output reg         wbb_ack_o,

    // DSHOT Motor Outputs
    output wire        motor1_o,
    output wire        motor2_o,
    output wire        motor3_o,
    output wire        motor4_o,

    // Ready signals
    output wire        motor1_ready,
    output wire        motor2_ready,
    output wire        motor3_ready,
    output wire        motor4_ready
);

    // =========================================================================
    // DSHOT Dispatch Signals (from mailbox)
    // =========================================================================
    wire [31:0] dshot_cmd_data;
    wire [2:0]  dshot_cmd_id;
    wire        dshot_cmd_vld;

    // Motor write strobes (decoded from dispatch)
    wire motor1_write = dshot_cmd_vld && (dshot_cmd_id == 3'd0);
    wire motor2_write = dshot_cmd_vld && (dshot_cmd_id == 3'd1);
    wire motor3_write = dshot_cmd_vld && (dshot_cmd_id == 3'd2);
    wire motor4_write = dshot_cmd_vld && (dshot_cmd_id == 3'd3);

    // =========================================================================
    // DSHOT Mode Register (shared, updated via any port)
    // =========================================================================
    reg [15:0] dshot_mode_reg;

    // Address decode
    wire [3:0] wba_addr = wba_adr_i[5:2];
    wire [3:0] wbb_addr = wbb_adr_i[5:2];

    // Config write detection
    wire wba_config_write = wba_cyc_i && wba_stb_i && wba_we_i && (wba_addr == 4'h5);
    wire wbb_config_write = wbb_cyc_i && wbb_stb_i && wbb_we_i && (wbb_addr == 4'h5);

    always @(posedge clk) begin
        if (rst) begin
            dshot_mode_reg <= DEFAULT_MODE[15:0];
        end else begin
            // Port B has priority
            if (wbb_config_write && !wbb_ack_o) begin
                dshot_mode_reg <= wbb_dat_i[15:0];
            end else if (wba_config_write) begin
                dshot_mode_reg <= wba_dat_i[15:0];
            end
        end
    end

    // =========================================================================
    // Auto-Repeat Interval Register (0x18) - 0 = disabled
    // =========================================================================
    reg [31:0] auto_interval_reg;
    
    wire wba_interval_write = wba_cyc_i && wba_stb_i && wba_we_i && (wba_addr == 4'h6);
    wire wbb_interval_write = wbb_cyc_i && wbb_stb_i && wbb_we_i && (wbb_addr == 4'h6);
    
    always @(posedge clk) begin
        if (rst) begin
            auto_interval_reg <= DEFAULT_AUTO_INTERVAL;
        end else begin
            if (wbb_interval_write && !wbb_ack_o) begin
                auto_interval_reg <= wbb_dat_i;
            end else if (wba_interval_write) begin
                auto_interval_reg <= wba_dat_i;
            end
        end
    end

    // =========================================================================
    // Auto-Repeat Timer & Shadow Registers
    // =========================================================================
    reg [31:0] auto_timer;
    reg        auto_fire;
    reg [1:0]  auto_motor_idx;  // Which motor to auto-send (0-3)
    
    // Watchdog: stops auto-repeat if no manual writes for 1 second
    // At 54MHz: 54_000_000 cycles = 1 second
    localparam WATCHDOG_TIMEOUT = 54_000_000;
    reg [25:0] watchdog_timer;  // 26 bits holds up to 67M
    reg        watchdog_active;
    
    // Any manual motor write kicks the watchdog
    wire any_manual_write = motor1_write || motor2_write || motor3_write || motor4_write;
    
    always @(posedge clk) begin
        if (rst) begin
            watchdog_timer <= 26'h0;
            watchdog_active <= 1'b0;
        end else begin
            if (any_manual_write) begin
                // Manual write: reset watchdog, enable auto-repeat
                watchdog_timer <= 26'h0;
                watchdog_active <= 1'b1;
            end else if (watchdog_active) begin
                if (watchdog_timer >= WATCHDOG_TIMEOUT) begin
                    // Timeout: stop auto-repeat until next manual write
                    watchdog_active <= 1'b0;
                end else begin
                    watchdog_timer <= watchdog_timer + 1'b1;
                end
            end
        end
    end
    
    // Shadow registers: store last written value for each motor
    reg [15:0] shadow_motor1, shadow_motor2, shadow_motor3, shadow_motor4;
    
    // Capture shadow values on manual writes
    always @(posedge clk) begin
        if (rst) begin
            shadow_motor1 <= 16'h0;
            shadow_motor2 <= 16'h0;
            shadow_motor3 <= 16'h0;
            shadow_motor4 <= 16'h0;
        end else begin
            if (motor1_write) shadow_motor1 <= dshot_cmd_data[15:0];
            if (motor2_write) shadow_motor2 <= dshot_cmd_data[15:0];
            if (motor3_write) shadow_motor3 <= dshot_cmd_data[15:0];
            if (motor4_write) shadow_motor4 <= dshot_cmd_data[15:0];
        end
    end
    
    // Auto-repeat timer: fires when interval reached AND watchdog active
    // Round-robin sends one motor per fire to avoid FIFO backup
    always @(posedge clk) begin
        if (rst) begin
            auto_timer <= 32'h0;
            auto_fire <= 1'b0;
            auto_motor_idx <= 2'b0;
        end else begin
            auto_fire <= 1'b0;  // Default: pulse
            
            if (auto_interval_reg != 0 && watchdog_active) begin
                if (auto_timer >= auto_interval_reg) begin
                    auto_timer <= 32'h0;
                    auto_fire <= 1'b1;
                    auto_motor_idx <= auto_motor_idx + 1'b1;  // Next motor
                end else begin
                    auto_timer <= auto_timer + 1'b1;
                end
            end else begin
                auto_timer <= 32'h0;  // Reset timer when disabled
            end
        end
    end
    
    // Auto-repeat dispatch signals (directly to DSHOT outputs)
    wire auto_motor1_write = auto_fire && (auto_motor_idx == 2'd0) && motor1_ready;
    wire auto_motor2_write = auto_fire && (auto_motor_idx == 2'd1) && motor2_ready;
    wire auto_motor3_write = auto_fire && (auto_motor_idx == 2'd2) && motor3_ready;
    wire auto_motor4_write = auto_fire && (auto_motor_idx == 2'd3) && motor4_ready;
    
    // Final write signals: manual OR auto (manual has priority via timing)
    wire final_motor1_write = motor1_write || auto_motor1_write;
    wire final_motor2_write = motor2_write || auto_motor2_write;
    wire final_motor3_write = motor3_write || auto_motor3_write;
    wire final_motor4_write = motor4_write || auto_motor4_write;
    
    // Mux data: manual command data OR shadow for auto
    wire [15:0] final_motor1_data = motor1_write ? dshot_cmd_data[15:0] : shadow_motor1;
    wire [15:0] final_motor2_data = motor2_write ? dshot_cmd_data[15:0] : shadow_motor2;
    wire [15:0] final_motor3_data = motor3_write ? dshot_cmd_data[15:0] : shadow_motor3;
    wire [15:0] final_motor4_data = motor4_write ? dshot_cmd_data[15:0] : shadow_motor4;

    // =========================================================================
    // Status/Config Registers
    // =========================================================================
    wire [31:0] status_reg = {27'b0, watchdog_active, motor4_ready, motor3_ready, motor2_ready, motor1_ready};
    wire [31:0] config_reg = {16'b0, dshot_mode_reg};
    wire [31:0] interval_reg = auto_interval_reg;

    // =========================================================================
    // Port B: Convert Wishbone to Generic Interface for Mailbox
    // =========================================================================
    wire [2:0]  gen_addr  = wbb_adr_i[4:2];  // Word address (0-7)
    wire [31:0] gen_wdata = wbb_dat_i;
    wire        gen_wen   = wbb_cyc_i && wbb_stb_i && wbb_we_i && (wbb_addr < 4'h4);
    wire [31:0] gen_rdata;

    // Port B ACK generation
    always @(posedge clk) begin
        if (rst) begin
            wbb_ack_o <= 1'b0;
        end else begin
            wbb_ack_o <= wbb_cyc_i && wbb_stb_i && !wbb_ack_o;
        end
    end

    // Port B read data mux
    always @(*) begin
        case (wbb_addr)
            4'h4:    wbb_dat_o = status_reg;
            4'h5:    wbb_dat_o = config_reg;
            4'h6:    wbb_dat_o = interval_reg;
            default: wbb_dat_o = gen_rdata;
        endcase
    end

    // =========================================================================
    // Motor Mailbox (Dual-Port Arbiter with FIFO)
    // =========================================================================
    wire [31:0] mailbox_wba_dat_o;
    wire        mailbox_wba_ack_o;

    motor_mailbox_sv #(
        .NUM_MOTORS(4)
    ) u_mailbox (
        .clk(clk),
        .rst(rst),

        // Port A: Wishbone (CPU) - only motor registers
        .wb_adr_i(wba_adr_i[4:2]),
        .wb_dat_i(wba_dat_i),
        .wb_we_i(wba_we_i && (wba_addr < 4'h4)),
        .wb_stb_i(wba_stb_i && (wba_addr < 4'h4)),
        .wb_cyc_i(wba_cyc_i),
        .wb_ack_o(mailbox_wba_ack_o),
        .wb_dat_o(mailbox_wba_dat_o),

        // Port B: Generic (SPI via conversion)
        .gen_addr(gen_addr),
        .gen_wdata(gen_wdata),
        .gen_wen(gen_wen),
        .gen_rdata(gen_rdata),

        // DSHOT Dispatch Output (individual signals for iverilog compatibility)
        .dshot_out_data(dshot_cmd_data),
        .dshot_out_id(dshot_cmd_id),
        .dshot_out_vld(dshot_cmd_vld)
    );

    // Port A ACK: from mailbox for motor regs, or generate for status/config/interval
    reg wba_special_ack;
    always @(posedge clk) begin
        if (rst) begin
            wba_special_ack <= 1'b0;
        end else begin
            wba_special_ack <= wba_cyc_i && wba_stb_i && !wba_special_ack && (wba_addr >= 4'h4);
        end
    end
    assign wba_ack_o = (wba_addr < 4'h4) ? mailbox_wba_ack_o : wba_special_ack;

    // Port A read data mux
    assign wba_dat_o = (wba_addr == 4'h4) ? status_reg :
                       (wba_addr == 4'h5) ? config_reg :
                       (wba_addr == 4'h6) ? interval_reg :
                       mailbox_wba_dat_o;

    // =========================================================================
    // DSHOT Output Encoders (4 motors)
    // Uses final_* signals which include auto-repeat
    // =========================================================================
    dshot_output #(
        .clockFrequency(CLK_FREQ_HZ)
    ) u_dshot_motor1 (
        .i_clk(clk),
        .i_reset(rst),
        .i_dshot_value(final_motor1_data),
        .i_dshot_mode(dshot_mode_reg),
        .i_write(final_motor1_write),
        .o_pwm(motor1_o),
        .o_ready(motor1_ready)
    );

    dshot_output #(
        .clockFrequency(CLK_FREQ_HZ)
    ) u_dshot_motor2 (
        .i_clk(clk),
        .i_reset(rst),
        .i_dshot_value(final_motor2_data),
        .i_dshot_mode(dshot_mode_reg),
        .i_write(final_motor2_write),
        .o_pwm(motor2_o),
        .o_ready(motor2_ready)
    );

    dshot_output #(
        .clockFrequency(CLK_FREQ_HZ)
    ) u_dshot_motor3 (
        .i_clk(clk),
        .i_reset(rst),
        .i_dshot_value(final_motor3_data),
        .i_dshot_mode(dshot_mode_reg),
        .i_write(final_motor3_write),
        .o_pwm(motor3_o),
        .o_ready(motor3_ready)
    );

    dshot_output #(
        .clockFrequency(CLK_FREQ_HZ)
    ) u_dshot_motor4 (
        .i_clk(clk),
        .i_reset(rst),
        .i_dshot_value(final_motor4_data),
        .i_dshot_mode(dshot_mode_reg),
        .i_write(final_motor4_write),
        .o_pwm(motor4_o),
        .o_ready(motor4_ready)
    );

endmodule

`default_nettype wire
