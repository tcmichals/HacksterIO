`timescale 1ns / 1ns

module sendRegAXIS
#( 
    parameter CLK_DIV = 76
)
(

    input wire axis_aclk,
    input wire axis_reset,
    
    /* AXIS slave */
    input wire [31:0] s_axis_data,
    input wire s_axis_valid,
    output wire s_axis_ready,
    
    //LED 
    output wire o_clk,
    output wire o_data
    );
    

reg [1:0] state;
reg ready;
reg [15:0] counter;
reg [31:0] shift_reg;
reg out_clk;
reg [5:0] bit_state;


localparam IDLE_BIT_BSTATE = 6'd0,
            START_BIT_BSTATE = 6'b1,
           SHIFT_DONE_BIT_BSTATE=6'd34,
            WAIT_BIT_BSTATE=6'd35,
            DONE_BIT_BSTATE=6'd36;
            
localparam IDLE_STATE = 2'd0,
          DONE_STATE = 2'd2,
          WAIT_STATE=2'd1;
          
initial begin
    ready = 0;
    state = IDLE_STATE;
    counter = 0;
    bit_state = IDLE_BIT_BSTATE;
    out_clk = 0;
    shift_reg = 0;
 end            
 
always @(posedge axis_aclk) begin

    case ( bit_state)
        IDLE_BIT_BSTATE: begin
            counter <= 0;
            out_clk <= 0;

            if (s_axis_valid & ready) begin
                bit_state <= bit_state +1'b1;
                shift_reg <= s_axis_data;
            end
            else begin
                bit_state <= IDLE_BIT_BSTATE;
                shift_reg <= 0;
            end

        end

        START_BIT_BSTATE: begin
            $display("START_BIT_BSTATE ");
            bit_state <= bit_state +1'b1;
            out_clk <= 1;
            counter <= 0;
        end

        
        SHIFT_DONE_BIT_BSTATE: begin
            out_clk <= 0;
            bit_state <= WAIT_BIT_BSTATE;
            counter <= 0;
        end

        WAIT_BIT_BSTATE: begin
            out_clk <= 0;
            counter <= counter +1'b1;
            if (counter > CLK_DIV * 10)
                bit_state <= DONE_BIT_BSTATE;

        end

        DONE_BIT_BSTATE: begin
            out_clk <= 0;
            bit_state <= IDLE_BIT_BSTATE;
            counter <= 0;
        end


        default: begin
            $display("default counter (%d)", counter);
            if (counter > CLK_DIV /2) begin
                counter <= 0;
                if (out_clk) begin
                    shift_reg <= { shift_reg[30:0], 1'b0};
                    out_clk <= 0;
                    bit_state = bit_state + 1'b1;
                end
                else begin
                    out_clk <= 1;
                end
            end
            else begin
	            counter <= counter +1'b1;
	        end
        end
    endcase
  
 end  
                      
always @(posedge axis_aclk) begin
    
        case(state)
        IDLE_STATE: begin
            if ( s_axis_valid & ready) begin
                ready <= 0;
                state <= WAIT_STATE;
            end
            else begin
            	if (bit_state == IDLE_BIT_BSTATE)
                	ready <= 1;
                else
                	ready <= 0;
                state <= IDLE_STATE;
            end
        end    
        WAIT_STATE: begin
            ready <= 0;
            if (bit_state == DONE_BIT_BSTATE)
                state <= DONE_STATE;
            else
                state <= WAIT_STATE;
        end
        DONE_STATE: begin
           ready <= 0;
           state <= IDLE_STATE;
        end

        endcase
    end



assign s_axis_ready = ready;
assign o_data = shift_reg[31];
assign o_clk =out_clk;

endmodule


