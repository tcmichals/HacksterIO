// Testbench for wb_usb_uart TX functionality
`timescale 1ns / 1ps

module wb_usb_uart_tb;

    // Parameters - faster baud for quicker simulation
    localparam CLK_FREQ = 54_000_000;
    localparam BAUD = 115200;
    localparam CLK_PERIOD = 18.5;  // ~54MHz
    localparam BIT_PERIOD = 1_000_000_000 / BAUD;  // ns per bit

    reg clk = 0;
    reg rst = 1;
    
    // Wishbone interface
    reg  [31:0] wb_adr_i;
    reg  [31:0] wb_dat_i;
    wire [31:0] wb_dat_o;
    reg         wb_we_i;
    reg         wb_stb_i;
    wire        wb_ack_o;
    
    // UART pins
    reg         uart_rx = 1;  // Idle high
    wire        uart_tx;

    // DUT
    wb_usb_uart #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD(BAUD)
    ) dut (
        .clk(clk),
        .rst(rst),
        .wb_adr_i(wb_adr_i),
        .wb_dat_i(wb_dat_i),
        .wb_dat_o(wb_dat_o),
        .wb_we_i(wb_we_i),
        .wb_stb_i(wb_stb_i),
        .wb_ack_o(wb_ack_o),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx)
    );

    // Clock generation
    always #(CLK_PERIOD/2) clk = ~clk;

    // Register addresses
    localparam REG_TX_DATA = 32'h0;
    localparam REG_STATUS  = 32'h4;
    localparam REG_RX_DATA = 32'h8;

    // Wishbone read task
    task wb_read(input [31:0] addr, output [31:0] data);
        begin
            @(posedge clk);
            wb_adr_i <= addr;
            wb_we_i <= 0;
            wb_stb_i <= 1;
            @(posedge clk);
            while (!wb_ack_o) @(posedge clk);
            data = wb_dat_o;
            wb_stb_i <= 0;
            @(posedge clk);
        end
    endtask

    // Wishbone write task
    task wb_write(input [31:0] addr, input [31:0] data);
        begin
            @(posedge clk);
            wb_adr_i <= addr;
            wb_dat_i <= data;
            wb_we_i <= 1;
            wb_stb_i <= 1;
            @(posedge clk);
            while (!wb_ack_o) @(posedge clk);
            wb_stb_i <= 0;
            wb_we_i <= 0;
            @(posedge clk);
        end
    endtask

    // Wait for TX ready
    task wait_tx_ready;
        reg [31:0] status;
        integer wait_count;
        begin
            status = 0;
            wait_count = 0;
            while (!(status & 32'h1)) begin
                wb_read(REG_STATUS, status);
                wait_count = wait_count + 1;
                if (wait_count % 1000 == 0)
                    $display("Waiting for TX_READY... (polls=%0d)", wait_count);
            end
            $display("TX_READY after %0d polls", wait_count);
        end
    endtask

    // Send a byte (mimics firmware)
    task send_byte(input [7:0] data);
        begin
            wait_tx_ready();
            wb_write(REG_TX_DATA, {24'b0, data});
            $display("Wrote byte 0x%02x ('%c')", data, data);
        end
    endtask

    // Capture TX output
    reg [7:0] captured_byte;
    integer bit_idx;
    
    task capture_tx_byte;
        begin
            // Wait for start bit (high to low)
            @(negedge uart_tx);
            $display("Start bit detected at %t", $time);
            
            // Wait half bit time to sample in middle
            #(BIT_PERIOD / 2);
            
            // Sample 8 data bits
            for (bit_idx = 0; bit_idx < 8; bit_idx = bit_idx + 1) begin
                #BIT_PERIOD;
                captured_byte[bit_idx] = uart_tx;
            end
            
            // Wait for stop bit
            #BIT_PERIOD;
            
            $display("Captured byte: 0x%02x ('%c')", captured_byte, captured_byte);
        end
    endtask

    // Send a byte via uart_rx (simulate external device sending to FPGA)
    task send_rx_byte(input [7:0] data);
        integer i;
        begin
            $display("RX: Sending 0x%02x ('%c')", data, data);
            // Start bit
            uart_rx = 0;
            #BIT_PERIOD;
            // Data bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                uart_rx = data[i];
                #BIT_PERIOD;
            end
            // Stop bit
            uart_rx = 1;
            #BIT_PERIOD;
        end
    endtask

    // Read RX byte via Wishbone
    task read_rx_byte(output [7:0] data, output logic valid);
        reg [31:0] status;
        reg [31:0] rx_data_reg;
        begin
            wb_read(REG_STATUS, status);
            valid = status[1];  // RX_VALID
            if (valid) begin
                wb_read(REG_RX_DATA, rx_data_reg);
                data = rx_data_reg[7:0];
                $display("RX: Read 0x%02x ('%c')", data, data);
            end else begin
                data = 8'h00;
                $display("RX: No data available (STATUS=0x%02x)", status);
            end
        end
    endtask

    // Main test
    initial begin
        $dumpfile("wb_usb_uart_tb.vcd");
        $dumpvars(0, wb_usb_uart_tb);
        
        // Initialize
        wb_adr_i = 0;
        wb_dat_i = 0;
        wb_we_i = 0;
        wb_stb_i = 0;
        
        // Reset
        #100;
        rst = 0;
        #100;
        
        // Debug: print internal TX signals
        $display("After reset:");
        $display("  tx_ready=%b, tx_busy=%b, tx_can_write=%b", 
                 dut.tx_ready, dut.tx_busy, dut.tx_can_write);
        $display("  uart_tx s_axis_tready=%b, busy=%b", 
                 dut.u_uart_tx.s_axis_tready, dut.u_uart_tx.busy);
        
        // Wait a few more cycles
        repeat(10) @(posedge clk);
        
        $display("After 10 more clocks:");
        $display("  tx_ready=%b, tx_busy=%b, tx_can_write=%b", 
                 dut.tx_ready, dut.tx_busy, dut.tx_can_write);
        
        $display("=== Testing TX: Send 'OK\\r\\n' ===");
        
        // Send "OK\r\n" like the firmware does
        fork
            begin
                send_byte(8'h4F);  // 'O'
                send_byte(8'h4B);  // 'K'
                send_byte(8'h0D);  // '\r'
                send_byte(8'h0A);  // '\n'
                $display("All bytes sent to UART");
            end
            begin
                capture_tx_byte();  // Capture 'O'
                capture_tx_byte();  // Capture 'K'
                capture_tx_byte();  // Capture '\r'
                capture_tx_byte();  // Capture '\n'
            end
        join
        
        #(BIT_PERIOD * 2);
        
        $display("");
        $display("=== Testing RX: Receive '$M<' ===");
        
        // Send some bytes via uart_rx
        send_rx_byte(8'h24);  // '$'
        #(BIT_PERIOD);  // Small gap
        
        send_rx_byte(8'h4D);  // 'M'
        #(BIT_PERIOD);
        
        send_rx_byte(8'h3C);  // '<'
        #(BIT_PERIOD);
        
        // Now read them back
        $display("Reading RX bytes...");
        begin
            reg [7:0] rx_byte;
            logic rx_valid;
            
            read_rx_byte(rx_byte, rx_valid);
            if (rx_valid && rx_byte == 8'h24)
                $display("PASS: Got '$'");
            else
                $display("FAIL: Expected '$' (0x24), got 0x%02x, valid=%b", rx_byte, rx_valid);
            
            read_rx_byte(rx_byte, rx_valid);
            if (rx_valid && rx_byte == 8'h4D)
                $display("PASS: Got 'M'");
            else
                $display("FAIL: Expected 'M' (0x4D), got 0x%02x, valid=%b", rx_byte, rx_valid);
            
            read_rx_byte(rx_byte, rx_valid);
            if (rx_valid && rx_byte == 8'h3C)
                $display("PASS: Got '<'");
            else
                $display("FAIL: Expected '<' (0x3C), got 0x%02x, valid=%b", rx_byte, rx_valid);
            
            // Should be empty now
            read_rx_byte(rx_byte, rx_valid);
            if (!rx_valid)
                $display("PASS: FIFO empty as expected");
            else
                $display("FAIL: FIFO should be empty, got 0x%02x", rx_byte);
        end
        
        $display("");
        $display("=== Test Complete ===");
        $finish;
    end

    // Timeout - 500 bit periods should be plenty for 4 bytes
    initial begin
        #(BIT_PERIOD * 500);
        $display("TIMEOUT!");
        $finish;
    end

endmodule
