/**
 * UART Receiver Wrapper
 * 
 * Wrapper around Alex Forencich's uart_rx module
 * Adapts AXI-Stream interface to simple valid/ready interface
 * 
 * Parameters:
 *   - CLK_FREQ_HZ: System clock frequency in Hz (default: 72MHz)
 *   - BAUD_RATE: Serial baud rate in bps (default: 115200)
 * 
 * Signals:
 *   - clk: System clock
 *   - rst: Synchronous reset (active high)
 *   - rx: Serial input line
 *   - data_out: Received data byte (8 bits)
 *   - valid: Data valid strobe (high for one clock cycle when byte received)
 *   - error: Framing error indicator (stop bit not high)
 */

module uart_rx_wrapper #(
    parameter CLK_FREQ_HZ = 72_000_000,
    parameter BAUD_RATE   = 115_200
) (
    input  logic        clk,
    input  logic        rst,
    input  logic        rx,
    output logic [7:0]  data_out,
    output logic        valid,
    output logic        error
);

    // Calculate prescale value for Alex's uart_rx
    // prescale is the number of clock cycles per bit / 8
    localparam PRESCALE = (CLK_FREQ_HZ / BAUD_RATE) / 8;
    
    wire [7:0] m_axis_tdata;
    wire m_axis_tvalid;
    wire frame_error;
    wire overrun_error;
    
    // Always ready to accept data (simple interface, no backpressure)
    wire m_axis_tready = 1'b1;
    
    assign data_out = m_axis_tdata;
    assign valid = m_axis_tvalid;
    assign error = frame_error | overrun_error;
    
    // Instantiate Alex Forencich's uart_rx module
    uart_rx #(
        .DATA_WIDTH(8)
    ) uart_rx_inst (
        .clk(clk),
        .rst(rst),
        // AXI-Stream output
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready),
        // UART interface
        .rxd(rx),
        // Status
        .busy(),  // Not used
        .overrun_error(overrun_error),
        .frame_error(frame_error),
        // Configuration
        .prescale(PRESCALE[15:0])
    );

endmodule
