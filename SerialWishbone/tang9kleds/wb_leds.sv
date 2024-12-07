module wb_leds
#( 
    parameter DATA_WIDTH = 32,                  // width of data bus in bits (8, 16, 32, or 64)
    parameter ADDR_WIDTH = 32,                  // width of address bus in bits
    parameter SELECT_WIDTH = (DATA_WIDTH/8)     // width of word select bus (1, 2, 4, or 8)
)
(   input i_clk,
    input i_rst,

     // master side
    input  wire [ADDR_WIDTH-1:0]   wb_adr_i,   // ADR_I() address
    input  wire [DATA_WIDTH-1:0]   wb_dat_i,   // DAT_I() data in
    output wire [DATA_WIDTH-1:0]   wb_dat_o,   // DAT_O() data out
    input  wire                    wb_we_i,    // WE_I write enable input
    input  wire [SELECT_WIDTH-1:0] wb_sel_i,   // SEL_I() select input
    input  wire                    wb_stb_i,   // STB_I strobe input
    output wire                    wb_ack_o,   // ACK_O acknowledge output
    output wire                    wb_err_o,   // ERR_O error output
    output wire                    wb_rty_o,   // RTY_O retry output
    input  wire                    wb_cyc_i,   // CYC_I cycle input

    output [5:0] o_led);

reg ack;
reg [5:0] led_reg;

initial begin

    ack = 0;
    led_reg = 6'h2F;
end

assign  wb_ack_o = ack;

always @(posedge i_clk) begin

    if (i_rst) begin
        ack <= 1'b0;
    end 
    else begin

        if ((~ack & wb_cyc_i & wb_stb_i)) begin
            if (wb_we_i) begin
                case(wb_adr_i[3:0])
                //set all leds
                8'h0 :  led_reg<= wb_dat_i;
                //toggle on
                8'h4 :  led_reg<= led_reg | wb_dat_i;
                // toggle off
                8'h8 :  led_reg<= led_reg & ~wb_dat_i;
                default: begin end
                endcase
            end
            ack <= 1'b1;
        end
        if (ack) begin
            ack <= 1'b0;
        end
    end
    
end
//always return led settings 
assign wb_dat_o= {26'h0, led_reg };
assign wb_err_o = 0;
assign wb_rty_o = 0;
assign o_led = ~led_reg; 
endmodule
