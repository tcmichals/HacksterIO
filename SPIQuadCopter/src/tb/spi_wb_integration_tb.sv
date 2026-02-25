/**
 * Integration Testbench for SPI to Wishbone with real peripherals
 * 
 * Tests:
 * 1. Read Version register (wb_version) - should return 0xDEADBEEF
 * 2. Write/Read LED controller (wb_led_controller)
 */

`timescale 1ns / 1ps

module spi_wb_integration_tb;

    // Clock period (54 MHz = ~18.5ns)
    localparam CLK_PERIOD = 18;
    // SPI clock period (1 MHz = 1000ns for easier debug)
    localparam SPI_CLK_PERIOD = 1000;
    
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
    
    // Wishbone master signals (from SPI-WB bridge)
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
    
    // Wishbone signals for slave 0 (Version)
    logic [31:0] s0_adr, s0_dat_i, s0_dat_o;
    logic        s0_we, s0_stb, s0_ack, s0_cyc;
    
    // Wishbone signals for slave 1 (LED)
    logic [31:0] s1_adr, s1_dat_i, s1_dat_o;
    logic        s1_we, s1_stb, s1_ack, s1_cyc;
    logic [3:0]  s1_sel;
    logic        s1_err, s1_rty;
    
    // LED output
    logic [3:0]  led_out;
    
    // Fixed-size buffers for SPI transactions
    reg [7:0] spi_tx_buf [0:63];
    reg [7:0] spi_rx_buf [0:63];
    integer   spi_buf_len;
    
    // Test counters
    integer pass_count, fail_count;
    
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
    
    // Simple 2-slave address decoder
    // Slave 0: 0x0000-0x00FF (Version)
    // Slave 1: 0x0100-0x01FF (LED)
    wire s0_match = (wb_adr[31:8] == 24'h000000);
    wire s1_match = (wb_adr[31:8] == 24'h000001);
    
    // Slave 0 signals
    assign s0_adr   = wb_adr;
    assign s0_dat_o = wb_dat_m2s;
    assign s0_we    = wb_we & s0_match;
    assign s0_stb   = wb_stb & s0_match;
    assign s0_cyc   = wb_cyc & s0_match;
    
    // Slave 1 signals
    assign s1_adr   = wb_adr;
    assign s1_dat_o = wb_dat_m2s;
    assign s1_we    = wb_we & s1_match;
    assign s1_sel   = wb_sel;
    assign s1_stb   = wb_stb & s1_match;
    assign s1_cyc   = wb_cyc & s1_match;
    
    // Mux data back to master
    assign wb_dat_s2m = s0_match ? s0_dat_i :
                        s1_match ? s1_dat_i :
                        32'hDEADDEAD;
    
    assign wb_ack = s0_ack | s1_ack;
    assign wb_err = ~(s0_match | s1_match) & wb_stb & wb_cyc;
    
    // Version Register (should return 0xDEADBEEF)
    wb_version #(
        .DATA_WIDTH(32),
        .ADDR_WIDTH(32)
    ) u_wb_version (
        .i_clk(clk),
        .i_rst(rst),
        .wb_adr_i(s0_adr[3:0]),
        .wb_dat_i(s0_dat_o),
        .wb_dat_o(s0_dat_i),
        .wb_we_i(s0_we),
        .wb_stb_i(s0_stb),
        .wb_ack_o(s0_ack),
        .wb_cyc_i(s0_cyc)
    );
    
    // LED Controller
    wb_led_controller #(
        .LED_WIDTH(4)
    ) u_wb_led (
        .clk(clk),
        .rst(rst),
        .wbs_adr_i(s1_adr),
        .wbs_dat_i(s1_dat_o),
        .wbs_dat_o(s1_dat_i),
        .wbs_we_i(s1_we),
        .wbs_sel_i(s1_sel),
        .wbs_stb_i(s1_stb),
        .wbs_cyc_i(s1_cyc),
        .wbs_ack_o(s1_ack),
        .wbs_err_o(s1_err),
        .wbs_rty_o(s1_rty),
        .led_out(led_out)
    );
    
    // SPI single byte transfer task
    task spi_byte(input [7:0] tx_byte, output [7:0] rx_byte);
        integer i;
        begin
            rx_byte = 8'h00;
            for (i = 7; i >= 0; i = i - 1) begin
                // Setup MOSI on falling edge
                spi_sclk = 1'b0;
                spi_mosi = tx_byte[i];
                #(SPI_CLK_PERIOD/2);
                
                // Sample MISO on rising edge
                spi_sclk = 1'b1;
                rx_byte[i] = spi_miso;
                #(SPI_CLK_PERIOD/2);
            end
            spi_sclk = 1'b0;
        end
    endtask
    
    // SPI transaction task
    task spi_transaction(input integer len);
        integer i;
        reg [7:0] rx;
        begin
            $display("[SPI] Starting transaction, %0d bytes", len);
            spi_cs_n = 1'b0;
            #(SPI_CLK_PERIOD);
            
            for (i = 0; i < len; i = i + 1) begin
                spi_byte(spi_tx_buf[i], rx);
                spi_rx_buf[i] = rx;
                $display("[SPI] TX: 0x%02x RX: 0x%02x", spi_tx_buf[i], rx);
                #(CLK_PERIOD * 4);  // Inter-byte delay
            end
            
            #(SPI_CLK_PERIOD);
            spi_cs_n = 1'b1;
            #(SPI_CLK_PERIOD * 2);
        end
    endtask
    
    // Test procedure
    initial begin
        $dumpfile("spi_wb_integration_tb.vcd");
        $dumpvars(0, spi_wb_integration_tb);
        
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
        // Test 1: Read Version register @ 0x0000
        // Expected: 0xDEADBEEF
        // =======================================================
        $display("\n=== Test 1: Read Version Register @ 0x0000 ===");
        // Frame: [A1][04 00][00 00 00 00][55 55 55 55][DA]
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
        
        spi_transaction(12);
        
        // Response: [DA][21][04 00][00 00 00 00][EF BE AD DE]
        // Data starts at byte 8
        begin
            reg [31:0] version;
            version = {spi_rx_buf[11], spi_rx_buf[10], spi_rx_buf[9], spi_rx_buf[8]};
            $display("[TEST1] RX[0]=0x%02x (expect DA), RX[1]=0x%02x (expect 21)", 
                     spi_rx_buf[0], spi_rx_buf[1]);
            $display("[TEST1] Data bytes [8..11]: %02x %02x %02x %02x", 
                     spi_rx_buf[8], spi_rx_buf[9], spi_rx_buf[10], spi_rx_buf[11]);
            $display("[TEST1] Version: expected=0xDEADBEEF got=0x%08x", version);
            
            if (version == 32'hDEADBEEF) begin
                $display("[TEST1] PASS");
                pass_count = pass_count + 1;
            end else begin
                $display("[TEST1] FAIL");
                fail_count = fail_count + 1;
            end
        end
        
        #(CLK_PERIOD * 20);
        
        // =======================================================
        // Test 2: Write LED register @ 0x0100
        // Write 0x0000000F (all 4 LEDs on)
        // =======================================================
        $display("\n=== Test 2: Write LED Register @ 0x0100 ===");
        // Frame: [A2][04 00][00 01 00 00][0F 00 00 00][DA]
        spi_tx_buf[0]  = 8'hA2;  // Write command
        spi_tx_buf[1]  = 8'h04;  // Length LSB
        spi_tx_buf[2]  = 8'h00;  // Length MSB
        spi_tx_buf[3]  = 8'h00;  // Addr[0] = 0x00
        spi_tx_buf[4]  = 8'h01;  // Addr[1] = 0x01 -> 0x0100
        spi_tx_buf[5]  = 8'h00;  // Addr[2]
        spi_tx_buf[6]  = 8'h00;  // Addr[3]
        spi_tx_buf[7]  = 8'h0F;  // Data[0] = 0x0F (all LEDs on)
        spi_tx_buf[8]  = 8'h00;  // Data[1]
        spi_tx_buf[9]  = 8'h00;  // Data[2]
        spi_tx_buf[10] = 8'h00;  // Data[3]
        spi_tx_buf[11] = 8'hDA;  // Sync
        
        spi_transaction(12);
        
        $display("[TEST2] RX[0]=0x%02x (expect DA), RX[1]=0x%02x (expect 22)", 
                 spi_rx_buf[0], spi_rx_buf[1]);
        $display("[TEST2] LED output = 0x%x (expect 0xF)", led_out);
        
        if (led_out == 4'hF) begin
            $display("[TEST2] PASS - LEDs set correctly");
            pass_count = pass_count + 1;
        end else begin
            $display("[TEST2] FAIL - LED output mismatch");
            fail_count = fail_count + 1;
        end
        
        #(CLK_PERIOD * 20);
        
        // =======================================================
        // Test 3: Read LED register @ 0x0100
        // Expected: 0x0000000F
        // =======================================================
        $display("\n=== Test 3: Read LED Register @ 0x0100 ===");
        // Frame: [A1][04 00][00 01 00 00][55 55 55 55][DA]
        spi_tx_buf[0]  = 8'hA1;  // Read command
        spi_tx_buf[1]  = 8'h04;  // Length LSB
        spi_tx_buf[2]  = 8'h00;  // Length MSB
        spi_tx_buf[3]  = 8'h00;  // Addr[0]
        spi_tx_buf[4]  = 8'h01;  // Addr[1] = 0x01 -> 0x0100
        spi_tx_buf[5]  = 8'h00;  // Addr[2]
        spi_tx_buf[6]  = 8'h00;  // Addr[3]
        spi_tx_buf[7]  = 8'h55;  // Pad 0
        spi_tx_buf[8]  = 8'h55;  // Pad 1
        spi_tx_buf[9]  = 8'h55;  // Pad 2
        spi_tx_buf[10] = 8'h55;  // Pad 3
        spi_tx_buf[11] = 8'hDA;  // Sync
        
        spi_transaction(12);
        
        begin
            reg [31:0] led_val;
            led_val = {spi_rx_buf[11], spi_rx_buf[10], spi_rx_buf[9], spi_rx_buf[8]};
            $display("[TEST3] RX[0]=0x%02x (expect DA), RX[1]=0x%02x (expect 21)", 
                     spi_rx_buf[0], spi_rx_buf[1]);
            $display("[TEST3] Data bytes [8..11]: %02x %02x %02x %02x", 
                     spi_rx_buf[8], spi_rx_buf[9], spi_rx_buf[10], spi_rx_buf[11]);
            $display("[TEST3] LED readback: expected=0x0000000F got=0x%08x", led_val);
            
            if (led_val == 32'h0000000F) begin
                $display("[TEST3] PASS");
                pass_count = pass_count + 1;
            end else begin
                $display("[TEST3] FAIL");
                fail_count = fail_count + 1;
            end
        end
        
        // =======================================================
        // Summary
        // =======================================================
        #(CLK_PERIOD * 20);
        $display("\n=== Test Summary ===");
        $display("PASSED: %0d", pass_count);
        $display("FAILED: %0d", fail_count);
        
        if (fail_count == 0) begin
            $display("\n*** ALL TESTS PASSED ***\n");
        end else begin
            $display("\n*** SOME TESTS FAILED ***\n");
        end
        
        $finish;
    end

endmodule
