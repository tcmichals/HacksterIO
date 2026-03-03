/**
 * UART TX Enable Generator
 * 
 * Simple helper module to generate TX enable signal for UARTs that don't
 * provide it. Detects when TX line is not idle (not high) and generates
 * an enable signal.
 * 
 * Usage:
 *   Connect this between your UART IP and the wb_spisystem_wrapper.
 *   
 *   UART IP --> uart_tx_enable_gen --> wb_spisystem_wrapper
 *
 * Note: If your Vivado UART IP already has TX_EN or similar signal,
 *       you don't need this module - connect that signal directly.
 */

`default_nettype none

module uart_tx_enable_gen (
    input  wire        clk,
    input  wire        rst,
    
    // From UART IP
    input  wire        uart_tx,      // UART TX signal
    
    // To ESC bridge
    output wire        uart_tx_en    // TX enable (high when transmitting)
);

    // UART idle state is high (1)
    // When transmitting, TX goes low for start bit
    // Keep TX_EN high for a few extra clocks after TX returns high
    // to account for stop bits
    
    reg [3:0] tx_counter;
    reg tx_active;
    
    always @(posedge clk) begin
        if (rst) begin
            tx_counter <= 4'h0;
            tx_active <= 1'b0;
        end else begin
            if (!uart_tx) begin
                // TX is low (start bit or data) - definitely transmitting
                tx_active <= 1'b1;
                tx_counter <= 4'hF;  // Reset counter
            end else if (tx_counter > 0) begin
                // TX is high but counter not expired - still in stop bits
                tx_counter <= tx_counter - 1;
                tx_active <= 1'b1;
            end else begin
                // TX is idle
                tx_active <= 1'b0;
            end
        end
    end
    
    assign uart_tx_en = tx_active;

endmodule

`default_nettype wire
