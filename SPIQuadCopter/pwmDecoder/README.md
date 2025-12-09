# PWM Decoder - Wishbone Interface

## Overview

The PWM Decoder module converts RC-style PWM (Pulse Width Modulation) signals into digital values accessible via a Wishbone bus interface. It supports 6 independent PWM input channels commonly used in RC receivers and drones.

## Features

- **6 PWM Input Channels**: Decodes up to 6 simultaneous PWM signals
- **Wishbone B3 Interface**: Standard 32-bit register-based access
- **Microsecond Resolution**: Pulse widths measured in microseconds (µs)
- **Error Detection**: Guards against invalid signals (timeouts, excessive pulse widths)
- **Status Monitoring**: Per-channel ready flags indicate valid data

## PWM Signal Characteristics

### Standard RC PWM Timing
- **Pulse Width Range**: 800 µs to 2600 µs (typical: 1000-2000 µs)
- **Frame Period**: <20 ms (typical: 20 ms for servo signals)
- **Center/Neutral**: ~1500 µs
- **Min Throttle**: ~1000 µs
- **Max Throttle**: ~2000 µs

### Error Conditions
- **Guard Error High (0x8000)**: Pulse width exceeds 2600 µs
- **Guard Error Low (0xC000)**: No signal detected for >20 ms

## Wishbone Register Map

All registers are 32-bit, read-only unless specified.

| Address | Register | Description |
|---------|----------|-------------|
| 0x00 | PWM_CH0 | Channel 0 pulse width (µs) |
| 0x04 | PWM_CH1 | Channel 1 pulse width (µs) |
| 0x08 | PWM_CH2 | Channel 2 pulse width (µs) |
| 0x0C | PWM_CH3 | Channel 3 pulse width (µs) |
| 0x10 | PWM_CH4 | Channel 4 pulse width (µs) |
| 0x14 | PWM_CH5 | Channel 5 pulse width (µs) |
| 0x18 | STATUS | Channel ready flags [5:0] |

### PWM Channel Registers (0x00-0x14)

**Format:**
```
[31:16] = Reserved (0x0000)
[15:0]  = Pulse width in microseconds
```

**Special Values:**
- `value | 0x8000`: Pulse too long (>2600 µs)
- `value | 0xC000`: No signal timeout (>20 ms)

**Example Values:**
- `0x03E8` = 1000 µs (minimum throttle)
- `0x05DC` = 1500 µs (center/neutral)
- `0x07D0` = 2000 µs (maximum throttle)
- `0x8A28` = Error: pulse exceeded 2600 µs
- `0xC000` = Error: no signal detected

### Status Register (0x18)

**Format:**
```
[31:6]  = Reserved
[5]     = Channel 5 ready (1=valid data)
[4]     = Channel 4 ready
[3]     = Channel 3 ready
[2]     = Channel 2 ready
[1]     = Channel 1 ready
[0]     = Channel 0 ready
```

## Module Parameters

```verilog
module pwmdecoder_wb #(
    parameter clockFreq = 100_000_000,  // System clock frequency (Hz)
    parameter DATA_WIDTH = 32,           // Wishbone data width
    parameter ADDR_WIDTH = 32,           // Wishbone address width
    parameter SELECT_WIDTH = 4           // Byte select width
)
```

**clockFreq**: Must match your system clock. Common values:
- 27 MHz: `27_000_000`
- 50 MHz: `50_000_000`
- 72 MHz: `72_000_000`
- 100 MHz: `100_000_000`

## Integration Example

### Instantiation

```verilog
wire [5:0] pwm_inputs;  // Your PWM input pins

pwmdecoder_wb #(
    .clockFreq(72_000_000)  // 72 MHz system clock
) u_pwm_decoder (
    .i_clk(clk_72m),
    .i_rstn(sys_rst_n),
    
    // Wishbone slave interface
    .wb_adr_i(wb_addr),
    .wb_dat_i(wb_data_in),
    .wb_dat_o(wb_data_out),
    .wb_we_i(wb_we),
    .wb_sel_i(wb_sel),
    .wb_stb_i(wb_stb),
    .wb_ack_o(wb_ack),
    .wb_err_o(wb_err),
    .wb_rty_o(wb_rty),
    .wb_cyc_i(wb_cyc),
    
    // PWM inputs
    .i_pwm_0(pwm_inputs[0]),
    .i_pwm_1(pwm_inputs[1]),
    .i_pwm_2(pwm_inputs[2]),
    .i_pwm_3(pwm_inputs[3]),
    .i_pwm_4(pwm_inputs[4]),
    .i_pwm_5(pwm_inputs[5])
);
```

### Reading PWM Values (Pseudo-C)

