// Wishbone USB UART with RX and TX (for MSP communication)
`default_nettype none

module wb_usb_uart #(
    parameter CLK_FREQ = 72_000_000,
    parameter BAUD     = 115200
)(
    input  wire        clk,
    input  wire        rst,
    
    // Wishbone slave interface
    input  wire [31:0] wb_adr_i,
    input  wire [31:0] wb_dat_i,
    output reg  [31:0] wb_dat_o,
    input  wire        wb_we_i,
    input  wire        wb_stb_i,
    output reg         wb_ack_o,
    
    // UART pins
    input  wire        uart_rx,
    output wire        uart_tx
);

    // Register offsets (relative addressing)
    localparam REG_TX_DATA   = 4'h0;   // Write: TX byte, Read: RX byte
    localparam REG_STATUS    = 4'h4;   // Read: bit0 = TX ready, bit1 = RX valid
    localparam REG_RX_DATA   = 4'h8;   // Read: RX byte (same as offset 0 read)

    // Prescale value for verilog-uart: CLK_FREQ / (BAUD * 8)
    localparam [15:0] PRESCALE = CLK_FREQ / (BAUD * 8);

    // TX interface
    reg  [7:0] tx_data;
    reg        tx_valid;
    wire       tx_ready;
    wire       tx_busy;

    // RX interface
    wire [7:0] rx_data;
    wire       rx_valid;
    reg        rx_read;  // Pulse to acknowledge RX

    // RX FIFO (simple 1-byte buffer with valid flag)
    reg [7:0]  rx_buffer;
    reg        rx_buffer_valid;

    // Instantiate uart_tx from verilog-uart library
    uart_tx #(
        .DATA_WIDTH(8)
    ) u_uart_tx (
        .clk(clk),
        .rst(rst),
        .s_axis_tdata(tx_data),
        .s_axis_tvalid(tx_valid),
        .s_axis_tready(tx_ready),
        .txd(uart_tx),
        .busy(tx_busy),
        .prescale(PRESCALE)
    );

    // Instantiate uart_rx from verilog-uart library
    uart_rx #(
        .DATA_WIDTH(8)
    ) u_uart_rx (
        .clk(clk),
        .rst(rst),
        .m_axis_tdata(rx_data),
        .m_axis_tvalid(rx_valid),
        .m_axis_tready(1'b1),  // Always ready - we buffer internally
        .rxd(uart_rx),
        .busy(),
        .overrun_error(),
        .frame_error(),
        .prescale(PRESCALE)
    );

    // RX buffer logic
    always @(posedge clk) begin
        if (rst) begin
            rx_buffer <= 8'b0;
            rx_buffer_valid <= 1'b0;
        end else begin
            // Clear buffer on read
            if (rx_read) begin
                rx_buffer_valid <= 1'b0;
            end
            // Capture new RX data (overwrites if not read - simple design)
            if (rx_valid) begin
                rx_buffer <= rx_data;
                rx_buffer_valid <= 1'b1;
            end
        end
    end

    // Wishbone logic
    always @(posedge clk) begin
        if (rst) begin
            wb_ack_o <= 1'b0;
            wb_dat_o <= 32'b0;
            tx_data  <= 8'b0;
            tx_valid <= 1'b0;
            rx_read  <= 1'b0;
        end else begin
            // Clear valid after one cycle (handshake)
            if (tx_valid && tx_ready)
                tx_valid <= 1'b0;
            
            // Clear rx_read pulse
            rx_read <= 1'b0;

            // Wishbone transaction
            if (wb_stb_i && !wb_ack_o) begin
                wb_ack_o <= 1'b1;
                
                if (wb_we_i) begin
                    // Write
                    case (wb_adr_i[3:0])
                        REG_TX_DATA: begin
                            if (tx_ready) begin
                                tx_data  <= wb_dat_i[7:0];
                                tx_valid <= 1'b1;
                            end
                        end
                        default: ;
                    endcase
                end else begin
                    // Read
                    case (wb_adr_i[3:0])
                        REG_TX_DATA, REG_RX_DATA: begin
                            wb_dat_o <= {24'b0, rx_buffer};
                            rx_read  <= rx_buffer_valid;  // Clear valid on read
                        end
                        REG_STATUS: begin
                            wb_dat_o <= {30'b0, rx_buffer_valid, tx_ready};
                        end
                        default: wb_dat_o <= 32'b0;
                    endcase
                end
            end else begin
                wb_ack_o <= 1'b0;
            end
        end
    end

endmodule

`default_nettype wire
