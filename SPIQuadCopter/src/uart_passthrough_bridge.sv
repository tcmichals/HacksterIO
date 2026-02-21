/**
 * UART Passthrough Bridge
 *
 * Bridges PC-side parallel bytes to half-duplex serial (ESC).
 * This module operates at the physical layer for the ESC (19200 baud).
 *
 * Architecture:
 *   PC (Bytes) ←→ This Module ←→ Half-Duplex Serial (19200) ←→ ESC
 *
 * Features:
 *   - Automatic half-duplex control (tri-state buffering)
 *   - Byte-level bridging with conversion FIFO
 *   - Echo suppression logic for 1-wire support
 */

module uart_passthrough_bridge #(
    parameter CLK_FREQ_HZ = 72_000_000,
    parameter SERIAL_BAUD_RATE = 19200,
    parameter DISABLE_AUTO_ECHO = 0
) (
    input  logic clk,
    input  logic rst,

    // PC Interface (Byte-Parallel)
    // Fed from shared top-level USB UART
    input  logic [7:0] pc_rx_data,
    input  logic       pc_rx_valid,
    output logic [7:0] pc_tx_data,
    output logic       pc_tx_valid,
    input  logic       pc_tx_ready,

    // Physical Serial Interface (to ESC pads)
    output logic serial_tx_out, 
    output logic serial_tx_oe,  
    input  logic serial_rx_in,  

    // External Request Interface (e.g. from 4-way handler)
    input  logic [7:0] ext_serial_tx_data,
    input  logic       ext_serial_tx_valid,
    output logic       ext_serial_tx_ready,
    output logic [7:0] ext_serial_rx_data,
    output logic       ext_serial_rx_valid,

    // Control
    input  logic enable,        // 1: passthrough active on pads

    // Status
    output logic active         
);

    // =============================
    // ESC UART (Physical Layer)
    // =============================
    logic [7:0] serial_rx_data;
    logic       serial_rx_valid;
    
    logic [7:0] serial_tx_data_byte;
    logic       serial_tx_valid_byte;
    logic       serial_tx_ready_byte;
    logic       serial_tx_active;
    
    // Half-duplex turn-around/enable sync
    logic enable_sync;
    logic enable_meta;
    always_ff @(posedge clk) begin
        if (rst) begin
            enable_meta <= 1'b0;
            enable_sync <= 1'b0;
        end else begin
            enable_meta <= enable;
            enable_sync <= enable_meta;
        end
    end

    uart_rx_wrapper #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .BAUD_RATE(SERIAL_BAUD_RATE)
    ) u_serial_rx (
        .clk(clk),
        .rst(rst),
        .rx(serial_rx_in),
        .data_out(serial_rx_data),
        .valid(serial_rx_valid),
        .error()
    );
    
    uart_tx_wrapper #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .BAUD_RATE(SERIAL_BAUD_RATE)
    ) u_serial_tx (
        .clk(clk),
        .rst(rst),
        .tx(serial_tx_out),
        .data_in(serial_tx_data_byte),
        .valid(serial_tx_valid_byte),
        .ready(serial_tx_ready_byte),
        .active(serial_tx_active)
    );
    
    assign serial_tx_oe = serial_tx_active & enable_sync;
    
    // =============================
    // Bridging & FIFO
    // =============================
    localparam FIFO_DEPTH = 512;
    localparam PTR_WIDTH = $clog2(FIFO_DEPTH);
    
    logic [7:0] tx_fifo [FIFO_DEPTH-1:0];
    logic [PTR_WIDTH-1:0] wr_ptr;
    logic [PTR_WIDTH-1:0] rd_ptr;
    logic [PTR_WIDTH:0]   count;
    
    wire fifo_empty = (count == 0);
    wire fifo_full = (count == FIFO_DEPTH);
    
    wire fifo_write = pc_rx_valid & ~fifo_full & enable; // Only capture if enabled
    wire fifo_read  = serial_tx_valid_byte & serial_tx_ready_byte & ~fifo_empty;
    
    always_ff @(posedge clk) begin
        if (rst) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            count  <= 0;
        end else begin
            if (fifo_write) begin
                tx_fifo[wr_ptr] <= pc_rx_data;
                wr_ptr <= wr_ptr + 1'b1;
            end
            if (fifo_read) begin
                rd_ptr <= rd_ptr + 1'b1;
            end
            if (fifo_write && !fifo_read)
                count <= count + 1'b1;
            else if (!fifo_write && fifo_read)
                count <= count - 1'b1;
        end
    end
    
    // Path selection: External (4-way) has priority or FIFO
    assign serial_tx_data_byte = ext_serial_tx_valid ? ext_serial_tx_data : tx_fifo[rd_ptr];
    assign serial_tx_valid_byte = (ext_serial_tx_valid | ~fifo_empty);
    assign ext_serial_tx_ready = serial_tx_ready_byte;
    
    assign ext_serial_rx_data = serial_rx_data;
    assign ext_serial_rx_valid = serial_rx_valid;
    
    // Echo Suppression
    logic [15:0] suppress_cnt;
    logic        suppressing;
    localparam   SUPPRESS_TIME = 2000; // ~27us @ 72MHz

    always_ff @(posedge clk) begin
        if (rst) begin
            suppress_cnt <= 0;
            suppressing <= 0;
        end else begin
            if (serial_tx_oe) begin
                suppressing <= 1;
                suppress_cnt <= 0;
            end else if (suppressing) begin
                if (suppress_cnt < SUPPRESS_TIME)
                    suppress_cnt <= suppress_cnt + 1'b1;
                else
                    suppressing <= 0;
            end
        end
    end

    // PC-bound byte path
    assign pc_tx_data  = serial_rx_data;
    assign pc_tx_valid = serial_rx_valid & enable_sync & ~suppressing & (DISABLE_AUTO_ECHO == 0);
    
    assign active = enable_sync & (serial_tx_active | pc_tx_valid | serial_rx_valid | ~fifo_empty);

endmodule
