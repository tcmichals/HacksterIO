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


/**
 * NeoPixel Bitstream Generator (WS2812)
 *
 * Features:
 * - Consumes pixel data via AXI-like interface (s_axis_data, s_axis_valid)
 * - Generates WS2812 bitstream with precise timing using axis_aclk (72 MHz)
 * - Bit timing:
 *     '0' bit: ~0.4 μs high, ~0.85 μs low
 *     '1' bit: ~0.8 μs high, ~0.45 μs low
 * - Localparams set for 72 MHz clock
 * - Use with wb_neoPx.v for Wishbone integration
 *
 * See SYSTEM_OVERVIEW.md for details.
 */
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
    
/* 72_000_000 0.013888889us   */ 
     
                        // WS2812B timings
localparam T0H_count =     16'd28,  // .4us 
           T1H_count =     16'd57,  // .8us
           T0L_count =     16'd61, // .85us
           T1L_count =     16'd32,  //  .45us
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
          DONE_STATE = 8'd25,
          WAIT_STATE=8'd26;
          
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
            bit_state <= IDLE_BIT_BSTATE;
            out_bit <= 1'b0;
            counter <= 0;
        end
        WAIT_STATE: begin
            bit_state <= IDLE_BIT_BSTATE;
            out_bit <= 1'b0;
            counter <= 0;
        end

        IDLE_STATE: begin
            bit_state <= IDLE_BIT_BSTATE;
            out_bit <= 1'b0;
            counter <= 0;
        end

        default: begin
            case (bit_state)
                IDLE_BIT_BSTATE: begin
                    // Send From MSB (Bit 31) because we shifted data << 8
                    if (shift_reg[31] == 1)
                        counter <= T1H_count;
                    else 
                        counter <= T0H_count;
                    bit_state <= WAIT_HIGH_BSTATE;
                end
                WAIT_HIGH_BSTATE: begin     
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
                // Shift Left by 8 to put RGB (24 bits) at 31..8
                shift_reg <= s_axis_data << 8;
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


