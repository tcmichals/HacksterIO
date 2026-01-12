`timescale 1ns / 1ps

module tb_wishbone_master_axis;

    // Parameters
    localparam ADDR_WIDTH = 32;
    localparam DATA_WIDTH = 32;
    localparam CLK_PERIOD = 10;

    // Signals
    logic clk;
    logic rst_n;

    // AXI Stream Slave (Command)
    logic [7:0] s_axis_tdata;
    logic       s_axis_tvalid;
    logic       s_axis_tready;
    logic       s_axis_tlast;

    // AXI Stream Master (Response)
    logic [7:0] m_axis_tdata;
    logic       m_axis_tvalid;
    logic       m_axis_tready;
    logic       m_axis_tlast;

    // Wishbone Master
    logic [ADDR_WIDTH-1:0]   wb_adr_o;
    logic [DATA_WIDTH-1:0]   wb_dat_o;
    logic [DATA_WIDTH-1:0]   wb_dat_i;
    logic                    wb_we_o;
    logic                    wb_stb_o;
    logic                    wb_cyc_o;
    logic [DATA_WIDTH/8-1:0] wb_sel_o;
    logic                    wb_ack_i;
    logic                    wb_err_i;

    // Helper for Wishbone Slave Simulation
    logic [31:0] memory [0:255]; // Small memory for testing
    // Cycle-based watchdog (module-scope)
`ifndef MAX_CYCLES
`define MAX_CYCLES 100000000
`endif
    localparam int MAX_CYCLES = `MAX_CYCLES; // number of clock cycles before watchdog triggers
    integer cycle_count;

    // Instantiation
    wishbone_master_axis #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tready(s_axis_tready),
        .s_axis_tlast(s_axis_tlast),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready),
        .m_axis_tlast(m_axis_tlast),
        .wb_adr_o(wb_adr_o),
        .wb_dat_o(wb_dat_o),
        .wb_dat_i(wb_dat_i),
        .wb_we_o(wb_we_o),
        .wb_stb_o(wb_stb_o),
        .wb_cyc_o(wb_cyc_o),
        .wb_sel_o(wb_sel_o),
        .wb_ack_i(wb_ack_i),
        .wb_err_i(wb_err_i)
    );

    // Monitor DUT for timeout alert and terminate simulation if asserted
    always @(posedge clk) begin
        if (dut.timeout_alert) begin
            $display("TESTBENCH: DUT timeout_alert asserted - terminating simulation");
            $finish;
        end
    end

    // Cycle-based watchdog process: runs at module scope
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) cycle_count <= 0;
        else if (cycle_count < MAX_CYCLES) cycle_count <= cycle_count + 1;
        else begin
            $display("TESTBENCH: Cycle watchdog exceeded %0d cycles - terminating", MAX_CYCLES);
            $finish;
        end
    end

    // Clock Generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, tb_wishbone_master_axis);
    end

    // Wishbone Slave Logic (Simple RAM)
    always @(posedge clk) begin
        wb_ack_i <= 0;
        wb_dat_i <= 0;
        if (wb_cyc_o && wb_stb_o && !wb_ack_i) begin
            wb_ack_i <= 1; // 1 cycle latency
            if (wb_we_o) begin
                memory[wb_adr_o[9:2]] <= wb_dat_o; // Word aligned index
                $display("WB SLAVE: Write Addr: %h Data: %h", wb_adr_o, wb_dat_o);
            end else begin
                wb_dat_i <= memory[wb_adr_o[9:2]];
                $display("WB SLAVE: Read  Addr: %h Data: %h", wb_adr_o, memory[wb_adr_o[9:2]]);
            end
        end
    end

    // Test Sequence
    initial begin
        // Init
        rst_n = 0;
        s_axis_tvalid = 0;
        s_axis_tdata = 0;
        m_axis_tready = 1; 
        s_axis_tlast = 0;
        wb_err_i = 0;
        
        // Reset
        #100;
        rst_n = 1;
        #20;

        

        $display("TEST: Starting Burst Write Transaction (2 Words)...");
        // 1. Burst Write (CMD=0x01, Addr=0x10, Len=0x0002)
        send_byte(8'h01); // CMD Write
        
        wait_response(8'hA5); // ACK

        send_byte(8'h00); // Addr[31:24]
        send_byte(8'h00); // Addr[23:16]
        send_byte(8'h00); // Addr[15:8]
        send_byte(8'h10); // Addr[7:0]

        send_byte(8'h00); // Len[15:8]
        send_byte(8'h02); // Len[7:0] = 2 Words
        send_byte(8'h00); // Dummy Byte

        // Word 0: CAFEBABE
        send_byte(8'hCA); 
        send_byte(8'hFE); 
        send_byte(8'hBA); 
        send_byte(8'hBE); 

        // Word 1: DEADBEEF
        send_byte(8'hDE); 
        send_byte(8'hAD); 
        send_byte(8'hBE); 
        send_byte(8'hEF); 
        
        wait_response(8'h01); // Final Status
        $display("TEST: Burst Write Complete.");

        #50;

        $display("TEST: Starting Burst Read Transaction (2 Words)...");
        // 2. Burst Read (CMD=0x00, Addr=0x10, Len=0x0002)
        send_byte(8'h00); // CMD Read
        
        wait_response(8'hA5); // ACK

        send_byte(8'h00);
        send_byte(8'h00);
        send_byte(8'h00);
        send_byte(8'h10);

        send_byte(8'h00);
        send_byte(8'h02); // 2 Words
        send_byte(8'h00); // Dummy Byte

        // Expect Word 0: CAFEBABE
        wait_response(8'hCA);
        wait_response(8'hFE);
        wait_response(8'hBA);
        wait_response(8'hBE);

        // Expect Word 1: DEADBEEF
        wait_response(8'hDE);
        wait_response(8'hAD);
        wait_response(8'hBE);
        wait_response(8'hEF);

        $display("TEST: Burst Read Complete.");

        #100;
        $finish;
    end

    // Tasks
    task send_byte(input [7:0] byte_in);
        begin
            s_axis_tdata <= byte_in;
            s_axis_tvalid <= 1;
            do begin
                @(posedge clk);
            end while (!s_axis_tready);
            s_axis_tvalid <= 0;
            // Removed small delay to stress back-to-back if needed, 
            // but for safety add 1 cycle gap if SPI is slow.
        end
    endtask

    task wait_response(input [7:0] expected_byte);
        begin
            // Wait for Valid
            while (!m_axis_tvalid) @(posedge clk);
            
            if (m_axis_tdata !== expected_byte) begin
                $error("Mismatch! Expected: %h, Got: %h", expected_byte, m_axis_tdata);
            end else begin
                $display("Verified Response Byte: %h", m_axis_tdata);
            end
            
            // Handshake
            @(posedge clk); 
            // In continuous ready mode, we just sampled it.
        end
    endtask

endmodule
