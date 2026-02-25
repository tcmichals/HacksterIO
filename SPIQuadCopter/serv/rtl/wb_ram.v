// Simple Wishbone RAM for SERV testbench
`default_nettype none

module wb_ram #(
    parameter DEPTH = 32768,     // Bytes (increased for large firmware.hex)
    parameter MEMFILE = ""
)(
    input  wire        i_clk,
    input  wire        i_rst,
    
    // Wishbone interface
    input  wire [31:0] i_wb_adr,
    input  wire [31:0] i_wb_dat,
    input  wire [3:0]  i_wb_sel,
    input  wire        i_wb_we,
    input  wire        i_wb_stb,
    output reg  [31:0] o_wb_rdt,
    output reg         o_wb_ack
);

    localparam AW = $clog2(DEPTH);
    
    // Memory array (word-addressed)
    reg [31:0] mem [0:(DEPTH/4)-1];
    
    // Initialize from file if specified
    initial begin
        if (MEMFILE != "") begin
            $readmemh(MEMFILE, mem);
        end
    end
    
    // Wishbone handling - single cycle ack
    wire [AW-3:0] word_addr = i_wb_adr[AW-1:2];
    
    always @(posedge i_clk) begin
        if (i_rst) begin
            o_wb_ack <= 1'b0;
        end else begin
            o_wb_ack <= i_wb_stb && !o_wb_ack;
            
            if (i_wb_stb && !o_wb_ack) begin
                if (i_wb_we) begin
                    // Byte-enable write
                    if (i_wb_sel[0]) mem[word_addr][7:0]   <= i_wb_dat[7:0];
                    if (i_wb_sel[1]) mem[word_addr][15:8]  <= i_wb_dat[15:8];
                    if (i_wb_sel[2]) mem[word_addr][23:16] <= i_wb_dat[23:16];
                    if (i_wb_sel[3]) mem[word_addr][31:24] <= i_wb_dat[31:24];
                end
                o_wb_rdt <= mem[word_addr];
            end
        end
    end

endmodule

`default_nettype wire
