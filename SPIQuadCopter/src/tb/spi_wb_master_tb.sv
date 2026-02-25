/**
 * Testbench for SPI to Wishbone Master
 * 
 * Tests:
 * 1. Single word read
 * 2. Single word write
 * 3. Burst read (multiple words)
 */

`timescale 1ns / 1ps

module spi_wb_master_tb;

    // Clock period (72 MHz = ~13.9ns, use 14ns)
    localparam CLK_PERIOD = 14;
    // SPI clock period (10 MHz = 100ns)
    localparam SPI_CLK_PERIOD = 100;
    
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
    
    // Wishbone signals
    logic [31:0] wb_adr;
    logic [31:0] wb_dat_wr;
    logic [31:0] wb_dat_rd;
    logic        wb_we;
    logic [3:0]  wb_sel;
    logic        wb_stb;
    logic        wb_ack;
    logic        wb_err;
    logic        wb_cyc;
    logic        busy;
    
    // Test memory (simple WB slave)
    logic [31:0] test_mem [0:255];
    
    // Fixed-size buffers for SPI transactions (max 64 bytes)
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
        .o_cs_n_sync()
    );
    
    // DUT: SPI to Wishbone Master
    spi_wb_master #(
        .WB_ADDR_WIDTH(32),
        .WB_DATA_WIDTH(32)
    ) u_dut (
        .clk(clk),
        .rst(rst),
        .spi_rx_valid(spi_rx_valid),
        .spi_rx_data(spi_rx_data),
        .spi_tx_valid(spi_tx_valid),
        .spi_tx_data(spi_tx_data),
        .spi_tx_ready(spi_tx_ready),
        .spi_cs_n(spi_cs_n),
        .wb_adr_o(wb_adr),
        .wb_dat_o(wb_dat_wr),
        .wb_dat_i(wb_dat_rd),
        .wb_we_o(wb_we),
        .wb_sel_o(wb_sel),
        .wb_stb_o(wb_stb),
        .wb_ack_i(wb_ack),
        .wb_err_i(wb_err),
        .wb_cyc_o(wb_cyc),
        .busy(busy)
    );
    
    // Simple Wishbone slave (memory)
    always @(posedge clk) begin
        if (rst) begin
            wb_ack <= 1'b0;
            wb_err <= 1'b0;
            wb_dat_rd <= 32'h0;
        end else begin
            wb_ack <= 1'b0;
            wb_err <= 1'b0;
            
            if (wb_stb && wb_cyc && !wb_ack) begin
                wb_ack <= 1'b1;
                if (wb_we) begin
                    // Write
                    test_mem[wb_adr[9:2]] <= wb_dat_wr;
                    $display("[WB] Write: addr=0x%08x data=0x%08x", wb_adr, wb_dat_wr);
                end else begin
                    // Read
                    wb_dat_rd <= test_mem[wb_adr[9:2]];
                    $display("[WB] Read: addr=0x%08x data=0x%08x", wb_adr, test_mem[wb_adr[9:2]]);
                end
            end
        end
    end
    
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
    
    // SPI transaction task - uses module-level buffers
    // Reads spi_tx_buf[0..spi_buf_len-1], writes to spi_rx_buf[0..spi_buf_len-1]
    task spi_transaction();
        integer i;
        logic [7:0] rx_byte;
        begin
            $display("[SPI] Starting transaction, %0d bytes", spi_buf_len);
            spi_cs_n = 1'b0;
            #(SPI_CLK_PERIOD);
            
            for (i = 0; i < spi_buf_len; i = i + 1) begin
                spi_byte(spi_tx_buf[i], rx_byte);
                spi_rx_buf[i] = rx_byte;
                $display("[SPI] TX: 0x%02x RX: 0x%02x", spi_tx_buf[i], rx_byte);
            end
            
            #(SPI_CLK_PERIOD);
            spi_cs_n = 1'b1;
            #(SPI_CLK_PERIOD * 2);
        end
    endtask
    
    // Helper: Setup read command in spi_tx_buf
    // NEW Format: cmd(1) + len(2,LE) + addr(4,LE) + pad(len,0x55) + DA
    task setup_read_cmd(input [31:0] addr, input [15:0] len);
        integer i;
        begin
            spi_tx_buf[0] = 8'hA1;           // Read command
            spi_tx_buf[1] = len[7:0];        // Len LE
            spi_tx_buf[2] = len[15:8];
            spi_tx_buf[3] = addr[7:0];       // Addr LE
            spi_tx_buf[4] = addr[15:8];
            spi_tx_buf[5] = addr[23:16];
            spi_tx_buf[6] = addr[31:24];
            // Pad bytes (0x55) for receiving data
            for (i = 0; i < len; i = i + 1)
                spi_tx_buf[7 + i] = 8'h55;
            // DA terminator
            spi_tx_buf[7 + len] = 8'hDA;
            spi_buf_len = 8 + len;
        end
    endtask
    
    // Helper: Setup write command in spi_tx_buf
    // NEW Format: cmd(1) + len(2,LE) + addr(4,LE) + data(len) + DA
    task setup_write_cmd(input [31:0] addr, input [7:0] d0, input [7:0] d1, 
                         input [7:0] d2, input [7:0] d3);
        begin
            spi_tx_buf[0] = 8'hA2;           // Write command
            spi_tx_buf[1] = 8'h04;           // Len = 4 bytes (LE)
            spi_tx_buf[2] = 8'h00;
            spi_tx_buf[3] = addr[7:0];       // Addr LE
            spi_tx_buf[4] = addr[15:8];
            spi_tx_buf[5] = addr[23:16];
            spi_tx_buf[6] = addr[31:24];
            spi_tx_buf[7] = d0;              // Data LE
            spi_tx_buf[8] = d1;
            spi_tx_buf[9] = d2;
            spi_tx_buf[10] = d3;
            spi_tx_buf[11] = 8'hDA;          // DA terminator
            spi_buf_len = 12;
        end
    endtask
    
    // Main test
    initial begin
        $dumpfile("spi_wb_master_tb.vcd");
        $dumpvars(0, spi_wb_master_tb);
        
        // Initialize
        pass_count = 0;
        fail_count = 0;
        rst = 1'b1;
        spi_cs_n = 1'b1;
        spi_sclk = 1'b0;
        spi_mosi = 1'b0;
        
        // Initialize test memory with known pattern
        for (integer i = 0; i < 256; i = i + 1)
            test_mem[i] = 32'hDEAD0000 + i;
        
        // Wait for reset
        #(CLK_PERIOD * 10);
        rst = 1'b0;
        #(CLK_PERIOD * 10);
        
        // =====================================================
        // Test 1: Single word read from address 0x100
        // =====================================================
        $display("\n=== Test 1: Single Word Read ===");
        setup_read_cmd(32'h00000100, 16'd4);  // Read 4 bytes
        spi_transaction();
        
        // Verify protocol bytes
        $display("[TEST1] RX[0]=0x%02x (expect DA), RX[1]=0x%02x (expect 21)", 
                 spi_rx_buf[0], spi_rx_buf[1]);
        $display("[TEST1] RX bytes [8..11]: %02x %02x %02x %02x", 
                 spi_rx_buf[8], spi_rx_buf[9], spi_rx_buf[10], spi_rx_buf[11]);
        
        // Memory[0x100>>2] = Memory[0x40] = 0xDEAD0040
        // Expected data LE: 0x40, 0x00, 0xAD, 0xDE
        begin
            logic [31:0] expected_val;
            logic [31:0] read_val;
            logic proto_ok;
            expected_val = test_mem[32'h40];
            read_val = {spi_rx_buf[11], spi_rx_buf[10], spi_rx_buf[9], spi_rx_buf[8]};
            proto_ok = (spi_rx_buf[0] == 8'hDA) && (spi_rx_buf[1] == 8'h21);
            $display("[TEST1] Expected: 0x%08x, Got: 0x%08x", expected_val, read_val);
            if (read_val == expected_val && proto_ok) begin
                $display("[TEST1] PASS");
                pass_count = pass_count + 1;
            end else begin
                $display("[TEST1] FAIL");
                fail_count = fail_count + 1;
            end
        end
        
        #(CLK_PERIOD * 20);
        
        // =====================================================
        // Test 2: Single word write to address 0x200
        // =====================================================
        $display("\n=== Test 2: Single Word Write ===");
        // Write 0xDEADBEEF to address 0x200
        // Data LE: 0xEF, 0xBE, 0xAD, 0xDE
        setup_write_cmd(32'h00000200, 8'hEF, 8'hBE, 8'hAD, 8'hDE);
        spi_transaction();
        
        // Verify protocol bytes
        $display("[TEST2] RX[0]=0x%02x (expect DA), RX[1]=0x%02x (expect 22)", 
                 spi_rx_buf[0], spi_rx_buf[1]);
        $display("[TEST2] RX[8..11]=0x%02x %02x %02x %02x (expect EE EE EE EE)", 
                 spi_rx_buf[8], spi_rx_buf[9], spi_rx_buf[10], spi_rx_buf[11]);
        
        // Verify memory was written
        #(CLK_PERIOD * 10);
        begin
            logic proto_ok, ack_ok, mem_ok;
            proto_ok = (spi_rx_buf[0] == 8'hDA) && (spi_rx_buf[1] == 8'h22);
            ack_ok = (spi_rx_buf[8] == 8'hEE) && (spi_rx_buf[9] == 8'hEE) && 
                     (spi_rx_buf[10] == 8'hEE) && (spi_rx_buf[11] == 8'hEE);
            mem_ok = (test_mem[32'h200 >> 2] == 32'hDEADBEEF);
            
            if (proto_ok && ack_ok && mem_ok) begin
                $display("[TEST2] PASS - Memory written correctly");
                pass_count = pass_count + 1;
            end else begin
                if (!proto_ok) $display("[TEST2] FAIL - Protocol bytes wrong");
                if (!ack_ok) $display("[TEST2] FAIL - Write ack pattern wrong");
                if (!mem_ok) $display("[TEST2] FAIL - Expected 0xDEADBEEF, got 0x%08x", test_mem[32'h200 >> 2]);
                fail_count = fail_count + 1;
            end
        end
        
        #(CLK_PERIOD * 20);
        
        // =====================================================
        // Test 3: Burst Read (2 words = 8 bytes)
        // =====================================================
        $display("\n=== Test 3: Burst Read (2 words) ===");
        setup_read_cmd(32'h00000100, 16'd8);  // Read 8 bytes
        spi_transaction();
        
        // Check data - first word at mem[0x40], second at mem[0x41]
        begin
            logic [31:0] word0, word1;
            logic [31:0] exp0, exp1;
            exp0 = test_mem[32'h40];  // 0xDEAD0040
            exp1 = test_mem[32'h41];  // 0xDEAD0041
            word0 = {spi_rx_buf[11], spi_rx_buf[10], spi_rx_buf[9], spi_rx_buf[8]};
            word1 = {spi_rx_buf[15], spi_rx_buf[14], spi_rx_buf[13], spi_rx_buf[12]};
            
            $display("[TEST3] Word0: expected=0x%08x got=0x%08x", exp0, word0);
            $display("[TEST3] Word1: expected=0x%08x got=0x%08x", exp1, word1);
            
            if (word0 == exp0 && word1 == exp1) begin
                $display("[TEST3] PASS");
                pass_count = pass_count + 1;
            end else begin
                $display("[TEST3] FAIL");
                fail_count = fail_count + 1;
            end
        end
        
        #(CLK_PERIOD * 20);
        
        // =====================================================
        // Test 4: Invalid Command (stays in sync, echoes DA)
        // =====================================================
        $display("\n=== Test 4: Invalid Command ===");
        // Send invalid command 0xBB - slave stays in sync mode
        spi_tx_buf[0] = 8'hBB;  // Invalid command
        spi_tx_buf[1] = 8'h00;
        spi_tx_buf[2] = 8'h00;
        spi_buf_len = 3;
        spi_transaction();
        
        $display("[TEST4] RX[0]=0x%02x (expect DA), RX[1]=0x%02x (expect DA)", 
                 spi_rx_buf[0], spi_rx_buf[1]);
        
        if (spi_rx_buf[0] == 8'hDA && spi_rx_buf[1] == 8'hDA) begin
            $display("[TEST4] PASS - Invalid command ignored, stays in sync");
            pass_count = pass_count + 1;
        end else begin
            $display("[TEST4] FAIL - Expected DA DA");
            fail_count = fail_count + 1;
        end
        
        #(CLK_PERIOD * 20);
        
        // =====================================================
        // Summary
        // =====================================================
        $display("\n=== Test Summary ===");
        $display("PASSED: %0d", pass_count);
        $display("FAILED: %0d", fail_count);
        
        if (fail_count == 0)
            $display("\n*** ALL TESTS PASSED ***\n");
        else
            $display("\n*** SOME TESTS FAILED ***\n");
        
        $finish;
    end
    
    // Timeout watchdog
    initial begin
        #(1000000);  // 1ms timeout
        $display("ERROR: Simulation timeout!");
        $finish;
    end

endmodule
