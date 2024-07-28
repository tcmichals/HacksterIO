module blinktLEDBar
#( 
    parameter DATA_WIDTH = 32,                  // width of data bus in bits (8, 16, 32, or 64)
    parameter ADDR_WIDTH = 32,                  // width of address bus in bits
    parameter SELECT_WIDTH = (DATA_WIDTH/8),     // width of word select bus (1, 2, 4, or 8)
    parameter  CLK_DIV = 120
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

    output o_led_clk,
    output o_led_data);

    reg [4:0] send_state, index;
    reg ack;
    reg [31:0] led [7:0];
    reg [31:0] shift_data;
    reg tvalid;
    wire ready;

sendRegAXIS axis(
        .i_clk(i_clk),
        .i_reset(i_rst),

        //AXIS slave
        .s_axis_data(shift_data),
        .s_axis_tvalid(tvalid),
        .s_axis_tready(ready),

        //LED 
        .o_led_clk(o_led_clk),
        .o_led_data(o_led_data));

initial begin

    send_state = 0;
    ack = 0;
    shift_data = 0;
    index = 0;

    led[0] = 0;
    led[1] = 0;
    led[2] = 0;
    led[3] = 0;
    led[4] = 0;
    led[5] = 0;
    led[6] = 0;
    led[7] = 0;
end

localparam  IDLE_STATE = 0,
            UPDATE_STATE =1,
            SEND_LED_0 = 2,
            SEND_LED_1 = 3,
            SEND_LED_3 = 4,

            DONE_STATE = 10;

assign wb_rty_o = 0;
assign wb_err_o = 0;
assign wb_dat_o = {27'h0,  state};
assign  wb_ack_o = ack;


always @(posedge i_clk or negedge i_rst) begin

    if (~i_rst) begin
        ack <= 1'b0;
    end else begin

        if ((~ack & wb_cyc_i & wb_stb_i)) begin
            if (wb_we_i) begin
                case(wb_adr_i[3:0])
                // toggle 
                8'h0 :  led[0]<= wb_dat_i;
                8'h1 :  led[1]<= wb_dat_i;
                8'h2 :  led[2]<= wb_dat_i;
                8'h3 :  led[3]<= wb_dat_i;
                8'h4 :  led[4]<= wb_dat_i;
                8'h5 :  led[5]<= wb_dat_i;
                8'h6 :  led[6]<= wb_dat_i;

                default:
                if ( IDLE_STATE == send_state)
                    send_state <= UPDATE_STATE;
                else
                    send_state <= IDLE_STATE;
                endcase
            end
            ack <= 1'b1;
        end
        if (ack) begin
            ack <= 1'b0;
        end

        case (send_date)
        IDLE_STATE: begin 
            index <= 0;
            shift_data <= led[0];
            tvalid <= 0;
        end
        UPDATE_STATE: begin
            if (ready) begin
                tvalid <=1;
                send_state <= send_state + 1'b1;
            end
        end
        default: begin
            if (ready) begin
                tvalid <=1;
                send_state <= send_state + 1'b1;
                shift_data <= led[index];
                index <= index + 1'b1;
            end
            else 
                tvalid <= 0;


        end

        endcase

    end
    
end

endmodule
