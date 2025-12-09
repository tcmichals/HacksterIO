# LED Blinker with PLL Module Documentation

## Overview

The LED blinker module provides multiple LED blinking patterns using clock dividers derived from the system clock. It demonstrates the concept of frequency division and PWM (Pulse Width Modulation) for LED brightness control.

## Features

- **4 independent LED patterns**:
  - LED0: Slow blink (~0.5 Hz) - 1 second on/off
  - LED1: Medium blink (~1 Hz) - 0.5 second on/off  
  - LED2: Fast blink (~2 Hz) - 0.25 second on/off
  - LED3: Breathing effect using PWM triangular wave

- **No external PLL required** for basic demo (uses internal clock dividers)
- **Synchronous design** - all outputs synchronized to system clock
- **Fully synchronous reset** for clean initialization

## Module Interface

```verilog
module led_blinker (
    input  logic i_sys_clk,      // 27 MHz system clock
    input  logic i_rst_n,        // Active-low reset
    output logic o_led0,         // Slow blink (~1 Hz)
    output logic o_led1,         // Medium blink (~2 Hz)
    output logic o_led2,         // Fast blink (~4 Hz)
    output logic o_led3          // Breathing pattern
);
```

## Implementation Details

### Clock Dividers

Each LED uses a different frequency by dividing the system clock:

| LED | Divider | Frequency | Bit | Period |
|-----|---------|-----------|-----|--------|
| LED0 | 2^26 | ~0.4 Hz | [25] | ~2.5s |
| LED1 | 2^25 | ~0.8 Hz | [24] | ~1.25s |
| LED2 | 2^24 | ~1.6 Hz | [23] | ~0.6s |
| LED3 | PWM | Variable | - | ~0.04s |

**System Clock**: 27 MHz (Tang9K on-board oscillator)

### PWM Breathing Effect (LED3)

LED3 implements a "breathing" effect using PWM:
- Triangular wave pattern (0→127→0) updates periodically
- PWM counter compares against pattern value
- Creates smooth brightness variation without multiple LEDs

```
Brightness
   100% |     /\     /\
        |    /  \   /  \
        |   /    \ /    \
        |  /      V      \
    0%  |/______________\__
        Time →
```

### Integration with Tang9K Top Module

The LED blinker is instantiated in `tang9k_top.sv`:

```verilog
led_blinker u_led_blinker (
    .i_sys_clk  (i_sys_clk),
    .i_rst_n    (i_rst_n),
    .o_led0     (led_blink0),
    .o_led1     (led_blink1),
    .o_led2     (led_blink2),
    .o_led3     (led_blink3)
);
```

LED outputs can be controlled by:
- Hardware: Auto-blinking from blinker module (default)
- Software: SPI register control (via SPI interface)

Outputs are ORed together:
```verilog
assign o_led0 = led_blink0 | reg_ctrl[0];
assign o_led1 = led_blink1 | reg_ctrl[1];
assign o_led2 = led_blink2 | reg_ctrl[2];
assign o_led3 = led_blink3 | reg_ctrl[3];
```

## PLL Module (pll.sv)

For advanced implementations, a Gowin PLL can be used instead of dividers:

```verilog
module pll_27m_to_100m (
    input  logic clkin,
    output logic clkout0,  // Main clock
    output logic clkout1,  // Secondary clock
    output logic locked    // PLL locked indicator
);
```

**Note**: The current implementation is simplified for simulation. For synthesis on Gowin hardware, instantiate `PLL_CORE` from Gowin IP library.

## Testing

### Simulation

Run the testbench to verify blinking patterns:

```bash
cd src
make simulate
```

### View Waveforms

```bash
cd src
make wave
```

Waveform shows:
- All four LED outputs blinking at different rates
- LED3 PWM pattern (breathing effect)
- Proper synchronization to system clock

### Test Metrics

The testbench monitors:
- Toggle count for LED0, LED1, LED2
- LED3 breathing pattern
- Timing verification

Expected toggle counts after ~2 seconds:
- LED0: ~1 toggle (slow)
- LED1: ~2 toggles (medium)
- LED2: ~4 toggles (fast)

## Synthesis Considerations

### For Gowin EDA Suite

To use actual PLL on hardware:

1. Create PLL core in Gowin EDA:
   - Input: 27 MHz
   - Output: 100 MHz (or desired frequency)
   - Save as Gowin primitive

2. Instantiate in design:
   ```verilog
   PLL_CORE #(.MODULE("Gowin_PLL")) u_pll (
       .clkin(i_sys_clk),
       .clkout(pll_clk_100m),
       .lock(pll_locked)
   );
   ```

3. Use PLL output for higher-speed designs

## Power Consumption

- Clock dividers: Minimal (just counters)
- PWM output: Negligible
- Overall: < 1mW at 3.3V typical

## Future Enhancements

- [ ] Configurable blink rates via SPI
- [ ] Individual LED brightness control (PWM for all LEDs)
- [ ] Color patterns for RGB LEDs
- [ ] Interrupt on LED events
- [ ] Real PLL integration with Gowin primitives

## File Structure

```
src/
├── led_blinker.sv      # Main LED blinker module
├── pll.sv              # PLL configuration
├── led_blinker_tb.sv   # Testbench
├── tang9k_top.sv       # Top-level with LED blinker
└── Makefile            # Build/test automation
```

## Debugging Tips

- **LED not blinking**: Check reset signal (i_rst_n should be low then high)
- **Wrong frequency**: Verify system clock frequency (27 MHz expected)
- **LED stuck on/off**: Check counter overflow logic
- **PWM not working**: Verify triangular wave pattern generation

## References

- Tang9K Datasheet: GW1N-9K FPGA specifications
- Gowin Verilog Primitives: PLL_CORE documentation
- iverilog Documentation: IEEE 1364-2005 Verilog