```c
// Read all 6 channels
uint16_t throttle   = read_word(PWM_BASE + 0x00) & 0xFFFF;
uint16_t aileron    = read_word(PWM_BASE + 0x04) & 0xFFFF;
uint16_t elevator   = read_word(PWM_BASE + 0x08) & 0xFFFF;
uint16_t rudder     = read_word(PWM_BASE + 0x0C) & 0xFFFF;
uint16_t aux1       = read_word(PWM_BASE + 0x10) & 0xFFFF;
uint16_t aux2       = read_word(PWM_BASE + 0x14) & 0xFFFF;

// Check status
uint32_t status = read_word(PWM_BASE + 0x18);
if (status & 0x01) {
    printf("Channel 0 valid: %d µs\n", throttle);
}

// Check for errors
if (throttle & 0x8000) {
    printf("Channel 0: Pulse too long\n");
}
if (throttle & 0xC000) {
    printf("Channel 0: No signal\n");
}
```

## Use Cases

### 1. RC Aircraft/Drone Control

```c
// Map PWM values to control surfaces
int16_t map_pwm_to_control(uint16_t pwm) {
    // 1000-2000 µs -> -100 to +100
    return ((int16_t)pwm - 1500) / 5;
}

int16_t throttle_pct = map_pwm_to_control(throttle);
int16_t aileron_deg = map_pwm_to_control(aileron);
```

### 2. Safety Monitoring

```c
bool check_signal_valid(uint16_t pwm) {
    // Reject error values
    if (pwm & 0xC000) return false;
    
    // Check range
    if (pwm < 800 || pwm > 2600) return false;
    
    return true;
}
```

### 3. Multi-Mode Switch Decoding

```c
typedef enum {
    MODE_MANUAL = 0,
    MODE_STABILIZE = 1,
    MODE_AUTO = 2
} flight_mode_t;

flight_mode_t decode_mode_switch(uint16_t pwm) {
    if (pwm < 1300) return MODE_MANUAL;
    if (pwm < 1700) return MODE_STABILIZE;
    return MODE_AUTO;
}
```

## Core Decoder (`pwmdecoder.v`)

The underlying decoder uses a state machine to measure pulse widths:

### States
1. **MEASURING_OFF**: Waiting for rising edge, counting low time
2. **MEASURING_ON**: Measuring high pulse width
3. **MEASURE_COMPLETE**: Data ready, restart measurement

### Timing
- **Clock Divider**: Generates 1 MHz timebase from system clock
- **Guard Times**:
  - ON_MIN: 800 µs
  - ON_MAX: 2600 µs
  - OFF_MAX: 20000 µs (20 ms)

## Timing Characteristics

| Parameter | Value | Notes |
|-----------|-------|-------|
| Wishbone latency | 1 cycle | Read acknowledge |
| PWM update rate | 20-50 Hz | Depends on TX frame rate |
| Measurement resolution | 1 µs | ±1 µs accuracy |
| Minimum pulse width | 800 µs | Below triggers error |
| Maximum pulse width | 2600 µs | Above triggers error |

## Synthesis

Included in main project Makefile:

```makefile
SRCS := ... pwmDecoder/pwmdecoder.v pwmDecoder/pwmdecoder_wb.v ...
```

Build normally:
```bash
make build
```

## Simulation

Test the PWM decoder with a testbench (create your own):

```verilog
// Generate test PWM signal
reg pwm_test;
initial begin
    pwm_test = 0;
    #1000;  // 1 µs low
    forever begin
        pwm_test = 1;
        #1500000;  // 1500 µs high (neutral)
        pwm_test = 0;
        #18500000;  // Rest of 20 ms frame
    end
end
```

## Common Issues

### Issue: All channels read 0xC000
**Cause**: No PWM signal connected or clock frequency mismatch  
**Fix**: Check `clockFreq` parameter matches actual clock

### Issue: Erratic readings
**Cause**: Noisy input signals  
**Fix**: Add external filtering or debounce logic

### Issue: Values stuck at old reading
**Cause**: PWM signal stopped updating  
**Fix**: Check status register ready flags

## Integration with Quadcopter Project

For the SPI Quadcopter project, connect to Wishbone multiplexer:

```verilog
wb_mux_4 u_wb_mux (
    .wbm_* (from SPI master),
    .wbs0_* (to LED controller),
    .wbs1_* (to UART controller),
    .wbs2_* (to PWM decoder),
    // ...
);
```

Address allocation:
- 0x0000: LEDs
- 0x0020: UART
- 0x0040: PWM Decoder (6 channels + status = 7 registers × 4 bytes = 28 bytes)

## References

- RC PWM Standard: https://www.rcgroups.com/forums/showthread.php?1677694
- Wishbone B3 Spec: http://opencores.org/opencores,wishbone
