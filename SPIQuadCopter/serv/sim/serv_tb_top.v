// SERV Testbench Top-Level for Verilator
// Instantiates SERV CPU + RAM + simple peripheral
`default_nettype none

module serv_tb_top (
    input  wire        i_clk,
    input  wire        i_rst,
    
    // Outputs for testbench monitoring
    output wire [31:0] o_pc,
    output wire        o_pc_valid,
    output wire [31:0] o_gpio
);

    parameter MEMSIZE = 32768;  // 32KB (increased for large firmware.hex)
    parameter MEMFILE = "";

    // Memory bus
    wire [31:0] wb_mem_adr;
    wire [31:0] wb_mem_dat;
    wire [3:0]  wb_mem_sel;
    wire        wb_mem_we;
    wire        wb_mem_stb;
    wire [31:0] wb_mem_rdt;
    wire        wb_mem_ack;

    // Extension (peripheral) bus  
    wire [31:0] wb_ext_adr;
    wire [31:0] wb_ext_dat;
    wire [3:0]  wb_ext_sel;
    wire        wb_ext_we;
    wire        wb_ext_stb;
    wire        wb_ext_cyc;
    wire [31:0] wb_ext_rdt;
    wire        wb_ext_ack;

    // SERV CPU wrapper
    serv_wb_top #(
        .MEMSIZE (MEMSIZE),
        .MEMFILE (MEMFILE)
    ) u_serv (
        .i_clk        (i_clk),
        .i_rst        (i_rst),
        
        // External peripheral bus
        .o_wb_ext_adr (wb_ext_adr),
        .o_wb_ext_dat (wb_ext_dat),
        .o_wb_ext_sel (wb_ext_sel),
        .o_wb_ext_we  (wb_ext_we),
        .o_wb_ext_stb (wb_ext_stb),
        .o_wb_ext_cyc (wb_ext_cyc),
        .i_wb_ext_rdt (wb_ext_rdt),
        .i_wb_ext_ack (wb_ext_ack),
        
        // Memory bus
        .o_wb_mem_adr (wb_mem_adr),
        .o_wb_mem_dat (wb_mem_dat),
        .o_wb_mem_sel (wb_mem_sel),
        .o_wb_mem_we  (wb_mem_we),
        .o_wb_mem_stb (wb_mem_stb),
        .i_wb_mem_rdt (wb_mem_rdt),
        .i_wb_mem_ack (wb_mem_ack),
        
        // Debug
        .o_debug_pc    (o_pc),
        .o_debug_valid (o_pc_valid)
    );

    // Instruction/Data RAM
    wb_ram #(
        .DEPTH   (MEMSIZE),
        .MEMFILE (MEMFILE)
    ) u_ram (
        .i_clk    (i_clk),
        .i_rst    (i_rst),
        .i_wb_adr (wb_mem_adr),
        .i_wb_dat (wb_mem_dat),
        .i_wb_sel (wb_mem_sel),
        .i_wb_we  (wb_mem_we),
        .i_wb_stb (wb_mem_stb),
        .o_wb_rdt (wb_mem_rdt),
        .o_wb_ack (wb_mem_ack)
    );

    // Simple GPIO peripheral at 0x4000_0000
    // Write to toggle, read returns current value
    reg [31:0] gpio_reg;
    reg        gpio_ack;
    
    assign o_gpio = gpio_reg;
    
    always @(posedge i_clk) begin
        if (i_rst) begin
            gpio_reg <= 32'h0;
            gpio_ack <= 1'b0;
        end else begin
            gpio_ack <= wb_ext_stb && !gpio_ack;
            
            if (wb_ext_stb && wb_ext_we && !gpio_ack) begin
                gpio_reg <= wb_ext_dat;
                $display("[%0t] GPIO write: 0x%08x", $time, wb_ext_dat);
            end
        end
    end
    
    assign wb_ext_rdt = gpio_reg;
    assign wb_ext_ack = gpio_ack;

    // Debug UART at 0x40000110
    wire uart_dbg_tx;
    simple_uart #(
        .WB_ADDR(32'h40000110),
        .CLK_FREQ(10000000), // match your system clock
        .BAUD(115200)
    ) u_uart_dbg (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_wb_adr(wb_ext_adr),
        .i_wb_dat(wb_ext_dat),
        .i_wb_we(wb_ext_we),
        .i_wb_stb(wb_ext_stb),
        .o_wb_ack(),
        .o_uart_tx(uart_dbg_tx)
    );

    // Optionally, expose debug UART TX as a testbench output
    // output wire o_uart_dbg_tx;
    // assign o_uart_dbg_tx = uart_dbg_tx;

    // Simulation finish detection
    // Convention: write 0x00000001 to GPIO means "test passed"
    //             write 0xDEADBEEF to GPIO means "test failed"
    always @(posedge i_clk) begin
        if (wb_ext_stb && wb_ext_we && !gpio_ack) begin
            if (wb_ext_dat == 32'h00000001) begin
                $display("[%0t] TEST PASSED!", $time);
                $finish;
            end else if (wb_ext_dat == 32'hDEADBEEF) begin
                $display("[%0t] TEST FAILED!", $time);
                $finish;
            end
        end
    end

endmodule

`default_nettype wire
