/**
 * Verilog Wrapper for spi_slave_wb_bridge.sv
 * 
 * This wrapper provides a plain Verilog interface for Xilinx Vivado
 * which may have issues with SystemVerilog in the block designer.
 * 
 * Protocol (all multi-byte values little-endian):
 *   Frame:    [cmd] [len 2B] [addr 4B] [data/pad N] [DA]
 *   Response: [DA]  [resp]   [len echo] [addr echo] [data/ack]
 * 
 * Commands:
 *   0xA1 = Read request  → 0x21 response
 *   0xA2 = Write request → 0x22 response
 *   0xDA = Sync/Ready/Terminate
 *   0x55 = Pad byte (read requests)
 *   0xEE = Write acknowledge
 */

`default_nettype none

module spi_slave_wb_bridge_wrapper #(
    parameter WB_ADDR_WIDTH = 32,
    parameter WB_DATA_WIDTH = 32,
    parameter WB_SEL_WIDTH = 4    // WB_DATA_WIDTH / 8
) (
    input  wire                      clk,
    input  wire                      rst,
    
    // SPI Slave Interface (from SPI slave module)
    input  wire                      spi_rx_valid,
    input  wire [7:0]                spi_rx_data,
    output wire                      spi_tx_valid,
    output wire [7:0]                spi_tx_data,
    input  wire                      spi_tx_ready,
    input  wire                      spi_cs_n,       // Active low chip select
    
    // Wishbone Master Interface
    output wire [WB_ADDR_WIDTH-1:0]  wb_adr_o,
    output wire [WB_DATA_WIDTH-1:0]  wb_dat_o,
    input  wire [WB_DATA_WIDTH-1:0]  wb_dat_i,
    output wire                      wb_we_o,
    output wire [WB_SEL_WIDTH-1:0]   wb_sel_o,
    output wire                      wb_stb_o,
    input  wire                      wb_ack_i,
    input  wire                      wb_err_i,
    output wire                      wb_cyc_o,
    
    // Status
    output wire                      busy
);

    // Instantiate the SystemVerilog module
    spi_slave_wb_bridge #(
        .WB_ADDR_WIDTH(WB_ADDR_WIDTH),
        .WB_DATA_WIDTH(WB_DATA_WIDTH),
        .WB_SEL_WIDTH(WB_SEL_WIDTH)
    ) u_spi_slave_wb_bridge (
        .clk(clk),
        .rst(rst),
        
        // SPI Slave Interface
        .spi_rx_valid(spi_rx_valid),
        .spi_rx_data(spi_rx_data),
        .spi_tx_valid(spi_tx_valid),
        .spi_tx_data(spi_tx_data),
        .spi_tx_ready(spi_tx_ready),
        .spi_cs_n(spi_cs_n),
        
        // Wishbone Master Interface
        .wb_adr_o(wb_adr_o),
        .wb_dat_o(wb_dat_o),
        .wb_dat_i(wb_dat_i),
        .wb_we_o(wb_we_o),
        .wb_sel_o(wb_sel_o),
        .wb_stb_o(wb_stb_o),
        .wb_ack_i(wb_ack_i),
        .wb_err_i(wb_err_i),
        .wb_cyc_o(wb_cyc_o),
        
        // Status
        .busy(busy)
    );

endmodule

`default_nettype wire
