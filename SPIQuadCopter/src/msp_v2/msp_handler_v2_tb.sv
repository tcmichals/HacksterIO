`default_nettype none
`timescale 1ns / 1ps

/**
 * Testbench for MSP Handler V2 (Pipelined Packet Processor)
 * Simplified for Icarus Verilog compatibility
 */
module msp_handler_v2_tb;

    // Clock and reset
    reg clk = 0;
    reg rst = 1;
    
    // Parameters
    localparam CLK_PERIOD = 13.889;  // 72 MHz
    localparam MAX_PAYLOAD = 16;
    
    // DUT signals
    reg [7:0]   pc_rx_data;
    reg         pc_rx_valid;
    wire [7:0]  pc_tx_data;
    wire        pc_tx_valid;
    reg         pc_tx_ready;
    wire        active;
    
    // Response capture
    reg [7:0] response [0:31];
    integer resp_idx;
    integer wait_cnt;
    
    // Clock generation
    always #(CLK_PERIOD/2) clk = ~clk;
    
    // DUT instantiation
    msp_handler_v2 #(
        .CLK_FREQ_HZ(72_000_000),
        .MAX_PAYLOAD(MAX_PAYLOAD)
    ) dut (
        .clk(clk),
        .rst(rst),
        .pc_rx_data(pc_rx_data),
        .pc_rx_valid(pc_rx_valid),
        .pc_tx_data(pc_tx_data),
        .pc_tx_valid(pc_tx_valid),
        .pc_tx_ready(pc_tx_ready),
        .active(active),
        .fc_version_major(8'h01),
        .fc_version_minor(8'h02),
        .fc_version_patch(8'h03),
        .api_version(32'h00010200),
        .fc_variant(32'h544E394B)  // "TN9K"
    );
    
    // Task: Send a byte using non-blocking to avoid timing issues
    task send_byte;
        input [7:0] data;
        begin
            @(negedge clk);   // Change on negedge so stable at posedge
            pc_rx_data = data;
            pc_rx_valid = 1'b1;
            @(negedge clk);   // Hold for one cycle
            pc_rx_valid = 1'b0;
            @(negedge clk);   // Gap between bytes
        end
    endtask
    
    // Task: Send MSP_API_VERSION command (cmd=1, len=0)
    task send_msp_api_version;
        begin
            $display("[%0t] Sending MSP_API_VERSION (cmd=1)", $time);
            send_byte(8'h24);  // '$'
            send_byte(8'h4D);  // 'M'
            send_byte(8'h3C);  // '<'
            send_byte(8'h00);  // len=0
            send_byte(8'h01);  // cmd=1
            send_byte(8'h01);  // checksum = 0 ^ 1 = 1
        end
    endtask
    
    // Task: Send MSP_FC_VARIANT command (cmd=2, len=0)
    task send_msp_fc_variant;
        begin
            $display("[%0t] Sending MSP_FC_VARIANT (cmd=2)", $time);
            send_byte(8'h24);  // '$'
            send_byte(8'h4D);  // 'M'
            send_byte(8'h3C);  // '<'
            send_byte(8'h00);  // len=0
            send_byte(8'h02);  // cmd=2
            send_byte(8'h02);  // checksum = 0 ^ 2 = 2
        end
    endtask
    
    // Task: Send MSP_IDENT command (cmd=100, len=0)
    task send_msp_ident;
        begin
            $display("[%0t] Sending MSP_IDENT (cmd=100)", $time);
            send_byte(8'h24);  // '$'
            send_byte(8'h4D);  // 'M'
            send_byte(8'h3C);  // '<'
            send_byte(8'h00);  // len=0
            send_byte(8'd100); // cmd=100
            send_byte(8'd100); // checksum = 0 ^ 100 = 100
        end
    endtask
    
    // Main test
    initial begin
        $dumpfile("msp_handler_v2_tb.vcd");
        $dumpvars(0, msp_handler_v2_tb);
        
        $display("=== MSP Handler V2 Testbench ===");
        
        // Initialize
        pc_rx_data = 8'd0;
        pc_rx_valid = 1'b0;
        pc_tx_ready = 1'b1;
        resp_idx = 0;
        
        // Reset
        rst = 1;
        repeat(10) @(posedge clk);
        rst = 0;
        repeat(10) @(posedge clk);
        
        // ===== Test 1: MSP_API_VERSION =====
        $display("\n--- Test 1: MSP_API_VERSION ---");
        send_msp_api_version();
        
        // Capture response
        resp_idx = 0;
        wait_cnt = 0;
        while (wait_cnt < 500) begin
            @(posedge clk);
            if (pc_tx_valid && pc_tx_ready) begin
                response[resp_idx] = pc_tx_data;
                $display("[%0t] RX[%0d]: 0x%02X", $time, resp_idx, pc_tx_data);
                resp_idx = resp_idx + 1;
            end
            if (!active && resp_idx > 0)
                wait_cnt = 500;  // Done
            else
                wait_cnt = wait_cnt + 1;
        end
        
        // Verify
        if (resp_idx >= 6 && response[0] == 8'h24 && response[1] == 8'h4D && 
            response[2] == 8'h3E && response[3] == 8'd3 && response[4] == 8'd1)
            $display("PASS: MSP_API_VERSION response valid (len=3)");
        else
            $display("FAIL: MSP_API_VERSION response invalid");
        
        repeat(100) @(posedge clk);
        
        // ===== Test 2: MSP_FC_VARIANT =====
        $display("\n--- Test 2: MSP_FC_VARIANT ---");
        send_msp_fc_variant();
        
        // Capture response
        resp_idx = 0;
        wait_cnt = 0;
        while (wait_cnt < 500) begin
            @(posedge clk);
            if (pc_tx_valid && pc_tx_ready) begin
                response[resp_idx] = pc_tx_data;
                $display("[%0t] RX[%0d]: 0x%02X", $time, resp_idx, pc_tx_data);
                resp_idx = resp_idx + 1;
            end
            if (!active && resp_idx > 0)
                wait_cnt = 500;
            else
                wait_cnt = wait_cnt + 1;
        end
        
        // Verify
        if (resp_idx >= 6 && response[0] == 8'h24 && response[3] == 8'd4 && response[4] == 8'd2)
            $display("PASS: MSP_FC_VARIANT response valid (len=4)");
        else
            $display("FAIL: MSP_FC_VARIANT response invalid");
        
        repeat(100) @(posedge clk);
        
        // ===== Test 3: MSP_IDENT =====
        $display("\n--- Test 3: MSP_IDENT ---");
        send_msp_ident();
        
        // Capture response
        resp_idx = 0;
        wait_cnt = 0;
        while (wait_cnt < 500) begin
            @(posedge clk);
            if (pc_tx_valid && pc_tx_ready) begin
                response[resp_idx] = pc_tx_data;
                $display("[%0t] RX[%0d]: 0x%02X", $time, resp_idx, pc_tx_data);
                resp_idx = resp_idx + 1;
            end
            if (!active && resp_idx > 0)
                wait_cnt = 500;
            else
                wait_cnt = wait_cnt + 1;
        end
        
        // Verify
        if (resp_idx >= 6 && response[0] == 8'h24 && response[3] == 8'd7 && response[4] == 8'd100)
            $display("PASS: MSP_IDENT response valid (len=7)");
        else
            $display("FAIL: MSP_IDENT response invalid");
        
        repeat(100) @(posedge clk);
        
        $display("\n=== All tests complete ===");
        $finish;
    end
    
    // Timeout
    initial begin
        #500000;
        $display("ERROR: Testbench timeout");
        $finish;
    end

endmodule
