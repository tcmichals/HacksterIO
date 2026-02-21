/**
 * wb_serial_dshot_mux Testbench (Parallel PC Sniffer Version)
 */
`timescale 1ns/1ps

module wb_serial_dshot_mux_tb;

    // Clock / reset (wb domain)
    logic wb_clk;
    logic wb_rst;

    // Wishbone signals
    logic        wb_we_i;
    logic [31:0] wb_dat_i;
    logic [31:0] wb_adr_i;
    logic [3:0]  wb_sel_i;
    logic        wb_stb_i;
    logic        wb_cyc_i;
    logic [31:0] wb_dat_o;
    logic        wb_ack_o;
    logic        wb_stall_o;

    // DUT physical pads (inout)
    tri [3:0] pad_motor;

    // PC Parallel Interface
    logic [7:0] pc_rx_data;
    logic       pc_rx_valid;

    // Internal signals
    logic [3:0] dshot_in;
    logic        serial_tx_i;
    logic       serial_oe_i;
    wire        serial_rx_o;
    wire        top_mux_sel;

    // Weak pull-ups for pads
    genvar gi;
    generate
        for (gi = 0; gi < 4; gi++) begin : PULLUPS
            pullup(pad_motor[gi]);
        end
    endgenerate

    // DUT instantiation
    logic tb_mux_force_en;
    logic tb_mux_force_sel;
    logic [1:0] tb_mux_force_ch;

    wb_serial_dshot_mux #(
        .CLK_FREQ_HZ(72_000_000)
    ) dut (
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
        .mux_sel(top_mux_sel), 
        .mux_ch(),
        .msp_mode(),
        
        .pc_rx_data(pc_rx_data),
        .pc_rx_valid(pc_rx_valid),

        .pad_motor(pad_motor),
        .dshot_in(dshot_in),
        .serial_tx_i(serial_tx_i),
        .serial_oe_i(serial_oe_i),
        .serial_rx_o(serial_rx_o)
`ifdef SIM_CONTROL
        ,
        .tb_mux_force_en(tb_mux_force_en),
        .tb_mux_force_sel(tb_mux_force_sel),
        .tb_mux_force_ch(tb_mux_force_ch)
`endif
    );

    // Clock generator (72MHz)
    initial begin
        wb_clk = 0;
        forever #6.944 wb_clk = ~wb_clk;
    end

    // Tasks (Using non-blocking for cleaner timing)
    task automatic pc_send_byte(input [7:0] data);
        begin
            @(posedge wb_clk);
            pc_rx_data <= data;
            pc_rx_valid <= 1;
            @(posedge wb_clk);
            pc_rx_valid <= 0;
            pc_rx_data <= 0;
        end
    endtask

    task automatic wb_write_mux(input logic sel, input logic [1:0] ch);
        begin
            @(posedge wb_clk);
            wb_dat_i <= {29'b0, ch, sel};
            wb_adr_i <= 32'h0400;
            wb_we_i  <= 1'b1;
            wb_stb_i <= 1'b1;
            wb_cyc_i <= 1'b1;
            @(posedge wb_clk);
            while (!wb_ack_o) @(posedge wb_clk);
            wb_stb_i <= 0; wb_cyc_i <= 0; wb_we_i <= 0;
            @(posedge wb_clk);
        end
    endtask

    // Main Test Sequence
    initial begin
        wb_rst = 1;
        pc_rx_valid = 0;
        serial_tx_i = 1;
        serial_oe_i = 0;
        dshot_in = 4'b0000;
`ifdef SIM_CONTROL
        tb_mux_force_en = 0;
`endif
        wb_we_i = 0; wb_stb_i = 0; wb_cyc_i = 0;
        
        #100; wb_rst = 0; #100;

        $display("\n[TEST 1] Manual Mode Switch (Register)");
        wb_write_mux(1'b0, 2'b01); // Passthrough ch 1
        repeat(5) @(posedge wb_clk);
        if (top_mux_sel === 1'b0) $display("PASS: Switched to Passthrough");
        else $display("FAIL: Still in DSHOT (top_mux_sel=%b)", top_mux_sel);

        $display("\n[TEST 2] Auto-Hijack (PC Sniffer)");
        wb_write_mux(1'b1, 2'b00); // Back to DSHOT
        repeat(5) @(posedge wb_clk);
        
        $display("Sending MSP_SET_PASSTHROUGH ($M< [0] [0xF5])");
        pc_send_byte("$");
        pc_send_byte("M");
        pc_send_byte("<");
        pc_send_byte(0);    // Len
        pc_send_byte(8'hF5); // CMD
        
        repeat(10) @(posedge wb_clk);
        if (top_mux_sel === 1'b0) $display("PASS: Auto-hijack triggered!");
        else $display("FAIL: Still in DSHOT mode (mux_sel=%b, state=%d)", top_mux_sel, dut.sniff_state);

        $display("\nAll Mux Tests Complete!");
        #1000; $finish;
    end

    initial begin
        $dumpfile("wb_serial_dshot_mux_tb.vcd");
        $dumpvars(0, wb_serial_dshot_mux_tb);
    end

endmodule
