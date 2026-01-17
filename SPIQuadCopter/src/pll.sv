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

module pll_27m_to_100m (
    input  logic clkin,
    output logic clkout0,  // intended 72 MHz (approx)
    output logic clkout1,  // 27 MHz passthrough
    output logic locked
);

`ifdef SYNTHESIS
    // Synthesis: instantiate the Gowin-generated PLL IP here.
    // Recommended workflow:
    // 1) Use Gowin IP generator to create a PLL that generates the required clocks
    //    (72 MHz and 27 MHz) from the 27 MHz crystal.
    // 2) Name the generated module `gowin_pll_27m_to_100m` (or change the name below),
    //    and keep the port mapping as shown so this wrapper can instantiate it.
    // 3) Add the generated IP files to the project so the synthesiser can find them.


rPLL #( // For GW1NR-9C C6/I5 (Tang Nano 9K proto dev board)
  .FCLKIN("27"),
  .IDIV_SEL(2), // -> PFD = 9 MHz (range: 3-400 MHz)
  .FBDIV_SEL(7), // -> CLKOUT = 72 MHz (range: 3.125-600 MHz)
  .ODIV_SEL(8) // -> VCO = 576 MHz (range: 400-1200 MHz)
) pll (.CLKOUTP(), .CLKOUTD(), .CLKOUTD3(), .RESET(1'b0), .RESET_P(1'b0), .CLKFB(1'b0), .FBDSEL(6'b0), .IDSEL(6'b0), .ODSEL(6'b0), .PSDA(4'b0), .DUTYDA(4'b0), .FDLY(4'b0),
  .CLKIN(clkin), // 27 MHz
  .CLKOUT(clkout0), // 72 MHz
  .LOCK(locked)
);
    assign clkout1 = clkin;


`else
    // Simulation fallback model (behavioral) - produces an approximate faster clock
    // from the incoming 27 MHz. This is not cycle-accurate but useful for tests.
    logic [15:0] phase_accum_sim = 0;

    always_ff @(posedge clkin) begin
        // Increment to approximate multiplication/division ratio.
        phase_accum_sim <= phase_accum_sim + 16'd1234;
    end

    assign clkout0 = phase_accum_sim[15];
    assign clkout1 = clkin;
    assign locked  = 1'b1;

`endif

endmodule


/**
 * 72 MHz PLL specialized module
 * 
 * Generates 72 MHz clock from 27 MHz input
 * Useful for TTL serial and other high-speed interfaces
 */
module pll_27m_to_72m (
    input  logic clkin,
    output logic clk72,
    output logic locked
);

`ifdef SYNTHESIS
    // Synthesis: instantiate the Gowin-generated 27->72 MHz PLL here.
    // Use the IP generator to create a module named `gowin_pll_27m_to_72m` (or
    // adjust the instantiation below to match the generated module name).
rPLL #( // For GW1NR-9C C6/I5 (Tang Nano 9K proto dev board)
  .FCLKIN("27"),
  .IDIV_SEL(2), // -> PFD = 9 MHz (range: 3-400 MHz)
  .FBDIV_SEL(7), // -> CLKOUT = 72 MHz (range: 3.125-600 MHz)
  .ODIV_SEL(8) // -> VCO = 576 MHz (range: 400-1200 MHz)
) pll (.CLKOUTP(), .CLKOUTD(), .CLKOUTD3(), .RESET(1'b0), .RESET_P(1'b0), .CLKFB(1'b0), .FBDSEL(6'b0), .IDSEL(6'b0), .ODSEL(6'b0), .PSDA(4'b0), .DUTYDA(4'b0), .FDLY(4'b0),
    .CLKIN(clkin), // 27 MHz input should be connected to module port 'clkin'
    .CLKOUT(clk72), // 72 MHz output mapped to module port 'clk72'
    .LOCK(locked)
);


`else
    // Behavioral simulation model - Bypass for testbench driving 72MHz directly
    assign clk72 = clkin;
    assign locked = 1'b1;

`endif

endmodule
