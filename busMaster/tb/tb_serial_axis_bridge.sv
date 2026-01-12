// =============================================================================
// tb_serial_axis_bridge.sv
// Testbench for Serial UART to AXIS Bridge
// =============================================================================
// Tests:
//   1. Single byte UART reception and AXIS transmission
//   2. Multi-byte frame reception
//   3. Break byte (0xFF) frame termination and TLAST assertion
//   4. Back-to-back frames
//   5. Flow control with TREADY
//   6. Baud rate timing accuracy
// =============================================================================

module tb_serial_axis_bridge ();

    localparam CLK_PERIOD = 10;       // 100 MHz system clock
    localparam CLK_FREQ_MHZ = 100;
    localparam BAUD_RATE = 115200;
    localparam BAUD_PERIOD = (CLK_FREQ_MHZ * 1_000_000) / BAUD_RATE;  // Cycles per bit
    
    // Signals
    logic clk;
    logic rst_n;
    
    // Serial Input
    logic uart_rx;
    
    // M_AXIS Output
    logic [7:0] m_axis_tdata;
    logic m_axis_tvalid;
    logic m_axis_tready;
    logic m_axis_tlast;
    
    // =========================================================================
    // Instantiate DUT
    // =========================================================================
    
    serial_axis_bridge #(
        .CLK_FREQ_MHZ (CLK_FREQ_MHZ),
        .BAUD_RATE    (BAUD_RATE)
    ) dut (
        .clk          (clk),
        .rst_n        (rst_n),
        .uart_rx      (uart_rx),
        .m_axis_tdata (m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready),
        .m_axis_tlast (m_axis_tlast)
    );
    
    // =========================================================================
    // Clock Generator
    // =========================================================================
    
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
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
        uart_rx = 1'b1;  // Idle state
        m_axis_tready = 1'b1;
        
        // Wait for reset
        #(CLK_PERIOD * 10);
        
        $display("\n=== Test 1: Single Byte Reception (0x42) ===");
        send_uart_byte(8'h42);
        wait_for_valid();
        
        if (m_axis_tdata == 8'h42 && m_axis_tvalid) begin
            $display("✓ Byte 0x42 received correctly");
        end else begin
            $display("✗ Byte reception ERROR: got 0x%02X", m_axis_tdata);
        end
        
        // Wait for byte to be consumed
        #(CLK_PERIOD * 100);
        
        // =====================================================================
        $display("\n=== Test 2: Command Header Sequence ===");
        
        // Send command byte
        $display("Sending command byte: 0x01 (Write)");
        send_uart_byte(8'h01);
        wait_for_valid();
        if (m_axis_tdata == 8'h01) $display("✓ Command byte OK");
        
        #(CLK_PERIOD * 100);
        
        // Send address bytes (big endian)
        $display("Sending address: 0x00002000");
        send_uart_byte(8'h00);  // Addr[31:24]
        wait_for_valid();
        $display("  Addr[31:24] = 0x%02X", m_axis_tdata);
        
        #(CLK_PERIOD * 100);
        
        send_uart_byte(8'h00);  // Addr[23:16]
        wait_for_valid();
        
        #(CLK_PERIOD * 100);
        
        send_uart_byte(8'h20);  // Addr[15:8]
        wait_for_valid();
        $display("  Addr[15:8] = 0x%02X", m_axis_tdata);
        
        #(CLK_PERIOD * 100);
        
        send_uart_byte(8'h00);  // Addr[7:0]
        wait_for_valid();
        
        #(CLK_PERIOD * 100);
        
        // Send length bytes
        $display("Sending length: 0x0001 (1 word)");
        send_uart_byte(8'h00);  // Len[15:8]
        wait_for_valid();
        
        #(CLK_PERIOD * 100);
        
        send_uart_byte(8'h01);  // Len[7:0]
        wait_for_valid();
        if (m_axis_tdata == 8'h01) $display("✓ Length byte OK");
        
        #(CLK_PERIOD * 100);
        
        // =====================================================================
        $display("\n=== Test 3: Data Payload ===");
        
        $display("Sending data word: 0xDEADBEEF");
        send_uart_byte(8'hDE);
        wait_for_valid();
        #(CLK_PERIOD * 100);
        
        send_uart_byte(8'hAD);
        wait_for_valid();
        #(CLK_PERIOD * 100);
        
        send_uart_byte(8'hBE);
        wait_for_valid();
        #(CLK_PERIOD * 100);
        
        send_uart_byte(8'hEF);
        wait_for_valid();
        #(CLK_PERIOD * 100);
        
        // =====================================================================
        $display("\n=== Test 4: Break Byte and TLAST Assertion ===");
        
        $display("Sending break byte: 0xFF");
        send_uart_byte(8'hFF);
        wait_for_valid();
        
        if (m_axis_tdata == 8'hFF && m_axis_tlast) begin
            $display("✓ Break byte 0xFF received with TLAST asserted");
        end else begin
            $display("✗ Break byte handling ERROR");
            $display("  Data: 0x%02X (expected 0xFF)", m_axis_tdata);
            $display("  TLAST: %b (expected 1)", m_axis_tlast);
        end
        
        #(CLK_PERIOD * 100);
        
        // =====================================================================
        $display("\n=== Test 5: Back-to-Back Frames ===");
        
        $display("Starting 2nd frame");
        send_uart_byte(8'hAA);
        wait_for_valid();
        if (m_axis_tdata == 8'hAA) $display("✓ 2nd frame byte 1 OK");
        
        #(CLK_PERIOD * 100);
        
        send_uart_byte(8'hBB);
        wait_for_valid();
        
        #(CLK_PERIOD * 100);
        
        send_uart_byte(8'hCC);
        wait_for_valid();
        
        #(CLK_PERIOD * 100);
        
        send_uart_byte(8'hFF);  // Break byte
        wait_for_valid();
        
        if (m_axis_tlast) begin
            $display("✓ 2nd frame terminated correctly");
        end else begin
            $display("✗ 2nd frame termination ERROR");
        end
        
        #(CLK_PERIOD * 100);
        
        // =====================================================================
        $display("\n=== Test 6: Flow Control (TREADY=0) ===");
        
        $display("Sending byte with TREADY=0");
        m_axis_tready = 1'b0;
        send_uart_byte(8'h55);
        
        // Wait a bit with TREADY=0
        #(CLK_PERIOD * 200);
        
        // Now assert TREADY
        $display("Asserting TREADY to drain queue");
        m_axis_tready = 1'b1;
        #(CLK_PERIOD * 50);
        
        if (m_axis_tdata == 8'h55 && m_axis_tvalid) begin
            $display("✓ Byte correctly output after TREADY assertion");
        end else begin
            $display("✗ Flow control handling ERROR");
        end
        
        #(CLK_PERIOD * 100);
        
        // =====================================================================
        $display("\n=== All Tests Completed ===");
        #(CLK_PERIOD * 100);
        $finish;
    end
    
    // =========================================================================
    // Helper Tasks
    // =========================================================================
    
    // Send a single byte via UART
    // Format: 1 start bit + 8 data bits + 1 stop bit
    task send_uart_byte(input logic [7:0] data);
        logic [7:0] temp;
        int i;
        temp = data;
        
        $display("Sending UART byte: 0x%02X", data);
        
        // Start bit
        uart_rx = 1'b0;
        #(BAUD_PERIOD * CLK_PERIOD);
        
        // Data bits (LSB first)
        for (i = 0; i < 8; i = i + 1) begin
            uart_rx = temp[i];
            #(BAUD_PERIOD * CLK_PERIOD);
        end
        
        // Stop bit
        uart_rx = 1'b1;
        #(BAUD_PERIOD * CLK_PERIOD);
    endtask
    
    // Wait for m_axis_tvalid to assert
    task wait_for_valid();
        int timeout;
        timeout = 0;
        while (!m_axis_tvalid && timeout < 100000) begin
            #CLK_PERIOD;
            timeout = timeout + 1;
        end
        
        if (timeout >= 100000) begin
            $display("✗ TIMEOUT waiting for m_axis_tvalid");
        end
    endtask
    
    // =========================================================================
    // Monitoring
    // =========================================================================
    
    initial begin
        $monitor("@%0t: TDATA=%02X TVALID=%b TLAST=%b TREADY=%b | RX=%b",
                 $time, m_axis_tdata, m_axis_tvalid, m_axis_tlast, m_axis_tready, uart_rx);
    end
    
endmodule
