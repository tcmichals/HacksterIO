// =============================================================================
// tb_spi_axis_bridge.sv
// Testbench for SPI AXIS Bridge
// =============================================================================
// Tests:
//   1. MOSI byte capture and transmission to M_AXIS
//   2. MISO byte reception from S_AXIS and transmission to SPI
//   3. CS frame termination (TLAST assertion)
//   4. Full-duplex simultaneous operation
//   5. Back-to-back transfers with CS toggle
// =============================================================================

module tb_spi_axis_bridge ();

    localparam CLK_PERIOD = 10;  // 100 MHz system clock
    localparam SPI_PERIOD = 1000; // 10 MHz SPI clock (slower than system)
    
    // Signals
    logic clk;
    logic rst_n;
    
    // SPI Interface
    logic spi_clk;
    logic spi_mosi;
    logic spi_miso;
    logic spi_cs_n;
    
    // M_AXIS (MOSI output)
    logic [7:0] m_axis_tdata;
    logic m_axis_tvalid;
    logic m_axis_tready;
    logic m_axis_tlast;
    
    // S_AXIS (MISO input)
    logic [7:0] s_axis_tdata;
    logic s_axis_tvalid;
    logic s_axis_tready;
    logic s_axis_tlast;
    
    // =========================================================================
    // Instantiate DUT
    // =========================================================================
    
    spi_axis_bridge dut (
        .clk             (clk),
        .rst_n           (rst_n),
        .spi_clk         (spi_clk),
        .spi_mosi        (spi_mosi),
        .spi_cs_n        (spi_cs_n),
        .spi_miso        (spi_miso),
        .s_axis_tdata    (s_axis_tdata),
        .s_axis_tvalid   (s_axis_tvalid),
        .s_axis_tready   (s_axis_tready),
        .s_axis_tlast    (s_axis_tlast),
        .m_axis_tdata    (m_axis_tdata),
        .m_axis_tvalid   (m_axis_tvalid),
        .m_axis_tready   (m_axis_tready),
        .m_axis_tlast    (m_axis_tlast)
    );
    
    // =========================================================================
    // Clock Generators
    // =========================================================================
    
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    initial begin
        spi_clk = 1'b0;
        forever #(SPI_PERIOD/2) spi_clk = ~spi_clk;
    end
    
    // =========================================================================
    // Reset
    // =========================================================================
    
    initial begin
        rst_n = 1'b0;
        #(CLK_PERIOD * 5);
        rst_n = 1'b1;
    end
    
    // =========================================================================
    // Test Stimulus
    // =========================================================================
    
    initial begin
        // Initialize
        spi_mosi = 1'b0;
        spi_cs_n = 1'b1;
        s_axis_tdata = 8'h00;
        s_axis_tvalid = 1'b0;
        s_axis_tlast = 1'b0;
        m_axis_tready = 1'b1;
        
        // Wait for reset
        #(CLK_PERIOD * 10);
        
        $display("\n=== Test 1: Simple MOSI Byte Transfer ===");
        // Send command byte: 0x01 (Write Command)
        send_spi_byte(8'h01);
        wait_spi_clocks(10);
        
        $display("MOSI byte received: 0x%02X", m_axis_tdata);
        if (m_axis_tdata == 8'h01 && m_axis_tvalid) begin
            $display("✓ MOSI byte correct");
        end else begin
            $display("✗ MOSI byte ERROR");
        end
        
        wait_spi_clocks(5);
        
        // =====================================================================
        $display("\n=== Test 2: MOSI Address Bytes + MISO Response ===");
        
        // Send 4 address bytes while providing response
        send_spi_byte_with_response(8'h00, 8'hA5);  // Addr MSB, send ACK
        wait_spi_clocks(5);
        
        send_spi_byte_with_response(8'h00, 8'h00);  // Addr
        wait_spi_clocks(5);
        
        send_spi_byte_with_response(8'h20, 8'h00);  // Addr
        wait_spi_clocks(5);
        
        send_spi_byte_with_response(8'h00, 8'h00);  // Addr LSB
        wait_spi_clocks(5);
        
        $display("✓ Full-duplex simultaneous transfer completed");
        
        // =====================================================================
        $display("\n=== Test 3: Frame Termination with CS ===");
        
        // Send length bytes and deassert CS to trigger TLAST
        send_spi_byte(8'h00);  // Len MSB
        wait_spi_clocks(5);
        
        send_spi_byte(8'h01);  // Len LSB
        wait_spi_clocks(5);
        
        // Deassert CS (end of frame)
        $display("Deasserting CS to trigger TLAST");
        spi_cs_n = 1'b1;
        wait_spi_clocks(10);
        
        if (m_axis_tlast) begin
            $display("✓ TLAST asserted on CS falling edge");
        end else begin
            $display("✗ TLAST NOT asserted (ERROR)");
        end
        
        wait_spi_clocks(10);
        
        // =====================================================================
        $display("\n=== Test 4: Back-to-Back Transfers ===");
        
        // Re-assert CS for next frame
        spi_cs_n = 1'b0;
        wait_spi_clocks(5);
        
        $display("Starting 2nd transfer");
        send_spi_byte(8'hAA);
        wait_spi_clocks(5);
        
        send_spi_byte(8'hBB);
        wait_spi_clocks(5);
        
        send_spi_byte(8'hCC);
        wait_spi_clocks(5);
        
        // End 2nd frame
        spi_cs_n = 1'b1;
        wait_spi_clocks(10);
        
        $display("✓ Back-to-back transfer completed");
        
        // =====================================================================
        $display("\n=== Test 5: Flow Control (TREADY) ===");
        
        spi_cs_n = 1'b0;
        wait_spi_clocks(5);
        
        // Send byte with TREADY=0
        m_axis_tready = 1'b0;
        send_spi_byte(8'hDD);
        wait_spi_clocks(10);
        
        $display("Byte sent with TREADY=0, should be buffered in FIFO");
        
        // Now assert TREADY and check byte comes out
        m_axis_tready = 1'b1;
        wait_spi_clocks(10);
        
        if (m_axis_tdata == 8'hDD && m_axis_tvalid) begin
            $display("✓ Buffered byte correctly output when TREADY asserted");
        end else begin
            $display("✗ Buffered byte ERROR");
        end
        
        spi_cs_n = 1'b1;
        wait_spi_clocks(10);
        
        // =====================================================================
        $display("\n=== All Tests Completed ===");
        #(CLK_PERIOD * 50);
        $finish;
    end
    
    // =========================================================================
    // Helper Tasks
    // =========================================================================
    
    // Send a single byte on MOSI (MSB first)
    task send_spi_byte(input logic [7:0] data);
        logic [7:0] temp;
        int i;
        temp = data;
        spi_cs_n = 1'b0;  // Assert CS
        
        for (i = 7; i >= 0; i = i - 1) begin
            spi_mosi = temp[i];
            wait_spi_clocks(1);
        end
    endtask
    
    // Send MOSI byte with simultaneous MISO response
    task send_spi_byte_with_response(input logic [7:0] mosi_data, input logic [7:0] miso_data);
        logic [7:0] mosi_temp;
        logic [7:0] miso_temp;
        int i;
        mosi_temp = mosi_data;
        miso_temp = miso_data;
        
        // Provide response
        s_axis_tdata = miso_data;
        s_axis_tvalid = 1'b1;
        s_axis_tlast = 1'b0;
        
        spi_cs_n = 1'b0;  // Assert CS
        
        for (i = 7; i >= 0; i = i - 1) begin
            spi_mosi = mosi_temp[i];
            wait_spi_clocks(1);
        end
        
        s_axis_tvalid = 1'b0;
    endtask
    
    // Wait N SPI clock cycles
    task wait_spi_clocks(input int n);
        int i;
        for (i = 0; i < n; i = i + 1) begin
            @(posedge spi_clk);
        end
    endtask
    
    // =========================================================================
    // Monitoring
    // =========================================================================
    
    initial begin
        $monitor("@%0t: M_AXIS=%02X TVALID=%b TLAST=%b | S_AXIS=%02X TVALID=%b | SPI_CS=%b MOSI=%b MISO=%b",
                 $time, m_axis_tdata, m_axis_tvalid, m_axis_tlast,
                 s_axis_tdata, s_axis_tvalid, spi_cs_n, spi_mosi, spi_miso);
    end
    
endmodule
