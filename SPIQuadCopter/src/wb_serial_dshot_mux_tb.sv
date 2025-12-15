/**
 * wb_serial_dshot_mux Testbench
 *
 * Directed tests to validate:
 *  - one-cycle global_tristate on mux change
 *  - non-target pads tri-stated in passthrough
 *  - serial_rx_o synchronization and gating
 *  - no persistent contention during rapid toggles
 */
`timescale 1ns/1ps

module wb_serial_dshot_mux_tb;

    // Clock / reset (wb domain)
    logic wb_clk;
    logic wb_rst;

    // Wishbone-lite control inputs (we'll poke regs directly for simplicity)
    logic        wb_we_i;
    logic [31:0] wb_dat_i;
    logic [31:0] wb_adr_i;
    logic [3:0]  wb_sel_i;
    logic        wb_stb_i;
    logic        wb_cyc_i;

    // Outputs from WB (not used heavily)
    logic [31:0] wb_dat_o;
    logic        wb_ack_o;
    logic        wb_stall_o;

    // DUT physical pads (inout) -- resolved tri-net so both DUT and TB can drive
    tri [3:0] pad_motor;

    // Internal signals
    logic [3:0] dshot_in;
    logic       serial_tx_i;
    logic       serial_oe_i;
    wire        serial_rx_o;

    // We'll model external ESC driver that can drive pad_motor (for passthrough input sampling)
    // The TB will selectively drive the pad lines; when TB isn't driving, DUT or other drivers may drive.
    // Use a resolved net by declaring "wire" and driving with assign when active.

    // Simple driver control variables
    logic esc_drive_en;
    logic [3:0] esc_drive_val;

    // Model ESC driver: drives pad line when esc_drive_en is set for the selected channel
    genvar gi;
    generate
        for (gi = 0; gi < 4; gi++) begin : ESC_DRIVE
            // Weak pull-up when no drivers
            tri pad_tri = 1'bz;
            assign pad_tri = (esc_drive_en && esc_drive_val[gi]) ? 1'b1 : 1'bz;
            // Connect resolved pad to top-level pad_motor
            assign pad_motor[gi] = pad_tri;
        end
    endgenerate

    // DUT instantiation
    // TB override signals for SIM_CONTROL
    logic tb_mux_force_en;
    logic tb_mux_force_sel;
    logic [1:0] tb_mux_force_ch;

    wb_serial_dshot_mux dut (
        .wb_clk_i(wb_clk),
        .wb_rst_i(wb_rst),
        .wb_dat_i(wb_dat_i),
        .wb_adr_i(wb_adr_i),
        .wb_we_i(wb_we_i),
        .wb_sel_i(wb_sel_i),
        .wb_stb_i(wb_stb_i),
        .wb_cyc_i(wb_cyc_i),
        .wb_dat_o(wb_dat_o),
        .wb_ack_o(wb_ack_o),
        .wb_stall_o(wb_stall_o),
        .mux_sel(), // not connected to direct port writes here
        .mux_ch(),
        .pad_motor(pad_motor),
        .dshot_in(dshot_in),
        .serial_tx_i(serial_tx_i),
        .serial_oe_i(serial_oe_i),
        .serial_rx_o(serial_rx_o)
    );

`ifdef SIM_CONTROL
    // Connect override ports
    assign dut.tb_mux_force_en = tb_mux_force_en;
    assign dut.tb_mux_force_sel = tb_mux_force_sel;
    assign dut.tb_mux_force_ch  = tb_mux_force_ch;
`endif

`ifdef SIM_CONTROL
    // Re-connect DUT with TB override ports if SIM_CONTROL enabled
    // (some simulators allow connecting conditional ports directly; for iverilog we connected above and now assign via hierarchical binding)
