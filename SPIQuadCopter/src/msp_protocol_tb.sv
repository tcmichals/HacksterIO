/**
 * MSP Protocol Testbench
 *
 * This testbench instantiates the MSP handler and a simple UART loopback to test protocol-level MSP commands (e.g., MSP_IDENT).
 */

`timescale 1ns/1ps

module msp_protocol_tb;

    // Clock and reset
    logic clk = 0;
    logic rst = 1;
    always #7 clk = ~clk; // ~71MHz

    // PC <-> MSP handler interface
    logic [7:0] pc_rx_data;
    logic       pc_rx_valid;
    logic [7:0] pc_tx_data;
    logic       pc_tx_valid;
    logic       pc_tx_ready;

    // Protocol reply variables (module scope, for all tasks and initial blocks)
    logic [7:0] header0, header1, header2;
    logic [7:0] len, cmd, checksum;
    logic [7:0] payload0, payload1, payload2, payload3, payload4;
    logic [7:0] payload5, payload6, payload7, payload8, payload9;

    // Instantiate MSP handler (standalone)
    msp_handler #(
        .CLK_FREQ_HZ(72_000_000)
    ) dut (
        .clk(clk),
        .rst(rst),
        .pc_rx_data(pc_rx_data),
        .pc_rx_valid(pc_rx_valid),
        .pc_tx_data(pc_tx_data),
        .pc_tx_valid(pc_tx_valid),
        .pc_tx_ready(pc_tx_ready),
        .active(),
        .fc_version_major(8'd1),
        .fc_version_minor(8'd0),
        .fc_version_patch(8'd0),
        .api_version(32'h01020304),
        .fc_variant(32'h11223344)
    );

    // Task to send a byte to the MSP handler
    task automatic send_pc_byte(input logic [7:0] data);
        begin
            @(posedge clk);
            pc_rx_data = data;
            pc_rx_valid = 1;
            @(posedge clk);
            pc_rx_valid = 0;
            pc_rx_data = 0;
        end
    endtask

    // Task to receive a byte from the MSP handler with timeout
    task automatic receive_pc_byte_timeout(output logic [7:0] data, input int max_cycles = 10000);
        int cycles;
        begin
            pc_tx_ready = 1;
            cycles = 0;
            while (!pc_tx_valid && cycles < max_cycles) begin
                @(posedge clk);
                cycles++;
            end
            if (pc_tx_valid) begin
                data = pc_tx_data;
                $display("[%0t] MSP Handler → PC: 0x%02X", $time, data);
            end else begin
                data = 8'hXX;
                $display("[TIMEOUT] No byte received after %0d cycles!", max_cycles);
            end
            pc_tx_ready = 0;
        end
    endtask

    // Helper: Send MSP command (no payload)
    task automatic send_msp_cmd(input logic [7:0] cmd);
        logic [7:0] checksum;
        begin
            checksum = 8'h00 ^ cmd;
            send_pc_byte(8'h24); // '$'
            send_pc_byte(8'h4D); // 'M'
            send_pc_byte(8'h3C); // '<'
            send_pc_byte(8'h00); // len = 0
            send_pc_byte(cmd);   // command
            send_pc_byte(checksum); // checksum
        end
    endtask

    // Helper: Receive full MSP reply (header + payload + checksum) with timeout
    task automatic recv_msp_reply(
        output logic [7:0] header0,
        output logic [7:0] header1,
        output logic [7:0] header2,
        output logic [7:0] len,
        output logic [7:0] cmd,
        output logic [7:0] payload0,
        output logic [7:0] payload1,
        output logic [7:0] payload2,
        output logic [7:0] payload3,
        output logic [7:0] payload4,
        output logic [7:0] payload5,
        output logic [7:0] payload6,
        output logic [7:0] payload7,
        output logic [7:0] payload8,
        output logic [7:0] payload9,
        output logic [7:0] checksum
    );
        int i;
        begin
            receive_pc_byte_timeout(header0);
            receive_pc_byte_timeout(header1);
            receive_pc_byte_timeout(header2);
            receive_pc_byte_timeout(len);
            receive_pc_byte_timeout(cmd);
            payload0 = 0; payload1 = 0; payload2 = 0; payload3 = 0; payload4 = 0;
            payload5 = 0; payload6 = 0; payload7 = 0; payload8 = 0; payload9 = 0;
            for (i = 0; i < len; i++) begin
                case(i)
                    0: receive_pc_byte_timeout(payload0);
                    1: receive_pc_byte_timeout(payload1);
                    2: receive_pc_byte_timeout(payload2);
                    3: receive_pc_byte_timeout(payload3);
                    4: receive_pc_byte_timeout(payload4);
                    5: receive_pc_byte_timeout(payload5);
                    6: receive_pc_byte_timeout(payload6);
                    7: receive_pc_byte_timeout(payload7);
                    8: receive_pc_byte_timeout(payload8);
                    9: receive_pc_byte_timeout(payload9);
                endcase
            end
            receive_pc_byte_timeout(checksum);
            $display("[MSP REPLY] Header: %s%s%s, Len: %0d, Cmd: 0x%02X, Payload:",
                header0, header1, header2, len, cmd);
            for (i = 0; i < len; i++) begin
                case(i)
                    0: $write(" %02X", payload0);
                    1: $write(" %02X", payload1);
                    2: $write(" %02X", payload2);
                    3: $write(" %02X", payload3);
                    4: $write(" %02X", payload4);
                    5: $write(" %02X", payload5);
                    6: $write(" %02X", payload6);
                    7: $write(" %02X", payload7);
                    8: $write(" %02X", payload8);
                    9: $write(" %02X", payload9);
                endcase
            end
            $display("\n[MSP REPLY] Checksum: 0x%02X", checksum);
        end
    endtask

    // BLHeli Passthrough/ESC test: Simulate PC->ESC and ESC->PC
    task automatic send_blheli_passthrough(input logic [7:0] esc_cmd, input logic [7:0] esc_reply);
        begin
            $display("\n[BLHeli PASSTHROUGH TEST] Sending BLHeli command 0x%02X to ESC", esc_cmd);
            // Simulate sending a BLHeli command from PC to ESC via passthrough
            send_pc_byte(esc_cmd);
            // Simulate ESC reply after a few cycles
            repeat (5) @(posedge clk);
            $display("[BLHeli PASSTHROUGH TEST] Simulating ESC reply 0x%02X", esc_reply);
            // In a real design, this would be injected on the ESC RX line; here we just print for now
            // Optionally, you could wire up a loopback or stub to the handler if the design supports it
        end
    endtask

    // Additional MSP command edge case tests
    initial begin
        // ...existing setup...

        // Test: MSP_IDENT with wrong checksum
        $display("\n[EDGE CASE] MSP_IDENT with wrong checksum");
        send_pc_byte(8'h24); // '$'
        send_pc_byte(8'h4D); // 'M'
        send_pc_byte(8'h3C); // '<'
        send_pc_byte(8'h00); // len = 0
        send_pc_byte(8'h64); // cmd = 0x64 (MSP_IDENT)
        send_pc_byte(8'h00); // wrong checksum (should be 0x64)
        // Should not get a valid reply
        #1000;

        // Test: MSP_SET_PASSTHROUGH (should trigger passthrough mode)
        $display("\n[EDGE CASE] MSP_SET_PASSTHROUGH");
        send_msp_cmd(8'd245); // MSP_SET_PASSTHROUGH
        recv_msp_reply(header0, header1, header2, len, cmd, payload0, payload1, payload2, payload3, payload4, payload5, payload6, payload7, payload8, payload9, checksum);

        // Test: Unknown MSP command
        $display("\n[EDGE CASE] Unknown MSP command");
        send_msp_cmd(8'd250); // Not implemented
        recv_msp_reply(header0, header1, header2, len, cmd, payload0, payload1, payload2, payload3, payload4, payload5, payload6, payload7, payload8, payload9, checksum);

        // Test: BLHeli passthrough with multi-byte frame
        $display("\n[BLHeli PASSTHROUGH] Multi-byte frame");
        send_blheli_passthrough(8'hAA, 8'h55);
        send_blheli_passthrough(8'hBB, 8'h66);
        send_blheli_passthrough(8'hCC, 8'h77);
        #1000;

        $display("\n[PROTOCOL TEST SUITE COMPLETE]");
        $finish;
    end

    // Main test sequence
    initial begin
        logic [7:0] msp_resp;
        logic [7:0] header0, header1, header2;
        logic [7:0] len, cmd, checksum;
        logic [7:0] payload0, payload1, payload2, payload3, payload4;
        logic [7:0] payload5, payload6, payload7, payload8, payload9;
        int global_cycles = 0;
        int max_global_cycles = 500000; // ~enough for all tests
        rst = 1;
        pc_rx_valid = 0;
        pc_tx_ready = 0;
        #100;
        rst = 0;
        #100;

        fork
            begin : test_sequence
                // Test all non-ESC MSP commands
                $display("\n[MSP TEST] MSP_IDENT");
                send_msp_cmd(8'd100); // MSP_IDENT
                recv_msp_reply(header0, header1, header2, len, cmd, payload0, payload1, payload2, payload3, payload4, payload5, payload6, payload7, payload8, payload9, checksum);

                $display("\n[MSP TEST] MSP_STATUS");
                send_msp_cmd(8'd101); // MSP_STATUS
                recv_msp_reply(header0, header1, header2, len, cmd, payload0, payload1, payload2, payload3, payload4, payload5, payload6, payload7, payload8, payload9, checksum);

                $display("\n[MSP TEST] MSP_API_VERSION");
                send_msp_cmd(8'd1); // MSP_API_VERSION
                recv_msp_reply(header0, header1, header2, len, cmd, payload0, payload1, payload2, payload3, payload4, payload5, payload6, payload7, payload8, payload9, checksum);

                $display("\n[MSP TEST] MSP_FC_VARIANT");
                send_msp_cmd(8'd2); // MSP_FC_VARIANT
                recv_msp_reply(header0, header1, header2, len, cmd, payload0, payload1, payload2, payload3, payload4, payload5, payload6, payload7, payload8, payload9, checksum);

                $display("\n[MSP TEST] MSP_FC_VERSION");
                send_msp_cmd(8'd3); // MSP_FC_VERSION
                recv_msp_reply(header0, header1, header2, len, cmd, payload0, payload1, payload2, payload3, payload4, payload5, payload6, payload7, payload8, payload9, checksum);

                $display("\n[MSP TEST] MSP_BOARD_INFO");
                send_msp_cmd(8'd4); // MSP_BOARD_INFO
                recv_msp_reply(header0, header1, header2, len, cmd, payload0, payload1, payload2, payload3, payload4, payload5, payload6, payload7, payload8, payload9, checksum);

                $display("\n[MSP TEST] MSP_BUILD_INFO");
                send_msp_cmd(8'd5); // MSP_BUILD_INFO
                recv_msp_reply(header0, header1, header2, len, cmd, payload0, payload1, payload2, payload3, payload4, payload5, payload6, payload7, payload8, payload9, checksum);

                $display("\n[MSP TEST] MSP_NAME");
                send_msp_cmd(8'd10); // MSP_NAME
                recv_msp_reply(header0, header1, header2, len, cmd, payload0, payload1, payload2, payload3, payload4, payload5, payload6, payload7, payload8, payload9, checksum);

                $display("\n[MSP TEST] MSP_SET_PASSTHROUGH");
                send_msp_cmd(8'd245); // MSP_SET_PASSTHROUGH
                recv_msp_reply(header0, header1, header2, len, cmd, payload0, payload1, payload2, payload3, payload4, payload5, payload6, payload7, payload8, payload9, checksum);

                // BLHeli Passthrough/ESC test
                send_blheli_passthrough(8'hAA, 8'h55); // Example: send 0xAA, expect 0x55 from ESC

                $display("\n[MSP+ESC TEST] Complete");
                #1000;
                $finish;
            end
            begin : watchdog
                while (global_cycles < max_global_cycles) begin
                    @(posedge clk);
                    global_cycles++;
                end
                $display("[TIMEOUT] Testbench exceeded max cycles (%0d), aborting!", max_global_cycles);
                $finish;
            end
        join_any
        disable fork;
    end

    initial begin
        $dumpfile("msp_protocol_tb.vcd");
        $dumpvars(0, msp_protocol_tb);
    end

endmodule
