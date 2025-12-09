/**
 * Wishbone Serial/DSHOT Mux Register
 * 
 * Simple Wishbone register to select which device (TTL Serial or DSHOT) drives the shared output line.
 * Address: 0x0400 (word-aligned)
 *   0: TTL Serial
 *   1: DSHOT
 */

module wb_serial_dshot_mux (
    input  wire        wb_clk_i,
    input  wire        wb_rst_i,
    input  wire [31:0] wb_dat_i,
    input  wire [31:0] wb_adr_i,
    input  wire        wb_we_i,
    input  wire [3:0]  wb_sel_i,
    input  wire        wb_stb_i,
    input  wire        wb_cyc_i,
    output reg  [31:0] wb_dat_o,
    output reg         wb_ack_o,
    output wire        wb_stall_o,
    output reg         mux_sel  // 0: TTL Serial, 1: DSHOT
);

    // Only respond to address 0x0400
    wire sel = wb_cyc_i & wb_stb_i & (wb_adr_i[11:2] == 10'h100);

    always @(posedge wb_clk_i) begin
        if (wb_rst_i) begin
            mux_sel <= 1'b0; // Default to TTL Serial
            wb_ack_o <= 1'b0;
            wb_dat_o <= 32'b0;
        end else begin
            wb_ack_o <= 1'b0;
            if (sel) begin
                wb_ack_o <= 1'b1;
                if (wb_we_i) begin
                    mux_sel <= wb_dat_i[0];
                end
                wb_dat_o <= {31'b0, mux_sel};
            end
        end
    end

    assign wb_stall_o = 1'b0;

endmodule
