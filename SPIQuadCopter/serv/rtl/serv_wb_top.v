// SERV Wishbone Top - Wrapper for Verilator testbench
// Uses servile wrapper with internal RAM and external Wishbone peripheral bus
`default_nettype none

module serv_wb_top #(
    parameter MEMSIZE = 2048,  // 2KB RAM (512 words)
    parameter MEMFILE = ""     // Firmware hex file
)(
    input  wire        i_clk,
    input  wire        i_rst,
    
    // External Wishbone master (to peripherals)
    output wire [31:0] o_wb_ext_adr,
    output wire [31:0] o_wb_ext_dat,
    output wire [3:0]  o_wb_ext_sel,
    output wire        o_wb_ext_we,
    output wire        o_wb_ext_stb,
    output wire        o_wb_ext_cyc,
    input  wire [31:0] i_wb_ext_rdt,
    input  wire        i_wb_ext_ack,
    
    // Memory interface (directly exposed for testbench visibility)
    output wire [31:0] o_wb_mem_adr,
    output wire [31:0] o_wb_mem_dat,
    output wire [3:0]  o_wb_mem_sel,
    output wire        o_wb_mem_we,
    output wire        o_wb_mem_stb,
    input  wire [31:0] i_wb_mem_rdt,
    input  wire        i_wb_mem_ack,
    
    // Debug outputs
    output wire [31:0] o_debug_pc,
    output wire        o_debug_valid
);

    // Parameters for servile
    localparam WIDTH = 1;           // Bit-serial (1-bit datapath)
    localparam RF_WIDTH = 2;        // Register file width = 2*WIDTH
    localparam REGS = 32;           // 32 registers (no CSR)
    localparam RF_L2D = $clog2(REGS * 32 / RF_WIDTH);  // RF address bits

    // Register file SRAM interface
    wire [RF_L2D-1:0]   rf_waddr;
    wire [RF_WIDTH-1:0] rf_wdata;
    wire                rf_wen;
    wire [RF_L2D-1:0]   rf_raddr;
    wire [RF_WIDTH-1:0] rf_rdata;
    wire                rf_ren;

    // Internal wires for memory bus
    wire [31:0] wb_mem_adr;
    wire [31:0] wb_mem_dat;
    wire [3:0]  wb_mem_sel;
    wire        wb_mem_we;
    wire        wb_mem_stb;
    wire [31:0] wb_mem_rdt;
    wire        wb_mem_ack;

    // Expose memory bus for external connection
    assign o_wb_mem_adr = wb_mem_adr;
    assign o_wb_mem_dat = wb_mem_dat;
    assign o_wb_mem_sel = wb_mem_sel;
    assign o_wb_mem_we  = wb_mem_we;
    assign o_wb_mem_stb = wb_mem_stb;
    assign wb_mem_rdt   = i_wb_mem_rdt;
    assign wb_mem_ack   = i_wb_mem_ack;

    // Debug: track PC (memory address during instruction fetch)
    assign o_debug_pc = wb_mem_adr;
    assign o_debug_valid = wb_mem_stb && wb_mem_ack && !wb_mem_we;

    // SERV CPU with Wishbone interface (servile wrapper)
    servile #(
        .width          (WIDTH),
        .reset_pc       (32'h0000_0000),
        .reset_strategy ("MINI"),
        .rf_width       (RF_WIDTH),
        .sim            (1'b0),
        .debug          (1'b0),
        .with_c         (1'b0),    // No compressed instructions
        .with_csr       (1'b0),    // No CSR (saves ~100 LUTs)
        .with_mdu       (1'b0)     // No multiply/divide
    ) u_servile (
        .i_clk        (i_clk),
        .i_rst        (i_rst),
        .i_timer_irq  (1'b0),
        
        // Memory bus (instruction + data arbitrated)
        .o_wb_mem_adr (wb_mem_adr),
        .o_wb_mem_dat (wb_mem_dat),
        .o_wb_mem_sel (wb_mem_sel),
        .o_wb_mem_we  (wb_mem_we),
        .o_wb_mem_stb (wb_mem_stb),
        .i_wb_mem_rdt (wb_mem_rdt),
        .i_wb_mem_ack (wb_mem_ack),
        
        // Extension bus (memory-mapped peripherals at 0x4000_0000+)
        .o_wb_ext_adr (o_wb_ext_adr),
        .o_wb_ext_dat (o_wb_ext_dat),
        .o_wb_ext_sel (o_wb_ext_sel),
        .o_wb_ext_we  (o_wb_ext_we),
        .o_wb_ext_stb (o_wb_ext_stb),
        .i_wb_ext_rdt (i_wb_ext_rdt),
        .i_wb_ext_ack (i_wb_ext_ack),
        
        // Register file SRAM interface
        .o_rf_waddr   (rf_waddr),
        .o_rf_wdata   (rf_wdata),
        .o_rf_wen     (rf_wen),
        .o_rf_raddr   (rf_raddr),
        .i_rf_rdata   (rf_rdata),
        .o_rf_ren     (rf_ren)
    );

    // Register file RAM (dual-port)
    reg [RF_WIDTH-1:0] rf_ram [0:(1<<RF_L2D)-1];
    
    always @(posedge i_clk) begin
        if (rf_wen)
            rf_ram[rf_waddr] <= rf_wdata;
    end
    
    reg [RF_WIDTH-1:0] rf_rdata_r;
    always @(posedge i_clk)
        rf_rdata_r <= rf_ram[rf_raddr];
    
    assign rf_rdata = rf_rdata_r;

    // Tie off ext_cyc (servile uses stb only)
    assign o_wb_ext_cyc = o_wb_ext_stb;

endmodule

`default_nettype wire
