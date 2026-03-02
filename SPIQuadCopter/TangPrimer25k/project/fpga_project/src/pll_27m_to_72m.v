
/**
 * Gowin PLL Configuration for Tang9K
 * 
 * Input: 27 MHz
 * Output: Multiple clocks for various functions
 * 
 * Available clock outputs:
 *   - clkout0: 72 MHz (27 MHz × 8 ÷ 3)
 *   - clkout1: 27 MHz (1:1 passthrough)
 */

module pll_27m_to_72m (
    input  logic clkin,
    output logic clk72,  // intended 72 MHz (approx)
    output logic clkout1,  // 27 MHz passthrough
    output logic locked
);




    Gowin_PLL pll150(
        .clkin(clkin), //input  clkin
        .clkout0(clk72), //output  clkout0
        .lock(locked), //output  lock
        .mdclk(clkin) //input  mdclk
);

assign clkout1 = clkin;

endmodule