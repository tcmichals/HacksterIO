// tb_comm.sv - simple include-based shared SPI/WB tasks for testbenches

// Framing constants
localparam logic [7:0] TB_READ_REQ  = 8'hA1;
localparam logic [7:0] TB_WRITE_REQ = 8'hA2;
localparam logic [7:0] TB_READ_RESP = 8'hA3;
localparam logic [7:0] TB_WRITE_RESP = 8'hA4;

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
// Protocol note:
// The DUT (axis_wb_master + surrounding mux) expects SPI frames in the
// following order:
//   1) Command byte (READ_REQ=0xA1 or WRITE_REQ=0xA2)
//   2) Address (MSB first: addr[31:24], addr[23:16], addr[15:8], addr[7:0])
//   3) Length (MSB first; e.g. 0x00 0x04 for a 4-byte transfer)
//   4) For WRITE: data bytes (LSB first per word in this TB); for READ: poll
//      by sending 0x00 until the DUT responds with READ_RESP (0xA3)
//
// This helper follows that ordering so the TB matches DUT expectations. Do
// not reorder LEN/ADDR unless the DUT is changed accordingly.
task automatic spi_wb_transaction(input bit is_read, input [31:0] addr, input [31:0] wdata, output [31:0] rdata);
    integer i;
    reg [7:0] tmp;
    integer timeout;
    bit header_found;
    begin
        if (tb_verbose) begin
            $display("[SPI TRX %0t] Start transaction (shared): %s addr=0x%08x wdata=0x%08x", $time, (is_read ? "READ" : "WRITE"), addr, wdata);
        end
        // Assert CS (active LOW)
        @(posedge i_clk);
        spi_cs_n = 1'b0;
        repeat (4) @(posedge i_clk);

        header_found = 0;

        // 1. Send Command
        send_spi_byte(is_read ? TB_READ_REQ : TB_WRITE_REQ, tmp);
        $display("[SPI TRX %0t] Cmd phase RX=0x%02x", $time, tmp);
        if (tmp == (is_read ? TB_READ_RESP : TB_WRITE_RESP)) begin
            header_found = 1;
            if (tb_verbose) $display("[SPI TRX %0t] Header matched immediately: 0x%02x", $time, tmp);
        end

        // 2. Send Address (MSB First)
        send_spi_byte(addr[31:24], tmp);
        if (tmp == (is_read ? TB_READ_RESP : TB_WRITE_RESP)) header_found = 1;

        send_spi_byte(addr[23:16], tmp);
        if (tmp == (is_read ? TB_READ_RESP : TB_WRITE_RESP)) header_found = 1;

        send_spi_byte(addr[15:8], tmp);
        if (tmp == (is_read ? TB_READ_RESP : TB_WRITE_RESP)) header_found = 1;

        send_spi_byte(addr[7:0], tmp);
        if (tmp == (is_read ? TB_READ_RESP : TB_WRITE_RESP)) header_found = 1;

        // 3. Send Length (MSB First: 00 01)
        send_spi_byte(8'h00, tmp);
        if (tmp == (is_read ? TB_READ_RESP : TB_WRITE_RESP)) header_found = 1;

        send_spi_byte(8'h04, tmp);
        if (tmp == (is_read ? TB_READ_RESP : TB_WRITE_RESP)) header_found = 1;

        if (header_found && tb_verbose) $display("[SPI TRX %0t] Header matched during Addr/Len phase", $time);

        if (!is_read) begin
            // Write Data (LSB First)
            send_spi_byte(wdata[7:0], tmp);
            if (tmp == (is_read ? TB_READ_RESP : TB_WRITE_RESP)) header_found = 1;
            
            send_spi_byte(wdata[15:8], tmp);
            if (tmp == (is_read ? TB_READ_RESP : TB_WRITE_RESP)) header_found = 1;
            
            send_spi_byte(wdata[23:16], tmp);
            if (tmp == (is_read ? TB_READ_RESP : TB_WRITE_RESP)) header_found = 1;
            
            send_spi_byte(wdata[31:24], tmp);
            if (tmp == (is_read ? TB_READ_RESP : TB_WRITE_RESP)) header_found = 1;

                timeout = 0;
                while (!header_found && timeout < 50) begin
                    send_spi_byte(8'h00, tmp);
                    if (tmp == TB_WRITE_RESP) header_found = 1;
                    timeout++;
                end

                if (!header_found && tb_verbose) $display("Warning: Write Response Header (A4) not found (shared)");

            spi_cs_n = 1'b1;
            repeat (20) @(posedge i_clk);

        end else begin
            // Read
            timeout = 0;
            while (!header_found && timeout < 50) begin
                send_spi_byte(8'h00, tmp);
                if (tb_verbose) $display("[SPI TRX %0t] Poll RX=0x%02x (timeout=%0d)", $time, tmp, timeout);
                if (tmp == TB_READ_RESP) header_found = 1;
                timeout++;
            end

            if (!header_found) begin
                if (tb_verbose) $display("Error: Read Response Header (A3) not found (shared)");
                rdata = 32'hBAADF00D;
            end else begin
                 // Drain the last Echo byte (Ln0)
                 send_spi_byte(8'h00, tmp);
                 if (tb_verbose) $display("[SPI TRX %0t] Drained Echo: 0x%02x", $time, tmp);
                 
                // Read 4 bytes of Data (LSB first)
                rdata = 0;
                for (i = 0; i < 4; i = i + 1) begin
                    send_spi_byte(8'h00, tmp);
                    if (tb_verbose) $display("[SPI TRX %0t] Data[%0d] RX=0x%02x", $time, i, tmp);
                    rdata = rdata | (tmp << (i*8));
                end
            end

            spi_cs_n = 1'b1;
            repeat (20) @(posedge i_clk);
        end
    end
endtask
