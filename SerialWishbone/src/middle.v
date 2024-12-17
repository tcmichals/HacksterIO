module middle
(
    input wire i_clk,
    input wire i_rst,

    // AXIS input
    input wire [7:0] s_axis_tdata,
    input wire s_axis_tvalid,
    output wire s_axis_tready,

    //AXIS output
    output wire [7:0] m_axis_tdata,
    output wire m_axis_tvalid,
    input wire m_axis_tready,

    output wire  [5:0] o_led,

    output wire o_led_clk,
    output wire o_led_data,
    output wire o_neoPx);


localparam  WB_DATA_WIDTH = 32,                    // width of data bus in bits (8, 16, 32, or 64)
            WB_ADDR_WIDTH = 32,                    // width of address bus in bits
            WB_SELECT_WIDTH = (WB_DATA_WIDTH/8);


wire [WB_ADDR_WIDTH-1:0]   wb_adr_o;   // ADR_O() address
wire [WB_DATA_WIDTH-1:0]   wb_dat_i;   // DAT_I() data in
wire [WB_DATA_WIDTH-1:0]   wb_dat_o;   // DAT_O() data out
wire                       wb_we_o;    // WE_O write enable output
wire [WB_SELECT_WIDTH-1:0] wb_sel_o;   // SEL_O() select output
wire  wb_stb_o;   // STB_O strobe output
reg   wb_ack_i;   // ACK_I acknowledge input
reg   wb_err_i;   // ERR_I error input
wire  wb_cyc_o;   // CYC_O cycle output
wire  busy;





wire [31:0] neoPx_axis_data;
wire neoPx_axis_valid, neoPx_axis_ready;

sendPx  neoPx
(
    .axis_aclk(i_clk),
    .axis_reset(i_rst),
    
    /* AXIS slave */
    .s_axis_data(neoPx_axis_data),
    .s_axis_valid(neoPx_axis_valid),
    .s_axis_ready(neoPx_axis_ready),
    
    /* output stream */
    .o_serial(o_neoPx));

wire [WB_ADDR_WIDTH-1:0]   neo_wb_adr_o;
wire [WB_DATA_WIDTH-1:0]   neo_wb_dat_i;   // DAT_I() data in
wire [WB_DATA_WIDTH-1:0]   neo_wb_dat_o;   // DAT_O() data out
wire                       neo_wb_we_i;    // WE_I write enable input
wire [WB_SELECT_WIDTH-1:0] neo_wb_sel_i;   // SEL_I() select input
wire                       neo_wb_stb_i;   // STB_I strobe input
wire                       neo_wb_ack_o;   // ACK_O acknowledge output
wire                       neo_wb_err_o;   // ERR_O error output
wire                       neo_wb_rty_o;   // RTY_O retry output
wire                       neo_wb_cyc_i;   // CYC_I cycle input
wb_neoPx neopixels
(
    .i_clk(i_clk),
    .i_rst(i_rst),
     // master side
    .wb_adr_i(neo_wb_adr_o),   // ADR_I() address
    .wb_dat_i(neo_wb_dat_i),   // DAT_I() data in
    .wb_dat_o(neo_wb_dat_o),   // DAT_O() data out
    .wb_we_i(neo_wb_we_i),    // WE_I write enable input
    .wb_sel_i(neo_wb_sel_i),   // SEL_I() select input
    .wb_stb_i(neo_wb_stb_i),   // STB_I strobe input
    .wb_ack_o(neo_wb_ack_o),   // ACK_O acknowledge output
    .wb_err_o(neo_wb_err_o),   // ERR_O error output
    .wb_rty_o(neo_wb_rty_o),   // RTY_O retry output
    .wb_cyc_i(neo_wb_cyc_i),   // CYC_I cycle input

    .m_axis_data(neoPx_axis_data),
    .m_axis_valid(neoPx_axis_valid),
    .s_axis_ready(neoPx_axis_ready));

axis_wb_master  #(.IMPLICIT_FRAMING(1))
 master  (
    .clk(i_clk),
    .rst(i_rst),
    .input_axis_tdata(s_axis_tdata),
    .input_axis_tkeep(),
    .input_axis_tvalid(s_axis_tvalid),
    .input_axis_tready(s_axis_tready),
    .input_axis_tlast(0),
    .input_axis_tuser(),
    .output_axis_tdata(m_axis_tdata),
    .output_axis_tkeep(),
    .output_axis_tvalid(m_axis_tvalid),
    .output_axis_tready(m_axis_tready),
    .output_axis_tlast(),
    .output_axis_tuser(),
    .wb_adr_o(wb_adr_o),
    .wb_dat_i(wb_dat_i),
    .wb_dat_o(wb_dat_o),
    .wb_we_o(wb_we_o),
    .wb_sel_o(wb_sel_o),
    .wb_stb_o(wb_stb_o),
    .wb_ack_i(wb_ack_i),
    .wb_err_i(wb_err_i),
    .wb_cyc_o(wb_cyc_o),
    .busy(busy));

