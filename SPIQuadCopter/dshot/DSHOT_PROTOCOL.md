# DSHOT Protocol Documentation

## Overview

DSHOT (Digital Shot) is a digital communication protocol for controlling ESCs (Electronic Speed Controllers) used in quadcopters and drones. It replaces older analog protocols like PWM and OneShot with a robust digital signal that includes error checking.

## Frame Format

Each DSHOT frame is **16 bits** transmitted MSB-first:

```
┌─────────────────────┬──────────────┬──────────────┐
│   Throttle Value    │  Telemetry   │     CRC      │
│     (11 bits)       │   (1 bit)    │   (4 bits)   │
│    Bits [15:5]      │   Bit [4]    │  Bits [3:0]  │
└─────────────────────┴──────────────┴──────────────┘
 MSB                                              LSB
```

### Bit Breakdown

| Bits    | Field      | Description                                |
|---------|------------|--------------------------------------------|
| [15:5]  | Throttle   | 11-bit throttle value (0-2047)            |
| [4]     | Telemetry  | Telemetry request flag (0=no, 1=yes)      |
| [3:0]   | CRC        | 4-bit checksum for error detection        |

## Throttle Values

The 11-bit throttle field (0-2047) is divided into ranges:

| Value    | Meaning                                      |
|----------|----------------------------------------------|
| 0        | **Disarmed** - Motor stopped                |
| 1-47     | **Special commands** (see below)            |
| 48-2047  | **Throttle range** (48=min, 2047=max)       |

### Special Commands (1-47)

| Value | Command                    | Description                           |
|-------|----------------------------|---------------------------------------|
| 0     | MOTOR_STOP                | Disarm motor / stop                   |
| 1-5   | Reserved                  | Do not use                            |
| 6     | ESC_INFO                  | Request ESC information               |
| 7     | SPIN_DIRECTION_1          | Set spin direction option 1           |
| 8     | SPIN_DIRECTION_2          | Set spin direction option 2           |
| 9     | 3D_MODE_OFF               | Disable 3D mode                       |
| 10    | 3D_MODE_ON                | Enable 3D mode (bidirectional)        |
| 11    | SETTINGS_REQUEST          | Request current ESC settings          |
| 12    | SAVE_SETTINGS             | Save current settings to EEPROM       |
| 20    | SPIN_DIRECTION_NORMAL     | Set normal spin direction             |
| 21    | SPIN_DIRECTION_REVERSED   | Set reversed spin direction           |
| 22-47 | Reserved                  | Reserved for future use               |

## CRC Calculation

The 4-bit CRC is calculated over the 12-bit payload (throttle + telemetry):

```verilog
crc = (payload ^ (payload >> 4) ^ (payload >> 8)) & 0x0F;
```

Or in C/Python:
```c
uint16_t payload = (throttle << 1) | telemetry;  // 12 bits
uint8_t crc = (payload ^ (payload >> 4) ^ (payload >> 8)) & 0x0F;
uint16_t frame = (payload << 4) | crc;  // Final 16-bit frame
```

### Example CRC Calculation

For throttle=1000, telemetry=0:
```
payload = (1000 << 1) | 0 = 2000 = 0x7D0
crc = (0x7D0 ^ 0x7D ^ 0x7) & 0xF
    = (0x7D0 ^ 0x07A) & 0xF
    = 0x7AA & 0xF
    = 0xA
frame = (2000 << 4) | 0xA = 0x7D0A
```

## DSHOT Variants

Different DSHOT speeds use different bit timings:

| Protocol  | Bit Period | "0" HIGH | "1" HIGH | Min Guard Time |
|-----------|------------|----------|----------|----------------|
| DSHOT150  | 6.67 µs    | 2.50 µs  | 5.00 µs  | 250 µs         |
| DSHOT300  | 3.33 µs    | 1.25 µs  | 2.50 µs  | 125 µs         |
| DSHOT600  | 1.67 µs    | 0.625 µs | 1.25 µs  | 62.5 µs        |

**Note**: This implementation supports **DSHOT150**, **DSHOT300**, and **DSHOT600** with **runtime mode selection** at 72 MHz clock frequency.

### Runtime Speed Selection

The DSHOT module supports **dynamic switching between speeds** via the `i_dshot_mode` input signal:

