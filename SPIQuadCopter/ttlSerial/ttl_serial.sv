/**
 * TTL Serial UART Module
 * 
 * Supports configurable baud rates and half-duplex operation.
 * Default: 115200 baud, 8-N-1 (8 data bits, no parity, 1 stop bit)
 * 
 * Parameters:
 *   - CLK_FREQ_HZ: System clock frequency in Hz (default: 27MHz)
 *   - BAUD_RATE: Serial baud rate in bps (default: 115200)
 *   - HALF_DUPLEX: Enable half-duplex mode (default: 1)
 * 
 * Signals:
 *   - clk: System clock
 *   - rst_n: Active low synchronous reset
 *   - tx_data: Data to transmit (8 bits)
 *   - tx_valid: Transmit data valid strobe
 *   - tx_ready: Transmitter ready for new data
 *   - rx_data: Received data (8 bits)
 *   - rx_valid: Received data valid strobe
 *   - serial: TTL serial line (open-drain output when driving)
 *   - half_duplex_en: Enable half-duplex mode (when HALF_DUPLEX=1)
 */

module ttl_serial #(
    parameter CLK_FREQ_HZ = 27_000_000,
    parameter BAUD_RATE   = 115_200,
    parameter HALF_DUPLEX = 1
) (
    input  logic        clk,
    input  logic        rst_n,
    
    // Transmit interface
    input  logic [7:0]  tx_data,
    input  logic        tx_valid,
    output logic        tx_ready,
    
    // Receive interface
    output logic [7:0]  rx_data,
    output logic        rx_valid,
    
    // Serial line (bidirectional for half-duplex)
    inout  wire         serial,
    
    // Half-duplex control (if HALF_DUPLEX=1)
    input  logic        half_duplex_en  // When high, TX drives the line; when low, RX listens
);

    // Calculated baud rate divisor
    localparam BAUD_DIV = CLK_FREQ_HZ / BAUD_RATE;
    
    // Transmitter and receiver instances
    logic tx_out;
    logic rx_in;
    
    // For half-duplex: control the serial line
    logic serial_tx_en;  // TX enable - when high, TX controls the line
    
    generate
        if (HALF_DUPLEX) begin : half_duplex_mode
            // Tri-state buffer: when transmitting, drive the line; otherwise high-Z for receiving
            // TX is active (driving) when we're sending data
            // Note: UART idle state is HIGH (mark state)
            assign serial = serial_tx_en ? tx_out : 1'bz;
            assign rx_in = serial;
        end else begin : full_duplex_mode
            // Full duplex: TX always drives out, RX always reads in
            // In real full-duplex, these would be separate pins
            assign serial = tx_out;
            assign rx_in = serial;
        end
    endgenerate
    
    // TX busy signal for half-duplex control
    logic tx_busy;
    
    // Instantiate transmitter
    ttl_serial_tx #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .BAUD_RATE(BAUD_RATE),
        .HALF_DUPLEX(HALF_DUPLEX)
    ) u_tx (
        .clk(clk),
        .rst_n(rst_n),
        .tx_data(tx_data),
        .tx_valid(tx_valid),
        .tx_ready(tx_ready),
        .tx_out(tx_out),
        .tx_busy(tx_busy),
        .half_duplex_en(half_duplex_en)
    );
    
    // TX enable: drive the line when transmitting in half-duplex mode
    assign serial_tx_en = half_duplex_en && (tx_busy || tx_valid);
    
    // Instantiate receiver
    ttl_serial_rx #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .BAUD_RATE(BAUD_RATE)
    ) u_rx (
        .clk(clk),
        .rst_n(rst_n),
        .rx_in(rx_in),
        .rx_data(rx_data),
        .rx_valid(rx_valid)
    );

endmodule


/**
 * TTL Serial Transmitter
 */
