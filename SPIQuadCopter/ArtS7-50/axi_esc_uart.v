/**
 * AXI4-Lite ESC UART Controller
 * 
 * Half-duplex UART for BLHeli ESC configuration at 19200 baud.
 * Compatible with Tang's wb_esc_uart but with AXI4-Lite interface.
 * 
 * Features:
 *   - AXI4-Lite slave interface
 *   - 19200 baud, 8-N-1 format
 *   - Automatic half-duplex control (tx_active signal)
 *   - TX and RX interrupts
 *   - TX done indication
 *   - Single byte TX/RX buffers
 * 
 * Register Map (byte addresses):
 *   0x00: TX_DATA   [W]  - Write byte to transmit (starts transmission)
 *   0x04: STATUS    [R]  - bit0=TX_READY, bit1=RX_VALID, bit2=TX_ACTIVE, bit3=TX_DONE
 *   0x08: RX_DATA   [R]  - Read received byte (clears RX_VALID and RX interrupt)
 *   0x0C: CONTROL   [RW] - bit0=TX_INT_EN, bit1=RX_INT_EN
 *   0x10: INT_STAT  [R]  - bit0=TX_INT, bit1=RX_INT (write 1 to clear)
 * 
 * Half-Duplex Behavior:
 *   - tx_active HIGH during transmission (disables RX)
 *   - tx_active LOW when idle (enables RX)
 *   - Guard time after TX before enabling RX
 * 
 * Interrupts:
 *   - irq_tx: Asserted when transmission completes (TX_DONE set)
 *   - irq_rx: Asserted when byte received (RX_VALID set)
 *   - Both cleared by writing to INT_STAT register or reading RX_DATA
 */

