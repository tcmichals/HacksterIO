/**
 * UART Passthrough Bridge Testbench (Parallel Interface Version)
 *
 * Tests:
 * 1. PC → ESC data flow (Parallel RX to Serial TX)
 * 2. ESC → PC data flow (Serial RX to Parallel TX)
 * 3. Half-duplex switching (tri-state control)
 * 4. Enable/disable functionality
 * 5. Bidirectional conversation (command-response)
 */

`timescale 1ns/1ps

module uart_passthrough_bridge_tb;

    // Timeout variables for MSP IDENT test
    integer timeout_cycles;
    integer cycles;
    reg got_resp;

    // Clock and reset
    logic clk;
    logic rst;
    
    // PC Parallel Interface (to/from shared UART in real design)
    logic [7:0] pc_rx_data;
    logic       pc_rx_valid;
    logic [7:0] pc_tx_data;
    logic       pc_tx_valid;
    logic       pc_tx_ready;
    
    // Half-duplex serial (to/from ESC)
    wire serial;
    
    // Control signals
    logic enable;
    logic active;
    
    // Test signals
    logic serial_drive;        // Simulate ESC driving the line
    logic serial_drive_value;  // Value ESC drives
    
    // Tri-state control with weak pullup (mimics pad)
    assign (weak1, weak0) serial = 1'b1;  // Weak pullup
    assign serial = serial_drive ? serial_drive_value : 1'bz;
    
    // DUT signals
    logic dut_tx_out;
    logic dut_tx_oe;
    logic dut_rx_in;
    
    // Pad emulation
    assign dut_rx_in = serial; 
    assign serial = dut_tx_oe ? dut_tx_out : 1'bz;

    uart_passthrough_bridge #(
        .CLK_FREQ_HZ(72_000_000),
        .SERIAL_BAUD_RATE(19200)
    ) dut (
        .clk(clk),
        .rst(rst),
        .pc_rx_data(pc_rx_data),
        .pc_rx_valid(pc_rx_valid),
        .pc_tx_data(pc_tx_data),
        .pc_tx_valid(pc_tx_valid),
        .pc_tx_ready(pc_tx_ready),
        
        .serial_tx_out(dut_tx_out),
        .serial_tx_oe(dut_tx_oe),
        .serial_rx_in(dut_rx_in),
        
        .ext_serial_tx_data(8'h00),
        .ext_serial_tx_valid(1'b0),
        .ext_serial_tx_ready(),
        .ext_serial_rx_data(),
        .ext_serial_rx_valid(),
        
        .enable(enable),
        .active(active)
    );
    
    // Clock generation (72 MHz)
    initial begin
        clk = 0;
        forever #6.944 clk = ~clk; 
    end
    
    // Serial bit timing at 19200 baud
    localparam BIT_PERIOD_SERIAL = 52083;  // ns 
    
    // Task to send a byte via PC Parallel Interface (simulate UART RX output)
    task automatic send_pc_byte(input logic [7:0] data);
        begin
            $display("[%0t] PC → Bridge: Submitting 0x%02X", $time, data);
            @(posedge clk);
            pc_rx_data = data;
            pc_rx_valid = 1;
            @(posedge clk);
            pc_rx_valid = 0;
            pc_rx_data = 0;
        end
    endtask
    
    // Task to send a byte via Serial (ESC to FPGA)
    task automatic send_serial_byte(input logic [7:0] data);
        integer i;
        begin
            $display("[%0t] ESC → FPGA: Sending 0x%02X", $time, data);
            serial_drive = 1;
            serial_drive_value = 0; // Start bit
            #BIT_PERIOD_SERIAL;
            for (i = 0; i < 8; i++) begin
                serial_drive_value = data[i];
                #BIT_PERIOD_SERIAL;
            end
            serial_drive_value = 1; // Stop bit
            #BIT_PERIOD_SERIAL;
            serial_drive = 0; 
            #BIT_PERIOD_SERIAL;
        end
    endtask
    
    // Task to receive a byte via PC Parallel Interface
    task automatic receive_pc_byte(output logic [7:0] data);
        begin
            pc_tx_ready = 1;
            wait(pc_tx_valid);
            @(posedge clk);
            data = pc_tx_data;
            $display("[%0t] Bridge → PC: Received 0x%02X", $time, data);
            pc_tx_ready = 0;
        end
    endtask
    
    // Task to receive a byte via Serial (FPGA to ESC)
    task automatic receive_serial_byte(output logic [7:0] data);
        integer i;
        begin
            wait(serial == 0); // Start bit
            #(BIT_PERIOD_SERIAL + BIT_PERIOD_SERIAL/2); 
            for (i = 0; i < 8; i++) begin
                data[i] = serial;
                #BIT_PERIOD_SERIAL;
            end
            $display("[%0t] Bridge → ESC: Received 0x%02X", $time, data);
        end
    endtask
    
    // Main test sequence
    initial begin
        logic [7:0] received;
        logic [7:0] msp_resp;
        
        $display("========================================");
        $display("UART Bridge TB (Parallel PC Interface)");
        $display("========================================");
        
        rst = 1;
        enable = 0;
        pc_rx_valid = 0;
        pc_tx_ready = 0;
        serial_drive = 0;
        
        #100;
        rst = 0;
        #100;
        
        $display("\n[%0t] TEST 1: Passthrough Disabled", $time);
        send_pc_byte(8'h55);
        #(BIT_PERIOD_SERIAL * 12);
        if (dut_tx_oe === 0) 
            $display("[%0t] PASS: OE is low when disabled", $time);
        else 
            $display("[%0t] FAIL: OE should be low", $time);

        $display("\n[%0t] TEST 2: PC → ESC", $time);
        enable = 1;
        fork
            send_pc_byte(8'h41);
            receive_serial_byte(received);
        join
        if (received == 8'h41) $display("[%0t] PASS: Forwarded 0x41", $time);
        
        $display("\n[%0t] TEST 3: ESC → PC", $time);
        fork
            send_serial_byte(8'h42);
            receive_pc_byte(received);
        join
        if (received == 8'h42) $display("[%0t] PASS: Forwarded 0x42", $time);

        $display("\n[%0t] TEST 4: Echo Suppression", $time);
        $display("PC sends 0xAA. Bridge should NOT echo it back to PC.");
        fork
            send_pc_byte(8'hAA);
            receive_serial_byte(received);
        join
        #2000;
        if (pc_tx_valid) $display("[%0t] FAIL: Echo detected!", $time);
        else $display("[%0t] PASS: No echo detected", $time);


        // MSP IDENT Test with timeout (Icarus-compatible)
        $display("\n[%0t] TEST 5: MSP IDENT Command", $time);
        // Compose MSP_IDENT request: $M< 0x00 0x64 0x64
        send_pc_byte(8'h24); // '$'
        send_pc_byte(8'h4D); // 'M'
        send_pc_byte(8'h3C); // '<'
        send_pc_byte(8'h00); // len = 0
        send_pc_byte(8'h64); // cmd = 0x64 (MSP_IDENT)
        send_pc_byte(8'h64); // checksum = 0x00 ^ 0x64 = 0x64

        // Wait for response header with timeout (counter-based)
        timeout_cycles = 1000000; // adjust as needed for your clock
        cycles = 0;
        got_resp = 0;

        while (cycles < timeout_cycles && !got_resp) begin
            @(posedge clk);
            if (pc_tx_valid)
                got_resp = 1;
            cycles = cycles + 1;
        end
        if (!got_resp) begin
            $display("[%0t] FAIL: MSP response timed out (no response)", $time);
        end else begin
            // Now receive and check the response bytes
            receive_pc_byte(msp_resp); // '$'
            if (msp_resp != 8'h24) $display("[%0t] FAIL: MSP response missing '$'", $time);
            receive_pc_byte(msp_resp); // 'M'
            if (msp_resp != 8'h4D) $display("[%0t] FAIL: MSP response missing 'M'", $time);
            receive_pc_byte(msp_resp); // '>'
            if (msp_resp != 8'h3E) $display("[%0t] FAIL: MSP response missing '>'", $time);
            receive_pc_byte(msp_resp); // len
            $display("[%0t] MSP response len: %0d", $time, msp_resp);
            receive_pc_byte(msp_resp); // cmd
            if (msp_resp != 8'h64) $display("[%0t] FAIL: MSP response wrong cmd", $time);
            // Optionally receive payload and checksum (skipped here for brevity)
        end

        $display("\n========================================");
        $display("All Tests Complete!");
        $display("========================================");
        #10000;
        $finish;
    end

    initial begin
        $dumpfile("uart_passthrough_bridge_tb.vcd");
        $dumpvars(0, uart_passthrough_bridge_tb);
    end

endmodule
