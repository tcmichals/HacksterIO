/**
 * SPI Slave Testbench
 * 
 * Tests the SPI Slave module in Mode 0 operation
 */

`timescale 1ns/1ps

module spi_slave_tb;

    // =============================
    // Parameters and Signals
    // =============================
    parameter DATA_WIDTH = 8;
    parameter SYS_CLK_PERIOD = 10;  // 100 MHz system clock
    parameter SPI_CLK_PERIOD = 40;  // 25 MHz SPI clock
    
    logic                    sys_clk;
    logic                    rst_n;
    logic                    i_sclk;
    logic                    i_cs_n;
    logic                    i_mosi;
    logic                    o_miso;
    logic [DATA_WIDTH-1:0]   o_rx_data;
    logic                    o_rx_valid;
    logic [DATA_WIDTH-1:0]   i_tx_data;
    logic                    i_tx_valid;
    logic                    o_busy;
    
    // =============================
    // DUT Instantiation
    // =============================
    spi_slave dut (
        .i_clk       (sys_clk),
        .i_rst_n     (rst_n),
        .i_sclk      (i_sclk),
        .i_cs_n      (i_cs_n),
        .i_mosi      (i_mosi),
        .o_miso      (o_miso),
        .o_rx_data   (o_rx_data),
        .o_rx_valid  (o_rx_valid),
        .i_tx_data   (i_tx_data),
        .i_tx_valid  (i_tx_valid),
        .o_busy      (o_busy)
    );
    
    // =============================
    // Clock Generation
    // =============================
    initial begin
        sys_clk = 1'b0;
        forever #(SYS_CLK_PERIOD/2) sys_clk = ~sys_clk;
    end
    
    initial begin
        i_sclk = 1'b0;
        forever #(SPI_CLK_PERIOD/2) i_sclk = ~i_sclk;
    end
    
    // =============================
    // Testbench Stimulus
    // =============================
    initial begin
        // File for waveform dump
        $dumpfile("spi_slave_tb.vcd");
        $dumpvars(0, spi_slave_tb);
        
        // Initialize
        rst_n = 1'b0;
        i_cs_n = 1'b1;
        i_mosi = 1'b0;
        i_tx_data = 8'h00;
        i_tx_valid = 1'b0;
        
        // Wait for reset
        repeat(10) @(posedge sys_clk);
        rst_n = 1'b1;
        
        repeat(10) @(posedge sys_clk);
        
        // ===========================
        // Test 1: Simple SPI Transfer
        // ===========================
        $display("Test 1: Simple SPI Transfer");
        $display("Master sends: 0xA5 (10100101)");
        $display("Slave sends: 0x5A (01011010)");
        
        // Load slave transmit data
        @(posedge sys_clk) i_tx_data = 8'h5A;
        @(posedge sys_clk) i_tx_valid = 1'b1;
        @(posedge sys_clk) i_tx_valid = 1'b0;
        
        // Start SPI transaction
        repeat(5) @(posedge sys_clk);
        @(posedge sys_clk) i_cs_n = 1'b0;
        
        // Wait for synchronization
        repeat(10) @(posedge sys_clk);
        
        // Send byte: 0xA5
        send_spi_byte(8'hA5);
        
        // Wait for synchronization
        repeat(10) @(posedge sys_clk);
        
        // End transaction
        @(posedge sys_clk) i_cs_n = 1'b1;
        
        repeat(20) @(posedge sys_clk);
        
        // ===========================
        // Test 2: Multiple Transfers
        // ===========================
        $display("\nTest 2: Multiple Transfers");
        
        repeat(5) @(posedge sys_clk);
        
        // Transfer 1
        $display("Transfer 1: Master sends 0x12, Slave sends 0x34");
        @(posedge sys_clk) i_tx_data = 8'h34;
        @(posedge sys_clk) i_tx_valid = 1'b1;
        @(posedge sys_clk) i_tx_valid = 1'b0;
        
        repeat(5) @(posedge sys_clk);
        @(posedge sys_clk) i_cs_n = 1'b0;
        repeat(10) @(posedge sys_clk);
        
        send_spi_byte(8'h12);
        
        repeat(10) @(posedge sys_clk);
        @(posedge sys_clk) i_cs_n = 1'b1;
        
        repeat(10) @(posedge sys_clk);
        
        // Transfer 2
        $display("Transfer 2: Master sends 0xAB, Slave sends 0xCD");
        @(posedge sys_clk) i_tx_data = 8'hCD;
        @(posedge sys_clk) i_tx_valid = 1'b1;
        @(posedge sys_clk) i_tx_valid = 1'b0;
        
        repeat(5) @(posedge sys_clk);
        @(posedge sys_clk) i_cs_n = 1'b0;
        repeat(10) @(posedge sys_clk);
        
        send_spi_byte(8'hAB);
        
        repeat(10) @(posedge sys_clk);
        @(posedge sys_clk) i_cs_n = 1'b1;
        
        repeat(20) @(posedge sys_clk);
        
        // ===========================
        // Test 3: All Zeros
        // ===========================
        $display("\nTest 3: Send All Zeros");
        
        repeat(5) @(posedge sys_clk);
        @(posedge sys_clk) i_tx_data = 8'h00;
        @(posedge sys_clk) i_tx_valid = 1'b1;
        @(posedge sys_clk) i_tx_valid = 1'b0;
        
        repeat(5) @(posedge sys_clk);
        @(posedge sys_clk) i_cs_n = 1'b0;
        repeat(10) @(posedge sys_clk);
        
        send_spi_byte(8'hFF);
        
        repeat(10) @(posedge sys_clk);
        @(posedge sys_clk) i_cs_n = 1'b1;
        
        repeat(20) @(posedge sys_clk);
        
        // ===========================
        // Test 4: All Ones
        // ===========================
        $display("\nTest 4: Send All Ones");
        
        repeat(5) @(posedge sys_clk);
        @(posedge sys_clk) i_tx_data = 8'hFF;
        @(posedge sys_clk) i_tx_valid = 1'b1;
        @(posedge sys_clk) i_tx_valid = 1'b0;
        
        repeat(5) @(posedge sys_clk);
        @(posedge sys_clk) i_cs_n = 1'b0;
        repeat(10) @(posedge sys_clk);
        
        send_spi_byte(8'h00);
        
        repeat(10) @(posedge sys_clk);
        @(posedge sys_clk) i_cs_n = 1'b1;
        
        repeat(20) @(posedge sys_clk);
        
        $display("\nAll tests completed!");
        $finish;
    end
    
    // =============================
    // Task: Send SPI Byte
    // =============================
    task send_spi_byte(input logic [7:0] byte_val);
        for (int i = 7; i >= 0; i--) begin
            // Set MOSI data bit
            @(posedge sys_clk) i_mosi = byte_val[i];
            
            // Wait for SCLK to complete a cycle
            @(posedge i_sclk);
            @(negedge i_sclk);
            
            // Small delay before next bit
            repeat(5) @(posedge sys_clk);
        end
    endtask
    
    // =============================
    // Monitors
    // =============================
    always @(posedge o_rx_valid) begin
        $display("  RX: Received 0x%02X at time %t", o_rx_data, $time);
    end
    
    always @(o_miso) begin
        $display("  MISO changed to: %b at time %t", o_miso, $time);
    end

endmodule
