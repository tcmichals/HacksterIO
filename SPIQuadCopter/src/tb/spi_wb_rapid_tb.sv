/**
 * Rapid back-to-back SPI transaction testbench
 * Simulates quadcopter 1kHz polling rate
 */

`timescale 1ns / 1ps

module spi_wb_rapid_tb;

    // Clock period (54 MHz = ~18.5ns)
    localparam CLK_PERIOD = 18;
    // SPI clock period (1 MHz = 1000ns, realistic Pi SPI)
    localparam SPI_CLK_PERIOD = 1000;
    // Inter-transaction gap (10us = 10000ns, much less than 1ms)
    localparam INTER_TX_GAP = 10000;
    
    // DUT signals
    logic clk;
    logic rst;
    
    // SPI physical signals
    logic spi_sclk;
    logic spi_cs_n;
    logic spi_mosi;
    logic spi_miso;
    
    // SPI slave to master interface
    logic [7:0] spi_rx_data;
    logic       spi_rx_valid;
    logic [7:0] spi_tx_data;
    logic       spi_tx_valid;
    logic       spi_tx_ready;
    
    // Wishbone master signals
    logic [31:0] wb_adr;
    logic [31:0] wb_dat_m2s;
    logic [31:0] wb_dat_s2m;
    logic        wb_we;
    logic [3:0]  wb_sel;
    logic        wb_stb;
    logic        wb_ack;
    logic        wb_err;
    logic        wb_cyc;
    logic        busy;
    
    // Wishbone slave 0 (Version)
    logic [31:0] s0_adr, s0_dat_i, s0_dat_o;
    logic        s0_we, s0_stb, s0_ack, s0_cyc;
    
    // Fixed-size buffers
    reg [7:0] spi_tx_buf [0:63];
    reg [7:0] spi_rx_buf [0:63];
    
    // Test counters
    integer pass_count, fail_count;
    integer i, j;
    
    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // SPI Slave instance
    spi_slave #(
        .DATA_WIDTH(8)
    ) u_spi_slave (
        .i_clk(clk),
        .i_rst(rst),
        .i_sclk(spi_sclk),
        .i_cs_n(spi_cs_n),
        .i_mosi(spi_mosi),
        .o_miso(spi_miso),
        .i_tx_data(spi_tx_data),
        .i_tx_valid(spi_tx_valid),
        .o_tx_ready(spi_tx_ready),
        .o_busy(),
        .o_rx_data(spi_rx_data),
        .o_data_valid(spi_rx_valid),
        .o_cs_n_sync(spi_cs_n_sync)
    );
    
    // Synchronized CS from spi_slave
    logic spi_cs_n_sync;
    
    // SPI to Wishbone Master
    spi_wb_master #(
        .WB_ADDR_WIDTH(32),
        .WB_DATA_WIDTH(32)
    ) u_spi_wb (
        .clk(clk),
        .rst(rst),
        .spi_rx_valid(spi_rx_valid),
        .spi_rx_data(spi_rx_data),
        .spi_tx_valid(spi_tx_valid),
        .spi_tx_data(spi_tx_data),
        .spi_tx_ready(spi_tx_ready),
        .spi_cs_n(spi_cs_n_sync),  // Use synchronized CS
        .wb_adr_o(wb_adr),
        .wb_dat_o(wb_dat_m2s),
        .wb_dat_i(wb_dat_s2m),
        .wb_we_o(wb_we),
        .wb_sel_o(wb_sel),
        .wb_stb_o(wb_stb),
        .wb_ack_i(wb_ack),
        .wb_err_i(wb_err),
        .wb_cyc_o(wb_cyc),
        .busy(busy)
    );
    
    // Simple address decoder - only version at 0x0000
    wire s0_match = (wb_adr[31:8] == 24'h000000);
    
    assign s0_adr   = wb_adr;
    assign s0_dat_o = wb_dat_m2s;
    assign s0_we    = wb_we & s0_match;
    assign s0_stb   = wb_stb & s0_match;
    assign s0_cyc   = wb_cyc & s0_match;
    
    assign wb_dat_s2m = s0_dat_i;
    assign wb_ack = s0_ack;
    assign wb_err = ~s0_match & wb_stb & wb_cyc;
    
    // Version Register
    wb_version #(
        .DATA_WIDTH(32),
        .ADDR_WIDTH(32)
    ) u_wb_version (
        .i_clk(clk),
        .i_rst(rst),
        .wb_adr_i(s0_adr),
        .wb_dat_i(s0_dat_o),
        .wb_dat_o(s0_dat_i),
        .wb_we_i(s0_we),
        .wb_stb_i(s0_stb),
        .wb_ack_o(s0_ack),
        .wb_cyc_i(s0_cyc)
    );
    
    // SPI single byte transfer task
    task spi_byte(input [7:0] tx_byte, output [7:0] rx_byte);
        integer k;
        begin
            rx_byte = 8'h00;
            for (k = 7; k >= 0; k = k - 1) begin
                spi_sclk = 1'b0;
                spi_mosi = tx_byte[k];
                #(SPI_CLK_PERIOD/2);
                
                spi_sclk = 1'b1;
                rx_byte[k] = spi_miso;
                #(SPI_CLK_PERIOD/2);
            end
            spi_sclk = 1'b0;
        end
    endtask
    
    // SPI read version transaction 
    task read_version(output [31:0] version, output logic ok);
        reg [7:0] rx;
        begin
            // Build read frame
            spi_tx_buf[0]  = 8'hA1;  // Read command
            spi_tx_buf[1]  = 8'h04;  // Length LSB
            spi_tx_buf[2]  = 8'h00;  // Length MSB
            spi_tx_buf[3]  = 8'h00;  // Addr[0]
            spi_tx_buf[4]  = 8'h00;  // Addr[1]
            spi_tx_buf[5]  = 8'h00;  // Addr[2]
            spi_tx_buf[6]  = 8'h00;  // Addr[3]
            spi_tx_buf[7]  = 8'h55;  // Pad 0
            spi_tx_buf[8]  = 8'h55;  // Pad 1
            spi_tx_buf[9]  = 8'h55;  // Pad 2
            spi_tx_buf[10] = 8'h55;  // Pad 3
            spi_tx_buf[11] = 8'hDA;  // Sync
            
            // Assert CS
            spi_cs_n = 1'b0;
            #(SPI_CLK_PERIOD/2);
            
            // Transfer bytes
            for (i = 0; i < 12; i = i + 1) begin
                spi_byte(spi_tx_buf[i], rx);
                spi_rx_buf[i] = rx;
            end
            
            // Deassert CS
            #(SPI_CLK_PERIOD/2);
            spi_cs_n = 1'b1;
            
            // Extract version
            version = {spi_rx_buf[11], spi_rx_buf[10], spi_rx_buf[9], spi_rx_buf[8]};
            
            // Check response header
            ok = (spi_rx_buf[0] == 8'hDA) && (spi_rx_buf[1] == 8'h21);
        end
    endtask
    
    // Test procedure
    initial begin
        $dumpfile("spi_wb_rapid_tb.vcd");
        $dumpvars(0, spi_wb_rapid_tb);
        
        // Initialize
        rst = 1;
        spi_sclk = 0;
        spi_cs_n = 1;
        spi_mosi = 0;
        pass_count = 0;
        fail_count = 0;
        
        // Reset
        #(CLK_PERIOD * 10);
        rst = 0;
        #(CLK_PERIOD * 10);
        
        // =======================================================
        // Test: 100 rapid back-to-back version reads
        // =======================================================
        $display("\n=== Rapid Back-to-Back Version Read Test (100 iterations) ===");
        
        for (j = 0; j < 100; j = j + 1) begin
            reg [31:0] version;
            reg ok;
            
            read_version(version, ok);
            
            if (version == 32'hDEADBEEF && ok) begin
                pass_count = pass_count + 1;
            end else begin
                fail_count = fail_count + 1;
                $display("[FAIL] Iteration %0d: got 0x%08x, header_ok=%0d", j, version, ok);
                $display("       RX bytes: %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x",
                         spi_rx_buf[0], spi_rx_buf[1], spi_rx_buf[2], spi_rx_buf[3],
                         spi_rx_buf[4], spi_rx_buf[5], spi_rx_buf[6], spi_rx_buf[7],
                         spi_rx_buf[8], spi_rx_buf[9], spi_rx_buf[10], spi_rx_buf[11]);
            end
            
            // Small gap between transactions (10us)
            #(INTER_TX_GAP);
        end
        
        // =======================================================
        // Summary
        // =======================================================
        $display("\n=== Test Summary ===");
        $display("PASSED: %0d / 100", pass_count);
        $display("FAILED: %0d / 100", fail_count);
        
        if (fail_count == 0) begin
            $display("\n*** ALL TESTS PASSED ***\n");
        end else begin
            $display("\n*** SOME TESTS FAILED ***\n");
        end
        
        $finish;
    end

endmodule
