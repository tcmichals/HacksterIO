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
    parameter SELECT_WIDTH = (DATA_WIDTH/8),
    parameter LED_WIDTH = 4,
    parameter LED_POLARITY = 0 // 0: Active Low (default), 1: Active High
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
    output wire [LED_WIDTH-1:0]    led_out

);

    localparam ADDR_LED_OUT     = 2'h0;
    localparam ADDR_LED_TOGGLE  = 2'h1;
    localparam ADDR_LED_CLEAR   = 2'h2;
    localparam ADDR_LED_SET     = 2'h3;

    // Decode address
    wire [1:0] addr_bits = wbs_adr_i[3:2];
    
    // Wishbone protocol
    assign wbs_err_o = 1'b0;
    assign wbs_rty_o = 1'b0;
    
    reg prev_stb_cyc;
    reg [LED_WIDTH-1:0] led_out_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            prev_stb_cyc <= 1'b0;
            wbs_ack_o <= 1'b0;
            wbs_dat_o <= 32'h0;
            led_out_reg <= {LED_WIDTH{1'b0}};

        end else begin
            // Create a one-cycle ack when stb & cyc are asserted (rising detection)

            if (wbs_stb_i && wbs_cyc_i) begin
                if (wbs_we_i) begin
                    // Write operation: address selects the operation
                    if (~wbs_ack_o) begin
                        wbs_ack_o <= 1;
                        case (addr_bits)
                            ADDR_LED_OUT: begin
                                if (wbs_sel_i[0]) begin
                                    led_out_reg <= wbs_dat_i[LED_WIDTH-1:0];
                                    $display("%0t wb_led_controller: WRITE LED_OUT addr=%h data=%h sel=%b", $time, wbs_adr_i, wbs_dat_i, wbs_sel_i);
                                end
                            end
                            ADDR_LED_TOGGLE: begin
                                if (wbs_sel_i[0]) begin
                                    led_out_reg <= led_out_reg ^ wbs_dat_i[LED_WIDTH-1:0];
                                    $display("%0t wb_led_controller: TOGGLE LED_OUT addr=%h data=%h sel=%b -> %h", $time, wbs_adr_i, wbs_dat_i, wbs_sel_i, led_out_reg ^ wbs_dat_i[LED_WIDTH-1:0]);
                                end
                            end
                            ADDR_LED_CLEAR: begin
                                if (wbs_sel_i[0]) begin
                                    led_out_reg <= led_out_reg & ~wbs_dat_i[LED_WIDTH-1:0];
                                    $display("%0t wb_led_controller: CLEAR LED_OUT addr=%h data=%h sel=%b -> %h", $time, wbs_adr_i, wbs_dat_i, wbs_sel_i, led_out_reg & ~wbs_dat_i[LED_WIDTH-1:0]);
                                end
                            end
                            ADDR_LED_SET: begin
                                if (wbs_sel_i[0]) begin
                                    led_out_reg <= led_out_reg | wbs_dat_i[LED_WIDTH-1:0];
                                    $display("%0t wb_led_controller: SET LED_OUT addr=%h data=%h sel=%b -> %h", $time, wbs_adr_i, wbs_dat_i, wbs_sel_i, led_out_reg | wbs_dat_i[LED_WIDTH-1:0]);
                                end
                            end
                        endcase
                    end
                end else begin
                    // Read operation
                    if (~wbs_ack_o) begin
                        wbs_ack_o <= 1;
                        case (addr_bits)
                            ADDR_LED_OUT,
                            ADDR_LED_TOGGLE,
                            ADDR_LED_CLEAR,
                            ADDR_LED_SET: begin
                                wbs_dat_o <= {{(32-LED_WIDTH){1'b0}}, led_out_reg};
                            end
                            default: begin
                                wbs_dat_o <= 32'h12345678;  // Test value
                            end
                        endcase
                    end
                end
            end
            else
                wbs_ack_o <= 0;
        end
    end
assign led_out = ~led_out_reg;
endmodule
