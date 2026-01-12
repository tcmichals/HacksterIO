// =============================================================================
// serial_axis_bridge.sv
// UART/Serial to AXI Stream Master Bridge
// =============================================================================
// Description:
//   Converts serial UART interface (RX) to AXI Stream master interface.
//   - UART slave receives bytes from external UART transmitter
//   - Output is AXI Stream (AXIS) format compatible with wishbone_master_axis
//   - Frame terminator: 0xFF (Break Byte) indicates end of frame
//   - Single byte rate: typically 115200 baud (standard)
//   - No XON/XOFF flow control (assume host is synchronous)
//
// Protocol:
//   - Each UART byte becomes an AXIS transfer
//   - When 0xFF (break byte) is received, TLAST is asserted
//   - No parity/stop bit stripping (assumed by UART PHY)
//   - BAUD_RATE configurable for different clock speeds
//
// Example Frame:
//   0x01 0x00 0x00 0x20 0x00 0x00 0x01 0x00 0xAA 0xBB 0xCC 0xDD 0xFF
//   (command, address, length, dummy, data[3:0], break_byte/frame terminator)
// =============================================================================

module serial_axis_bridge #(
    parameter DATA_WIDTH = 8,
    parameter CLK_FREQ_MHZ = 100,  // System clock frequency
    parameter BAUD_RATE = 115200   // Serial baud rate
) (
    // Clock and Reset
    input  logic                    clk,
    input  logic                    rst_n,
    
    // Serial Input (UART RX)
    input  logic                    uart_rx,        // Serial input
    
    // AXI Stream Master (Output to Wishbone Bridge)
    output logic [DATA_WIDTH-1:0]   m_axis_tdata,
    output logic                    m_axis_tvalid,
    input  logic                    m_axis_tready,
    output logic                    m_axis_tlast
);

    localparam BAUD_COUNTER_MAX = CLK_FREQ_MHZ * 1_000_000 / BAUD_RATE;
    localparam BAUD_COUNTER_HALF = BAUD_COUNTER_MAX / 2;
    
    // =========================================================================
    // UART RX State Machine
    // =========================================================================
    
    typedef enum logic [2:0] {
        RX_IDLE,
        RX_START,
        RX_DATA,
        RX_STOP,
        RX_DONE
    } rx_state_t;
    
    rx_state_t rx_state, rx_state_next;
    
    // =========================================================================
    // Input Synchronization (Metastability Protection)
    // =========================================================================
    
    logic uart_rx_sync1, uart_rx_sync2;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            uart_rx_sync1 <= 1'b1;
            uart_rx_sync2 <= 1'b1;
        end else begin
            uart_rx_sync1 <= uart_rx;
            uart_rx_sync2 <= uart_rx_sync1;
        end
    end
    
    // =========================================================================
    // Baud Rate Counter
    // =========================================================================
    
    logic [31:0] baud_counter;
    logic baud_tick, baud_tick_half;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            baud_counter <= 32'h0;
        end else begin
            if (baud_counter == 0) begin
                baud_counter <= BAUD_COUNTER_MAX - 1;
            end else begin
                baud_counter <= baud_counter - 1;
            end
        end
    end
    
    assign baud_tick = (baud_counter == 0);
    assign baud_tick_half = (baud_counter == BAUD_COUNTER_HALF);
    
    // =========================================================================
    // RX Shift Register and Bit Counter
    // =========================================================================
    
    logic [7:0] rx_shift_reg;
    logic [2:0] rx_bit_count;
    
    // =========================================================================
    // RX State Machine
    // =========================================================================
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_state <= RX_IDLE;
            rx_shift_reg <= 8'h0;
            rx_bit_count <= 3'h0;
            baud_counter <= 32'h0;
        end else begin
            rx_state <= rx_state_next;
            
            case (rx_state)
                RX_IDLE: begin
                    rx_bit_count <= 3'h0;
                    baud_counter <= 32'h0;
                    // Transition handled in combinational logic
                end
                
                RX_START: begin
                    // Wait for half bit time to sample start bit in middle
                    if (baud_tick_half) begin
                        baud_counter <= 32'h0;
                        if (uart_rx_sync2 == 1'b0) begin
                            // Valid start bit detected
                            rx_bit_count <= 3'h0;
                            // Transition to RX_DATA handled in combinational
                        end
                    end
                end
                
                RX_DATA: begin
                    if (baud_tick) begin
                        // Sample bit at tick
                        rx_shift_reg <= {uart_rx_sync2, rx_shift_reg[7:1]};  // LSB first
                        rx_bit_count <= rx_bit_count + 1'b1;
                        baud_counter <= 32'h0;
                    end
                end
                
                RX_STOP: begin
                    if (baud_tick) begin
                        // Sample stop bit
                        baud_counter <= 32'h0;
                        // Transition to RX_DONE handled in combinational
                    end
                end
                
                RX_DONE: begin
                    // Data ready, transition handled externally
                    baud_counter <= 32'h0;
                end
            endcase
        end
    end
    
    // Combinational next state logic
    always_comb begin
        rx_state_next = rx_state;
        
        case (rx_state)
            RX_IDLE: begin
                if (uart_rx_sync2 == 1'b0) begin
                    rx_state_next = RX_START;
                end
            end
            
            RX_START: begin
                if (baud_tick_half && uart_rx_sync2 == 1'b0) begin
                    rx_state_next = RX_DATA;
                end else if (uart_rx_sync2 == 1'b1) begin
                    // False start, go back to idle
                    rx_state_next = RX_IDLE;
                end
            end
            
            RX_DATA: begin
                if (baud_tick && rx_bit_count == 3'h7) begin
                    rx_state_next = RX_STOP;
                end
            end
            
            RX_STOP: begin
                if (baud_tick) begin
                    rx_state_next = RX_DONE;
                end
            end
            
            RX_DONE: begin
                // Stay until data is consumed
                if (m_axis_tready && m_axis_tvalid) begin
                    rx_state_next = RX_IDLE;
                end
            end
        endcase
    end
    
    // =========================================================================
    // AXI Stream Output
    // =========================================================================
    
    assign m_axis_tdata  = rx_shift_reg;
    assign m_axis_tvalid = (rx_state == RX_DONE);
    assign m_axis_tlast  = (rx_shift_reg == 8'hFF) && m_axis_tvalid;  // Break byte triggers TLAST
    
endmodule
