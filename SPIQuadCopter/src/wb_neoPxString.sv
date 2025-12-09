/**
 * Wishbone NeoPixel String Controller
 * 
 * Exposes a Wishbone interface for controlling a NeoPixel (WS2812) string.
 * Address map:
 *   0x00: Pixel Data (W) - Write 24-bit RGB value for next pixel
 *   0x04: Control (W)    - Write to trigger update
 *   0x08: Status (R)     - Read busy status
 */

module wb_neoPxString #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter NUM_PIXELS = 8
) (
    input  wire                  wb_clk_i,
    input  wire                  wb_rst_i,
    input  wire [ADDR_WIDTH-1:0] wb_adr_i,
    input  wire [DATA_WIDTH-1:0] wb_dat_i,
    input  wire                  wb_we_i,
    input  wire [3:0]            wb_sel_i,
    input  wire                  wb_stb_i,
    input  wire                  wb_cyc_i,
    output reg  [DATA_WIDTH-1:0] wb_dat_o,
    output reg                   wb_ack_o,
    output wire                  wb_stall_o,
    output wire                  neopixel_out
);

    // Internal pixel buffer
    reg [23:0] pixel_buffer [0:NUM_PIXELS-1];
    reg [3:0]  pixel_index;
    reg        update_req;
    reg        busy;

    // Address decode
    wire [3:0] addr = wb_adr_i[5:2];
    
    always @(posedge wb_clk_i) begin
        if (wb_rst_i) begin
            wb_ack_o <= 1'b0;
            wb_dat_o <= 32'h0;
            pixel_index <= 0;
            update_req <= 1'b0;
            busy <= 1'b0;
        end else begin
            wb_ack_o <= wb_cyc_i & wb_stb_i & ~wb_ack_o;
            if (wb_cyc_i & wb_stb_i) begin
                if (wb_we_i) begin
                    case (addr)
                        4'h0: begin
                            pixel_buffer[pixel_index] <= wb_dat_i[23:0];
                            pixel_index <= pixel_index + 1;
                        end
                        4'h1: begin
                            update_req <= 1'b1;
                            busy <= 1'b1;
                        end
                    endcase
                end else begin
                    case (addr)
                        4'h2: wb_dat_o <= {31'b0, busy};
                        default: wb_dat_o <= 32'h0;
                    endcase
                end
            end
            // Simulate update complete (replace with real NeoPixel driver)
            if (update_req) begin
                update_req <= 1'b0;
                busy <= 1'b0;
                pixel_index <= 0;
            end
        end
    end

    assign wb_stall_o = 1'b0;
    assign neopixel_out = 1'b0; // Replace with real NeoPixel output logic

endmodule
