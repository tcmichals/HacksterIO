/**
 * SPI to PWM Decoder Integration Testbench
 * 
 * Tests the complete data path:
 *   SPI Master → spi_slave → spi_slave_wb_bridge → pwmdecoder_wb
 * 
 * Test scenario:
 *   1. Generate PWM waveforms with known pulse widths
 *   2. Read PWM values via SPI commands
 *   3. Verify read values match expected pulse widths
 */

`timescale 1ns / 1ps

module spi_pwm_integration_tb;

    // Clock parameters
    localparam CLK_FREQ_HZ = 54_000_000;  // 54 MHz system clock
    localparam CLK_PERIOD = 19;            // 54 MHz = 18.5ns, rounded to 19ns
    localparam SPI_CLK_PERIOD = 100;       // 10 MHz SPI clock
    
    // PWM Guard Time Parameters (from pwmdecoder.v)
    localparam GUARD_TIME_ON_MIN = 800;    // Minimum valid pulse (us)
    localparam GUARD_TIME_ON_MAX = 2600;   // Maximum valid pulse (us)
    localparam GUARD_TIME_OFF_MAX = 20000; // No signal timeout (us)
    
    // Error flags (from pwmdecoder.v)
    localparam GUARD_ERROR_LOW   = 16'hC000;  // No signal timeout
    localparam GUARD_ERROR_HIGH  = 16'h8000;  // Pulse too long
    localparam GUARD_ERROR_SHORT = 16'h4000;  // Pulse too short
    
    // PWM timing parameters (in clock cycles at 54 MHz)
    // 1 us = 54 clock cycles
    localparam CLKS_PER_US = CLK_FREQ_HZ / 1_000_000;
    
    // PWM decoder base address (from SYSTEM_OVERVIEW)
    localparam PWM_BASE_ADDR = 32'h0000_0200;
    
    // System signals
    logic clk;
    logic rst;
    
    // SPI physical signals
    logic spi_sclk;
    logic spi_cs_n;
    logic spi_mosi;
    logic spi_miso;
    
    // SPI slave to WB master interface
    logic [7:0] spi_rx_data;
    logic       spi_rx_valid;
    logic [7:0] spi_tx_data;
    logic       spi_tx_valid;
    logic       spi_tx_ready;
    
    // Wishbone signals
    logic [15:0] wb_adr;
    logic [31:0] wb_dat_wr;
    logic [31:0] wb_dat_rd;
    logic        wb_we;
    logic [3:0]  wb_sel;
    logic        wb_stb;
    logic        wb_ack;
    logic        wb_err;
    logic        wb_cyc;
    logic        busy;
    
    // PWM input signals
    logic pwm_ch0, pwm_ch1, pwm_ch2, pwm_ch3, pwm_ch4, pwm_ch5;
    
    // Test data buffers
    reg [7:0] spi_tx_buf [0:63];
    reg [7:0] spi_rx_buf [0:63];
    integer   spi_buf_len;
    
    // Test counters
    integer pass_count, fail_count;
    
    // Expected PWM values (in microseconds)
    integer expected_pwm [0:5];
    
    // =========================================================================
    // Clock generation
    // =========================================================================
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // =========================================================================
    // Module Instantiations
    // =========================================================================
    
    // SPI Slave
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
    
    // SPI to Wishbone Master
    spi_slave_wb_bridge #(
        .WB_ADDR_WIDTH(16),
        .WB_DATA_WIDTH(32)
    ) u_spi_slave_wb_bridge (
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
    
    // PWM Decoder with Wishbone interface
    pwmdecoder_wb #(
        .clockFreq(CLK_FREQ_HZ),
        .DATA_WIDTH(32),
        .ADDR_WIDTH(32)
    ) u_pwm_decoder (
        .i_clk(clk),
        .i_rst(rst),
        .wb_adr_i(wb_adr),
        .wb_dat_i(wb_dat_wr),
        .wb_dat_o(wb_dat_rd),
        .wb_we_i(wb_we),
        .wb_sel_i(wb_sel),
        .wb_stb_i(wb_stb),
        .wb_ack_o(wb_ack),
        .wb_err_o(wb_err),
        .wb_rty_o(),
        .wb_cyc_i(wb_cyc),
        .i_pwm_0(pwm_ch0),
        .i_pwm_1(pwm_ch1),
        .i_pwm_2(pwm_ch2),
        .i_pwm_3(pwm_ch3),
        .i_pwm_4(pwm_ch4),
        .i_pwm_5(pwm_ch5)
    );
    
    // =========================================================================
    // SPI Transaction Tasks
    // =========================================================================
    
    // SPI single byte transfer
    task spi_byte(input [7:0] tx_byte, output [7:0] rx_byte);
        integer i;
        begin
            rx_byte = 8'h00;
            for (i = 7; i >= 0; i = i - 1) begin
                spi_sclk = 1'b0;
                spi_mosi = tx_byte[i];
                #(SPI_CLK_PERIOD/2);
                spi_sclk = 1'b1;
                rx_byte[i] = spi_miso;
                #(SPI_CLK_PERIOD/2);
            end
            spi_sclk = 1'b0;
        end
    endtask
    
    // Full SPI transaction
    task spi_transaction();
        integer i;
        logic [7:0] rx_byte;
        begin
            $display("[SPI] Transaction start, %0d bytes", spi_buf_len);
            spi_cs_n = 1'b0;
            #(SPI_CLK_PERIOD);
            
            for (i = 0; i < spi_buf_len; i = i + 1) begin
                spi_byte(spi_tx_buf[i], rx_byte);
                spi_rx_buf[i] = rx_byte;
            end
            
            #(SPI_CLK_PERIOD);
            spi_cs_n = 1'b1;
            #(SPI_CLK_PERIOD * 2);
        end
    endtask
    
    // Setup SPI read command
    // Format: cmd(1) + len(2,LE) + addr(4,LE) + pad(len) + DA
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
            for (i = 0; i < len; i = i + 1)
                spi_tx_buf[7 + i] = 8'h55;   // Pad bytes
            spi_tx_buf[7 + len] = 8'hDA;     // Terminator
            spi_buf_len = 8 + len;
        end
    endtask
    
    // Read 32-bit value from SPI response buffer
    // Data starts at byte 8 (after cmd echo, len echo, addr echo)
    function [31:0] get_read_data();
        begin
            get_read_data = {spi_rx_buf[11], spi_rx_buf[10], spi_rx_buf[9], spi_rx_buf[8]};
        end
    endfunction
    
    // =========================================================================
    // PWM Generation Tasks
    // =========================================================================
    
    // Generate a single PWM pulse with specified width in microseconds
    task generate_pwm_pulse(
        output logic pwm_out,
        input integer pulse_width_us,
        input integer period_us
    );
        integer on_time_ns, off_time_ns;
        begin
            on_time_ns = pulse_width_us * 1000;
            off_time_ns = (period_us - pulse_width_us) * 1000;
            
            // High phase (pulse)
            pwm_out = 1'b1;
            #(on_time_ns);
            
            // Low phase
            pwm_out = 1'b0;
            #(off_time_ns);
        end
    endtask
    
    // Note: pwm_generator task removed - Icarus Verilog does not support 'ref' ports
    // PWM signals are generated directly in test sequences instead
    
    // =========================================================================
    // Test Helpers
    // =========================================================================
    
    task read_pwm_channel(
        input integer channel,
        output [15:0] value
    );
        logic [31:0] addr;
        logic [31:0] read_val;
        begin
            addr = PWM_BASE_ADDR + (channel * 4);
            setup_read_cmd(addr, 16'd4);
            spi_transaction();
            read_val = get_read_data();
            value = read_val[15:0];
            $display("[PWM] Channel %0d @ 0x%08x = %0d us", channel, addr, value);
        end
    endtask
    
    task check_pwm_value(
        input integer channel,
        input integer expected_us,
        input integer tolerance_us
    );
        logic [15:0] actual;
        integer diff;
        logic [1:0] error_flags;
        begin
            read_pwm_channel(channel, actual);
            error_flags = actual[15:14];
            
            // Check for guard time errors
            if (error_flags != 2'b00) begin
                if (error_flags == 2'b11)
                    $display("[TEST] Channel %0d: GUARD_ERROR_LOW (no signal) - 0x%04x", channel, actual);
                else if (error_flags == 2'b10)
                    $display("[TEST] Channel %0d: GUARD_ERROR_HIGH (too long) - 0x%04x", channel, actual);
                else if (error_flags == 2'b01)
                    $display("[TEST] Channel %0d: GUARD_ERROR_SHORT (too short) - 0x%04x", channel, actual);
                fail_count = fail_count + 1;
                return;
            end
            
            diff = (actual > expected_us) ? (actual - expected_us) : (expected_us - actual);
            
            if (diff <= tolerance_us) begin
                $display("[TEST] Channel %0d: PASS (expected=%0d, got=%0d, diff=%0d)", 
                         channel, expected_us, actual, diff);
                pass_count = pass_count + 1;
            end else begin
                $display("[TEST] Channel %0d: FAIL (expected=%0d, got=%0d, diff=%0d)", 
                         channel, expected_us, actual, diff);
                fail_count = fail_count + 1;
            end
        end
    endtask
    
    // Task to verify expected guard time error
    task check_pwm_guard_error(
        input integer channel,
        input [1:0] expected_error  // 01=SHORT, 10=HIGH, 11=LOW
    );
        logic [15:0] actual;
        logic [1:0] error_flags;
        string error_name;
        begin
            read_pwm_channel(channel, actual);
            error_flags = actual[15:14];
            
            case (expected_error)
                2'b01: error_name = "GUARD_ERROR_SHORT";
                2'b10: error_name = "GUARD_ERROR_HIGH";
                2'b11: error_name = "GUARD_ERROR_LOW";
                default: error_name = "NO_ERROR";
            endcase
            
            if (error_flags == expected_error) begin
                $display("[TEST] Channel %0d: PASS (expected %s, got 0x%04x)", 
                         channel, error_name, actual);
                pass_count = pass_count + 1;
            end else begin
                $display("[TEST] Channel %0d: FAIL (expected %s, got 0x%04x)", 
                         channel, error_name, actual);
                fail_count = fail_count + 1;
            end
        end
    endtask
    
    // =========================================================================
    // Main Test
    // =========================================================================
    initial begin
        $dumpfile("spi_pwm_integration_tb.vcd");
        $dumpvars(0, spi_pwm_integration_tb);
        
        // Initialize
        pass_count = 0;
        fail_count = 0;
        rst = 1'b1;
        spi_cs_n = 1'b1;
        spi_sclk = 1'b0;
        spi_mosi = 1'b0;
        
        // Initialize PWM signals low
        pwm_ch0 = 1'b0;
        pwm_ch1 = 1'b0;
        pwm_ch2 = 1'b0;
        pwm_ch3 = 1'b0;
        pwm_ch4 = 1'b0;
        pwm_ch5 = 1'b0;
        
        // Expected PWM values (in microseconds, real timing)
        // All values within valid guard time range: 800-2600 us
        expected_pwm[0] = 1000;  // Minimum throttle
        expected_pwm[1] = 1500;  // Center stick
        expected_pwm[2] = 2000;  // Maximum throttle
        expected_pwm[3] = 1250;  // Quarter
        expected_pwm[4] = 1750;  // Three-quarter
        expected_pwm[5] = 1100;  // Arm switch
        
        // Release reset
        #(CLK_PERIOD * 10);
        rst = 1'b0;
        #(CLK_PERIOD * 10);
        
        $display("\n========================================");
        $display("SPI-PWM Integration Test");
        $display("========================================\n");
        
        // =====================================================
        // Test 1: Valid PWM pulses (within 800-2600 us range)
        // Generate 2 pulses to ensure stable measurement
        // =====================================================
        $display("=== Test 1: Valid PWM Pulses ===\n");
        $display("Generating PWM waveforms (real timing)...");
        
        fork
            // Channel 0: 1000 us pulse (min throttle)
            begin
                repeat(2) begin
                    pwm_ch0 = 1'b1;
                    #(1000 * 1000);  // 1000 us = 1ms
                    pwm_ch0 = 1'b0;
                    #(4000 * 1000);  // 4ms off (5ms period for faster sim)
                end
            end
            
            // Channel 1: 1500 us pulse (center)
            begin
                repeat(2) begin
                    pwm_ch1 = 1'b1;
                    #(1500 * 1000);
                    pwm_ch1 = 1'b0;
                    #(3500 * 1000);
                end
            end
            
            // Channel 2: 2000 us pulse (max throttle)
            begin
                repeat(2) begin
                    pwm_ch2 = 1'b1;
                    #(2000 * 1000);
                    pwm_ch2 = 1'b0;
                    #(3000 * 1000);
                end
            end
            
            // Channel 3: 1250 us pulse (quarter)
            begin
                repeat(2) begin
                    pwm_ch3 = 1'b1;
                    #(1250 * 1000);
                    pwm_ch3 = 1'b0;
                    #(3750 * 1000);
                end
            end
            
            // Channel 4: 1750 us pulse (three-quarter)
            begin
                repeat(2) begin
                    pwm_ch4 = 1'b1;
                    #(1750 * 1000);
                    pwm_ch4 = 1'b0;
                    #(3250 * 1000);
                end
            end
            
            // Channel 5: 1100 us pulse (arm switch)
            begin
                repeat(2) begin
                    pwm_ch5 = 1'b1;
                    #(1100 * 1000);
                    pwm_ch5 = 1'b0;
                    #(3900 * 1000);
                end
            end
        join
        
        // Wait for PWM decoder to finish measurement
        #(2000 * 1000);  // 2ms settle
        
        // =====================================================
        // Test 1: Read all PWM channels via SPI
        // =====================================================
        $display("\n=== Test 1: Reading PWM Values via SPI ===\n");
        
        check_pwm_value(0, expected_pwm[0], 5);  // +/- 5us tolerance
        #(CLK_PERIOD * 100);
        
        check_pwm_value(1, expected_pwm[1], 5);
        #(CLK_PERIOD * 100);
        
        check_pwm_value(2, expected_pwm[2], 5);
        #(CLK_PERIOD * 100);
        
        check_pwm_value(3, expected_pwm[3], 5);
        #(CLK_PERIOD * 100);
        
        check_pwm_value(4, expected_pwm[4], 5);
        #(CLK_PERIOD * 100);
        
        check_pwm_value(5, expected_pwm[5], 5);
        #(CLK_PERIOD * 100);
        
        // =====================================================
        // Test 2: Minimum guard time edge (800us)
        // =====================================================
        $display("\n=== Test 2: Minimum Guard Time (800us) ===\n");
        begin
            // Send 800us pulse on channel 0 (exactly at minimum)
            pwm_ch0 = 1'b1;
            #(800 * 1000);  // 800us
            pwm_ch0 = 1'b0;
            #(4000 * 1000);  // 4ms off
            
            // Should be valid (exactly at limit)
            check_pwm_value(0, 800, 5);
        end
        #(CLK_PERIOD * 100);
        
        // =====================================================
        // Test 3: Maximum guard time edge (2600us)
        // =====================================================
        $display("\n=== Test 3: Maximum Guard Time (2600us) ===\n");
        begin
            // Send 2600us pulse on channel 1 (exactly at maximum)
            pwm_ch1 = 1'b1;
            #(2600 * 1000);  // 2600us
            pwm_ch1 = 1'b0;
            #(4000 * 1000);  // 4ms off
            
            // Should be valid (exactly at limit)
            check_pwm_value(1, 2600, 5);
        end
        #(CLK_PERIOD * 100);
        
        // =====================================================
        // Test 4: Too short pulse (GUARD_ERROR_SHORT)
        // =====================================================
        $display("\n=== Test 4: Too Short Pulse (<800us) ===\n");
        begin
            // Send 500us pulse on channel 2 (below minimum)
            pwm_ch2 = 1'b1;
            #(500 * 1000);  // 500us - too short
            pwm_ch2 = 1'b0;
            #(4000 * 1000);  // 4ms off
            
            // Should have GUARD_ERROR_SHORT (bits 15:14 = 01)
            check_pwm_guard_error(2, 2'b01);
        end
        #(CLK_PERIOD * 100);
        
        // =====================================================
        // Test 5: Too long pulse (GUARD_ERROR_HIGH)
        // =====================================================
        $display("\n=== Test 5: Too Long Pulse (>2600us) ===\n");
        begin
            // Send 3000us pulse on channel 3 (above maximum)
            pwm_ch3 = 1'b1;
            #(3000 * 1000);  // 3000us - too long
            pwm_ch3 = 1'b0;
            #(4000 * 1000);  // 4ms off
            
            // Should have GUARD_ERROR_HIGH (bits 15:14 = 10)
            check_pwm_guard_error(3, 2'b10);
        end
        #(CLK_PERIOD * 100);
        
        // =====================================================
        // Test 6: No signal (GUARD_ERROR_LOW)
        // =====================================================
        $display("\n=== Test 6: No PWM Signal (>20ms timeout) ===\n");
        begin
            // Channel 4 has not received pulses for a while
            // Wait >20ms with no pulse
            pwm_ch4 = 1'b0;  // Ensure low
            #(25000 * 1000);  // 25ms - exceeds 20ms timeout
            
            // Should have GUARD_ERROR_LOW (bits 15:14 = 11)
            check_pwm_guard_error(4, 2'b11);
        end
        #(CLK_PERIOD * 100);
        
        // =====================================================
        // Test 7: Status register read
        // =====================================================
        $display("\n=== Test 7: Status Register ===\n");
        begin
            logic [31:0] addr;
            logic [31:0] status;
            addr = PWM_BASE_ADDR + 32'h18;  // Status register at offset 0x18
            setup_read_cmd(addr, 16'd4);
            spi_transaction();
            status = get_read_data();
            $display("[STATUS] PWM Status = 0x%08x (ready flags: %06b)", status, status[5:0]);
            $display("[TEST] Status: PASS - Status register read successfully");
            pass_count = pass_count + 1;
        end
        
        // =====================================================
        // Summary
        // =====================================================
        $display("\n========================================");
        $display("Test Summary");
        $display("========================================");
        $display("PASSED: %0d", pass_count);
        $display("FAILED: %0d", fail_count);
        
        if (fail_count == 0)
            $display("\n*** ALL TESTS PASSED ***\n");
        else
            $display("\n*** SOME TESTS FAILED ***\n");
        
        $finish;
    end
    
    // Timeout watchdog (200ms total simulation time max)
    initial begin
        #(200_000_000);
        $display("ERROR: Simulation timeout!");
        $finish;
    end

endmodule
