module shared_buffer_ram #(
    parameter ADDR_WIDTH = 6, // 64 bytes
    parameter DATA_WIDTH = 8
)(
    input  logic clk,
    input  logic [ADDR_WIDTH-1:0] addr,
    input  logic [DATA_WIDTH-1:0] din,
    input  logic we,
    output logic [DATA_WIDTH-1:0] dout
);
    reg [DATA_WIDTH-1:0] ram [2**ADDR_WIDTH-1:0];
    
    // Yosys/Gowin BRAM inference template
    always @(posedge clk) begin
        if (we) ram[addr] <= din;
        dout <= ram[addr];
    end
endmodule