```verilog
// Module ports include:
input wire [15:0] i_dshot_mode,   // 150, 300, or 600
output wire o_ready                // Ready for next command

// Switch modes at runtime:
assign dshot_mode = 16'd150;  // DSHOT150 (default, slower, more reliable)
assign dshot_mode = 16'd300;  // DSHOT300 (2x faster)
assign dshot_mode = 16'd600;  // DSHOT600 (4x faster)
```

**Important considerations when switching speeds:**

1. **Mode takes effect on next transmission**: Current transmission completes at old speed
2. **Guard time adjusts automatically**: Each mode has its own guard time (250µs/125µs/62.5µs)
3. **Always check o_ready signal**: Ensures guard time has elapsed before next write
4. **ESC must support the speed**: Not all ESCs support all DSHOT variants - check ESC specs

**When to use each speed:**

- **DSHOT150**: Most reliable, works with all ESCs, recommended for initial testing
- **DSHOT300**: Good balance of speed and reliability, standard choice
- **DSHOT600**: Fastest update rate, requires high-quality signal paths, for racing/performance
| DSHOT1200 | 0.83 µs    | 0.313 µs | 0.625 µs | 31.25 µs       |

### Bit Encoding

Each bit is encoded using pulse width:
- **Bit "0"**: ~37.5% duty cycle (e.g., 2.5µs HIGH, 4.17µs LOW for DSHOT150)
- **Bit "1"**: ~75% duty cycle (e.g., 5.0µs HIGH, 1.67µs LOW for DSHOT150)

## Guard Time

After transmitting a 16-bit frame, the signal must remain LOW for at least the minimum guard time before the next frame can be sent. This allows the ESC to:
1. Process the received frame
2. Calculate and verify the CRC
3. Execute the command
4. Prepare for the next frame

**The master controller is responsible for respecting this timing.**

## Usage Example

### Creating a Throttle Command

```python
def create_dshot_frame(throttle, telemetry=False):
    """
    Create a DSHOT frame with proper CRC.
    
    Args:
        throttle: 11-bit throttle value (0-2047)
        telemetry: Request telemetry (True/False)
    
    Returns:
        16-bit DSHOT frame ready to transmit
    """
    # Validate inputs
    assert 0 <= throttle <= 2047, "Throttle must be 0-2047"
    
    # Build 12-bit payload
    payload = (throttle << 1) | (1 if telemetry else 0)
    
    # Calculate CRC
    crc = (payload ^ (payload >> 4) ^ (payload >> 8)) & 0x0F
    
    # Combine into 16-bit frame
    frame = (payload << 4) | crc
    
    return frame

# Examples:
motor_stop = create_dshot_frame(0)           # 0x0000 (with CRC)
min_throttle = create_dshot_frame(48)        # Minimum throttle
half_throttle = create_dshot_frame(1047)     # Approximately 50%
max_throttle = create_dshot_frame(2047)      # Maximum throttle
with_telemetry = create_dshot_frame(1000, telemetry=True)
```

### Verilog Usage

```verilog
// Instantiate DSHOT output module
dshot_output #(
    .clockFrequency(72000000)  // 72 MHz system clock
) motor1_dshot (
    .i_clk(clk),
    .i_reset(reset),
    .i_dshot_value(dshot_frame),   // 16-bit frame (pre-computed with CRC)
    .i_dshot_mode(dshot_mode),     // 150, 300, or 600 (runtime selectable)
    .i_write(dshot_write),         // Pulse HIGH to transmit
    .o_pwm(motor1_signal),         // Output to ESC
    .o_ready(motor1_ready)         // Ready for next command
);

// Example: Control with speed selection
reg [15:0] dshot_mode = 16'd150;  // Start with DSHOT150

always @(posedge clk) begin
    if (motor1_ready && new_command_available) begin
        dshot_frame <= compute_dshot_frame(throttle, telemetry);
        dshot_write <= 1'b1;
    end else begin
        dshot_write <= 1'b0;
    end
    
    // Switch to faster mode when desired
    if (switch_to_fast_mode) begin
        dshot_mode <= 16'd600;  // Switch to DSHOT600
    end
end

// Master controller must:
// 1. Calculate throttle + telemetry + CRC to create 16-bit frame
// 2. Wait for o_ready signal to be HIGH before writing
// 3. Assert i_write for one clock cycle
// 4. Mode can be changed anytime (takes effect on next transmission)
```

## Implementation Notes

### Master Responsibilities

The controller/master writing to the DSHOT module **must**:

1. **Encode the frame properly**:
   - Combine 11-bit throttle + 1-bit telemetry into bits [15:4]
   - Calculate 4-bit CRC and place in bits [3:0]

