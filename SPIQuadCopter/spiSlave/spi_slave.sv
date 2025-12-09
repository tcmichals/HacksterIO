/**
 * SPI Slave Module (Mode 0)
 * 
 * Mode 0: CPOL=0, CPHA=0
 * - Clock idle state: LOW
 * - Data sampled on leading (rising) edge
 * - Data changed on trailing (falling) edge
 * 
 * Features:
 * - 8-bit data width
 * - 2-FF synchronizer for clock domain crossing
 * - Configurable clock polarity and phase (currently hardcoded to Mode 0)
 */

module spi_slave #(
    parameter DATA_WIDTH = 8
) (
    // Clock and Reset
    input  logic                    i_clk,
    input  logic                    i_rst_n,
    
    // SPI Interface
    input  logic                    i_sclk,       // SPI Clock
    input  logic                    i_cs_n,       // Chip Select (active low)
    input  logic                    i_mosi,       // Master Out Slave In
    output logic                    o_miso,       // Master In Slave Out
    
    // Slave Interface (to internal module)
    output logic [DATA_WIDTH-1:0]   o_rx_data,    // Received data
    output logic                    o_rx_valid,   // Received data valid pulse
    input  logic [DATA_WIDTH-1:0]   i_tx_data,    // Data to transmit
    input  logic                    i_tx_valid,   // Load new transmit data
    output logic                    o_busy        // SPI transaction in progress
);

    // =============================
    // 2-FF Synchronizer for SCLK
    // =============================
    logic sclk_sync1, sclk_sync2;
    logic sclk_r1, sclk_r2;
    
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            sclk_sync1 <= 1'b0;
            sclk_sync2 <= 1'b0;
        end else begin
            sclk_sync1 <= i_sclk;
            sclk_sync2 <= sclk_sync1;
        end
    end
    
    // =============================
    // 2-FF Synchronizer for CS_N
    // =============================
    logic cs_n_sync1, cs_n_sync2;
    
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            cs_n_sync1 <= 1'b1;
            cs_n_sync2 <= 1'b1;
        end else begin
            cs_n_sync1 <= i_cs_n;
            cs_n_sync2 <= cs_n_sync1;
        end
    end
    
    // =============================
    // 2-FF Synchronizer for MOSI
    // =============================
    logic mosi_sync1, mosi_sync2;
    
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            mosi_sync1 <= 1'b0;
            mosi_sync2 <= 1'b0;
        end else begin
            mosi_sync1 <= i_mosi;
            mosi_sync2 <= mosi_sync1;
        end
    end
    
    // Edge Detection for SCLK (detect rising edge for Mode 0)
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            sclk_r1 <= 1'b0;
            sclk_r2 <= 1'b0;
        end else begin
            sclk_r1 <= sclk_sync2;
            sclk_r2 <= sclk_r1;
        end
    end
    
    logic sclk_rising_edge;
    assign sclk_rising_edge = sclk_r1 && !sclk_r2;
    
    logic sclk_falling_edge;
    assign sclk_falling_edge = !sclk_r1 && sclk_r2;
    
    // =============================
    // Shift Register and Control Logic
    // =============================
    logic [DATA_WIDTH-1:0] shift_reg;
    logic [2:0]            bit_count;
    logic [DATA_WIDTH-1:0] tx_shift_reg;
    
    // Track previous CS state
    logic cs_n_r;
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n)
            cs_n_r <= 1'b1;
        else
            cs_n_r <= cs_n_sync2;
    end
    
    logic cs_falling_edge;
    assign cs_falling_edge = cs_n_r && !cs_n_sync2;
    
    // Main SPI Slave Logic
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            shift_reg     <= '0;
            bit_count     <= '0;
            o_rx_valid    <= 1'b0;
            tx_shift_reg  <= '0;
            o_miso        <= 1'b0;
            o_busy        <= 1'b0;
        end else begin
            o_rx_valid <= 1'b0;  // Default: pulse valid for one clock
            
            // CS goes low - start transaction
            if (cs_falling_edge) begin
                bit_count <= '0;
                o_busy    <= 1'b1;
                // Load transmit data if available
                if (i_tx_valid)
                    tx_shift_reg <= i_tx_data;
                else
                    tx_shift_reg <= '0;
                // Set MISO to MSB of tx data
                o_miso <= i_tx_valid ? i_tx_data[DATA_WIDTH-1] : 1'b0;
            end
            // CS is high - transaction ended
            else if (cs_n_sync2) begin
                o_busy <= 1'b0;
                o_miso <= 1'b0;
            end
            // CS is low and we see SCLK rising edge - sample MOSI
            else if (sclk_rising_edge && !cs_n_sync2) begin
                shift_reg <= {shift_reg[DATA_WIDTH-2:0], mosi_sync2};
                bit_count <= bit_count + 1'b1;
                
                // After 8 bits received
                if (bit_count == (DATA_WIDTH - 1)) begin
                    o_rx_data <= {shift_reg[DATA_WIDTH-2:0], mosi_sync2};
                    o_rx_valid <= 1'b1;
                    bit_count <= '0;
                end
            end
            // SCLK falling edge - shift out next MISO bit
            else if (sclk_falling_edge && !cs_n_sync2) begin
                if (bit_count < DATA_WIDTH) begin
                    tx_shift_reg <= {tx_shift_reg[DATA_WIDTH-2:0], 1'b0};
                    o_miso <= tx_shift_reg[DATA_WIDTH-1];
                end
            end
            
            // Load new transmit data when requested
            if (i_tx_valid) begin
                tx_shift_reg <= i_tx_data;
            end
        end
    end

endmodule
