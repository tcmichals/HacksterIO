`timescale 1ns / 1ps

module wb_neoPx_tb();

    parameter CLK_FREQ_HZ = 72_000_000;
    parameter CLK_PERIOD  = 13.888; 

    // Use SK6812 nominal timings (ns) to match 32-bit RGBW test vectors
    localparam T0H_NOMINAL = 300.0;
    localparam T1H_NOMINAL = 600.0;
    localparam TOLERANCE   = 150.0;

    reg         clk = 0;
    reg         rst = 0;
    reg [31:0]  wb_adr;
    reg [31:0]  wb_dat_i;
    wire [31:0] wb_dat_o;
    reg         wb_we, wb_stb, wb_cyc;
    reg [3:0]   wb_sel;
    wire        wb_ack, wb_err, wb_rty, o_serial;

    reg [31:0] test_colors [0:7];
    reg [31:0] captured_pixel;
    integer    error_count = 0;
    integer    bit_count = 0;
    integer    p_idx = 0;
    realtime   rising_edge, pulse_width;

    wb_neoPx #(.CLK_FREQ_HZ(CLK_FREQ_HZ)) uut (
        .i_clk(clk), .i_rst(rst),
        .wb_adr_i(wb_adr), .wb_dat_i(wb_dat_i), .wb_dat_o(wb_dat_o),
        .wb_we_i(wb_we), .wb_sel_i(wb_sel), .wb_stb_i(wb_stb),
        .wb_ack_o(wb_ack), .wb_err_o(wb_err), .wb_rty_o(wb_rty),
        .wb_cyc_i(wb_cyc), .o_serial(o_serial)
    );

    always #(CLK_PERIOD/2) clk = ~clk;

    initial begin
        // VCD dumping disabled to minimize USB disk I/O
        // $dumpfile("wb_neoPx_full.vcd");
        // $dumpvars(0, wb_neoPx_tb);
    end

    // Periodic diagnostics to help debug hangs
    // Expose small set of signals for diagnostics
    wire [3:0] dbg_state = uut.state;
    wire [3:0] dbg_count = uut.count;
    wire       dbg_isReady = uut.isReady;

    initial begin
        forever begin
            #1000000; // every 1 ms simulated
            $display("[DIAG] time=%0t state=%0d count=%0d tvalid=%b sendState=%b isReady=%b update_req=%b bit_count=%0d", $realtime, dbg_state, dbg_count, uut.tvalid, uut.sendState, dbg_isReady, uut.update_req, bit_count);
        end
    end

    // Safety timeout to avoid infinite hangs in CI
    initial begin
        #100000000; // 100 ms simulated
        $display("[TIMEOUT] Simulation exceeded 100ms, dumping summary and finishing.");
        $display("Current time: %0t, bit_count=%0d, error_count=%0d", $realtime, bit_count, error_count);
        $finish;
    end

    task wb_write(input [31:0] addr, input [31:0] data);
        begin
            @(posedge clk);
            wb_adr <= addr; wb_dat_i <= data;
            wb_we <= 1; wb_cyc <= 1; wb_stb <= 1; wb_sel <= 4'hF;
            wait(wb_ack);
            @(posedge clk);
            wb_cyc <= 0; wb_stb <= 0; wb_we <= 0;
        end
    endtask

    task verify_pixel(input integer id, input [31:0] expected);
        reg [7:0] eg, er, eb, ew, cg, cr, cb, cw;
        begin
            {eg, er, eb, ew} = expected;
            wait(bit_count == 32);
            {cg, cr, cb, cw} = captured_pixel;
            $display("[CHECK] LED %0d | G:%h R:%h B:%h W:%h | %s", 
                     id, cg, cr, cb, cw, (captured_pixel === expected) ? "PASS" : "FAIL");
            if (captured_pixel !== expected) error_count = error_count + 1;
            bit_count = 0;
        end
    endtask

    always @(posedge o_serial) begin
        rising_edge = $realtime;
        @(negedge o_serial);
        pulse_width = $realtime - rising_edge;
        // Classify using midpoint threshold between T0 and T1 to be robust
        if (pulse_width > ((T0H_NOMINAL + T1H_NOMINAL)/2.0)) begin
            captured_pixel[31 - bit_count] = 1'b1;
            if (pulse_width < (T1H_NOMINAL-TOLERANCE) || pulse_width > (T1H_NOMINAL+TOLERANCE)) error_count = error_count + 1;
        end else begin
            captured_pixel[31 - bit_count] = 1'b0;
            if (pulse_width < (T0H_NOMINAL-TOLERANCE) || pulse_width > (T0H_NOMINAL+TOLERANCE)) error_count = error_count + 1;
        end
        bit_count = bit_count + 1;
    end

    initial begin
        test_colors[0] = 32'hFF000000; test_colors[1] = 32'h00FF0000;
        test_colors[2] = 32'h0000FF00; test_colors[3] = 32'h000000FF;
        test_colors[4] = 32'hAABBCCDD; test_colors[5] = 32'h12345678;
        test_colors[6] = 32'h55AA55AA; test_colors[7] = 32'hDEADBEEF;

        rst = 1; #100; rst = 0; #50;

        for (integer i = 0; i < 8; i = i + 1) wb_write(i*4, test_colors[i]);
        
        $display("--- Triggering Update ---");
        wb_write(32'h20, 32'h1);

        for (p_idx = 0; p_idx < 8; p_idx = p_idx + 1) verify_pixel(p_idx, test_colors[p_idx]);

        #30000;
        $display("\n=======================================");
        if (error_count == 0) $display("    FINAL STATUS: ALL TESTS PASSED    ");
        else $display("    FINAL STATUS: FAILED (%0d Errors)", error_count);
        $display("=======================================\n");
        $finish;
    end

endmodule

