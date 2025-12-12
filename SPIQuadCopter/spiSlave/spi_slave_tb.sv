/**
 * SPI Slave Testbench (Self-Checking)
 * 
 * Tests the SPI Slave module in Mode 0 operation with randomized data.
 */

`timescale 1ns/1ps

module spi_slave_tb;

    // Parameters
    parameter DATA_WIDTH = 8;
    parameter CLK_PERIOD = 10;     // 100 MHz System Clock
    parameter SCLK_PERIOD = 50;    // 20 MHz SPI Clock (1/5 System Clock)

    // System Signals
    logic clk = 0;
    logic rst = 1;
    
    // SPI Signals (Master Output)
    logic sclk = 0;
    logic cs_n = 1;
    logic mosi = 0;
    
    // SPI Signal (Slave Output)
    wire  miso;
    
    // User Interface Signals (Slave Side)
    logic [DATA_WIDTH-1:0] tx_data_in; 
    logic tx_valid = 0;
    wire  tx_ready;
    wire  busy;
    wire  [DATA_WIDTH-1:0] rx_data;
    wire  rx_valid;

    // Verification Variables
    int error_count = 0;

    // Instantiate DUT
    // Instantiate DUT
    spi_slave #(.DATA_WIDTH(DATA_WIDTH)) dut (
        .i_clk(clk),
        .i_rst(rst),
        .i_sclk(sclk),
        .i_cs_n(cs_n),
        .i_mosi(mosi),
        .o_miso(miso),
        .i_tx_data(tx_data_in),
        .i_tx_valid(tx_valid),
        .o_tx_ready(tx_ready),
        .o_busy(busy),
        .o_rx_data(rx_data),
        .o_data_valid(rx_valid)
    );

    // System Clock Generation
    always #(CLK_PERIOD/2) clk = ~clk;

    // SPI Master Task (Mode 0: CPOL=0, CPHA=0)
    // Returns the byte received from Slave (MISO)
    task automatic spi_transfer(
        input  logic [DATA_WIDTH-1:0] tx_byte,
        output logic [DATA_WIDTH-1:0] rx_byte
    );
        integer i;
        begin
            rx_byte = 0;
            cs_n = 0; // Assert CS
            #(SCLK_PERIOD); // Setup time
            
            for (i = DATA_WIDTH-1; i >= 0; i--) begin
                mosi = tx_byte[i]; // Master drives MOSI
                
                #(SCLK_PERIOD/2) sclk = 1; // Rising edge (Slave samples MOSI)
                
                // Sample MISO on Rising Edge (Mode 0) or slightly after
                // We sample just before falling edge to be safe in simulation
                rx_byte[i] = miso; 
                
                #(SCLK_PERIOD/2) sclk = 0; // Falling edge (Slave shifts MISO)
            end
            
            #(SCLK_PERIOD/2);
            cs_n = 1; // De-assert CS
            mosi = 0;
            #(SCLK_PERIOD);
        end
    endtask

    // Main Test Sequence
    initial begin
        logic [DATA_WIDTH-1:0] master_tx_data;
        logic [DATA_WIDTH-1:0] slave_tx_data;
        logic [DATA_WIDTH-1:0] master_rx_data;
        
        // Setup
        $dumpfile("spi_slave_tb.vcd");
        $dumpvars(0, spi_slave_tb);
        
        $display("---------------------------------------");
        $display("   Starting SPI Slave Self-Checking TB ");
        $display("---------------------------------------");
        
        // Reset
        rst = 1;
        #50 rst = 0;
        #100;
        
        // --- Test 1: Single Byte Exchange ---
        master_tx_data = 8'hA5;
        slave_tx_data  = 8'h55;
        
        $display("[Test 1] Loading Slave with 0x%h...", slave_tx_data);
        
        // Load Slave
        wait(tx_ready);
        @(posedge clk);
        tx_data_in = slave_tx_data;
        tx_valid = 1;
        @(posedge clk);
        tx_valid = 0;
        
        // Run SPI transaction
        spi_transfer(master_tx_data, master_rx_data);
        
        // Check Master received correct data from Slave
        if (master_rx_data !== slave_tx_data) begin
            $display("ERROR: Master Received 0x%h, Expected 0x%h", master_rx_data, slave_tx_data);
            error_count++;
        end else begin
            $display("SUCCESS: Master Received 0x%h", master_rx_data);
        end

        // Check Slave received correct data from Master
        // We need to wait for rx_valid pulse or check it was set
        @(posedge clk);
        if (rx_data !== master_tx_data) begin
            $display("ERROR: Slave Received 0x%h, Expected 0x%h", rx_data, master_tx_data);
            error_count++;
        end else begin
             $display("SUCCESS: Slave Received 0x%h", rx_data);
        end

        // --- Test 2: Randomized Streaming ---
        $display("\n[Test 2] Randomized Streaming Test (10 Iterations)");
        
        for (int k = 0; k < 10; k++) begin
            master_tx_data = $random;
            slave_tx_data  = $random;
            
            // 1. Load Slave with data for this turn
            wait(tx_ready);
            @(posedge clk);
            tx_data_in = slave_tx_data;
            tx_valid = 1;
            @(posedge clk);
            tx_valid = 0;
            
            // 2. Perform Transaction
            spi_transfer(master_tx_data, master_rx_data);
            
            // 3. Verify Master RX (MISO)
            if (master_rx_data !== slave_tx_data) begin
                $display("ITER %0d FAIL: Master RX=0x%h Exp=0x%h", k, master_rx_data, slave_tx_data);
                error_count++;
            end
            
            // 4. Verify Slave RX (MOSI)
            // Wait for data valid if needed, but the task waits long enough for the slave to latch
            if (rx_data !== master_tx_data) begin
                 $display("ITER %0d FAIL: Slave RX=0x%h Exp=0x%h", k, rx_data, master_tx_data);
                 error_count++;
            end
            
            // Short random delay between transactions
            repeat($urandom_range(5, 20)) @(posedge clk);
        end
        
        // Summary
        $display("---------------------------------------");
        if (error_count == 0) begin
             $display("TEST PASSED: All checks successful.");
        end else begin
             $display("TEST FAILED: %0d errors found.", error_count);
        end
        $display("---------------------------------------");
        
        $finish;
    end

endmodule