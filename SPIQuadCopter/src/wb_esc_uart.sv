/**
 * Wishbone ESC UART Controller
 * 
 * Half-duplex UART for BLHeli ESC configuration at 19200 baud.
 * Connected to motor pins via external mux (controlled by mux register).
 * 
 * Features:
 *   - 19200 baud, 8-N-1 format
 *   - Half-duplex: TX drives line, RX listens when idle
 *   - Simple TX/RX FIFOs (1 byte each)
 *   - Direction automatically switches based on TX activity
 * 
 * Register Map (offset from base):
 *   0x00: TX_DATA  [W]  - Write byte to transmit
 *   0x04: STATUS   [R]  - bit0=TX ready, bit1=RX valid, bit2=TX active
 *   0x08: RX_DATA  [R]  - Read received byte (clears RX valid)
 * 
 * Half-Duplex Behavior:
 *   - When TX idle, RX enabled (listening)
 *   - When TX starts, RX disabled until TX complete + guard time
 *   - Guard time: ~1 bit period after stop bit
 */

module wb_esc_uart #(
    parameter CLK_FREQ_HZ = 72_000_000
) (
    input  logic        clk,
    input  logic        rst,
    
    // Wishbone slave interface
    input  logic [3:0]  wb_adr_i,       // Address (register select)
    input  logic [31:0] wb_dat_i,       // Write data
    output logic [31:0] wb_dat_o,       // Read data
    input  logic        wb_we_i,        // Write enable
    input  logic        wb_stb_i,       // Strobe
    input  logic        wb_cyc_i,       // Cycle
    output logic        wb_ack_o,       // Acknowledge
    
    // Half-duplex serial interface
    output logic        tx_out,         // TX output (directly to external mux/pin)
    input  logic        rx_in,          // RX input (directly from external mux/pin)
    output logic        tx_active       // High when transmitting (for external direction control)
);

    // =========================================================================
    // Baud rate calculation (FIXED at 19200 for BLHeli ESC protocol)
    // =========================================================================
    localparam integer BAUD_RATE    = 19_200;
    localparam integer CLKS_PER_BIT = CLK_FREQ_HZ / BAUD_RATE;  // 3750 @ 72MHz/19200
    localparam integer HALF_BIT     = CLKS_PER_BIT / 2;
    localparam integer GUARD_CLKS   = CLKS_PER_BIT;             // Guard time after TX
    
    // =========================================================================
    // TX State Machine
    // =========================================================================
    typedef enum logic [2:0] {
        TX_IDLE,
        TX_START,
        TX_DATA,
        TX_STOP,
        TX_GUARD
    } tx_state_t;
    
    tx_state_t          tx_state;
    logic [7:0]         tx_shift;
    logic [2:0]         tx_bit_idx;
    logic [12:0]        tx_counter;     // Enough for 3750 clocks
    logic               tx_ready;
    logic [7:0]         tx_data_reg;
    logic               tx_data_valid;
    
    // TX state machine
    always_ff @(posedge clk) begin
        if (rst) begin
            tx_state      <= TX_IDLE;
            tx_out        <= 1'b1;      // UART idle = HIGH
            tx_shift      <= 8'h00;
            tx_bit_idx    <= 3'd0;
            tx_counter    <= 13'd0;
            tx_ready      <= 1'b1;
            tx_data_valid <= 1'b0;
            tx_active     <= 1'b0;
        end else begin
            // Clear data valid after loading
            if (tx_state == TX_START && tx_counter == 0)
                tx_data_valid <= 1'b0;
            
            case (tx_state)
                TX_IDLE: begin
                    tx_out     <= 1'b1;
                    tx_active  <= 1'b0;
                    tx_ready   <= 1'b1;
                    if (tx_data_valid) begin
                        tx_shift   <= tx_data_reg;
                        tx_state   <= TX_START;
                        tx_counter <= CLKS_PER_BIT - 1;
                        tx_out     <= 1'b0;     // Start bit
                        tx_ready   <= 1'b0;
                        tx_active  <= 1'b1;
                    end
                end
                
                TX_START: begin
                    if (tx_counter == 0) begin
                        tx_state   <= TX_DATA;
                        tx_counter <= CLKS_PER_BIT - 1;
                        tx_out     <= tx_shift[0];
                        tx_bit_idx <= 3'd0;
                    end else begin
                        tx_counter <= tx_counter - 1;
                    end
                end
                
                TX_DATA: begin
                    if (tx_counter == 0) begin
                        tx_shift <= {1'b0, tx_shift[7:1]};  // Shift right
                        if (tx_bit_idx == 3'd7) begin
                            tx_state   <= TX_STOP;
                            tx_counter <= CLKS_PER_BIT - 1;
                            tx_out     <= 1'b1;  // Stop bit
                        end else begin
                            tx_bit_idx <= tx_bit_idx + 1;
                            tx_counter <= CLKS_PER_BIT - 1;
                            tx_out     <= tx_shift[1];  // Next bit (after shift)
                        end
                    end else begin
                        tx_counter <= tx_counter - 1;
                    end
                end
                
                TX_STOP: begin
                    if (tx_counter == 0) begin
                        tx_state   <= TX_GUARD;
                        tx_counter <= GUARD_CLKS - 1;
                    end else begin
                        tx_counter <= tx_counter - 1;
                    end
                end
                
                TX_GUARD: begin
                    // Guard time before re-enabling RX
                    if (tx_counter == 0) begin
                        tx_state  <= TX_IDLE;
                        tx_active <= 1'b0;
                    end else begin
                        tx_counter <= tx_counter - 1;
                    end
                end
                
                default: tx_state <= TX_IDLE;
            endcase
        end
    end
    
    // =========================================================================
    // RX State Machine
    // =========================================================================
    typedef enum logic [2:0] {
        RX_IDLE,
        RX_START,
        RX_DATA,
        RX_STOP
    } rx_state_t;
    
    rx_state_t          rx_state;
    logic [7:0]         rx_shift;
    logic [2:0]         rx_bit_idx;
    logic [12:0]        rx_counter;
    logic [7:0]         rx_data_reg;
    logic               rx_valid;
    
    // 2-stage synchronizer for RX input
    logic rx_meta, rx_sync;
    always_ff @(posedge clk) begin
        if (rst) begin
            rx_meta <= 1'b1;
            rx_sync <= 1'b1;
        end else begin
            rx_meta <= rx_in;
            rx_sync <= rx_meta;
        end
    end
    
    // RX state machine (disabled during TX)
    always_ff @(posedge clk) begin
        if (rst) begin
            rx_state   <= RX_IDLE;
            rx_shift   <= 8'h00;
            rx_bit_idx <= 3'd0;
            rx_counter <= 13'd0;
            rx_data_reg <= 8'h00;
            rx_valid   <= 1'b0;
        end else begin
            // Clear valid on read (handled in Wishbone section)
            
            // RX disabled during TX active
            if (tx_active) begin
                rx_state <= RX_IDLE;
            end else begin
                case (rx_state)
                    RX_IDLE: begin
                        if (rx_sync == 1'b0) begin  // Start bit detected
                            rx_state   <= RX_START;
                            rx_counter <= HALF_BIT - 1;  // Sample mid-bit
                        end
                    end
                    
                    RX_START: begin
                        if (rx_counter == 0) begin
                            if (rx_sync == 1'b0) begin  // Valid start bit
                                rx_state   <= RX_DATA;
                                rx_counter <= CLKS_PER_BIT - 1;
                                rx_bit_idx <= 3'd0;
                            end else begin
                                rx_state <= RX_IDLE;  // False start
                            end
                        end else begin
                            rx_counter <= rx_counter - 1;
                        end
                    end
                    
                    RX_DATA: begin
                        if (rx_counter == 0) begin
                            rx_shift <= {rx_sync, rx_shift[7:1]};  // Shift in from MSB
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
                            if (rx_sync == 1'b1) begin  // Valid stop bit
                                rx_data_reg <= rx_shift;
                                rx_valid    <= 1'b1;
                            end
                            // else: framing error, discard byte
                            rx_state <= RX_IDLE;
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
    // Wishbone Interface
    // =========================================================================
    logic wb_access;
    assign wb_access = wb_stb_i && wb_cyc_i;
    
    // Single-cycle acknowledge
    always_ff @(posedge clk) begin
        if (rst)
            wb_ack_o <= 1'b0;
        else
            wb_ack_o <= wb_access && !wb_ack_o;
    end
    
    // Write handling
    always_ff @(posedge clk) begin
        if (rst) begin
            tx_data_reg   <= 8'h00;
            // tx_data_valid cleared in TX FSM
        end else if (wb_access && wb_we_i && !wb_ack_o) begin
            case (wb_adr_i[3:2])
                2'b00: begin  // TX_DATA (0x00)
                    if (tx_ready) begin
                        tx_data_reg   <= wb_dat_i[7:0];
                        tx_data_valid <= 1'b1;
                    end
                end
                // Other registers are read-only
                default: ;
            endcase
        end
    end
    
    // Read handling
    always_comb begin
        wb_dat_o = 32'h0;
        case (wb_adr_i[3:2])
            2'b00: wb_dat_o = {24'h0, tx_data_reg};                   // TX_DATA echo
            2'b01: wb_dat_o = {29'h0, tx_active, rx_valid, tx_ready}; // STATUS
            2'b10: wb_dat_o = {24'h0, rx_data_reg};                   // RX_DATA
            default: wb_dat_o = 32'h0;
        endcase
    end
    
    // Clear RX valid on read
    always_ff @(posedge clk) begin
        if (rst) begin
            // rx_valid handled in RX FSM
        end else if (wb_access && !wb_we_i && wb_ack_o && wb_adr_i[3:2] == 2'b10) begin
            rx_valid <= 1'b0;  // Clear on RX_DATA read
        end
    end

endmodule
