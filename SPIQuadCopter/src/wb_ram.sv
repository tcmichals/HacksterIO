/**
 * wb_ram.sv - Wishbone RAM with Memory Initialization
 *
 * Supports:
 * - Verilog $readmemh for simulation and Gowin synthesis
 * - Vivado synthesis with .coe file initialization
 *
 * For Vivado:
 *   Set MEMFILE to the .mem file path
 *   Use "ram_style" attribute for block RAM inference
 *   For .coe initialization: use IP Catalog Block Memory Generator
 *
 * Memory Map:
 *   Address 0x00000000 to (DEPTH*4)-1
 *
 * Parameters:
 *   DEPTH   - Number of 32-bit words (default: 8192 = 32KB)
 *   MEMFILE - .mem file path for initialization (optional)
 */

module wb_ram #(
    parameter DEPTH   = 8192,     // 32KB default (8192 x 4 bytes)
    parameter MEMFILE = ""        // Optional .mem file for initialization
) (
    input  wire        i_clk,
    input  wire        i_rst,
    
    // Wishbone Slave Interface
    input  wire [31:0] i_wb_adr,
    input  wire [31:0] i_wb_dat,
    input  wire [3:0]  i_wb_sel,
    input  wire        i_wb_we,
    input  wire        i_wb_stb,
    output reg  [31:0] o_wb_rdt,
    output reg         o_wb_ack
);

    // Address bits needed for depth
    localparam ADDR_WIDTH = $clog2(DEPTH);
    
    // RAM storage
    (* ram_style = "block" *) reg [31:0] mem [0:DEPTH-1];
    
    // Word address (drop byte offset bits [1:0])
    wire [ADDR_WIDTH-1:0] word_addr = i_wb_adr[ADDR_WIDTH+1:2];
    
    // RAM initialization
    initial begin
        if (MEMFILE != "") begin
            $readmemh(MEMFILE, mem);
        end
    end
    
    // Synchronous RAM with byte enables
    always @(posedge i_clk) begin
        if (i_rst) begin
            o_wb_ack <= 1'b0;
        end else begin
            o_wb_ack <= i_wb_stb & ~o_wb_ack;
            
            if (i_wb_stb) begin
                // Read
                o_wb_rdt <= mem[word_addr];
                
                // Write with byte enables
                if (i_wb_we) begin
                    if (i_wb_sel[0]) mem[word_addr][7:0]   <= i_wb_dat[7:0];
                    if (i_wb_sel[1]) mem[word_addr][15:8]  <= i_wb_dat[15:8];
                    if (i_wb_sel[2]) mem[word_addr][23:16] <= i_wb_dat[23:16];
                    if (i_wb_sel[3]) mem[word_addr][31:24] <= i_wb_dat[31:24];
                end
            end
        end
    end

endmodule
