// tb_comm.sv - simple include-based shared SPI/WB tasks for testbenches

// Framing constants (new protocol)
localparam logic [7:0] TB_READ_REQ  = 8'hA1;
localparam logic [7:0] TB_WRITE_REQ = 8'hA2;
localparam logic [7:0] TB_READ_RESP = 8'h21;   // CMD ^ 0x80
localparam logic [7:0] TB_WRITE_RESP = 8'h22;  // CMD ^ 0x80
localparam logic [7:0] TB_SYNC_BYTE = 8'hDA;
localparam logic [7:0] TB_PAD_BYTE  = 8'h55;
localparam logic [7:0] TB_ACK_BYTE  = 8'hEE;

// SPI send/receive (MSB first) using signals expected to be present in the
// including testbench: spi_mosi, spi_miso, i_sclk, i_clk
// Deterministic synchronous SPI master task
// Configurable: send_msb_first controls bit order
task automatic send_spi_byte(input [7:0] tx, output [7:0] rx);
    integer i;
    bit send_msb_first;
    begin
        // choose bit order: try MSB-first by default (set to 1)
        send_msb_first = 1; // MSB-first (protocol framing expected by axis_wb_master)

        rx = 8'h00;
        // Ensure SCLK idle low (CPOL=0)
        i_sclk = 1'b0;
        // Ensure SCLK idle low (CPOL=0)
        i_sclk = 1'b0;
        repeat(16) @(posedge i_clk);

        // Print either verbose trace or short TX marker depending on tb_verbose
        if (tb_verbose) begin
            $display("[SPI %0t] send_spi_byte (sync): TX=0x%02x msb_first=%0d", $time, tx, send_msb_first);
        end else begin
            // Non-verbose: print the TX byte only
            $display("SPI-TX: 0x%02x", tx);
        end

        for (i = 0; i < 8; i = i + 1) begin
            // select bit depending on order
            if (send_msb_first) begin
                spi_mosi = tx[7 - i];
            end else begin
                spi_mosi = tx[i];
            end

            // small settle before raising SCLK
            repeat(8) @(posedge i_clk);

            // SCLK rising edge: slave samples here
            i_sclk = 1'b1;
            repeat(16) @(posedge i_clk);

            // sample MISO at or just after rising edge
            if (send_msb_first) begin
                rx[7 - i] = spi_miso;
            end else begin
                rx[i] = spi_miso;
            end

            // drive SCLK low for next bit
            i_sclk = 1'b0;
            repeat(16) @(posedge i_clk);
        end

        // leave MOSI/SCLK in idle
        spi_mosi = 1'b0;
        i_sclk = 1'b0;

        // Non-verbose: print RX byte in hex
        if (tb_verbose) begin
            $display("[SPI %0t] send_spi_byte (sync): DONE TX=0x%02x RX=0x%02x", $time, tx, rx);
        end else begin
            $display("SPI-RX: 0x%02x", rx);
        end
    end
endtask

