`timescale 1ns/1ps

module tang9k_top_tb();

    // System clock for design: drive 72 MHz (half period 7ns)
    reg i_sys_clk = 0;
    always #7 i_sys_clk = ~i_sys_clk;

    // Reset and PLL lock model
    reg i_rst = 0; 

    // SPI signals
    wire spi_clk;
    reg spi_cs_0 = 1; // active-low chip select, default inactive high
    reg spi_mosi = 0;
    wire spi_miso;

    // Other I/Os
    wire o_led0, o_led1, o_led2, o_led3;
    wire o_motor1, o_motor2, o_motor3, o_motor4;
    wire o_neopixel;
    wire o_status_led0, o_status_led1, o_status_led2;
    reg i_usb_uart_rx = 1;
    wire o_usb_uart_tx;
    wire serial;
    wire o_pll_locked;
    
    reg [31:0] read_data;
    reg [31:0] dummy_read;

    // Instantiate DUT
    tang9k_top dut (
        .i_sys_clk    (i_sys_clk),
        .i_rst        (i_rst),
        .i_spi_clk    (spi_clk),
        .i_spi_cs_n   (spi_cs_0),
        .i_spi_mosi   (spi_mosi),
        .o_spi_miso   (spi_miso),
        .o_led0       (o_led0),
        .o_led1       (o_led1),
        .o_led2       (o_led2),
        .o_led3       (o_led3),
        .i_btn0       (1'b0),
        .i_btn1       (1'b0),
        .i_uart_rx    (1'b1),
        .o_uart_tx    (),
        .o_uart_irq   (),
        .i_usb_uart_rx(i_usb_uart_rx),
        .o_usb_uart_tx(o_usb_uart_tx),
        .serial       (serial),
        .i_pwm_ch0    (1'b0),
        .i_pwm_ch1    (1'b0),
        .i_pwm_ch2    (1'b0),
        .i_pwm_ch3    (1'b0),
        .i_pwm_ch4    (1'b0),
        .i_pwm_ch5    (1'b0),
        .o_motor1     (o_motor1),
        .o_motor2     (o_motor2),
        .o_motor3     (o_motor3),
        .o_motor4     (o_motor4),
        .o_neopixel   (o_neopixel),
        .o_status_led0(o_status_led0),
        .o_status_led1(o_status_led1),
        .o_status_led2(o_status_led2),
        .o_pll_locked (o_pll_locked)
    );

    // SPI master clock (i_sclk) and signals - driven by send_spi_byte (bit-banged)
    reg i_sclk = 0;
    assign spi_clk = i_sclk;

    // Small helper to drive SPI bytes (MSB first)
    // Synchronous Slave needs SCLK << CLK. We use a slow bit-bang.
    task send_spi_byte(input logic [7:0] byte_val);
        integer i;
        begin
            for (i = 7; i >= 0; i = i - 1) begin
                // Drive MOSI
                spi_mosi = byte_val[i]; 
                repeat(4) @(posedge i_sys_clk);

                // Pulse SCLK High
                i_sclk = 1'b1;
                repeat(4) @(posedge i_sys_clk);
                
                // Pulse SCLK Low
                i_sclk = 1'b0;
                repeat(4) @(posedge i_sys_clk);
            end
        end
    endtask
    
    // Receive helper (samples MISO)
    task receive_spi_byte(output logic [7:0] byte_val);
        integer i;
        begin
            byte_val = 0;
            for (i = 7; i >= 0; i = i - 1) begin
                // Drive MOSI (don't care)
                spi_mosi = 0;
                repeat(4) @(posedge i_sys_clk);

                // Pulse SCLK High
                i_sclk = 1'b1;
                // Sample MISO on rising edge (or stable high)
                byte_val[i] = spi_miso;
                repeat(4) @(posedge i_sys_clk);
                
                // Pulse SCLK Low
                i_sclk = 1'b0;
                repeat(4) @(posedge i_sys_clk);
            end
        end
    endtask

    // Combined SPI Wishbone transaction task
    task spi_wb_transaction(
        input bit is_read,
        input [31:0] addr,
        input [31:0] write_data,
        output [31:0] read_data_out
    );
        integer i;
        reg [7:0] b; 
        reg [7:0] tmp;
        begin
            @(posedge i_sys_clk);
            spi_cs_0 = 1'b0; // assert CS (active low)
            repeat(4) @(posedge i_sys_clk); // Wait for CS to settle

            // Command byte
            send_spi_byte(is_read ? 8'hA1 : 8'hA2);

            // Address bytes MSB-first
            send_spi_byte(addr[31:24]);
            send_spi_byte(addr[23:16]);
            send_spi_byte(addr[15:8]);
            send_spi_byte(addr[7:0]);

            if (!is_read) begin
                // Write: send 4 data bytes (LSB first for Wishbone Adapter)
                send_spi_byte(write_data[7:0]);
                send_spi_byte(write_data[15:8]);
                send_spi_byte(write_data[23:16]);
                send_spi_byte(write_data[31:24]);
                
                // Deassert CS
                repeat(4) @(posedge i_sys_clk);
                spi_cs_0 = 1'b1; 
                repeat (20) @(posedge i_sys_clk);
            end else begin
                // Read: give the DUT time to prepare response
                repeat (100) @(posedge i_sys_clk);

                // Read 5 bytes (header + 4 data bytes LSB first)
                read_data_out = 32'h0;
                for (i = 0; i <= 4; i = i + 1) begin
                   receive_spi_byte(b); // Use receive helper
                   if (i == 0) begin // First byte is header
                       if (b != 8'hA3) $display("ERROR: unexpected response header: %02x", b);
                   end else begin
                       // i=1 (LSB) -> shift 0, i=2 -> shift 8, ...
                       read_data_out = read_data_out | (b << ((i-1)*8));
                   end
                end
                
                // Deassert CS
                repeat(4) @(posedge i_sys_clk);
                spi_cs_0 = 1'b1; 
                repeat (20) @(posedge i_sys_clk);
            end
        end
    endtask

    // Test sequence
    initial begin
        // Reset initialization
        i_rst = 1; // Active High Reset
        spi_cs_0 = 1;
        spi_mosi = 0;
        
        $dumpfile("tb_tang9k_top.vcd");
        $dumpvars(0, tang9k_top_tb);
        
        #200; 
        
        // Release Reset
        i_rst = 0;
        #1000;
        
        // Wait for PLL Lock
        wait(o_pll_locked);
        #100;

        $display("Test: write LED register");
        spi_wb_transaction(0, 32'h0000, 32'h0000000F, dummy_read);
        #1000;

        // Read back LED register
         $display("Test: READ LED register");
        spi_wb_transaction(1, 32'h0000, 32'h0, read_data);
        $display("Read LED register: 0x%08x", read_data);

        // Check LED outputs
        if (read_data[3:0] === 4'hF) 
            $display("SUCCESS: LEDs readback correct");
        else 
            $display("FAILURE: LEDs readback incorrect");

        $finish;
    end

endmodule
