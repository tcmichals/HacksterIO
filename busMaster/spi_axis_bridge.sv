// =============================================================================
// spi_axis_bridge.sv
// SPI Slave to AXI Stream Master Bridge
// =============================================================================
// Description:
//   Converts SPI slave interface (MOSI/MISO) to AXI Stream master interface.
//   - SPI operates as slave, receiving commands from SPI master
//   - Output is AXI Stream (AXIS) format compatible with wishbone_master_axis
//   - CS (Chip Select) is used as frame terminator (TLAST when CS deasserts)
//   - Supports simultaneous full-duplex operation
//   - No clock stretching support (must have fast response)
//
// Protocol:
//   - MOSI bytes are captured into S_AXIS output stream
//   - MISO bytes come from M_AXIS input stream
//   - CS falling edge triggers TLAST assertion
//   - Supports standard SPI modes (CPOL=0, CPHA=0)
// =============================================================================

module spi_axis_bridge #(
    parameter DATA_WIDTH = 8    // SPI operates on bytes
) (
    // Clock and Reset
    input  logic                    clk,
    input  logic                    rst_n,
    
    // SPI Slave Interface (Input)
    input  logic                    spi_clk,        // SPI clock
    input  logic                    spi_mosi,       // Master Out Slave In
    input  logic                    spi_cs_n,       // Chip Select (active low)
    output logic                    spi_miso,       // Master In Slave Out
    
    // AXI Stream Slave (Input from Host Response)
    // This receives status/data bytes to send back on MISO
    input  logic [DATA_WIDTH-1:0]   s_axis_tdata,
    input  logic                    s_axis_tvalid,
    output logic                    s_axis_tready,
    input  logic                    s_axis_tlast,
    
    // AXI Stream Master (Output to Wishbone Bridge)
    // This sends command/address/data bytes received from MOSI
    output logic [DATA_WIDTH-1:0]   m_axis_tdata,
    output logic                    m_axis_tvalid,
    input  logic                    m_axis_tready,
    output logic                    m_axis_tlast
);

    // =========================================================================
    // SPI Clock Domain Synchronization
    // =========================================================================
    
    // Synchronize SPI clock to system clock for edge detection
    logic spi_clk_sync1, spi_clk_sync2, spi_clk_r;
    logic spi_clk_edge;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            spi_clk_sync1 <= 1'b0;
            spi_clk_sync2 <= 1'b0;
            spi_clk_r     <= 1'b0;
        end else begin
            spi_clk_sync1 <= spi_clk;
            spi_clk_sync2 <= spi_clk_sync1;
            spi_clk_r     <= spi_clk_sync2;
        end
    end
    
    assign spi_clk_edge = spi_clk_sync2 & ~spi_clk_r;  // Rising edge detector
    
    // =========================================================================
    // CS Synchronization and Edge Detection
    // =========================================================================
    
    logic cs_sync1, cs_sync2, cs_r;
    logic cs_falling_edge;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cs_sync1 <= 1'b1;
            cs_sync2 <= 1'b1;
            cs_r     <= 1'b1;
        end else begin
            cs_sync1 <= spi_cs_n;
            cs_sync2 <= cs_sync1;
            cs_r     <= cs_sync2;
        end
    end
    
    assign cs_falling_edge = cs_r & ~cs_sync2;  // Falling edge (active)
    
    // =========================================================================
    // MOSI Shift Register (RX - Master Out Slave In)
    // Collects bits from SPI master and forms bytes
    // =========================================================================
    
    logic [7:0] mosi_shift_reg;
    logic [2:0] mosi_bit_count;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mosi_shift_reg <= 8'h00;
            mosi_bit_count <= 3'h0;
        end else if (~cs_sync2) begin  // CS active (low)
            if (spi_clk_edge) begin
                // Shift in MOSI bit (MSB first)
                mosi_shift_reg <= {mosi_shift_reg[6:0], spi_mosi};
                mosi_bit_count <= mosi_bit_count + 1'b1;
            end
        end else begin
            // CS inactive - reset
            mosi_bit_count <= 3'h0;
        end
    end
    
    // MOSI byte ready when 8 bits collected
    logic mosi_byte_ready;
    assign mosi_byte_ready = (mosi_bit_count == 3'h7) & spi_clk_edge & (~cs_sync2);
    
    // =========================================================================
    // MISO Shift Register (TX - Master In Slave Out)
    // Delivers bits to SPI master from shift register
    // =========================================================================
    
    logic [7:0] miso_shift_reg;
    logic [2:0] miso_bit_count;
    logic miso_last_byte;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            miso_shift_reg <= 8'h00;
            miso_bit_count <= 3'h0;
            miso_last_byte <= 1'b0;
        end else if (~cs_sync2) begin  // CS active
            // Load new byte when ready and available
            if ((miso_bit_count == 3'h0) && spi_clk_edge && s_axis_tvalid) begin
                miso_shift_reg <= s_axis_tdata;
                miso_last_byte <= s_axis_tlast;
            end else if (spi_clk_edge) begin
                // Shift out MISO bit (MSB first)
                miso_shift_reg <= {miso_shift_reg[6:0], 1'b0};
                miso_bit_count <= miso_bit_count + 1'b1;
            end
        end else begin
            // CS inactive
            miso_bit_count <= 3'h0;
        end
    end
    
    // MISO output (direct from MSB of shift register)
    assign spi_miso = miso_shift_reg[7];
    
    // Signal when MISO byte transmission complete
    logic miso_byte_done;
    assign miso_byte_done = (miso_bit_count == 3'h7) & spi_clk_edge & (~cs_sync2);
    
    // =========================================================================
    // AXI Stream Output (MOSI -> M_AXIS)
    // ==========================================================================
    
    logic mosi_fifo_wr, mosi_fifo_full;
    logic [7:0] mosi_fifo_out;
    logic mosi_fifo_empty, mosi_fifo_rd;
    
    // Simple async FIFO (8 entries) for MOSI bytes
    spi_async_fifo #(.WIDTH(8), .DEPTH(8)) mosi_fifo (
        .wr_clk     (clk),
        .wr_rst_n   (rst_n),
        .wr_en      (mosi_fifo_wr),
        .wr_data    ({mosi_shift_reg}),
        .wr_full    (mosi_fifo_full),
        
        .rd_clk     (clk),
        .rd_rst_n   (rst_n),
        .rd_en      (mosi_fifo_rd),
        .rd_data    (mosi_fifo_out),
        .rd_empty   (mosi_fifo_empty)
    );
    
    assign mosi_fifo_wr = mosi_byte_ready & ~mosi_fifo_full;
    
    // M_AXIS master (MOSI data going to Wishbone bridge)
    assign m_axis_tdata  = mosi_fifo_out;
    assign m_axis_tvalid = ~mosi_fifo_empty;
    assign m_axis_tlast  = cs_falling_edge;  // CS falling triggers TLAST
    assign mosi_fifo_rd  = m_axis_tready & m_axis_tvalid;
    
    // =========================================================================
    // AXI Stream Input (MISO <- S_AXIS)
    // =========================================================================
    
    // S_AXIS ready depends on MISO FIFO availability
    // MISO shift register pulls from this stream
    
    // Accept response data when we have room and MISO is ready for new byte
    assign s_axis_tready = (miso_bit_count == 3'h0) & (~cs_sync2);
    
    // =========================================================================
    // Synchronization: Mark end of frame on MISO when CS falls
    // =========================================================================
    
    // When CS falls, we should stop sending data on MISO
    // (or the protocol should have TLAST from S_AXIS indicating last byte)
    
endmodule

// =============================================================================
// spi_async_fifo.sv - Simple Asynchronous FIFO
// Used for MOSI byte buffering in SPI clock domain
// =============================================================================

module spi_async_fifo #(
    parameter WIDTH = 8,
    parameter DEPTH = 8,
    parameter ADDR_WIDTH = $clog2(DEPTH)
) (
    // Write Port
    input  logic                wr_clk,
    input  logic                wr_rst_n,
    input  logic                wr_en,
    input  logic [WIDTH-1:0]    wr_data,
    output logic                wr_full,
    
    // Read Port
    input  logic                rd_clk,
    input  logic                rd_rst_n,
    input  logic                rd_en,
    output logic [WIDTH-1:0]    rd_data,
    output logic                rd_empty
);
    
    logic [WIDTH-1:0] mem [0:DEPTH-1];
    logic [ADDR_WIDTH:0] wr_ptr, wr_ptr_sync1, wr_ptr_sync2;
    logic [ADDR_WIDTH:0] rd_ptr, rd_ptr_sync1, rd_ptr_sync2;
    logic [ADDR_WIDTH:0] wr_ptr_gray, rd_ptr_gray;
    
    // Write domain
    always_ff @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            wr_ptr <= {ADDR_WIDTH+1{1'b0}};
        end else if (wr_en && !wr_full) begin
            wr_ptr <= wr_ptr + 1;
        end
    end
    
    always_ff @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            for (int i = 0; i < DEPTH; i++) begin
                mem[i] <= 8'h00;
            end
        end else if (wr_en && !wr_full) begin
            mem[wr_ptr[ADDR_WIDTH-1:0]] <= wr_data;
        end
    end
    
    // Gray code conversion for write pointer
    assign wr_ptr_gray = wr_ptr ^ (wr_ptr >> 1);
    
    // CDC: Synchronize read pointer to write clock domain
    always_ff @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            rd_ptr_sync1 <= {ADDR_WIDTH+1{1'b0}};
            rd_ptr_sync2 <= {ADDR_WIDTH+1{1'b0}};
        end else begin
            rd_ptr_sync1 <= rd_ptr_gray;
            rd_ptr_sync2 <= rd_ptr_sync1;
        end
    end
    
    logic [ADDR_WIDTH:0] rd_ptr_sync_gray;
    assign rd_ptr_sync_gray = rd_ptr_sync2;
    
    // Decode gray code
    logic [ADDR_WIDTH:0] rd_ptr_sync_binary;
    assign rd_ptr_sync_binary = rd_ptr_sync_gray ^ (rd_ptr_sync_gray >> 1);
    
    // Full when write pointer equals read pointer (MSB differ, rest same)
    assign wr_full = (wr_ptr[ADDR_WIDTH] != rd_ptr_sync_binary[ADDR_WIDTH]) &&
                     (wr_ptr[ADDR_WIDTH-1:0] == rd_ptr_sync_binary[ADDR_WIDTH-1:0]);
    
    // Read domain
    always_ff @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            rd_ptr <= {ADDR_WIDTH+1{1'b0}};
        end else if (rd_en && !rd_empty) begin
            rd_ptr <= rd_ptr + 1;
        end
    end
    
    assign rd_data = mem[rd_ptr[ADDR_WIDTH-1:0]];
    
    // Gray code conversion for read pointer
    assign rd_ptr_gray = rd_ptr ^ (rd_ptr >> 1);
    
    // CDC: Synchronize write pointer to read clock domain
    always_ff @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            wr_ptr_sync1 <= {ADDR_WIDTH+1{1'b0}};
            wr_ptr_sync2 <= {ADDR_WIDTH+1{1'b0}};
        end else begin
            wr_ptr_sync1 <= wr_ptr_gray;
            wr_ptr_sync2 <= wr_ptr_sync1;
        end
    end
    
    logic [ADDR_WIDTH:0] wr_ptr_sync_gray;
    assign wr_ptr_sync_gray = wr_ptr_sync2;
    
    // Decode gray code
    logic [ADDR_WIDTH:0] wr_ptr_sync_binary;
    assign wr_ptr_sync_binary = wr_ptr_sync_gray ^ (wr_ptr_sync_gray >> 1);
    
    // Empty when read pointer equals write pointer
    assign rd_empty = (rd_ptr == wr_ptr_sync_binary);
    
endmodule
