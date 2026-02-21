`default_nettype none
`timescale 1ns / 1ps

module wb_uart_wrapper #(
    parameter CLK_FREQ_HZ = 72_000_000,
    parameter FIFO_DEPTH = 64
) (
    input  wire        clk,
    input  wire        rst,

    // Wishbone Interface
    input  wire [31:0] wb_adr_i,
    input  wire [31:0] wb_dat_i,
    output reg  [31:0] wb_dat_o,
    input  wire        wb_we_i,
    input  wire        wb_stb_i,
    input  wire        wb_cyc_i,
    input  wire [3:0]  wb_sel_i,
    output reg         wb_ack_o,

    // Interface to UART Passthrough Bridge
    output reg  [7:0]  ext_tx_data,
    output reg         ext_tx_valid,
    input  wire        ext_tx_ready,
    input  wire [7:0]  ext_rx_data,
    input  wire        ext_rx_valid
);

    // Register Offsets
    localparam REG_DATA = 5'h00;
    localparam REG_IER  = 5'h04;
    localparam REG_IIR  = 5'h08;
    localparam REG_LSR  = 5'h0C;
    localparam REG_CTRL = 5'h10;

    // RX FIFO
    reg [7:0] rx_fifo [0:FIFO_DEPTH-1];
    reg [$clog2(FIFO_DEPTH)-1:0] rx_wr_ptr;
    reg [$clog2(FIFO_DEPTH)-1:0] rx_rd_ptr;
    reg [$clog2(FIFO_DEPTH):0]   rx_count;

    wire rx_empty = (rx_count == 0);
    wire rx_full  = (rx_count == FIFO_DEPTH);

    // Wishbone Logic
    always @(posedge clk) begin
        if (rst) begin
            rx_wr_ptr <= 0;
            rx_rd_ptr <= 0;
            rx_count <= 0;
            wb_ack_o <= 0;
            wb_dat_o <= 0;
            ext_tx_valid <= 0;
            ext_tx_data <= 0;
        end else begin
            // RX FIFO Write Logic (Independent of Wishbone)
            if (ext_rx_valid && !rx_full) begin
                rx_fifo[rx_wr_ptr] <= ext_rx_data;
                rx_wr_ptr <= rx_wr_ptr + 1;
                rx_count <= rx_count + 1;
            end

            // Wishbone Acknowledge Logic
            if (wb_cyc_i && wb_stb_i && !wb_ack_o) begin
                wb_ack_o <= 1; // Auto-ack after 1 cycle
                
                // Read Logic
                if (!wb_we_i) begin
                    case (wb_adr_i[4:0]) // Decoding lower 5 bits to support 0x10
                        REG_DATA: begin
                            if (!rx_empty) begin
                                wb_dat_o <= {24'h0, rx_fifo[rx_rd_ptr]};
                                rx_rd_ptr <= rx_rd_ptr + 1;
                                // Need to decrement rx_count, but it might be incremented by RX write simultaneously
                                if (ext_rx_valid && !rx_full) begin
                                    // Write happened, so +1. Reading removes 1. Net change 0.
                                    rx_count <= rx_count; 
                                end else begin
                                    // No write, only read. -1.
                                    rx_count <= rx_count - 1;
                                end
                            end else begin
                                wb_dat_o <= 0; // Return 0 if empty
                            end
                        end
                        REG_LSR: begin
                            // Bit 0: RX Ready, Bit 5: TX Holding Register Empty (Ready to accept char)
                            wb_dat_o <= {26'h0, ext_tx_ready, 4'h0, !rx_empty};
                        end
                        default: wb_dat_o <= 0;
                    endcase
                end 
                // Write Logic
                else begin
                    if (wb_adr_i[4:0] == REG_DATA) begin
                        if (ext_tx_ready) begin
                            ext_tx_data <= wb_dat_i[7:0];
                            ext_tx_valid <= 1;
                        end
                    end
                end
            end else begin
                wb_ack_o <= 0;
                // Deassert valid after one cycle (it pulses)
                // Bridge expects valid pulse or hold until ready? 
                // Bridge logic: `assign serial_tx_valid = (ext_serial_tx_valid | ...)`
                // `u_serial_tx` latches on `valid & ready`.
                // So if we assert valid this cycle, and it was ready, it captures.
                // We should deassert next cycle.
                ext_tx_valid <= 0;
            end
        end
    end

endmodule