module ttl_serial_tx #(
    parameter CLK_FREQ_HZ = 27_000_000,
    parameter BAUD_RATE   = 115_200,
    parameter HALF_DUPLEX = 1
) (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [7:0]  tx_data,
    input  logic        tx_valid,
    output logic        tx_ready,
    output logic        tx_out,
    output logic        tx_busy,          // High when transmitting
    input  logic        half_duplex_en
);

    localparam BAUD_DIV = CLK_FREQ_HZ / BAUD_RATE;
    
    enum logic [2:0] {
        IDLE,
        START_BIT,
        DATA_BITS,
        STOP_BIT,
        STOP_BIT2
    } state, next_state;
    
    logic [3:0]  bit_count;
    logic [15:0] baud_counter;
    logic [7:0]  tx_shift_reg;
    logic        bit_done;
    
    // Baud rate counter
    always_comb begin
        bit_done = (baud_counter == BAUD_DIV - 1);
    end
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            baud_counter <= 0;
        end else if (!tx_busy) begin
            baud_counter <= 0;
        end else if (bit_done) begin
            baud_counter <= 0;
        end else begin
            baud_counter <= baud_counter + 1;
        end
    end
    
    // State machine for transmission
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            bit_count <= 0;
            tx_shift_reg <= 8'hFF;
            tx_out <= 1'b1;
            tx_busy <= 1'b0;
        end else begin
            state <= next_state;
            
            if (next_state != IDLE) begin
                tx_busy <= 1'b1;
            end else begin
                tx_busy <= 1'b0;
            end
            
            case (next_state)
                IDLE: begin
                    tx_out <= 1'b1;
                    bit_count <= 0;
                end
                
                START_BIT: begin
                    tx_out <= 1'b0;
                    if (bit_done) begin
                        tx_shift_reg <= tx_data;
                    end
                end
                
                DATA_BITS: begin
                    if (bit_done) begin
                        tx_out <= tx_shift_reg[0];
                        tx_shift_reg <= {1'b1, tx_shift_reg[7:1]};
                        bit_count <= bit_count + 1;
                    end else begin
                        tx_out <= tx_shift_reg[0];
                    end
                end
                
                STOP_BIT: begin
                    tx_out <= 1'b1;
                end
                
                STOP_BIT2: begin
                    tx_out <= 1'b1;
                end
            endcase
        end
    end
    
    // Next state logic
    always_comb begin
        next_state = state;
        
        case (state)
            IDLE: begin
                if (tx_valid) begin
                    next_state = START_BIT;
                end
            end
            
            START_BIT: begin
                if (bit_done) begin
                    next_state = DATA_BITS;
                end
            end
            
            DATA_BITS: begin
                if (bit_done && bit_count == 7) begin
                    next_state = STOP_BIT;
                end
            end
            
            STOP_BIT: begin
                if (bit_done) begin
                    next_state = STOP_BIT2;
                end
            end
            
            STOP_BIT2: begin
                if (bit_done) begin
                    next_state = IDLE;
                end
            end
        endcase
    end
    
    // TX ready when idle and not in half-duplex or when half-duplex is enabled
    assign tx_ready = (state == IDLE) && (!HALF_DUPLEX || half_duplex_en);

endmodule


/**
 * TTL Serial Receiver
 */
module ttl_serial_rx #(
    parameter CLK_FREQ_HZ = 27_000_000,
    parameter BAUD_RATE   = 115_200
) (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        rx_in,
    output logic [7:0]  rx_data,
    output logic        rx_valid
);

    localparam BAUD_DIV = CLK_FREQ_HZ / BAUD_RATE;
    localparam HALF_BAUD_DIV = BAUD_DIV / 2;
    
    enum logic [2:0] {
        IDLE,
        START_BIT,
        DATA_BITS,
        STOP_BIT,
        DATA_READY
    } state, next_state;
    
    logic [3:0]  bit_count;
    logic [15:0] baud_counter;
    logic [7:0]  rx_shift_reg;
    logic        bit_done;
    logic        rx_in_sync;
    logic        rx_in_prev;
    
    // Synchronize rx input
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_in_sync <= 1'b1;
            rx_in_prev <= 1'b1;
        end else begin
            rx_in_sync <= rx_in;
            rx_in_prev <= rx_in_sync;
        end
    end
    
    // Baud rate counter
    always_comb begin
        bit_done = (baud_counter == BAUD_DIV - 1);
    end
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            baud_counter <= 0;
        end else if (state == IDLE) begin
            if (baud_counter == HALF_BAUD_DIV - 1) begin
                baud_counter <= 0;
            end else begin
                baud_counter <= baud_counter + 1;
            end
        end else if (bit_done) begin
            baud_counter <= 0;
        end else begin
            baud_counter <= baud_counter + 1;
        end
    end
    
    // State machine for reception
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            bit_count <= 0;
            rx_shift_reg <= 8'h00;
            rx_data <= 8'h00;
            rx_valid <= 1'b0;
        end else begin
            state <= next_state;
            
            rx_valid <= 1'b0;  // Default: no valid data
            
            case (next_state)
                IDLE: begin
                    bit_count <= 0;
                    rx_shift_reg <= 8'h00;
                end
                
                START_BIT: begin
                    // Already transitioning from IDLE
                end
                
                DATA_BITS: begin
                    if (bit_done) begin
                        rx_shift_reg <= {rx_in_sync, rx_shift_reg[7:1]};
                        bit_count <= bit_count + 1;
                    end
                end
                
                STOP_BIT: begin
                    // Waiting for stop bit
                end
                
                DATA_READY: begin
                    rx_data <= rx_shift_reg;
                    rx_valid <= 1'b1;
                end
            endcase
        end
    end
    
    // Next state logic
    always_comb begin
        next_state = state;
        
        case (state)
            IDLE: begin
                // Detect start bit (falling edge)
                if (!rx_in_sync && rx_in_prev) begin
                    next_state = START_BIT;
                end
            end
            
            START_BIT: begin
                if (bit_done) begin
                    next_state = DATA_BITS;
                end
            end
            
            DATA_BITS: begin
                if (bit_done && bit_count == 7) begin
                    next_state = STOP_BIT;
                end
            end
            
            STOP_BIT: begin
                if (bit_done) begin
                    next_state = DATA_READY;
                end
            end
            
            DATA_READY: begin
                next_state = IDLE;
            end
        endcase
    end

endmodule