`endif

    // Local copies to poke internal regs via tasks (we will drive the wb register interface instead of direct regs)
    // But the module uses internal reg mux_sel/mux_ch; easiest is to write via the WB interface 'sel' logic

    // Clock generator
    initial begin
        wb_clk = 0;
        forever #5 wb_clk = ~wb_clk; // 100 MHz wb clock (10 ns period)
    end

    // Reset and init
    initial begin
        wb_rst = 1;
        esc_drive_en = 0;
        esc_drive_val = 4'b0000;
        dshot_in = 4'b0000;
        serial_tx_i = 1'b0;
        serial_oe_i = 1'b0;
        // WB default signals
        wb_we_i = 0; wb_dat_i = 32'b0; wb_adr_i = 32'b0; wb_sel_i = 4'hF; wb_stb_i = 0; wb_cyc_i = 0;
        #100; wb_rst = 0;
        #100;

        $display("[TB] Starting directed tests for wb_serial_dshot_mux");

        test_dshot_to_passthrough_handover();
        test_non_target_tri_state();
        test_serial_rx_synchronizer();
        test_rapid_toggle_stress();

        $display("[TB] All directed tests complete");
        #200; $finish;
    end

    // Helper: write mux register at address 0x0400 (word aligned uses adr[11:2]==10'h100 in DUT)
    task automatic wb_write_mux(input logic sel, input logic [1:0] ch);
        begin
            // Build data as {29'b0, ch, sel}
            wb_dat_i = {29'b0, ch, sel};
            wb_adr_i = 32'h0400; // matches sel test in DUT
            wb_we_i  = 1'b1;
            wb_stb_i = 1'b1;
            wb_cyc_i = 1'b1;
            @(posedge wb_clk);
            // one-cycle write
            wb_stb_i = 0; wb_cyc_i = 0; wb_we_i = 0;
            @(posedge wb_clk);
            // Debug: display DUT internal regs and ack
            $display("[WBWRITE] wb_dat_i=%h wb_ack=%b wb_dat_o=%h dut.mux_sel=%b dut.mux_ch=%b pad=%b", wb_dat_i, wb_ack_o, wb_dat_o, dut.mux_sel, dut.mux_ch, pad_motor);
        end
    endtask

    // Helper: force mux signals directly inside DUT (useful if WB writes are not updating during test)
    task automatic force_mux(input logic sel, input logic [1:0] ch);
        begin
            $display("[FORCE] Forcing tb_mux_force_en=1 sel=%b ch=%b", sel, ch);
            tb_mux_force_en = 1'b1;
            tb_mux_force_sel = sel;
            tb_mux_force_ch  = ch;
            // wait a couple cycles for prev_* and global_tristate logic to observe edge
            @(posedge wb_clk);
            @(posedge wb_clk);
        end
    endtask

    task automatic release_mux();
        begin
            tb_mux_force_en = 1'b0;
            @(posedge wb_clk);
        end
    endtask

    // Helper: read back mux register (simple read)
    task automatic wb_read_mux(output logic sel, output logic [1:0] ch);
        begin
            wb_adr_i = 32'h0400;
            wb_we_i  = 1'b0;
            wb_stb_i = 1'b1;
            wb_cyc_i = 1'b1;
            @(posedge wb_clk);
            sel = wb_dat_o[0];
            ch  = wb_dat_o[2:1];
            wb_stb_i = 0; wb_cyc_i = 0;
            @(posedge wb_clk);
        end
    endtask

    // Test 1: DSHOT -> Passthrough handover (global_tristate check)
    task automatic test_dshot_to_passthrough_handover();
        logic sel_read;
        logic [1:0] ch_read;
        begin
            $display("[TEST1] DSHOT→Passthrough handover");

            // Start in DSHOT mode, channel 2 driven
            dshot_in = 4'b0100; // channel 2 = 1
            // Force DUT to DSHOT ch=2
            force_mux(1'b1, 2'b10);
            // Observe pad driven by DSHOT
            if (pad_motor[2] !== dshot_in[2]) $display("[TEST1] FAIL: pad not driven by DSHOT as expected (pad=%b dshot=%b)", pad_motor[2], dshot_in[2]);
            else $display("[TEST1] OK: DSHOT driving pad before handover");

            // Prepare serial passthrough to drive
            serial_tx_i = 1'b0; serial_oe_i = 1'b1; // drive low
            // Now switch to passthrough targeting channel 2 by forcing
            force_mux(1'b0, 2'b10);

            // Immediately sample pad: should be Z due to global_tristate asserted one cycle
            @(posedge wb_clk);
            if (pad_motor[2] === 1'bz) $display("[TEST1] OK: pad Z during handover (global_tristate asserted)");
            else $display("[TEST1] FAIL: pad not Z during handover (pad=%b)", pad_motor[2]);

            // Next cycle the passthrough should drive the pad
            @(posedge wb_clk);
            if (pad_motor[2] === serial_tx_i) $display("[TEST1] OK: pad driven by passthrough after handover");
            else $display("[TEST1] FAIL: pad not driven by passthrough after handover (pad=%b)", pad_motor[2]);

            // release forced control
            release_mux();
        end
    endtask

    // Test 2: Non-target pads tri-state in passthrough
    task automatic test_non_target_tri_state();
        begin
            $display("[TEST2] Non-target pads tri-stated in passthrough");
            // Ensure we are in passthrough channel 1
            // Force passthrough channel 1
            force_mux(1'b0, 2'b01);
            serial_oe_i = 1'b1; serial_tx_i = 1'b1;
            @(posedge wb_clk);
            // Target pad 1 should be driven
            if (pad_motor[1] === 1'b1) $display("[TEST2] OK: target pad driven"); else $display("[TEST2] FAIL: target pad not driven (pad=%b)", pad_motor[1]);
            // Non-target pads should be Z
            if ((pad_motor[0] === 1'bz) && (pad_motor[2] === 1'bz) && (pad_motor[3] === 1'bz)) $display("[TEST2] OK: non-target pads Z"); else $display("[TEST2] FAIL: some non-target pads not Z (pads=%b)", pad_motor);
            release_mux();
        end
    endtask

    // Test 3: serial_rx synchronizer and gating
    task automatic test_serial_rx_synchronizer();
        begin
            $display("[TEST3] serial_rx synchronizer and gating");
            // Target channel 0 passthrough
            // Force passthrough channel 0
            force_mux(1'b0, 2'b00);
            serial_oe_i = 1'b0; // ensure DUT not driving
            // Drive the pad externally from ESC
            esc_drive_en = 1; esc_drive_val = 4'b0001; // drive channel 0 high
            @(posedge wb_clk);
            // It takes two cycles of wb_clk to appear on serial_rx_o due to 2-FF sync
            @(posedge wb_clk);
            @(posedge wb_clk);
            if (serial_rx_o === 1'b1) $display("[TEST3] OK: serial_rx_o sampled high after sync"); else $display("[TEST3] FAIL: serial_rx_o != 1 (val=%b)", serial_rx_o);
            // Switch to DSHOT mode and ensure serial_rx_o is 0
            // Force DSHOT mode channel 0 to observe gating
            force_mux(1'b1, 2'b00);
            // allow mux_sel update to take effect
            @(posedge wb_clk);
            if (serial_rx_o === 1'b0) $display("[TEST3] OK: serial_rx_o forced 0 in DSHOT mode"); else $display("[TEST3] FAIL: serial_rx_o not 0 in DSHOT mode (val=%b)", serial_rx_o);
            esc_drive_en = 0; esc_drive_val = 4'b0000;
            release_mux();
        end
    endtask

    // Test 4: Rapid toggle stress (ensure no persistent contention)
    task automatic test_rapid_toggle_stress();
        integer i;
        begin
            $display("[TEST4] Rapid toggle stress test");
            // Start with DSHOT driving channel 3 and serial also trying to drive
            dshot_in = 4'b1000;
            serial_tx_i = 1'b1; serial_oe_i = 1'b1;
            for (i = 0; i < 20; i++) begin
                // Toggle sel and channel quickly via force
                force_mux((i[0]==1)?1'b1:1'b0, i[1:0]);
                // sample pad for 'x' or unexpected values
                @(posedge wb_clk);
                if (pad_motor === 4'bxxxx) $display("[TEST4] FAIL: persistent unknowns on pad at iter %0d", i);
                release_mux();
            end
            $display("[TEST4] Completed rapid toggle loop");
        end
    endtask

    // Trace some signals
    initial begin
        $dumpfile("wb_serial_dshot_mux_tb.vcd");
        $dumpvars(0, wb_serial_dshot_mux_tb);
    end

endmodule
