package tb_comm_pkg;

    // Shared constants for WB framing
    localparam logic [7:0] READ_REQ  = 8'hA1;
    localparam logic [7:0] WRITE_REQ = 8'hA2;
    localparam logic [7:0] READ_RESP = 8'hA3;
    localparam logic [7:0] WRITE_RESP = 8'hA4;

    // SPI send/receive MSB-first. The tasks expect the testbench to pass
    // references to spi signals so the package is reusable across benches.

    task automatic send_spi_byte(
        output logic [7:0] rx,
        input  logic [7:0] tx,
        inout  ref logic spi_mosi,
        input  ref logic spi_miso,
        inout  ref logic i_sclk,
        input  ref logic i_clk
    );
        integer i;
        begin
            rx = 8'h00;
            $display("[SPI %0t] send_spi_byte (pkg): TX=0x%02x", $time, tx);
            for (i = 7; i >= 0; i = i - 1) begin
                spi_mosi = tx[i];
                repeat (4) @(posedge i_clk);

                // SCLK High
                i_sclk = 1'b1;
                repeat (4) @(posedge i_clk);

                // Sample MISO
                rx[i] = spi_miso;

                // SCLK Low
                i_sclk = 1'b0;
                repeat (4) @(posedge i_clk);
            end
            $display("[SPI %0t] send_spi_byte (pkg): DONE TX=0x%02x RX=0x%02x", $time, tx, rx);
        end
    endtask

    // Use a parameterized spi_wb_transaction that operates on passed refs
    task automatic spi_wb_transaction(
        output ref logic [31:0] rdata,
        input bit is_read,
        input logic [31:0] addr,
        input logic [31:0] wdata,
        inout ref logic spi_cs_n,
        inout ref logic spi_mosi,
        input  ref logic spi_miso,
        inout  ref logic i_sclk,
        input  ref logic i_clk
    );
        integer i;
        logic [7:0] tmp;
        integer timeout;
        bit header_found;
        begin
            $display("[SPI TRX %0t] Start transaction (pkg): %s addr=0x%08x wdata=0x%08x", $time, (is_read ? "READ" : "WRITE"), addr, wdata);
            @(posedge i_clk);
            spi_cs_n = 1'b0;
            repeat (4) @(posedge i_clk);

            header_found = 0;

            // 1. Send Command
            send_spi_byte(tmp, (is_read ? READ_REQ : WRITE_REQ), spi_mosi, spi_miso, i_sclk, i_clk);
            $display("[SPI TRX %0t] Cmd phase RX=0x%02x", $time, tmp);
            if (tmp == (is_read ? READ_RESP : WRITE_RESP)) begin
                header_found = 1;
                $display("[SPI TRX %0t] Header matched immediately: 0x%02x", $time, tmp);
            end

            // 2. Send Address (MSB First)
            send_spi_byte(tmp, addr[31:24], spi_mosi, spi_miso, i_sclk, i_clk);
            send_spi_byte(tmp, addr[23:16], spi_mosi, spi_miso, i_sclk, i_clk);
            send_spi_byte(tmp, addr[15:8], spi_mosi, spi_miso, i_sclk, i_clk);
            send_spi_byte(tmp, addr[7:0], spi_mosi, spi_miso, i_sclk, i_clk);

            // 3. Send Length (MSB First: 00 01)
            send_spi_byte(tmp, 8'h00, spi_mosi, spi_miso, i_sclk, i_clk);
            send_spi_byte(tmp, 8'h04, spi_mosi, spi_miso, i_sclk, i_clk);

            if (!is_read) begin
                // Write Data (LSB First)
                send_spi_byte(tmp, wdata[7:0], spi_mosi, spi_miso, i_sclk, i_clk);
                send_spi_byte(tmp, wdata[15:8], spi_mosi, spi_miso, i_sclk, i_clk);
                send_spi_byte(tmp, wdata[23:16], spi_mosi, spi_miso, i_sclk, i_clk);
                send_spi_byte(tmp, wdata[31:24], spi_mosi, spi_miso, i_sclk, i_clk);

                timeout = 0;
                while (!header_found && timeout < 50) begin
                    send_spi_byte(tmp, 8'h00, spi_mosi, spi_miso, i_sclk, i_clk);
                    if (tmp == WRITE_RESP) header_found = 1;
                    timeout++;
                end

                if (!header_found) $display("Warning: Write Response Header (A4) not found (pkg)");

                spi_cs_n = 1'b1;
                repeat (20) @(posedge i_clk);

            end else begin
                // Read
                timeout = 0;
                while (!header_found && timeout < 50) begin
                    send_spi_byte(tmp, 8'h00, spi_mosi, spi_miso, i_sclk, i_clk);
                    $display("[SPI TRX %0t] Poll RX=0x%02x (timeout=%0d)", $time, tmp, timeout);
                    if (tmp == READ_RESP) header_found = 1;
                    timeout++;
                end

                if (!header_found) begin
                    $display("Error: Read Response Header (A3) not found (pkg)");
                    rdata = 32'hBAADF00D;
                end else begin
                    send_spi_byte(tmp, 8'h00, spi_mosi, spi_miso, i_sclk, i_clk);
                    $display("[SPI TRX %0t] Drained Echo: 0x%02x", $time, tmp);

                    rdata = 0;
                    for (i = 0; i < 4; i = i + 1) begin
                        send_spi_byte(tmp, 8'h00, spi_mosi, spi_miso, i_sclk, i_clk);
                        $display("[SPI TRX %0t] Data[%0d] RX=0x%02x", $time, i, tmp);
                        rdata = rdata | (tmp << (i*8));
                    end
                end

                spi_cs_n = 1'b1;
                repeat (20) @(posedge i_clk);
            end
        end
    endtask

endpackage
