module blinktLEDBar
#( 
    parameter DATA_WIDTH = 32,                  // width of data bus in bits (8, 16, 32, or 64)
    parameter ADDR_WIDTH = 32,                  // width of address bus in bits
    parameter SELECT_WIDTH = (DATA_WIDTH/8)     // width of word select bus (1, 2, 4, or 8)
)
(   input wire i_clk,
    input wire i_rst,

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

    output wire [31:0] m_axis_data,
    output wire m_axis_valid,
    input wire s_axis_ready   );

reg ack,update;
reg  [31:0] ledData[7:0];
reg [4:0] state;

reg tvalid;
reg [31:0] o_data, o_ledData;
reg sendState;
reg [3:0] count;

localparam LEDCOUNT = 4'd10,
            IDLE = 4'd0,
            DONE = LEDCOUNT +1;

initial begin

    count  = 0;
    ack =0;
    update = 0; 
    tvalid = 0;
    sendState = 0;
    state = 0;
    ledData[0] = 32'h0000_0001;
    ledData[1] = 32'h0000_0002;
    ledData[2] = 32'h0000_0003;
    ledData[3] = 32'h0000_0004;
    ledData[4] = 32'h0000_0005;
    ledData[5] = 32'h0000_0006;
    ledData[6] = 32'h0000_0007;
    ledData[7] = 32'h0000_0008;
    o_data = 32'd0;
    o_ledData = 32'd0;
end

assign  wb_ack_o = ack;

 always @(*) begin
    if ((~ack & wb_cyc_i & wb_stb_i)) begin
        case(wb_adr_i[5:0])
            //set all leds
           8'h00 :   o_data = ledData[0];
           8'h04 :   o_data = ledData[0];
           8'h08 :   o_data = ledData[0];
           8'h0C :   o_data = ledData[0];
           8'h10 :   o_data = ledData[0];
           8'h14 :   o_data = ledData[0];
           8'h18 :   o_data = ledData[0];
           8'h1C :   o_data = ledData[0];
           default: o_data = 32'hFFFF_FFFF;       
        endcase
    end
    else
        o_data = 32'hFFFF_FFFF;    
 end

always @(posedge i_clk) begin

    if (i_rst) begin
        ack <= 1'b0;
    end 
    else begin

        if ((~ack & wb_cyc_i & wb_stb_i)) begin
            if (wb_we_i) begin
                case(wb_adr_i[5:0])
                //set all leds
                6'h00 :   ledData[0]<= wb_dat_i;
                6'h04 :   ledData[1]<= wb_dat_i;
                6'h08 :   ledData[2]<= wb_dat_i;
                6'h0C :   ledData[3]<= wb_dat_i;
                6'h10 :   ledData[4]<= wb_dat_i;
                6'h14 :   ledData[5]<= wb_dat_i;
                6'h18 :   ledData[6]<= wb_dat_i;
                6'h1C :   ledData[7]<= wb_dat_i;
                default: begin 
                      update <= 1;
                end
                       
                endcase
            end 

            ack <= 1'b1;     
        end
        else if (state == DONE && update)
            update <= 0;
        if (ack) begin
            ack <= 1'b0;
        end
        
    end
    
end


always @(*) begin

    case (count)
        4'd0: o_ledData = 32'h0000_0000;
        4'd9: o_ledData= 32'hFFFF_FFFF;
        default: o_ledData = ledData[count -1'b1];
    endcase
 
end

always @(posedge i_clk) begin

    case(state) 
        IDLE: begin 
                if ( update)
                    state<= state + 1'b1;
                else
                   state <= 0;

                tvalid <= 0;
                sendState <= 0;

                count <= 0;
        end

        DONE: begin 
                state <= IDLE;
                tvalid <= 0;
                sendState <= 0;

                count <= 0;
        end

        default: begin
            if ( sendState == 0) 
            begin
                if(s_axis_ready) begin
                    tvalid <= 1'b1;
                    sendState <= 1;
                    count <= count;
                    state <= state;

                end 
                else begin
                    tvalid <= 0;
                    count <= count;
                    state <= state;
                    sendState <= sendState;
                end
            end 
            else begin
                tvalid <= 0;
                sendState <= 0;
                if (count < LEDCOUNT)
                    count <= count + 1'b1;
                else
                    count <= count;
                state <= state + 1'b1;
    
            end

         end  
       
     endcase
end

//always return led settings 
assign wb_dat_o= { 6'd0, tvalid, state, o_data[23:0] };
assign wb_err_o = 0;
assign wb_rty_o = 0;
assign m_axis_data = o_ledData;
assign m_axis_valid = tvalid;


endmodule
