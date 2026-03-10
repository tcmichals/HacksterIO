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
 *
 * Features:
 *   - Zero-latency reads from both ports
 *   - FIFO-based write arbitration (Port B/SPI has priority)
 *   - Automatic dispatch to per-motor DSHOT encoders
 *   - Runtime DSHOT mode selection
 */

`default_nettype none

module wb_dshot_mailbox #(
    parameter CLK_FREQ_HZ = 54_000_000,
    parameter DEFAULT_MODE = 150
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
    // Status/Config Registers
    // =========================================================================
    wire [31:0] status_reg = {28'b0, motor4_ready, motor3_ready, motor2_ready, motor1_ready};
    wire [31:0] config_reg = {16'b0, dshot_mode_reg};

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

    // Port A ACK: from mailbox for motor regs, or generate for status/config
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
                       mailbox_wba_dat_o;

    // =========================================================================
    // DSHOT Output Encoders (4 motors)
    // =========================================================================
    dshot_output #(
        .clockFrequency(CLK_FREQ_HZ)
    ) u_dshot_motor1 (
        .i_clk(clk),
        .i_reset(rst),
        .i_dshot_value(dshot_cmd_data[15:0]),
        .i_dshot_mode(dshot_mode_reg),
        .i_write(motor1_write),
        .o_pwm(motor1_o),
        .o_ready(motor1_ready)
    );

    dshot_output #(
        .clockFrequency(CLK_FREQ_HZ)
    ) u_dshot_motor2 (
        .i_clk(clk),
        .i_reset(rst),
        .i_dshot_value(dshot_cmd_data[15:0]),
        .i_dshot_mode(dshot_mode_reg),
        .i_write(motor2_write),
        .o_pwm(motor2_o),
        .o_ready(motor2_ready)
    );

    dshot_output #(
        .clockFrequency(CLK_FREQ_HZ)
    ) u_dshot_motor3 (
        .i_clk(clk),
        .i_reset(rst),
        .i_dshot_value(dshot_cmd_data[15:0]),
        .i_dshot_mode(dshot_mode_reg),
        .i_write(motor3_write),
        .o_pwm(motor3_o),
        .o_ready(motor3_ready)
    );

    dshot_output #(
        .clockFrequency(CLK_FREQ_HZ)
    ) u_dshot_motor4 (
        .i_clk(clk),
        .i_reset(rst),
        .i_dshot_value(dshot_cmd_data[15:0]),
        .i_dshot_mode(dshot_mode_reg),
        .i_write(motor4_write),
        .o_pwm(motor4_o),
        .o_ready(motor4_ready)
    );

endmodule

`default_nettype wire
