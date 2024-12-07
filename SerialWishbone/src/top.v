module top
(
    input clk,
    output [5:0] o_led,

    input uartRx,
    output uartTx,

    output led_clk,
    output led_data,
    output debug_0,
    output debug_1);



localparam  clkRate = 120_000_000;
localparam baudrate = 3_000_000;
localparam uartPreScale = (clkRate)/(baudrate*8);
localparam   WB_DATA_WIDTH = 32,                    // width of data bus in bits (8, 16, 32, or 64)
            WB_ADDR_WIDTH = 32,                    // width of address bus in bits
            WB_SELECT_WIDTH = (WB_DATA_WIDTH/8);

wire [7:0] uart_tx_axis_tdata;
wire uart_tx_axis_tvalid;
wire uart_tx_axis_tready;

wire [7:0] uart_rx_axis_tdata;
wire uart_rx_axis_tvalid;
wire uart_rx_axis_tready;
wire pll_clk, clk_lock;
reg rst;
reg sync_rx_0, sync_rx_1;
reg [3:0] div;
reg lock_rx;

initial begin 
    rst = 0;
    sync_rx_0 = 0;
    sync_rx_1 = 0;
end 


uart uart_inst(
    .clk(pll_clk),
    .rst(rst),
    // AXI input
    .s_axis_tdata(uart_tx_axis_tdata),
    .s_axis_tvalid(uart_tx_axis_tvalid),
    .s_axis_tready(uart_tx_axis_tready),
    // AXI output
    .m_axis_tdata(uart_rx_axis_tdata),
    .m_axis_tvalid(uart_rx_axis_tvalid),
    .m_axis_tready(uart_rx_axis_tready),
    // uart
    .rxd(sync_rx_1),
    .txd(uartTx),
    // status
    .tx_busy(),
    .rx_busy(),
    .rx_overrun_error(),
    .rx_frame_error(),
    // configuration
    .prescale(uartPreScale)

);

rPLL #( // For GW1NR-9C C6/I5 (Tang Nano 9K proto dev board)
  .FCLKIN("27"),
  .IDIV_SEL(8), // -> PFD = 3 MHz (range: 3-400 MHz)
  .FBDIV_SEL(39), // -> CLKOUT = 120 MHz (range: 3.125-600 MHz)
  .ODIV_SEL(4) // -> VCO = 480 MHz (range: 400-1200 MHz)
) pll (.CLKOUTP(), .CLKOUTD(), .CLKOUTD3(), .RESET(1'b0), .RESET_P(1'b0), .CLKFB(1'b0), .FBDSEL(6'b0), .IDSEL(6'b0), .ODSEL(6'b0), .PSDA(4'b0), .DUTYDA(4'b0), .FDLY(4'b0),
  .CLKIN(clk), // 27 MHz
  .CLKOUT(pll_clk), // 120 MHz
  .LOCK(clk_lock)
);



middle wb(
    
    .i_clk(pll_clk),
    .i_rst(rst),

    // AXIS input
    .s_axis_tdata(uart_rx_axis_tdata),
    .s_axis_tvalid(uart_rx_axis_tvalid),
    .s_axis_tready(uart_rx_axis_tready),

    //AXIS outout
    .m_axis_tdata(uart_tx_axis_tdata),
    .m_axis_tvalid(uart_tx_axis_tvalid),
    .m_axis_tready(uart_tx_axis_tready),

    .o_led(o_led),

    .o_led_clk(led_clk),
    .o_led_data(led_data));


always @(posedge pll_clk ) begin

   { sync_rx_1, sync_rx_0} <= { sync_rx_0, uartRx};

end


//assign debug_0=uart_rx_axis_tdata[0];
//assign debug_1=uart_rx_axis_tdata[1];
//assign debug_2=uart_rx_axis_tdata[2];
//assign debug_3=uart_rx_axis_tdata[3];
//assign debug_4=uart_rx_axis_tdata[4];
//assign debug_5=uart_rx_axis_tdata[5];

//assign debug_6=uart_rx_axis_tvalid;

endmodule