wire [WB_ADDR_WIDTH-1:0]   led_wb_adr_o;
wire [WB_DATA_WIDTH-1:0]   led_wb_dat_i;   // DAT_I() data in
wire [WB_DATA_WIDTH-1:0]   led_wb_dat_o;   // DAT_O() data out
wire                       led_wb_we_i;    // WE_I write enable input
wire [WB_SELECT_WIDTH-1:0] led_wb_sel_i;   // SEL_I() select input
wire                       led_wb_stb_i;   // STB_I strobe input
wire                       led_wb_ack_o;   // ACK_O acknowledge output
wire                       led_wb_err_o;   // ERR_O error output
wire                       led_wb_rty_o;   // RTY_O retry output
wire                       led_wb_cyc_i;   // CYC_I cycle input


wb_leds intLeds
(
    .i_clk(i_clk),
    .i_rst(i_rst),

     // master side
    .wb_adr_i(led_wb_adr_o),   // ADR_I() address
    .wb_dat_i(led_wb_dat_i),   // DAT_I() data in
    .wb_dat_o(led_wb_dat_o),   // DAT_O() data out
    .wb_we_i(led_wb_we_i),    // WE_I write enable input
    .wb_sel_i(led_wb_sel_i),   // SEL_I() select input
    .wb_stb_i(led_wb_stb_i),   // STB_I strobe input
    .wb_ack_o(led_wb_ack_o),   // ACK_O acknowledge output
    .wb_err_o(led_wb_err_o),   // ERR_O error output
    .wb_rty_o(led_wb_rty_o),   // RTY_O retry output
    .wb_cyc_i(led_wb_cyc_i),   // CYC_I cycle input
    .o_led(o_led));


gen_mux_wb mux(

    .clk(i_clk),
    .rst(i_rst),

    /*
     * Wishbone master input
     */
   .wbm_adr_i(wb_adr_o),     // ADR_I() address input
   .wbm_dat_i(wb_dat_o),     // DAT_I() data in
   .wbm_dat_o(wb_dat_i),     // DAT_O() data out
   .wbm_we_i(wb_we_o),      // WE_I write enable input
   .wbm_sel_i(wb_sel_o),     // SEL_I() select input
   .wbm_stb_i(wb_stb_o),     // STB_I strobe input
   .wbm_ack_o(wb_ack_i),     // ACK_O acknowledge output
   .wbm_err_o(wb_err_i),     // ERR_O error output
   .wbm_rty_o(),     // RTY_O retry output
   .wbm_cyc_i(wb_cyc_o),     // CYC_I cycle input

    /*
     * Wishbone slave 0 output
     */
    .wbs0_adr_o(led_wb_adr_o),    // ADR_O() address output
    .wbs0_dat_i(led_wb_dat_o),    // DAT_I() data in
    .wbs0_dat_o(led_wb_dat_i),    // DAT_O() data out
    .wbs0_we_o(led_wb_we_i),     // WE_O write enable output
    .wbs0_sel_o(led_wb_sel_i),    // SEL_O() select output
    .wbs0_stb_o(led_wb_stb_i),    // STB_O strobe output
    .wbs0_ack_i(led_wb_ack_o),    // ACK_I acknowledge input
    .wbs0_err_i(led_wb_err_o),    // ERR_I error input
    .wbs0_rty_i(),    // RTY_I retry input
    .wbs0_cyc_o(led_wb_cyc_i),    // CYC_O cycle output

    /*
     * Wishbone slave 0 address configuration
     */
   .wbs0_addr(32'h0000_0000),     // Slave address prefix
   .wbs0_addr_msk(32'hFFFF_FF00), // Slave address prefix mask

    /*
     * Wishbone slave 1 output
     */
    .wbs1_adr_o(neo_wb_adr_o),    // ADR_O() address output
    .wbs1_dat_i(neo_wb_dat_o),    // DAT_I() data in
    .wbs1_dat_o(neo_wb_dat_i),    // DAT_O() data out
    .wbs1_we_o(neo_wb_we_i),     // WE_O write enable output
    .wbs1_sel_o(neo_wb_sel_i),    // SEL_O() select output
    .wbs1_stb_o(neo_wb_stb_i),    // STB_O strobe output
    .wbs1_ack_i(neo_wb_ack_o),    // ACK_I acknowledge. input
    .wbs1_err_i(neo_wb_err_o),    // ERR_I error inpu.t
    .wbs1_rty_i(),    // RTY_I retry inpu.t
    .wbs1_cyc_o(neo_wb_cyc_i),    // CYC_O cycle output.

    /*
     * Wishbone slave 1 address configuration
     */
    .wbs1_addr(32'h0000_0100),     // Slave address prefix
    .wbs1_addr_msk(32'hFFFF_FF00) 
);
always @(posedge i_clk) begin


end


endmodule