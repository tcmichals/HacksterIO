/**
 * pll - PLL for Tang Nano 20K (Gowin GW2AR-18)
 *
 * Input:  27 MHz crystal
 * Output: 72 MHz system clock
 */

module pll (
    input  wire clk_in,   // 27 MHz input
    output wire clk_out,  // 72 MHz output
    output wire locked    // PLL locked indicator
);

    // Gowin rPLL primitive for GW2AR-18
    // gowin_pack VCO formula: VCO = FCLKIN*(FBDIV+1)*ODIV/(IDIV+1), must be 500-1250 MHz
    // CLKOUT = FCLKIN * (FBDIV+1) / (IDIV+1) / ODIV
    // Config: 27MHz * 32 / 3 / 4 = 72 MHz, VCO = 1152 MHz
    rPLL #(
        .FCLKIN("27"),           // Input clock frequency (MHz)
        .IDIV_SEL(2),            // IDIV = 3
        .FBDIV_SEL(31),          // FBDIV = 32, VCO = 27*32*4/3 = 1152 MHz
        .ODIV_SEL(4),            // ODIV = 4, output = 1152/4/4 = 72 MHz
        .PSDA_SEL("0000"),       // No phase shift
        .DYN_SDIV_SEL(2),        // Static division
        .DEVICE("GW2AR-18C")     // Device type
    ) u_rpll (
        .CLKIN(clk_in),          // Input clock
        .CLKFB(1'b0),            // Internal feedback
        .RESET(1'b0),            // No reset
        .RESET_P(1'b0),          // No reset (positive)
        .FBDSEL(6'b000000),      // Fixed feedback divider
        .IDSEL(6'b000000),       // Fixed input divider
        .ODSEL(6'b000000),       // Fixed output divider
        .PSDA(4'b0000),          // No phase shift
        .DUTYDA(4'b0000),        // Default duty cycle
        .FDLY(4'b0000),          // No delay
        .CLKOUT(clk_out),        // Clock output
        .LOCK(locked),           // Lock indicator
        .CLKOUTP(),              // Unused outputs
        .CLKOUTD(),
        .CLKOUTD3()
    );

endmodule