module axi_esc_uart #(
    parameter integer C_S_AXI_DATA_WIDTH = 32,
    parameter integer C_S_AXI_ADDR_WIDTH = 5,
    parameter integer CLK_FREQ_HZ = 54_000_000
) (
    // AXI4-Lite Interface
    input  wire                                 S_AXI_ACLK,
    input  wire                                 S_AXI_ARESETN,
    
    // Write Address Channel
    input  wire [C_S_AXI_ADDR_WIDTH-1:0]       S_AXI_AWADDR,
    input  wire [2:0]                           S_AXI_AWPROT,
    input  wire                                 S_AXI_AWVALID,
    output wire                                 S_AXI_AWREADY,
    
    // Write Data Channel
    input  wire [C_S_AXI_DATA_WIDTH-1:0]       S_AXI_WDATA,
    input  wire [(C_S_AXI_DATA_WIDTH/8)-1:0]   S_AXI_WSTRB,
    input  wire                                 S_AXI_WVALID,
    output wire                                 S_AXI_WREADY,
    
    // Write Response Channel
    output wire [1:0]                           S_AXI_BRESP,
    output wire                                 S_AXI_BVALID,
    input  wire                                 S_AXI_BREADY,
    
    // Read Address Channel
    input  wire [C_S_AXI_ADDR_WIDTH-1:0]       S_AXI_ARADDR,
    input  wire [2:0]                           S_AXI_ARPROT,
    input  wire                                 S_AXI_ARVALID,
    output wire                                 S_AXI_ARREADY,
    
    // Read Data Channel
    output wire [C_S_AXI_DATA_WIDTH-1:0]       S_AXI_RDATA,
    output wire [1:0]                           S_AXI_RRESP,
    output wire                                 S_AXI_RVALID,
    input  wire                                 S_AXI_RREADY,
    
    // UART Half-Duplex Interface
    output wire                                 tx_out,         // TX output to motor mux
    input  wire                                 rx_in,          // RX input from motor mux
    output wire                                 tx_active,      // Direction control for half-duplex
    
    // Interrupts
    output wire                                 irq_tx,         // TX complete interrupt
    output wire                                 irq_rx          // RX ready interrupt
);

    // Clock and reset
    wire clk = S_AXI_ACLK;
    wire rst = !S_AXI_ARESETN;

    // Baud rate calculation (19200 baud for BLHeli)
    localparam integer BAUD_RATE    = 19200;
    localparam integer CLKS_PER_BIT = CLK_FREQ_HZ / BAUD_RATE;
    localparam integer GUARD_CLKS   = CLKS_PER_BIT;

    // =========================================================================
    // AXI4-Lite Logic
    // =========================================================================
    reg axi_awready;
    reg axi_wready;
    reg axi_bvalid;
    reg axi_arready;
    reg [C_S_AXI_DATA_WIDTH-1:0] axi_rdata;
    reg axi_rvalid;
    
    wire [C_S_AXI_ADDR_WIDTH-1:0] waddr = S_AXI_AWADDR;
    wire [C_S_AXI_ADDR_WIDTH-1:0] raddr = S_AXI_ARADDR;
    
    wire aw_valid = S_AXI_AWVALID && S_AXI_WVALID && !axi_bvalid;
    wire ar_valid = S_AXI_ARVALID && !axi_rvalid;
    
    // AXI handshaking
    always @(posedge clk) begin
        if (rst) begin
            axi_awready <= 1'b0;
            axi_wready  <= 1'b0;
            axi_bvalid  <= 1'b0;
            axi_arready <= 1'b0;
            axi_rvalid  <= 1'b0;
        end else begin
            // Write channels
            axi_awready <= aw_valid && !axi_awready;
            axi_wready  <= aw_valid && !axi_wready;
            if (axi_awready && axi_wready) begin
                axi_bvalid <= 1'b1;
            end else if (S_AXI_BREADY && axi_bvalid) begin
                axi_bvalid <= 1'b0;
            end
            
            // Read channels
            axi_arready <= ar_valid && !axi_arready;
            if (axi_arready) begin
                axi_rvalid <= 1'b1;
            end else if (S_AXI_RREADY && axi_rvalid) begin
                axi_rvalid <= 1'b0;
            end
        end
    end
    
    assign S_AXI_AWREADY = axi_awready;
    assign S_AXI_WREADY  = axi_wready;
    assign S_AXI_BVALID  = axi_bvalid;
    assign S_AXI_BRESP   = 2'b00;  // OKAY
    assign S_AXI_ARREADY = axi_arready;
    assign S_AXI_RDATA   = axi_rdata;
    assign S_AXI_RVALID  = axi_rvalid;
    assign S_AXI_RRESP   = 2'b00;  // OKAY

    // =========================================================================
    // Registers
    // =========================================================================
    reg [7:0]  tx_data_reg;
    reg        tx_data_valid;
    reg [7:0]  rx_data_reg;
    reg        rx_data_valid;
    reg        rx_done;         // Pulse when RX complete
    reg        tx_int_en;
    reg        rx_int_en;
    reg        tx_done;
    reg        tx_int_flag;
    reg        rx_int_flag;
    
    // UART status
    wire tx_ready;
    wire tx_active_internal;
    
    // =========================================================================
    // TX State Machine
    // =========================================================================
    localparam [2:0] TX_IDLE  = 3'd0,
                     TX_START = 3'd1,
                     TX_DATA  = 3'd2,
                     TX_STOP  = 3'd3,
                     TX_GUARD = 3'd4;
    
    reg [2:0]  tx_state;
    reg [7:0]  tx_shift;
    reg [2:0]  tx_bit_idx;
    reg [15:0] tx_counter;
    reg        tx_out_reg;
    reg        tx_ready_reg;
    reg        tx_active_reg;
    
    always @(posedge clk) begin
        if (rst) begin
            tx_state      <= TX_IDLE;
            tx_out_reg    <= 1'b1;  // UART idle = HIGH
            tx_shift      <= 8'h00;
            tx_bit_idx    <= 3'd0;
            tx_counter    <= 16'd0;
            tx_ready_reg  <= 1'b1;
            tx_active_reg <= 1'b0;
            tx_done       <= 1'b0;
        end else begin
            case (tx_state)
                TX_IDLE: begin
                    tx_out_reg    <= 1'b1;
                    tx_active_reg <= 1'b0;
                    tx_ready_reg  <= 1'b1;
                    if (tx_data_valid) begin
                        tx_shift      <= tx_data_reg;
                        tx_state      <= TX_START;
                        tx_counter    <= CLKS_PER_BIT - 1;
                        tx_out_reg    <= 1'b0;  // Start bit
                        tx_ready_reg  <= 1'b0;
                        tx_active_reg <= 1'b1;
                        tx_done       <= 1'b0;
                    end
                end
                
                TX_START: begin
                    if (tx_counter == 0) begin
                        tx_state   <= TX_DATA;
                        tx_counter <= CLKS_PER_BIT - 1;
                        tx_out_reg <= tx_shift[0];
                        tx_bit_idx <= 3'd0;
                    end else begin
                        tx_counter <= tx_counter - 1;
                    end
                end
                
                TX_DATA: begin
                    if (tx_counter == 0) begin
                        tx_shift <= {1'b0, tx_shift[7:1]};
                        if (tx_bit_idx == 3'd7) begin
                            tx_state   <= TX_STOP;
                            tx_counter <= CLKS_PER_BIT - 1;
                            tx_out_reg <= 1'b1;  // Stop bit
                        end else begin
                            tx_bit_idx <= tx_bit_idx + 1;
                            tx_counter <= CLKS_PER_BIT - 1;
                            tx_out_reg <= tx_shift[1];
                        end
                    end else begin
                        tx_counter <= tx_counter - 1;
                    end
                end
                
                TX_STOP: begin
                    if (tx_counter == 0) begin
                        tx_state  <= TX_GUARD;
                        tx_counter <= GUARD_CLKS - 1;
                        tx_done    <= 1'b1;  // Set TX done flag
                    end else begin
                        tx_counter <= tx_counter - 1;
                    end
                end
                
                TX_GUARD: begin
                    if (tx_counter == 0) begin
                        tx_state      <= TX_IDLE;
                        tx_active_reg <= 1'b0;
                    end else begin
                        tx_counter <= tx_counter - 1;
                    end
                end
                
                default: tx_state <= TX_IDLE;
            endcase
        end
    end
    
    assign tx_out = tx_out_reg;
    assign tx_ready = tx_ready_reg;
    assign tx_active = tx_active_reg;

    // =========================================================================
    // RX State Machine
    // =========================================================================
    localparam [2:0] RX_IDLE  = 3'd0,
                     RX_START = 3'd1,
                     RX_DATA  = 3'd2,
                     RX_STOP  = 3'd3;
    
    reg [2:0]  rx_state;
    reg [7:0]  rx_shift;
    reg [2:0]  rx_bit_idx;
    reg [15:0] rx_counter;
    reg        rx_in_sync1, rx_in_sync2;
    
    // Synchronize RX input
    always @(posedge clk) begin
        rx_in_sync1 <= rx_in;
        rx_in_sync2 <= rx_in_sync1;
    end
    
    always @(posedge clk) begin
        if (rst) begin
            rx_state      <= RX_IDLE;
            rx_shift      <= 8'h00;
            rx_bit_idx    <= 3'd0;
            rx_counter    <= 16'd0;
            rx_done       <= 1'b0;
        end else begin
            rx_done <= 1'b0;  // Default: single-cycle pulse
            // Don't receive while transmitting
            if (tx_active_reg) begin
                rx_state <= RX_IDLE;
                rx_counter <= 16'd0;
            end else begin
                case (rx_state)
                    RX_IDLE: begin
                        if (!rx_in_sync2) begin  // Start bit (falling edge)
                            rx_state   <= RX_START;
                            rx_counter <= (CLKS_PER_BIT / 2) - 1;  // Sample mid-bit
                        end
                    end
                    
                    RX_START: begin
                        if (rx_counter == 0) begin
                            rx_state   <= RX_DATA;
                            rx_counter <= CLKS_PER_BIT - 1;
                            rx_bit_idx <= 3'd0;
                        end else begin
                            rx_counter <= rx_counter - 1;
                        end
                    end
                    
                    RX_DATA: begin
                        if (rx_counter == 0) begin
                            rx_shift <= {rx_in_sync2, rx_shift[7:1]};
                            if (rx_bit_idx == 3'd7) begin
                                rx_state   <= RX_STOP;
                                rx_counter <= CLKS_PER_BIT - 1;
                            end else begin
                                rx_bit_idx <= rx_bit_idx + 1;
                                rx_counter <= CLKS_PER_BIT - 1;
                            end
                        end else begin
                            rx_counter <= rx_counter - 1;
                        end
                    end
                    
                    RX_STOP: begin
                        if (rx_counter == 0) begin
                            rx_state      <= RX_IDLE;
                            rx_data_reg   <= rx_shift;
                            rx_done       <= 1'b1;  // Pulse to indicate data ready
                        end else begin
                            rx_counter <= rx_counter - 1;
                        end
                    end
                    
                    default: rx_state <= RX_IDLE;
                endcase
            end
        end
    end

    // =========================================================================
    // Register Access
    // =========================================================================
    wire write_en = axi_awready && axi_wready;
    wire read_en  = ar_valid && !axi_rvalid;
    
    wire [2:0] write_addr = waddr[4:2];
    wire [2:0] read_addr  = raddr[4:2];
    
    // Write logic
    always @(posedge clk) begin
        if (rst) begin
            tx_data_reg   <= 8'h00;
            tx_data_valid <= 1'b0;
            rx_data_valid <= 1'b0;
            tx_int_en     <= 1'b0;
            rx_int_en     <= 1'b0;
            tx_int_flag   <= 1'b0;
            rx_int_flag   <= 1'b0;
        end else begin
            tx_data_valid <= 1'b0;  // Single cycle pulse
            
            if (write_en) begin
                case (write_addr)
                    3'd0: begin  // TX_DATA (0x00)
                        tx_data_reg   <= S_AXI_WDATA[7:0];
                        tx_data_valid <= 1'b1;
                    end
                    3'd3: begin  // CONTROL (0x0C)
                        tx_int_en <= S_AXI_WDATA[0];
                        rx_int_en <= S_AXI_WDATA[1];
                    end
                    3'd4: begin  // INT_STAT (0x10) - write 1 to clear
                        if (S_AXI_WDATA[0]) tx_int_flag <= 1'b0;
                        if (S_AXI_WDATA[1]) rx_int_flag <= 1'b0;
                    end
                endcase
            end
            
            // Auto-set interrupt flags
            if (tx_done && tx_int_en) tx_int_flag <= 1'b1;
            if (rx_done && rx_int_en) rx_int_flag <= 1'b1;
            
            // Set rx_data_valid when new data arrives
            if (rx_done) rx_data_valid <= 1'b1;
            
            // Reading RX_DATA clears RX valid and interrupt
            if (read_en && read_addr == 3'd2) begin
                rx_data_valid <= 1'b0;
                rx_int_flag   <= 1'b0;
            end
        end
    end
    
    // Read logic
    always @(posedge clk) begin
        if (read_en) begin
            case (read_addr)
                3'd0: axi_rdata <= {24'h0, tx_data_reg};  // TX_DATA (write-only, reads as last written)
                3'd1: axi_rdata <= {28'h0, tx_done, tx_active_reg, rx_data_valid, tx_ready};  // STATUS
                3'd2: axi_rdata <= {24'h0, rx_data_reg};  // RX_DATA
                3'd3: axi_rdata <= {30'h0, rx_int_en, tx_int_en};  // CONTROL
                3'd4: axi_rdata <= {30'h0, rx_int_flag, tx_int_flag};  // INT_STAT
                default: axi_rdata <= 32'h0;
            endcase
        end
    end
    
    // Interrupt outputs
    assign irq_tx = tx_int_flag;
    assign irq_rx = rx_int_flag;

endmodule

