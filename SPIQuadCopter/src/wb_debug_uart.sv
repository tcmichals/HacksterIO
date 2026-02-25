// Wishbone wrapper for verilog-uart uart_tx module (debug UART)
`default_nettype none

module wb_debug_uart #(
    parameter CLK_FREQ = 72_000_000,
    parameter BAUD     = 1_000_000  // 1 Mbaud
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
    
    // UART output
    output wire        uart_tx
);

    // Register offsets (relative addressing)
    localparam REG_TX_DATA = 3'h0;   // Write: TX byte
    localparam REG_STATUS  = 3'h4;   // Read: bit0 = TX ready

    // Prescale value for verilog-uart: CLK_FREQ / (BAUD * 8)
    localparam [15:0] PRESCALE = CLK_FREQ / (BAUD * 8);

    // AXI-Stream interface to uart_tx
    reg  [7:0] tx_data;
    reg        tx_valid;
    wire       tx_ready;
    wire       tx_busy;

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

    // Wishbone logic
    always @(posedge clk) begin
        if (rst) begin
            wb_ack_o <= 1'b0;
            wb_dat_o <= 32'b0;
            tx_data  <= 8'b0;
            tx_valid <= 1'b0;
        end else begin
            // Clear valid after one cycle (handshake)
            if (tx_valid && tx_ready)
                tx_valid <= 1'b0;

            // Wishbone transaction
            if (wb_stb_i && !wb_ack_o) begin
                wb_ack_o <= 1'b1;
                
                if (wb_we_i) begin
                    // Write
                    case (wb_adr_i[2:0])
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
                    case (wb_adr_i[2:0])
                        REG_STATUS: wb_dat_o <= {31'b0, tx_ready};
                        default:    wb_dat_o <= 32'b0;
                    endcase
                end
            end else begin
                wb_ack_o <= 1'b0;
            end
        end
    end

endmodule

`default_nettype wire
