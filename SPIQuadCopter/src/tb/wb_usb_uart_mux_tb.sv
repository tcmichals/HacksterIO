// Testbench for wb_usb_uart WITH wb_mux_6 - simulates SERV behavior
// Tests the registered data path issue
`timescale 1ns / 1ps

module wb_usb_uart_mux_tb;

    // Parameters
    localparam CLK_FREQ = 54_000_000;
    localparam BAUD = 115200;
    localparam CLK_PERIOD = 18.5;  // ~54MHz
    localparam BIT_PERIOD = 1_000_000_000 / BAUD;  // ns per bit

    reg clk = 0;
    reg rst = 1;
    
    // Master Wishbone interface (like SERV)
    reg  [31:0] wbm_adr;
    reg  [31:0] wbm_dat_o;
    wire [31:0] wbm_dat_i;
    reg         wbm_we;
    reg         wbm_stb;
    reg         wbm_cyc;
    wire        wbm_ack;
    reg  [3:0]  wbm_sel;
    
    // UART pins
    reg         uart_rx = 1;  // Idle high
    wire        uart_tx;
    
    // Slave 3 signals (USB UART at 0x40000800)
    wire [31:0] wbs3_adr;
    wire [31:0] wbs3_dat_i;  // slave -> mux
    wire [31:0] wbs3_dat_o;  // mux -> slave
    wire        wbs3_we;
    wire        wbs3_stb;
    wire        wbs3_ack;
    wire [3:0]  wbs3_sel;
    wire        wbs3_cyc;

    // Instantiate the mux (only using slave 3)
    wb_mux_6 #(
        .DATA_WIDTH(32),
        .ADDR_WIDTH(32),
        .SELECT_WIDTH(4)
    ) u_mux (
        .clk(clk),
        .rst(rst),
        
        // Master
        .wbm_adr_i(wbm_adr),
        .wbm_dat_i(wbm_dat_o),
        .wbm_dat_o(wbm_dat_i),
        .wbm_we_i(wbm_we),
        .wbm_sel_i(wbm_sel),
        .wbm_stb_i(wbm_stb),
        .wbm_ack_o(wbm_ack),
        .wbm_err_o(),
        .wbm_rty_o(),
        .wbm_cyc_i(wbm_cyc),
        
        // Slave 0, 1, 2 - unused, tie off
        .wbs0_addr(32'h00000000), .wbs0_addr_msk(32'hFFFFFF00),
        .wbs0_adr_o(), .wbs0_dat_i(32'h0), .wbs0_dat_o(), .wbs0_we_o(),
        .wbs0_sel_o(), .wbs0_stb_o(), .wbs0_ack_i(1'b0), .wbs0_err_i(1'b0),
        .wbs0_rty_i(1'b0), .wbs0_cyc_o(),
        
        .wbs1_addr(32'h10000000), .wbs1_addr_msk(32'hFFFFFF00),
        .wbs1_adr_o(), .wbs1_dat_i(32'h0), .wbs1_dat_o(), .wbs1_we_o(),
        .wbs1_sel_o(), .wbs1_stb_o(), .wbs1_ack_i(1'b0), .wbs1_err_i(1'b0),
        .wbs1_rty_i(1'b0), .wbs1_cyc_o(),
        
        .wbs2_addr(32'h20000000), .wbs2_addr_msk(32'hFFFFFF00),
        .wbs2_adr_o(), .wbs2_dat_i(32'h0), .wbs2_dat_o(), .wbs2_we_o(),
        .wbs2_sel_o(), .wbs2_stb_o(), .wbs2_ack_i(1'b0), .wbs2_err_i(1'b0),
        .wbs2_rty_i(1'b0), .wbs2_cyc_o(),
        
        // Slave 3 - USB UART at 0x40000800
        .wbs3_addr(32'h40000800), .wbs3_addr_msk(32'hFFFFFF00),
        .wbs3_adr_o(wbs3_adr), .wbs3_dat_i(wbs3_dat_i), .wbs3_dat_o(wbs3_dat_o),
        .wbs3_we_o(wbs3_we), .wbs3_sel_o(wbs3_sel), .wbs3_stb_o(wbs3_stb),
        .wbs3_ack_i(wbs3_ack), .wbs3_err_i(1'b0), .wbs3_rty_i(1'b0), .wbs3_cyc_o(wbs3_cyc),
        
        // Slave 4, 5 - unused
        .wbs4_addr(32'h50000000), .wbs4_addr_msk(32'hFFFFFF00),
        .wbs4_adr_o(), .wbs4_dat_i(32'h0), .wbs4_dat_o(), .wbs4_we_o(),
        .wbs4_sel_o(), .wbs4_stb_o(), .wbs4_ack_i(1'b0), .wbs4_err_i(1'b0),
        .wbs4_rty_i(1'b0), .wbs4_cyc_o(),
        
        .wbs5_addr(32'h60000000), .wbs5_addr_msk(32'hFFFFFF00),
        .wbs5_adr_o(), .wbs5_dat_i(32'h0), .wbs5_dat_o(), .wbs5_we_o(),
        .wbs5_sel_o(), .wbs5_stb_o(), .wbs5_ack_i(1'b0), .wbs5_err_i(1'b0),
        .wbs5_rty_i(1'b0), .wbs5_cyc_o()
    );

    // USB UART
    wb_usb_uart #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD(BAUD)
    ) u_uart (
        .clk(clk),
        .rst(rst),
        .wb_adr_i(wbs3_adr),
        .wb_dat_i(wbs3_dat_o),
        .wb_dat_o(wbs3_dat_i),
        .wb_we_i(wbs3_we),
        .wb_stb_i(wbs3_stb),
        .wb_ack_o(wbs3_ack),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx)
    );

    // Clock generation
    always #(CLK_PERIOD/2) clk = ~clk;

    // Register addresses
    localparam ADDR_TX_DATA = 32'h40000800;
    localparam ADDR_STATUS  = 32'h40000804;
    localparam ADDR_RX_DATA = 32'h40000808;

    // SERV-like Wishbone read: holds stb until ack, samples data on ack
    task serv_wb_read(input [31:0] addr, output [31:0] data);
        integer cycle_count;
        begin
            cycle_count = 0;
            @(posedge clk);
            wbm_adr <= addr;
            wbm_we <= 0;
            wbm_stb <= 1;
            wbm_cyc <= 1;
            wbm_sel <= 4'hF;
            
            // Wait for ACK like SERV does
            while (!wbm_ack) begin
                @(posedge clk);
                cycle_count = cycle_count + 1;
                if (cycle_count > 100) begin
                    $display("TIMEOUT waiting for ACK on read!");
                    $finish;
                end
            end
            
            // Sample data on same cycle as ACK (this is what SERV does)
            data = wbm_dat_i;
            $display("Read 0x%08x from addr 0x%08x (cycles=%0d)", data, addr, cycle_count);
            
            // Deassert
            wbm_stb <= 0;
            wbm_cyc <= 0;
            @(posedge clk);
        end
    endtask

    // SERV-like Wishbone write
    task serv_wb_write(input [31:0] addr, input [31:0] data);
        integer cycle_count;
        begin
            cycle_count = 0;
            @(posedge clk);
            wbm_adr <= addr;
            wbm_dat_o <= data;
            wbm_we <= 1;
            wbm_stb <= 1;
            wbm_cyc <= 1;
            wbm_sel <= 4'hF;
            
            while (!wbm_ack) begin
                @(posedge clk);
                cycle_count = cycle_count + 1;
                if (cycle_count > 100) begin
                    $display("TIMEOUT waiting for ACK on write!");
                    $finish;
                end
            end
            
            $display("Wrote 0x%08x to addr 0x%08x (cycles=%0d)", data, addr, cycle_count);
            
            wbm_stb <= 0;
            wbm_cyc <= 0;
            wbm_we <= 0;
            @(posedge clk);
        end
    endtask

    // Wait for TX ready
    task wait_tx_ready;
        reg [31:0] status;
        integer polls;
        begin
            polls = 0;
            status = 0;
            while (!(status & 32'h1)) begin
                serv_wb_read(ADDR_STATUS, status);
                polls = polls + 1;
                if (polls > 10000) begin
                    $display("TIMEOUT waiting for TX_READY!");
                    $finish;
                end
            end
            $display("TX_READY after %0d polls", polls);
        end
    endtask

    // Send byte
    task send_byte(input [7:0] data);
        begin
            wait_tx_ready();
            serv_wb_write(ADDR_TX_DATA, {24'b0, data});
        end
    endtask

    // Capture TX byte from uart_tx pin
    reg [7:0] captured_byte;
    integer bit_idx;
    
    task capture_tx_byte;
        begin
            @(negedge uart_tx);
            $display("TX: Start bit at %t", $time);
            #(BIT_PERIOD / 2);
            for (bit_idx = 0; bit_idx < 8; bit_idx = bit_idx + 1) begin
                #BIT_PERIOD;
                captured_byte[bit_idx] = uart_tx;
            end
            #BIT_PERIOD;
            $display("TX: Captured 0x%02x ('%c')", captured_byte, captured_byte);
        end
    endtask

    // Send RX byte via uart_rx pin
    task send_rx_byte(input [7:0] data);
        integer i;
        begin
            $display("RX: Sending 0x%02x ('%c')", data, data);
            uart_rx = 0;  // Start bit
            #BIT_PERIOD;
            for (i = 0; i < 8; i = i + 1) begin
                uart_rx = data[i];
                #BIT_PERIOD;
            end
            uart_rx = 1;  // Stop bit
            #BIT_PERIOD;
        end
    endtask

    // Main test
    initial begin
        $dumpfile("wb_usb_uart_mux_tb.vcd");
        $dumpvars(0, wb_usb_uart_mux_tb);
        
        // Initialize
        wbm_adr = 0;
        wbm_dat_o = 0;
        wbm_we = 0;
        wbm_stb = 0;
        wbm_cyc = 0;
        wbm_sel = 4'hF;
        
        // Reset
        #100;
        rst = 0;
        #100;
        
        $display("");
        $display("=== Testing with wb_mux_6 (like real hardware) ===");
        $display("");
        
        $display("=== TX Test: Send 'OK' ===");
        fork
            begin
                send_byte(8'h4F);  // 'O'
                send_byte(8'h4B);  // 'K'
                $display("Both bytes sent via Wishbone");
            end
            begin
                capture_tx_byte();
                capture_tx_byte();
            end
        join
        
        #(BIT_PERIOD * 2);
        
        $display("");
        $display("=== RX Test: Receive 'AB' ===");
        
        send_rx_byte(8'h41);  // 'A'
        #BIT_PERIOD;
        send_rx_byte(8'h42);  // 'B'
        #(BIT_PERIOD * 2);
        
        // Read them back
        begin
            reg [31:0] status, rx_data;
            
            serv_wb_read(ADDR_STATUS, status);
            $display("STATUS = 0x%08x (RX_VALID=%b)", status, status[1]);
            
            if (status[1]) begin
                serv_wb_read(ADDR_RX_DATA, rx_data);
                if (rx_data[7:0] == 8'h41)
                    $display("PASS: Got 'A' (0x41)");
                else
                    $display("FAIL: Expected 'A' (0x41), got 0x%02x", rx_data[7:0]);
            end else begin
                $display("FAIL: RX_VALID not set!");
            end
            
            serv_wb_read(ADDR_STATUS, status);
            if (status[1]) begin
                serv_wb_read(ADDR_RX_DATA, rx_data);
                if (rx_data[7:0] == 8'h42)
                    $display("PASS: Got 'B' (0x42)");
                else
                    $display("FAIL: Expected 'B' (0x42), got 0x%02x", rx_data[7:0]);
            end else begin
                $display("FAIL: Second byte missing!");
            end
            
            // Should be empty
            serv_wb_read(ADDR_STATUS, status);
            if (!status[1])
                $display("PASS: FIFO empty as expected");
            else
                $display("FAIL: FIFO should be empty");
        end
        
        $display("");
        $display("=== Test Complete ===");
        $finish;
    end

    // Timeout
    initial begin
        #(BIT_PERIOD * 300);
        $display("TIMEOUT!");
        $finish;
    end

endmodule
