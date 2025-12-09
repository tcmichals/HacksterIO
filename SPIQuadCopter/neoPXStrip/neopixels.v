`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/26/2024 02:04:10 PM
// Design Name: 
// Module Name: neopixels
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
 * NeoPixel Top-Level Controller
 *
 * Integrates Wishbone/AXI pixel buffer and WS2812 bitstream generator.
 * - Feeds pixel data to sendPx.v for WS2812 timing
 * - System clock: 72 MHz
 * - Debug signals for handshake and state
 *
 * See SYSTEM_OVERVIEW.md for details.
 */
module neopixels(
    input wire axi_clk,
    input wire axi_reset,
    output wire o_serialPin,
    output wire [3:0] o_debug   );
             
reg [2:0] bitState;
reg  [23:0] ledData[7:0];
reg [2:0] count;
reg tvalid;
wire isReady;
reg [4:0] state;
reg [23:0] data;
reg [31:0] timeout;
reg sendState;
assign o_debug[3] = isReady;
assign o_debug[2] = state[1];
assign o_debug[1] = state[0];
assign o_debug[0] = sendState;

initial begin 
    ledData[0] = 24'h00_FF00;
    ledData[1] = 24'h00_0000;
    ledData[2] = 24'h00_0000;
    ledData[3] = 24'h00_0000;
    ledData[4] = 24'h00_0000;
    ledData[5] = 24'h00_0000;
    ledData[6] = 24'h00_0000;
    ledData[7] = 24'h00_0000;

    count =0;
    tvalid = 0;
    state = 0;
    sendState = 0;
    timeout = 0;

 end
 
 sendPx   axis(
                .axis_aclk(axi_clk),
                .axis_reset(axi_reset),
                /* AXIS slave */
                .s_axis_data(data),
                .s_axis_valid(tvalid),
                .s_axis_ready(isReady),
                /* output stream */
                .o_serial(o_serialPin));

always @(posedge axi_clk) begin

    if ( state != 0) begin 
        if ( sendState == 0) begin
            if(isReady) begin
               data <=  ledData[count];
               tvalid <= 1'b1;
               sendState <= 1;
            end 
            else
                tvalid <= 0;
         end else begin
            tvalid <= 0;
            sendState <= 0;
            count <= count +1'b1;
         end
     end
     else begin
        tvalid <= 0;
        sendState <= 0;
        data <=  ledData[count];
        count <= 0;
     end
end

always @(posedge axi_clk) begin

    case(state) 
        4'd0:   if (timeout == 32'd100_000_000)
                begin
                    if ( isReady ) state <= state +1;
                    else
                        timeout<= 0;
                end
                else begin
                    state<= 0;
                    timeout <= timeout + 1'b1;
                end
        4'd1:  if (sendState)  state <= state +1;
          
                   
      
        default: begin
            state <= 0;

         end  
       
     endcase



end
 
endmodule
