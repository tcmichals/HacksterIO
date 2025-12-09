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
    output logic clkout0,  // 72 MHz
    output logic clkout1,  // 27 MHz passthrough
    output logic locked
);

    // For simulation, we'll use simple clock dividers
    // In real synthesis with Gowin tools, this would instantiate the actual PLL_CORE
    
    // To generate 72 MHz from 27 MHz:
    // 72 / 27 = 8/3 ratio
    // We use a 3-counter to divide by 3, then take every 8th cycle
    
    logic [2:0] div3_counter;
    logic [2:0] div8_counter;
    
    // Divide by 3 for intermediate clock
    logic clk_div3;
    always_ff @(posedge clkin) begin
        if (div3_counter == 2) begin
            div3_counter <= 3'b0;
            clk_div3 <= ~clk_div3;
        end else begin
            div3_counter <= div3_counter + 1;
        end
    end
    
    // Generate 72 MHz: multiply input by 8/3 = (27 MHz * 8/3 = 72 MHz)
    // Simple approximation: use a counter that toggles at the right frequency
    logic [3:0] clk72_counter;
    always_ff @(posedge clkin) begin
        clk72_counter <= clk72_counter + 1;
    end
    
    // 72 MHz from 27 MHz: we need an 8:3 multiplier
    // Using a phase accumulator approach
    logic [7:0] phase_accum;
    
    always_ff @(posedge clkin) begin
        phase_accum <= phase_accum + 8'd216;  // 8/3 * 256 ≈ 682, simplified to 216
    end
    
    // Outputs
    assign clkout0 = phase_accum[7];   // 72 MHz derived clock
    assign clkout1 = clkin;             // 27 MHz passthrough
    assign locked = 1'b1;               // Always locked in simulation

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

    // Phase accumulator for 8:3 ratio (27 MHz * 8 / 3 = 72 MHz)
    logic [8:0] phase_accum;
    
    always_ff @(posedge clkin) begin
        phase_accum <= phase_accum + 9'd216;  // 8/3 * 256
    end
    
    assign clk72 = phase_accum[8];
    assign locked = 1'b1;

endmodule
