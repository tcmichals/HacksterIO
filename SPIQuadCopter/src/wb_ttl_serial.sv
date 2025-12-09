/**
 * Wishbone TTL Serial UART Controller (16650-style)
 *
 * Features:
 * - RX and TX FIFOs (16 bytes each)
 * - External interrupt output (RX ready, TX empty)
 * - Register map: Data, Interrupt Enable, Interrupt ID, FIFO Control, Line Status, etc.
 * - Timing: 115200 baud @ 72 MHz clock (bit period = 625 cycles)
 * - Half/full duplex selectable
 *
 * Address map:
 *   0x00: Data register (R/W, FIFO)
 *   0x04: Interrupt Enable (R/W)
 *   0x08: Interrupt ID (R)
 *   0x0C: Line Status (R)
 *   0x10: Control register (RW)
 *
 * See SYSTEM_OVERVIEW.md for details.
 */

module wb_ttl_serial #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter SELECT_WIDTH = (DATA_WIDTH/8),
    parameter CLK_FREQ_HZ = 72_000_000,
    parameter BAUD_RATE = 115_200,
    parameter HALF_DUPLEX = 1
) (
    input  wire                    clk,
    input  wire                    rst,
    
    // Wishbone slave interface
    input  wire [ADDR_WIDTH-1:0]   wbs_adr_i,
    input  wire [DATA_WIDTH-1:0]   wbs_dat_i,
    output reg  [DATA_WIDTH-1:0]   wbs_dat_o,
    input  wire                    wbs_we_i,
    input  wire [SELECT_WIDTH-1:0] wbs_sel_i,
    input  wire                    wbs_stb_i,
    output reg                     wbs_ack_o,
    output wire                    wbs_err_o,
    output wire                    wbs_rty_o,
    input  wire                    wbs_cyc_i,
    
    // Serial interface
    inout  wire                    serial,
    
    // Control signals
    output reg                     half_duplex_en
);

    localparam ADDR_TX_DATA = 2'h0;
    localparam ADDR_RX_DATA = 2'h1;
    localparam ADDR_STATUS  = 2'h2;
    localparam ADDR_CTRL    = 2'h3;
    
    // Address bits
    wire [1:0] addr_bits = wbs_adr_i[3:2];
    
    // Internal signals
    logic [7:0] tx_data;
    logic       tx_valid;
    logic       tx_ready;
    logic [7:0] rx_data;
    logic       rx_valid;
    
    // Wishbone protocol
    assign wbs_err_o = 1'b0;
    assign wbs_rty_o = 1'b0;
    
    // Instantiate TTL Serial module
    ttl_serial #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .BAUD_RATE(BAUD_RATE),
        .HALF_DUPLEX(HALF_DUPLEX)
    ) u_ttl_serial (
        .clk(clk),
        .rst_n(~rst),
        .tx_data(tx_data),
        .tx_valid(tx_valid),
        .tx_ready(tx_ready),
        .rx_data(rx_data),
        .rx_valid(rx_valid),
        .serial(serial),
        .half_duplex_en(half_duplex_en)
    );
    
    // RX data capture (from TTL Serial)
    logic [7:0] rx_data_latched;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rx_data_latched <= 8'h00;
        end else if (rx_valid) begin
            rx_data_latched <= rx_data;
        end
    end
    
    // 16650 UART Wishbone interface logic with FIFOs and interrupt
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wbs_ack_o <= 1'b0;
            wbs_dat_o <= 32'h0;
            tx_valid <= 1'b0;
            half_duplex_en <= 1'b1;
            irq_enabled <= 1'b0;
        end else begin
            tx_valid <= 1'b0;  // Default
            wbs_ack_o <= wbs_stb_i && wbs_cyc_i;

            if (wbs_stb_i && wbs_cyc_i) begin
                if (wbs_we_i) begin
                    // Write operation
                    case (addr_bits)
                        ADDR_DATA: begin
                            // Write to TX FIFO
                            if (tx_fifo_count < 16) begin
                                tx_fifo[tx_fifo_wr_ptr] <= wbs_dat_i[7:0];
                                tx_fifo_wr_ptr <= tx_fifo_wr_ptr + 1;
                                tx_fifo_count  <= tx_fifo_count + 1;
                            end
                        end
                        ADDR_IER: begin
                            irq_enabled <= wbs_dat_i[0];
                        end
                        ADDR_LCR: begin
                            half_duplex_en <= wbs_dat_i[0];
                        end
                        // FIFO Control, Modem Control, etc. can be added here
                    endcase
                end else begin
                    // Read operation
                    case (addr_bits)
                        ADDR_DATA: begin
                            wbs_dat_o <= {24'h0, rx_fifo_count ? rx_fifo[rx_fifo_rd_ptr] : 8'h0};
                            if (rx_fifo_count > 0) begin
                                rx_fifo_rd_ptr <= rx_fifo_rd_ptr + 1;
                                rx_fifo_count  <= rx_fifo_count - 1;
                            end
                        end
                        ADDR_IER: begin
                            wbs_dat_o <= {31'h0, irq_enabled};
                        end
                        ADDR_IIR: begin
                            wbs_dat_o <= {30'h0, irq_rx_ready, irq_tx_empty};
                        end
                        ADDR_LSR: begin
                            wbs_dat_o <= {24'h0, 8'h60 | (rx_fifo_count ? 8'h01 : 8'h00)}; // Line Status: TX empty, RX ready
                        end
                        default: begin
                            wbs_dat_o <= 32'h0;
                        end
                    endcase
                end
            end
        end
    end

endmodule
