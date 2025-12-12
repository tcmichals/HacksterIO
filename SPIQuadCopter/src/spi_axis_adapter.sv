/**
 * SPI to AXI Stream Bridge
 * 
 * Simple bridge that streams SPI data directly to AXI Stream interface
 * Uses IMPLICIT_FRAMING mode - axis_wb_master detects command bytes (0xA1/0xA2)
 * 
 * Operation:
 * 1. SPI bytes are forwarded directly to AXI Stream
 * 2. axis_wb_master looks for READ_REQ (0xA1) or WRITE_REQ (0xA2) to detect frame start
 * 3. Command format defines packet length, so tlast is not needed
 * 4. Responses are streamed back to SPI
 */

module spi_axis_adapter #(
    parameter AXIS_DATA_WIDTH = 8
) (
    input  logic                       clk,
    input  logic                       rst,
    
    // SPI Slave Interface
    input  logic [7:0]                 spi_rx_data,
    input  logic                       spi_rx_valid,
    output logic [7:0]                 spi_tx_data,
    output logic                       spi_tx_valid,
    input  logic                       spi_busy,
    input  logic                       spi_cs_n,      // Optional: can be used for debug/status
    input  logic                       spi_tx_ready,  // Slave ready for new TX data
    
    // AXI Stream Output (to axis_wb_master input)
    output logic [AXIS_DATA_WIDTH-1:0] m_axis_tdata,
    output logic                       m_axis_tvalid,
    input  logic                       m_axis_tready,
    output logic                       m_axis_tlast,  // Not used in implicit framing
    
    // AXI Stream Input (from axis_wb_master output)
    input  logic [AXIS_DATA_WIDTH-1:0] s_axis_tdata,
    input  logic                       s_axis_tvalid,
    output logic                       s_axis_tready,
    input  logic                       s_axis_tlast
);


reg m_tvalid;
reg [7:0] spiData;

// Accept data from Wishbone Master whenever SPI slave can take it (holding register free)
assign s_axis_tready = spi_tx_ready;
assign spi_tx_valid = (s_axis_tready & s_axis_tvalid);
assign spi_tx_data = (spi_tx_valid)? s_axis_tdata: 0;
assign m_axis_tdata = spiData;
assign m_axis_tvalid = m_tvalid;
 
// tlast not used in implicit framing mode
assign m_axis_tlast = 1'b0;
    
    // =============================
    // AXI Stream RX to SPI TX
    // Forward data from the AXIS sink back to the SPI TX path so the
    // SPI slave can shift out response bytes while CS is asserted.
    // =============================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            m_tvalid <= 1'b0;
            spiData <= 8'h0;
        end else begin
            if (~m_tvalid  & spi_rx_valid) begin
                m_tvalid <= 1'b1;
                spiData <= spi_rx_data;
            end
            else begin
                m_tvalid <= 1'b0;
            end
        end


    end

endmodule