// SPI -> Wishbone transaction helper using the same global names
//
// Protocol (new spi_wb_master.sv format, all multi-byte values little-endian):
//   TX: [cmd 1B] [len 2B LE] [addr 4B LE] [data/pad N] [0xDA sync]
//   RX: [DA]     [resp]      [len echo]   [addr echo]  [data/ack]
//
// Response is shifted by 1 byte (SPI full-duplex).
// Length must be 4 bytes for single word R/W.
task automatic spi_wb_transaction(input bit is_read, input [31:0] addr, input [31:0] wdata, output [31:0] rdata);
    integer i;
    reg [7:0] tmp;
    reg [7:0] rx_bytes[0:15];  // Buffer for all received bytes
    integer byte_idx;
    begin
        if (tb_verbose) begin
            $display("[SPI TRX %0t] Start transaction (new protocol): %s addr=0x%08x wdata=0x%08x", $time, (is_read ? "READ" : "WRITE"), addr, wdata);
        end
        // Assert CS (active LOW)
        @(posedge i_clk);
        spi_cs_n = 1'b0;
        repeat (4) @(posedge i_clk);

        byte_idx = 0;

        // 1. Send Command - RX should be DA (sync from IDLE)
        send_spi_byte(is_read ? TB_READ_REQ : TB_WRITE_REQ, tmp);
        rx_bytes[byte_idx] = tmp; byte_idx++;
        if (tb_verbose) $display("[SPI TRX %0t] Cmd phase RX=0x%02x (expect DA)", $time, tmp);

        // 2. Send Length (2B, Little Endian: LSB first) - fixed 4 bytes
        //    RX should be resp (0x21 or 0x22)
        send_spi_byte(8'h04, tmp);  // len[7:0] = 4
        rx_bytes[byte_idx] = tmp; byte_idx++;
        
        send_spi_byte(8'h00, tmp);  // len[15:8] = 0
        rx_bytes[byte_idx] = tmp; byte_idx++;

        // 3. Send Address (4B, Little Endian: LSB first)
        //    RX echoes len
        send_spi_byte(addr[7:0], tmp);
        rx_bytes[byte_idx] = tmp; byte_idx++;
        
        send_spi_byte(addr[15:8], tmp);
        rx_bytes[byte_idx] = tmp; byte_idx++;
        
        send_spi_byte(addr[23:16], tmp);
        rx_bytes[byte_idx] = tmp; byte_idx++;
        
        send_spi_byte(addr[31:24], tmp);
        rx_bytes[byte_idx] = tmp; byte_idx++;

        if (!is_read) begin
            // 4. Write Data (4B, Little Endian)
            //    RX echoes addr
            send_spi_byte(wdata[7:0], tmp);
            rx_bytes[byte_idx] = tmp; byte_idx++;
            
            send_spi_byte(wdata[15:8], tmp);
            rx_bytes[byte_idx] = tmp; byte_idx++;
            
            send_spi_byte(wdata[23:16], tmp);
            rx_bytes[byte_idx] = tmp; byte_idx++;
            
            send_spi_byte(wdata[31:24], tmp);
            rx_bytes[byte_idx] = tmp; byte_idx++;

            // 5. Send Sync terminator (0xDA)
            //    RX should be EE ack for last byte
            send_spi_byte(TB_SYNC_BYTE, tmp);
            rx_bytes[byte_idx] = tmp; byte_idx++;

            // Verify response: rx_bytes[0]=DA, rx_bytes[1]=0x22
            if (rx_bytes[0] != TB_SYNC_BYTE || rx_bytes[1] != TB_WRITE_RESP) begin
                if (tb_verbose) $display("Warning: Write response mismatch: [0]=0x%02x (exp DA), [1]=0x%02x (exp 22)", rx_bytes[0], rx_bytes[1]);
            end

            spi_cs_n = 1'b1;
            repeat (20) @(posedge i_clk);
            rdata = 32'h0;

        end else begin
            // 4. Send Pad bytes to clock out read data (0x55)
            //    RX: addr echo then data
            for (i = 0; i < 4; i = i + 1) begin
                send_spi_byte(TB_PAD_BYTE, tmp);
                rx_bytes[byte_idx] = tmp; byte_idx++;
            end

            // 5. Send Sync terminator
            send_spi_byte(TB_SYNC_BYTE, tmp);
            rx_bytes[byte_idx] = tmp; byte_idx++;

            // Parse response:
            // rx_bytes[0] = DA (sync from IDLE)
            // rx_bytes[1] = 0x21 (read response)
            // rx_bytes[2:3] = len echo
            // rx_bytes[4:7] = addr echo
            // rx_bytes[8:11] = data (LSB first)
            
            if (rx_bytes[0] != TB_SYNC_BYTE || rx_bytes[1] != TB_READ_RESP) begin
                if (tb_verbose) $display("Warning: Read response mismatch: [0]=0x%02x (exp DA), [1]=0x%02x (exp 21)", rx_bytes[0], rx_bytes[1]);
                rdata = 32'hBAADF00D;
            end else begin
                // Extract data from rx_bytes[8:11] (Little Endian)
                rdata = {rx_bytes[11], rx_bytes[10], rx_bytes[9], rx_bytes[8]};
                if (tb_verbose) $display("[SPI TRX %0t] Read data: 0x%08x", $time, rdata);
            end

            spi_cs_n = 1'b1;
            repeat (20) @(posedge i_clk);
        end
    end
endtask
