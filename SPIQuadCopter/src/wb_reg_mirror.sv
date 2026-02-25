/**
 * Wishbone Read-Only Register Mirror
 * 
 * Provides a read-only view of an external register value on the Wishbone bus.
 * Writes are ACK'd normally but have no effect (bus never hangs).
 * 
 * Use case: Allow SPI bus to read SERV's mux register without sharing the bus.
 */

`default_nettype none

module wb_reg_mirror #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
) (
    input  wire                    i_clk,
    input  wire                    i_rst,
    
    // Wishbone slave interface
    input  wire [ADDR_WIDTH-1:0]   wb_adr_i,
    input  wire [DATA_WIDTH-1:0]   wb_dat_i,
    output wire [DATA_WIDTH-1:0]   wb_dat_o,
    input  wire                    wb_we_i,
    input  wire                    wb_stb_i,
    output reg                     wb_ack_o,
    input  wire                    wb_cyc_i,
    
    // Mirror input (directly wired from source register)
    input  wire [DATA_WIDTH-1:0]   i_mirror_value
);

    // Always output the mirror value
    assign wb_dat_o = i_mirror_value;
    
    // ACK any valid cycle (reads AND writes) - writes just do nothing
    always @(posedge i_clk) begin
        if (i_rst) begin
            wb_ack_o <= 1'b0;
        end else begin
            // Single-cycle ACK for any strobe
            wb_ack_o <= wb_stb_i && wb_cyc_i && !wb_ack_o;
        end
    end

endmodule

`default_nettype wire
