/**
 * TTL Serial Module Testbench
 * 
 * Tests basic TX/RX functionality with 115200 baud rate
 */

`timescale 1ns/1ps

module ttl_serial_tb ();

    // Clock frequency: 27 MHz
    localparam CLK_PERIOD = 37.037; // ns
    localparam BAUD_RATE = 115_200;
    localparam CLK_FREQ_HZ = 27_000_000;
    localparam BAUD_PERIOD = 1_000_000_000 / BAUD_RATE; // ns
    
    logic        clk;
    logic        rst_n;
    logic [7:0]  tx_data;
    logic        tx_valid;
    logic        tx_ready;
    logic [7:0]  rx_data;
    logic        rx_valid;
    wire         serial;
    logic        half_duplex_en;
    
    // Instantiate the TTL Serial module
    ttl_serial #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .BAUD_RATE(BAUD_RATE),
        .HALF_DUPLEX(1)
    ) u_ttl_serial (
        .clk(clk),
        .rst_n(rst_n),
        .tx_data(tx_data),
        .tx_valid(tx_valid),
        .tx_ready(tx_ready),
        .rx_data(rx_data),
        .rx_valid(rx_valid),
        .serial(serial),
        .half_duplex_en(half_duplex_en)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // Test stimulus
    initial begin
        rst_n = 0;
        tx_data = 8'h00;
        tx_valid = 0;
        half_duplex_en = 1;
        
        // Reset
        repeat(10) @(posedge clk);
        rst_n = 1;
        repeat(10) @(posedge clk);
        
        $display("Starting TTL Serial Testbench");
        $display("Clock period: %.3f ns", CLK_PERIOD);
        $display("Baud period: %.3f ns", BAUD_PERIOD);
        $display("Baud divisor: %d clock cycles", CLK_FREQ_HZ / BAUD_RATE);
        
        // Test 1: Transmit 0xA5 (10100101)
        $display("\n=== Test 1: Transmit 0xA5 ===");
        tx_data = 8'hA5;
        tx_valid = 1;
        @(posedge clk);
        tx_valid = 0;
        
        // Wait for transmission to complete (start + 8 data + 2 stop = 11 bits)
        repeat(15 * CLK_FREQ_HZ / BAUD_RATE) @(posedge clk);
        
        $display("TX complete");
        
        // Test 2: Transmit 0x55 (01010101)
        #1000;
        $display("\n=== Test 2: Transmit 0x55 ===");
        tx_data = 8'h55;
        tx_valid = 1;
        @(posedge clk);
        tx_valid = 0;
        
        repeat(15 * CLK_FREQ_HZ / BAUD_RATE) @(posedge clk);
        
        $display("TX complete");
        
        // Test 3: Loopback test (transmit and receive on same line)
        // Note: Disable half-duplex for loopback test
        #1000;
        $display("\n=== Test 3: Loopback Test (half-duplex disabled) ===");
        half_duplex_en = 0;  // Disable half-duplex mode
        repeat(10) @(posedge clk);
        
        tx_data = 8'hC3;
        tx_valid = 1;
        @(posedge clk);
        tx_valid = 0;
        
        // Wait for transmission
        repeat(15 * CLK_FREQ_HZ / BAUD_RATE) @(posedge clk);
        
        // Check if we received the data back (with timeout)
        fork
            begin
                @(posedge rx_valid);
                $display("Received: 0x%02X (expected 0xC3)", rx_data);
            end
            begin
                repeat(20 * CLK_FREQ_HZ / BAUD_RATE) @(posedge clk);
                $display("Timeout waiting for RX");
            end
        join_any
        disable fork;
        
        repeat(1000) @(posedge clk);
        $display("\n=== All Tests Complete ===");
        $finish;
    end
    
    // Monitor serial line
    always @(posedge clk) begin
        if (rx_valid) begin
            $display("[%t] RX: 0x%02X", $time, rx_data);
        end
    end
    
    // Dump waveforms
    initial begin
        $dumpfile("ttl_serial_tb.vcd");
        $dumpvars(0, ttl_serial_tb);
    end

endmodule
