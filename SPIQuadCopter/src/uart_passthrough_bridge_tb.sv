/**
 * UART Passthrough Bridge Testbench
 *
 * Tests:
 * 1. PC → ESC data flow (USB UART RX to Serial TX)
 * 2. ESC → PC data flow (Serial RX to USB UART TX)
 * 3. Half-duplex switching (tri-state control)
 * 4. Enable/disable functionality
 * 5. Bidirectional conversation (command-response)
 */

`timescale 1ns/1ps

module uart_passthrough_bridge_tb;

    // Clock and reset
    logic clk;
    logic rst;
    
    // USB UART signals (to/from PC)
    logic usb_uart_rx;
    logic usb_uart_tx;
    
    // Half-duplex serial (to/from ESC)
    wire serial;
    
    // Control signals
    logic enable;
    logic active;
    
    // Test signals
    logic serial_drive;        // Simulate ESC driving the line
    logic serial_drive_value;  // Value ESC drives
    
    // Tri-state control for test with weak pullup
    assign (weak1, weak0) serial = 1'b1;  // Weak pullup
    assign serial = serial_drive ? serial_drive_value : 1'bz;
    
    // DUT instantiation
    uart_passthrough_bridge #(
        .CLK_FREQ_HZ(72_000_000),
        .BAUD_RATE(115200)
    ) dut (
        .clk(clk),
        .rst(rst),
        .usb_uart_rx(usb_uart_rx),
        .usb_uart_tx(usb_uart_tx),
        .serial(serial),
        .enable(enable),
        .active(active)
    );
    
    // Clock generation (72 MHz)
    initial begin
        clk = 0;
        forever #6.944 clk = ~clk;  // 72 MHz = 13.888ns period
    end
    
    // UART bit timing at 115200 baud
    localparam BIT_PERIOD = 8680;  // ns (1/115200 = 8.68 us)
    
    // Task to send a byte via USB UART RX (PC to FPGA)
    task automatic send_usb_byte(input logic [7:0] data);
        integer i;
        begin
            $display("[%0t] PC → FPGA: Sending 0x%02X ('%c')", $time, data, data);
            // Start bit
            usb_uart_rx = 0;
            #BIT_PERIOD;
            // Data bits (LSB first)
            for (i = 0; i < 8; i++) begin
                usb_uart_rx = data[i];
                #BIT_PERIOD;
            end
            // Stop bit
            usb_uart_rx = 1;
            #BIT_PERIOD;
        end
    endtask
    
    // Task to send a byte via Serial (ESC to FPGA)
    task automatic send_serial_byte(input logic [7:0] data);
        integer i;
        begin
            $display("[%0t] ESC → FPGA: Sending 0x%02X ('%c')", $time, data, data);
            serial_drive = 1;
            // Start bit
            serial_drive_value = 0;
            #BIT_PERIOD;
            // Data bits (LSB first)
            for (i = 0; i < 8; i++) begin
                serial_drive_value = data[i];
                #BIT_PERIOD;
            end
            // Stop bit
            serial_drive_value = 1;
            #BIT_PERIOD;
            serial_drive = 0;  // Release the line
            #BIT_PERIOD;
        end
    endtask
    
    // Task to receive a byte via USB UART TX (FPGA to PC)
    task automatic receive_usb_byte(output logic [7:0] data);
        integer i;
        begin
            // Wait for start bit
            wait(usb_uart_tx == 0);
            $display("[%0t] FPGA → PC: Start bit detected", $time);
            #(BIT_PERIOD + BIT_PERIOD/2);  // Wait to middle of first data bit
            
            // Read data bits
            for (i = 0; i < 8; i++) begin
                data[i] = usb_uart_tx;
                #BIT_PERIOD;
            end
            
            // Check stop bit
            if (usb_uart_tx !== 1) begin
                $display("[%0t] ERROR: Stop bit not high!", $time);
            end
            
            $display("[%0t] FPGA → PC: Received 0x%02X ('%c')", $time, data, data);
        end
    endtask
    
    // Task to receive a byte via Serial (FPGA to ESC)
    task automatic receive_serial_byte(output logic [7:0] data);
        integer i;
        begin
            // Wait for start bit
            wait(serial == 0);
            $display("[%0t] FPGA → ESC: Start bit detected (serial=%b)", $time, serial);
            #(BIT_PERIOD + BIT_PERIOD/2);  // Wait to middle of first data bit
            
            // Read data bits
            for (i = 0; i < 8; i++) begin
                data[i] = serial;
                $display("[%0t]   Bit %0d: %b (serial=%b)", $time, i, data[i], serial);
                #BIT_PERIOD;
            end
            
            // Check stop bit
            if (serial !== 1) begin
                $display("[%0t] ERROR: Stop bit not high! (serial=%b)", $time, serial);
            end
            
            $display("[%0t] FPGA → ESC: Received 0x%02X ('%c')", $time, data, data);
        end
    endtask
    
    // Main test sequence
    initial begin
        logic [7:0] received_data;
        
        $display("========================================");
        $display("UART Passthrough Bridge Testbench");
        $display("========================================");
        
        // Initialize signals
        rst = 1;
        enable = 0;
        usb_uart_rx = 1;  // UART idle high
        serial_drive = 0;
        serial_drive_value = 1;
        
        // Reset
        #100;
        rst = 0;
        #100;
        
        $display("\n[%0t] TEST 1: Passthrough Disabled", $time);
        $display("----------------------------------------");
        enable = 0;
        #1000;
        send_usb_byte(8'h55);
        #(BIT_PERIOD * 20);
        if (serial === 1'bz) begin
            $display("[%0t] PASS: Serial line is tri-stated when disabled", $time);
        end else begin
            $display("[%0t] FAIL: Serial line should be tri-stated", $time);
        end
        
        $display("\n[%0t] TEST 2: PC → ESC (USB UART to Serial)", $time);
        $display("----------------------------------------");
        enable = 1;
        #1000;
        
        fork
            send_usb_byte(8'h41);  // Send 'A'
            receive_serial_byte(received_data);
        join
        
        if (received_data == 8'h41) begin
            $display("[%0t] PASS: Byte forwarded correctly (0x%02X)", $time, received_data);
        end else begin
            $display("[%0t] FAIL: Expected 0x41, got 0x%02X", $time, received_data);
        end
        
        #(BIT_PERIOD * 10);
        
        $display("\n[%0t] TEST 3: ESC → PC (Serial to USB UART)", $time);
        $display("----------------------------------------");
        
        fork
            send_serial_byte(8'h42);  // Send 'B'
            receive_usb_byte(received_data);
        join
        
        if (received_data == 8'h42) begin
            $display("[%0t] PASS: Byte forwarded correctly (0x%02X)", $time, received_data);
        end else begin
            $display("[%0t] FAIL: Expected 0x42, got 0x%02X", $time, received_data);
        end
        
        #(BIT_PERIOD * 10);
        
        $display("\n[%0t] TEST 4: Bidirectional Conversation (BLHeli-like)", $time);
        $display("----------------------------------------");
        
        // Simulate BLHeli command-response sequence
        $display("[%0t] Simulating BLHeli handshake...", $time);
        
        // PC sends command
        fork
            send_usb_byte(8'h30);  // BLHeli connect command
            receive_serial_byte(received_data);
        join
        
        if (received_data == 8'h30) begin
            $display("[%0t] PASS: Command forwarded to ESC", $time);
        end
        
        #(BIT_PERIOD * 5);
        
        // ESC sends response
        fork
            send_serial_byte(8'hF4);  // BLHeli ACK
            receive_usb_byte(received_data);
        join
        
        if (received_data == 8'hF4) begin
            $display("[%0t] PASS: Response forwarded to PC", $time);
        end
        
        #(BIT_PERIOD * 10);
        
        $display("\n[%0t] TEST 5: Half-Duplex Tri-State Verification", $time);
        $display("----------------------------------------");
        
        // Monitor serial line during transmission
        fork
            begin
                send_usb_byte(8'h58);  // Send 'X'
            end
            begin
                // Check that serial line is driven during TX
                #(BIT_PERIOD * 2);  // Wait past start bit
                if (serial !== 1'bz && serial !== 1'bx) begin
                    $display("[%0t] PASS: Serial line driven during transmission", $time);
                end else begin
                    $display("[%0t] FAIL: Serial line should be driven", $time);
                end
                
                // Wait for transmission to complete
                #(BIT_PERIOD * 10);
                
                // Check that line goes back to tri-state
                if (serial === 1'bz || serial === 1'b1) begin
                    $display("[%0t] PASS: Serial line tri-stated after transmission", $time);
                end else begin
                    $display("[%0t] INFO: Serial line state: %b", $time, serial);
                end
            end
        join
        
        #(BIT_PERIOD * 10);
        
        $display("\n[%0t] TEST 6: Multi-byte Message", $time);
        $display("----------------------------------------");
        
        // Send string "HELLO" from PC to ESC
        $display("[%0t] Sending 'HELLO' from PC...", $time);
        fork
            begin
                send_usb_byte(8'h48);  // 'H'
                send_usb_byte(8'h45);  // 'E'
                send_usb_byte(8'h4C);  // 'L'
                send_usb_byte(8'h4C);  // 'L'
                send_usb_byte(8'h4F);  // 'O'
            end
            begin
                receive_serial_byte(received_data);
                if (received_data == 8'h48) $display("[%0t] Char 1: PASS", $time);
                receive_serial_byte(received_data);
                if (received_data == 8'h45) $display("[%0t] Char 2: PASS", $time);
                receive_serial_byte(received_data);
                if (received_data == 8'h4C) $display("[%0t] Char 3: PASS", $time);
                receive_serial_byte(received_data);
                if (received_data == 8'h4C) $display("[%0t] Char 4: PASS", $time);
                receive_serial_byte(received_data);
                if (received_data == 8'h4F) $display("[%0t] Char 5: PASS", $time);
            end
        join
        
        #(BIT_PERIOD * 10);
        
        $display("\n[%0t] TEST 7: Disable During Operation", $time);
        $display("----------------------------------------");
        
        fork
            begin
                #(BIT_PERIOD * 5);
                $display("[%0t] Disabling passthrough mid-transmission...", $time);
                enable = 0;
            end
            send_usb_byte(8'h99);
        join
        
        #(BIT_PERIOD * 10);
        
        if (serial === 1'bz) begin
            $display("[%0t] PASS: Serial line tri-stated after disable", $time);
        end
        
        // Re-enable
        enable = 1;
        #1000;
        
        $display("\n========================================");
        $display("All Tests Complete!");
        $display("========================================");
        
        #10000;
        $finish;
    end
    
    // Monitor active signal
    always @(active) begin
        $display("[%0t] Active signal: %b", $time, active);
    end
    
    // Timeout watchdog
    initial begin
        #50_000_000;  // 50ms timeout
        $display("\n[%0t] ERROR: Testbench timeout!", $time);
        $finish;
    end
    
    // VCD dump for waveform viewing
    initial begin
        $dumpfile("uart_passthrough_bridge_tb.vcd");
        $dumpvars(0, uart_passthrough_bridge_tb);
        $display("VCD file: uart_passthrough_bridge_tb.vcd");
        $display("GTKWave save file: uart_passthrough_bridge_tb.gtkw");
        $display("View with: gtkwave uart_passthrough_bridge_tb.vcd uart_passthrough_bridge_tb.gtkw");
    end

endmodule
