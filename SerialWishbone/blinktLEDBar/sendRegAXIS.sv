
module sendRegAXIS
#( 
    parameter CLK_DIV = 60
)
( 
    input wire i_clk,
    input wire i_reset,

     //AXIS slave
    input wire [31:0] s_axis_data,
    input wire s_axis_tvalid,
    output wire s_axis_tready,

        //LED 
    output wire o_led_clk,
    output wire o_led_data
);

reg [31:0] o_shift_data;
reg [31:0] clk_div;
reg [8:0] state;
reg clk_done, led_clk;


initial begin
    led_clk = 0;
    o_shift_data = 0;
    state = 0;
    clk_div = 0;
    led_clk = 0;
    clk_done = 0;
end

localparam 
    IDLE_STATE = 0,
    START=1,
    DONE = 33;


assign o_led_clk = (state!=IDLE_STATE && state!=DONE)?led_clk:1'b0;
assign o_led_data = (state!=IDLE_STATE && state!=DONE)?o_shift_data[31]:1'b0;
assign s_axis_tready = (state==IDLE_STATE)?1'b1:1'b0;


always @( posedge i_clk ) begin

if (i_reset || state==IDLE_STATE) begin
        clk_div <= 0;
        clk_done <= 0; 
        led_clk <= 0;
end
else begin

    if (CLK_DIV == clk_div) begin
        clk_div <= 0;
        led_clk <= ~led_clk;
        if (led_clk )
            clk_done <= 1'b1;
    end
    else begin
        clk_div <= clk_div + 1'b1;
        clk_done <= 1'b0;
        led_clk <= led_clk;
    end

end
end

always @( posedge i_clk) begin

 if (i_reset) begin
    led_clk = 0;
    o_shift_data = 0;
    state = IDLE_STATE;
    clk_div = 0;
 end
 else begin
    case (state)
        IDLE_STATE: begin
            if (s_axis_tvalid) begin
                o_shift_data <= s_axis_data;
                state <= START;
                $display("Start");
            end
        end
        DONE: begin
             if (clk_done) begin
                state <= IDLE_STATE;
             end
        end

        default: begin

            if (clk_done) begin
                o_shift_data <= {o_shift_data[30:0], 1'b0};
                state <= state + 1'b1;
            end

        end
    endcase
 end


end

endmodule