/**
 * UART Transmitter Wrapper
 * 
 * Wrapper around Alex Forencich's uart_tx module
 * Adapts AXI-Stream interface to simple valid/ready interface
 * 
 * Parameters:
 *   - CLK_FREQ_HZ: System clock frequency in Hz (default: 72MHz)
 *   - BAUD_RATE: Serial baud rate in bps (default: 115200)
 * 
 * Signals:
 *   - clk: System clock
 *   - rst: Synchronous reset (active high)
 *   - tx: Serial output line
 *   - data_in: Data byte to transmit (8 bits)
 *   - valid: Data valid strobe (high for one clock when data is ready)
 *   - ready: Transmitter ready for new data
 *   - active: High when transmission in progress
 */

module uart_tx_wrapper #(
    parameter CLK_FREQ_HZ = 72_000_000,
    parameter BAUD_RATE   = 115_200
) (
    input  logic        clk,
    input  logic        rst,
    output logic        tx,
    input  logic [7:0]  data_in,
    input  logic        valid,
    output logic        ready,
    output logic        active      // High when actively transmitting
);

    // Calculate prescale value for Alex's uart_tx
    // prescale is the number of clock cycles per bit / 8
    localparam PRESCALE = (CLK_FREQ_HZ / BAUD_RATE) / 8;
    
    wire txd_wire;
    assign tx = txd_wire;
    
    // Instantiate Alex Forencich's uart_tx module
    uart_tx #(
        .DATA_WIDTH(8)
    ) uart_tx_inst (
        .clk(clk),
        .rst(rst),
        // AXI-Stream input
        .s_axis_tdata(data_in),
        .s_axis_tvalid(valid),
        .s_axis_tready(ready),
        // UART interface
        .txd(txd_wire),
        // Status
        .busy(active),
        // Configuration
        .prescale(PRESCALE[15:0])
    );

endmodule