2. **Select appropriate speed**:
   - Set `i_dshot_mode` to 150, 300, or 600 based on ESC capabilities
   - Faster speeds = higher update rates but require better signal quality
   - Can switch modes dynamically at runtime

3. **Respect timing constraints**:
   - **Always wait for `o_ready` signal** before writing
   - `o_ready` automatically handles guard time for each mode
   - Do not write while previous transmission is in progress

4. **Handle mode changes safely**:
   - Mode change takes effect on the **next** transmission
   - Wait for `o_ready` after mode change before first write at new speed
   - Each mode has different guard times (handled automatically)

5. **Monitor write acceptance**:
   - If write occurs when `o_ready` is LOW, it will be rejected
   - Check ready signal to ensure command was accepted

### DSHOT Module Responsibilities

The `dshot_output.v` module handles:

1. **Bit-level timing**:
   - Converts each bit (0 or 1) into proper HIGH/LOW pulse widths
   - Generates accurate timing based on clock frequency

2. **Guard time enforcement**:
   - Maintains internal guard timer
   - Rejects writes that arrive too soon after previous frame

3. **PWM generation**:
   - Produces clean digital output signal for ESC

## References

- [Betaflight DSHOT Documentation](https://github.com/betaflight/betaflight/wiki/DSHOT-ESC-Protocol)
- [DSHOT Protocol Specification](https://github.com/blheli-configurator/blheli-configurator)
- [Brushless Motor ESC Protocols](https://oscarliang.com/dshot/)

## Testing

The testbench `dshot_tb.v` validates:
- ✅ Correct bit timing for "0" and "1" bits
- ✅ Frame transmission (all 16 bits)
- ✅ Guard time enforcement
- ✅ Write acceptance/rejection logic
- ✅ Multi-frame sequences

Run tests with:
```bash
cd dshot
make simulate
```

## TUI Control Interface

The Tang9K TUI application (`python/test/tang9k_tui.py`) provides an interactive interface for controlling DSHOT ESCs:

### Features

- **Runtime speed selection**: Switch between DSHOT150, DSHOT300, and DSHOT600 on the fly
- **Throttle control**: Send throttle commands to individual motors or all motors
- **Motor stop**: Emergency stop for all motors
- **Status monitoring**: Real-time display of motor ready states
- **Proper frame encoding**: Automatically calculates CRC for all commands

### Usage

```bash
cd python/test
python3 tang9k_tui.py
```

### Keyboard Shortcuts

- `1` - Switch to DSHOT150 (most reliable)
- `2` - Switch to DSHOT300 (standard speed)
- `3` - Switch to DSHOT600 (high performance)
- `q` - Quit application

### TUI Controls

**DSHOT Speed Selection:**
- Click `DSHOT150`, `DSHOT300`, or `DSHOT600` buttons to change protocol speed
- Active mode is highlighted in green
- Mode changes take effect on next transmission

**Throttle Control:**
- Enter throttle value (48-2047) in the input field
- Click `Send M1` to send to Motor 1
- Click `Send All` to send to all motors
- Click `Stop All` for emergency motor stop

**Status Display:**
- `DSHOT Mode`: Current protocol speed (150/300/600)
- `Motors Ready`: Ready state for each motor (R=ready, -=busy)
  - Example: `RR--` means motors 1 and 2 are ready, 3 and 4 are busy

### Example Workflow

1. **Start with safe mode**:
   ```
   Press '1' to select DSHOT150
   Click "Stop All" to ensure motors are stopped
   ```

2. **Test individual motor**:
   ```
   Enter "100" in throttle field
   Click "Send M1" to test motor 1
   Wait for "R---" in Motors Ready status
   ```

3. **Switch to faster mode**:
   ```
   Press '2' to switch to DSHOT300
   Wait for all motors to show ready
   ```

4. **Control all motors**:
   ```
   Enter "500" in throttle field
   Click "Send All" to control all motors
   ```

5. **Emergency stop**:
   ```
   Click "Stop All" immediately stops all motors
   ```

### Safety Notes

⚠️ **IMPORTANT SAFETY WARNINGS**:

1. **Remove propellers during testing**: Always test on bench without props first
2. **Start with DSHOT150**: Most reliable mode for initial testing
3. **Use Stop All frequently**: Emergency stop is always available
4. **Monitor ready status**: Don't send commands faster than motors can accept
5. **Check ESC compatibility**: Not all ESCs support all DSHOT speeds

