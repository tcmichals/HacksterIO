/**
 * UART Passthrough Bridge
 *
 * Bridges USB UART (from PC/BLHeli tools) to half-duplex serial (ESC).
 * This module operates independently of Wishbone - it's pure hardware passthrough.
 *
 * Architecture:
 *   PC (BLHeli) ←→ USB UART (115200) ←→ This Module ←→ Half-Duplex Serial (115200) ←→ ESC
 *
 * Features:
 *   - Automatic half-duplex control (tri-state buffering)
 *   - Byte-level bridging with minimal latency
 *   - Enable/disable control (for switching to DSHOT mode)
 */

module uart_passthrough_bridge #(
    parameter CLK_FREQ_HZ = 72_000_000,
    parameter BAUD_RATE = 115200,
    // Configuration parameter: when set to 1 disables automatic echo
    // (prevents serial->USB forwarding). Default 0 = echo enabled.
    parameter DISABLE_AUTO_ECHO = 0
) (
    input  logic clk,
    input  logic rst,

    // USB UART Interface (to PC)
    input  logic usb_uart_rx,
    output logic usb_uart_tx,

    // Split Half-Duplex Serial Interface (to/from ESC)
    output logic serial_tx_out, // driven serial output
    output logic serial_tx_oe,  // output enable for tri-state on external pad
    input  logic  serial_rx_in, // receive from external pad

    // Control
    input  logic enable,        // 1: passthrough enabled

    // Status
    output logic active         // 1: currently transmitting or receiving
);

    // =============================
    // USB UART (Full Duplex to PC)
    // =============================
    logic [7:0] usb_rx_data;
    logic       usb_rx_valid;
    logic       usb_rx_error;
    
    logic [7:0] usb_tx_data;
    logic       usb_tx_valid;
    logic       usb_tx_ready;
    
    uart_rx_wrapper #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .BAUD_RATE(BAUD_RATE)
    ) u_usb_uart_rx (
        .clk(clk),
        .rst(rst),
        .rx(usb_uart_rx),
        .data_out(usb_rx_data),
        .valid(usb_rx_valid),
        .error(usb_rx_error)
    );
    
    uart_tx_wrapper #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .BAUD_RATE(BAUD_RATE)
    ) u_usb_uart_tx (
        .clk(clk),
        .rst(rst),
        .tx(usb_uart_tx),
        .data_in(usb_tx_data),
        .valid(usb_tx_valid),
        .ready(usb_tx_ready),
        .active()               // Not used for USB UART
    );
    
    // =============================
    // Half-Duplex Serial (to ESC)
    // =============================
    logic [7:0] serial_rx_data;
    logic       serial_rx_valid;
    logic       serial_rx_error;
    
    logic [7:0] serial_tx_data;
    logic       serial_tx_valid;
    logic       serial_tx_ready;
    logic       serial_tx_active;
    
    logic       serial_out;
    logic       serial_oe;      // Output enable for tri-state
    
    uart_rx_wrapper #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .BAUD_RATE(BAUD_RATE)
    ) u_serial_rx (
        .clk(clk),
        .rst(rst),
        .rx(serial_rx_in),      // Read from external pad when not transmitting
        .data_out(serial_rx_data),
        .valid(serial_rx_valid),
        .error(serial_rx_error)
    );
    
    uart_tx_wrapper #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .BAUD_RATE(BAUD_RATE)
    ) u_serial_tx (
        .clk(clk),
        .rst(rst),
        .tx(serial_tx_out),
        .data_in(serial_tx_data),
        .valid(serial_tx_valid),
        .ready(serial_tx_ready),
        .active(serial_tx_active)   // High when transmitting
    );
    
    // Tri-state control: expose TX data and OE for external pad driver
    assign serial_tx_oe = serial_tx_active & enable;
    
    // =============================
    // Bridging Logic
    // =============================
    // USB RX → Serial TX (PC to ESC)
    assign serial_tx_data = usb_rx_data;
    assign serial_tx_valid = usb_rx_valid & enable;
    
    // Serial RX → USB TX (ESC to PC)
    // Prevent echo: do not forward received bytes while we are actively driving the serial pin
    assign usb_tx_data = serial_rx_data;
    assign usb_tx_valid = serial_rx_valid & enable & (~serial_oe) & (DISABLE_AUTO_ECHO == 0);
    
    // Status
    assign active = enable & (serial_tx_active | usb_tx_valid | serial_rx_valid);

endmodule
