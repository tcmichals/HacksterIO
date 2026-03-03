/**
 * Gowin PLL module for Tang9K
 * 
 * Generates system clock from 27 MHz crystal input
 * Output frequency configured via FBDIV_SEL parameter (currently 54 MHz)
 */
module pll_gowin_27m (
    input  logic clkin,
    output logic clkout,
    output logic locked
);

`ifdef SYNTHESIS
    // Synthesis: Gowin rPLL instantiation
    // To change output frequency, adjust FBDIV_SEL:
    //   FBDIV_SEL=5: 54 MHz, FBDIV_SEL=7: 72 MHz, FBDIV_SEL=3: 36 MHz
rPLL #( // For GW1NR-9C C6/I5 (Tang Nano 9K proto dev board)
  .FCLKIN("27"),
  .IDIV_SEL(2), // -> PFD = 27 / (2+1) = 9 MHz (range: 3-400 MHz)
  .FBDIV_SEL(5), // -> VCO = 9 * (5+1) * 8 = 432 MHz (range: 400-1200 MHz)
  .ODIV_SEL(8) // -> CLKOUT = 432 / 8 = 54 MHz
) pll (.CLKOUTP(), .CLKOUTD(), .CLKOUTD3(), .RESET(1'b0), .RESET_P(1'b0), .CLKFB(1'b0), .FBDSEL(6'b0), .IDSEL(6'b0), .ODSEL(6'b0), .PSDA(4'b0), .DUTYDA(4'b0), .FDLY(4'b0),
    .CLKIN(clkin), // 27 MHz input
    .CLKOUT(clkout), // System clock output (54 MHz)
    .LOCK(locked)
);


`else
    // Behavioral simulation model - Bypass for testbench
    assign clkout = clkin;
    reg locked_reg = 0;
    assign locked = locked_reg;
    initial begin
        #100;
        locked_reg = 1;
    end

`endif

endmodule
