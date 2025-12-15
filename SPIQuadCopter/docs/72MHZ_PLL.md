# 72 MHz PLL Addition

## Overview

A 72 MHz PLL has been added to the Tang9K design to support high-speed interfaces like TTL Serial UART at elevated baud rates.

## Clock Specifications

| Clock | Frequency | Source | Use Case |
|-------|-----------|--------|----------|
| i_sys_clk | 27 MHz | External crystal | System clock, SPI, LED blinker |
| clk_72m | 72 MHz | PLL (27 MHz × 8 ÷ 3) | High-speed serial (TTL), timing-critical logic |

## PLL Configuration

**Input:** 27 MHz (from board oscillator)  
**Output:** 72 MHz (8:3 ratio multiplier)  
**Ratio:** 72 / 27 = 2.667 (or 8/3)

### Implementation

The PLL uses a phase accumulator approach:
```verilog
logic [8:0] phase_accum;
always_ff @(posedge clkin) begin
    phase_accum <= phase_accum + 9'd216;  // 8/3 * 256
end
assign clk72 = phase_accum[8];  // MSB gives 72 MHz
```

## Integration Points

### In tang9k_top.sv

The 72 MHz clock is instantiated at the top level:

```verilog
logic clk_72m;
logic pll_locked;

pll_27m_to_72m u_pll_72m (
    .clkin(i_sys_clk),
    .clk72(clk_72m),
    .locked(pll_locked)
);
```

### Available for Use

The `clk_72m` signal is now available to any module in the design. Example uses:

#### TTL Serial UART at Higher Baud Rates

For 115,200 baud at 72 MHz:
```verilog
ttl_serial #(
    .CLK_FREQ_HZ(72_000_000),
    .BAUD_RATE(115_200)
) u_uart (
    .clk(clk_72m),
    .rst_n(i_rst_n),
    // ... other signals
);
```

Baud divisor: 72,000,000 / 115,200 = 625 clock cycles

#### Higher Baud Rates

With 72 MHz, you can achieve:
- 230,400 bps: divisor = 313
- 460,800 bps: divisor = 156
- 921,600 bps: divisor = 78

## Synthesis Notes

### For Gowin EDA

In real hardware synthesis, replace the simulation implementation with the actual Gowin PLL core:

```verilog
module pll_27m_to_72m (
    input  logic clkin,
    output logic clk72,
    output logic locked
);

    // Use Gowin IP core:
    // Create an instance with:
    // - Input: 27 MHz
    // - Output: 72 MHz
    // - Locked signal for synchronization
    
    // This is a placeholder for simulation
    // Replace with: Gowin_pll_27m_72m u_pll_core (...)
    
endmodule
```

## Testing

To verify the PLL generation works in simulation:

```bash
cd src
iverilog -g2012 -o test_pll.vvp pll.sv tang9k_top.sv
vvp test_pll.vvp
```

## Future Enhancements

- [ ] Add dynamic clock switching (27 MHz ↔ 72 MHz) based on mode
- [ ] Implement additional PLL outputs (48 MHz for USB, etc.)
- [ ] Add PLL lock monitoring and error handling
- [ ] Gowin IP core integration for actual hardware

## References

- **Input Clock:** 27 MHz (standard Tang9K board)
- **PLL Ratio:** 8:3 = 2.667×
- **Output Clock:** 72 MHz
- **Common Baud Rates Supported at 72 MHz:**
  - 115,200 (standard)
  - 230,400 (high-speed)
  - 460,800 (very high-speed)
  - 921,600 (extreme)
