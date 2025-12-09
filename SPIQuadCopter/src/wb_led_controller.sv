/**
 * Wishbone LED Controller
 * 
 * Simple LED register interface via Wishbone bus
 * Address map:
 *   0x00: LED output register (RW) - bits [3:0] control LEDs 0-3
 *   0x04: LED mode register (RW)   - bits [3:0] select mode (0=manual, 1=blink, etc.)
 */

module wb_led_controller #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter SELECT_WIDTH = (DATA_WIDTH/8)
) (
    input  wire                    clk,
    input  wire                    rst,
    
    // Wishbone slave interface
    input  wire [ADDR_WIDTH-1:0]   wbs_adr_i,
    input  wire [DATA_WIDTH-1:0]   wbs_dat_i,
    output reg  [DATA_WIDTH-1:0]   wbs_dat_o,
    input  wire                    wbs_we_i,
    input  wire [SELECT_WIDTH-1:0] wbs_sel_i,
    input  wire                    wbs_stb_i,
    output reg                     wbs_ack_o,
    output wire                    wbs_err_o,
    output wire                    wbs_rty_o,
    input  wire                    wbs_cyc_i,
    
    // LED outputs
    output reg  [3:0]              led_out,
    output reg  [3:0]              led_mode
);

    localparam ADDR_LED_OUT  = 2'h0;
    localparam ADDR_LED_MODE = 2'h1;
    
    // Decode address
    wire [1:0] addr_bits = wbs_adr_i[3:2];
    
    // Wishbone protocol
    assign wbs_err_o = 1'b0;
    assign wbs_rty_o = 1'b0;
    
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            wbs_ack_o <= 1'b0;
            wbs_dat_o <= 32'h0;
            led_out <= 4'h0;
            led_mode <= 4'h0;
        end else begin
            wbs_ack_o <= wbs_stb_i && wbs_cyc_i;
            
            if (wbs_stb_i && wbs_cyc_i) begin
                if (wbs_we_i) begin
                    // Write operation
                    case (addr_bits)
                        ADDR_LED_OUT: begin
                            if (wbs_sel_i[0]) led_out <= wbs_dat_i[3:0];
                        end
                        ADDR_LED_MODE: begin
                            if (wbs_sel_i[0]) led_mode <= wbs_dat_i[3:0];
                        end
                    endcase
                end else begin
                    // Read operation
                    case (addr_bits)
                        ADDR_LED_OUT: begin
                            wbs_dat_o <= {28'h0, led_out};
                        end
                        ADDR_LED_MODE: begin
                            wbs_dat_o <= {28'h0, led_mode};
                        end
                        default: begin
                            wbs_dat_o <= 32'hDEADBEEF;
                        end
                    endcase
                end
            end
        end
    end

endmodule
