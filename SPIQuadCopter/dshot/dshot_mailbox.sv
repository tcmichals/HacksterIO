// 1. Package definition for the dispatch interface
package dshot_pkg;
    typedef struct packed {
        logic [31:0] data; // 32-bit Motor Command
        logic [2:0]  id;   // Motor ID (0-7)
        logic        vld;  // Pulse high on update
    } motor_cmd_t;
endpackage

// 2. Main Mailbox Module
import dshot_pkg::*;

module motor_mailbox_sv #(
    parameter int NUM_MOTORS = 8
)(
    input  logic        clk,
    input  logic        rst, // Positive Synchronous Reset

    // --- Port A: Wishbone Slave ---
    input  logic [2:0]  wb_adr_i,
    input  logic [31:0] wb_dat_i,
    input  logic        wb_we_i,
    input  logic        wb_stb_i,
    input  logic        wb_cyc_i,
    output logic        wb_ack_o,
    output logic [31:0] wb_dat_o,

    // --- Port B: Generic Interface ---
    input  logic [2:0]  gen_addr,
    input  logic [31:0] gen_wdata,
    input  logic        gen_wen,
    output logic [31:0] gen_rdata,

    // --- Single-Channel DSHOT Dispatch Output ---
    output motor_cmd_t  dshot_out
);

    // Internal Memory for Motor Speeds
    logic [31:0] motor_regs [NUM_MOTORS];

    // --- Combinatorial Reads ---
    // Zero-latency read access for both interfaces
    assign wb_dat_o  = motor_regs[wb_adr_i];
    assign gen_rdata = motor_regs[gen_addr];

    // --- Registered Wishbone Acknowledge ---
    // Logic ensures only one ACK per transaction even if STB is held
    always_ff @(posedge clk) begin
        if (rst) begin
            wb_ack_o <= 1'b0;
        end else begin
            wb_ack_o <= wb_stb_i && wb_cyc_i && !wb_ack_o;
        end
    end

    // --- Shared Write Logic & DSHOT Dispatch ---
    // Generic Port B is given priority in case of simultaneous writes
    always_ff @(posedge clk) begin
        if (rst) begin
            dshot_out <= '0;
            for (int i = 0; i < NUM_MOTORS; i++) begin
                motor_regs[i] <= 32'h0;
            end
        end else begin
            // Default: clear valid pulse every cycle
            dshot_out.vld <= 1'b0;

            if (gen_wen) begin
                // Update Storage
                motor_regs[gen_addr] <= gen_wdata;
                // Dispatch to DSHOT Engine
                dshot_out.data       <= gen_wdata;
                dshot_out.id         <= gen_addr;
                dshot_out.vld        <= 1'b1;
            end 
            else if (wb_stb_i && wb_cyc_i && wb_we_i && !wb_ack_o) begin
                // Update Storage
                motor_regs[wb_adr_i] <= wb_dat_i;
                // Dispatch to DSHOT Engine
                dshot_out.data       <= wb_dat_i;
                dshot_out.id         <= wb_adr_i;
                dshot_out.vld        <= 1'b1;
            end
        end
    end

endmodule
