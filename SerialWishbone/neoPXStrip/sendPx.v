`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/26/2024 02:31:40 PM
// Design Name: 
// Module Name: sendPx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sendPx(

    input wire axis_aclk,
    input wire axis_reset,
    
    /* AXIS slave */
    input wire [31:0] s_axis_data,
    input wire s_axis_valid,
    output wire s_axis_ready,
    
    /* output stream */
    output wire o_serial 
    );
    
/* 120_000_000 .008333 us = 10_000_000   */ 
     
                        // WS2812B timings
localparam T0H_count =     16'd48,  // .4us 
           T1H_count =     16'd96,  // .8us
           T0L_count =     16'd102, // .85us
           T1L_count =     16'd66,  //  .45us
           GAP_count =     16'd15,
           RESET    =      16'd6600;// above 55us
    

/* SK6812
localparam T0H_count = 16'd48,  // .3us 
           T1H_count = 16'd96,  // .6us
           T0L_count = 16'd144, // .9us
           T1L_count = 16'd96,  // .6us
           GAP_count = 16'd10,
           RESET    =      16'd8800;// above 80us
 */
reg [7:0] state;
reg ready;
reg [15:0] counter;
reg [31:0] shift_reg;
reg out_bit;
reg [3:0] bit_state;
reg [15:0] gapTimer; 

localparam IDLE_BIT_BSTATE = 4'd0,
           WAIT_HIGH_BSTATE=4'd1,
           WAIT_LOW_BSTATE=4'd2,
           DONE_BIT_BSTATE=4'd3;
            
localparam IDLE_STATE = 8'd0,
          DONE_STATE = 8'd33,
          WAIT_STATE=8'd34;
          
initial begin
    ready = 0;
    state = IDLE_STATE;
    counter = 0;
    bit_state = IDLE_BIT_BSTATE;
    out_bit = 0;
 end            
 
always @(posedge axis_aclk) begin

    case ( state)
        DONE_STATE: begin
            $display("DONE_STATE ");
            bit_state <= IDLE_BIT_BSTATE;
            out_bit <= 1'b0;
            counter <= 0;
        end
        WAIT_STATE: begin
            $display("WAIT_STATE ");
            bit_state <= IDLE_BIT_BSTATE;
            out_bit <= 1'b0;
            counter <= 0;
        end

        IDLE_STATE: begin
            $display("IDLE_STATE ");
            bit_state <= IDLE_BIT_BSTATE;
            out_bit <= 1'b0;
            counter <= 0;
        end

        default: begin
             $display("DEFAULT ");
            case (bit_state)
                IDLE_BIT_BSTATE: begin
                    if (shift_reg[31] == 1)
                        counter <= T1H_count;
                    else 
                        counter <= T0H_count;
                    bit_state <= WAIT_HIGH_BSTATE;
                end
                WAIT_HIGH_BSTATE: begin     
                    $display("counter %d", counter);     
                    out_bit <= 1'b1;
                    counter <= counter - 1'b1;
                    if (counter == 0) begin
                        out_bit <= 1'b0;
                        bit_state <= WAIT_LOW_BSTATE;
                        if (shift_reg[31] == 1)
                            counter <= T1L_count;
                        else 
                            counter <= T0L_count;
                    end
                    else
                         out_bit <= 1'b1;
                end

                WAIT_LOW_BSTATE: begin
                    out_bit <= 1'b0;  
                    counter <= counter - 1'b1;
                    if (counter == 0) begin  
                        bit_state <= DONE_BIT_BSTATE;
                    end
                end

                DONE_BIT_BSTATE:  begin 
                    bit_state <= IDLE_BIT_BSTATE;
                    out_bit <= 1'b0;
                    counter <= 0;
                end
    
                default: begin 
                        bit_state <= IDLE_BIT_BSTATE;
                        out_bit <= 1'b0;
                        counter <= 0;
                end
            endcase 
        end


    endcase
  
 end  
                      
always @(posedge axis_aclk) begin
    
    if (axis_reset) begin
        state <= IDLE_STATE;
        ready <= 0;
        shift_reg <= 0;
        gapTimer <= 0;
    end
    else begin 

        case(state)
        IDLE_STATE: begin
            gapTimer <= 0;
            if ( s_axis_valid & ready) begin
                ready <= 0;
                shift_reg <= s_axis_data;
                state <= state + 1'b1;
            end
            else begin
                ready <= 1;
                state <= IDLE_STATE;
            end
        end    
        DONE_STATE: begin
            ready <= 1;
            gapTimer <= 0;
            state <= IDLE_STATE;
        end
        WAIT_STATE: begin
            ready <= 0;
            if(gapTimer== GAP_count)
                state <= IDLE_STATE;
            else
                gapTimer<= gapTimer + 1'b1;

        end
        default: begin
            ready <= 0;
            if( bit_state == DONE_BIT_BSTATE) begin
                shift_reg <= { shift_reg[30:0], 1'b0};
                state <= state +1;
            end
        end
        endcase
    end

end

assign s_axis_ready = ready;
assign o_serial = (bit_state!= IDLE_BIT_BSTATE)?out_bit:1'b0;

endmodule


