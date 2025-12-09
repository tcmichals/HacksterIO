# Half-Duplex Serial Implementation

## Overview

The Tang9K UART module supports **half-duplex operation** for BLHeli ESC communication. This allows a single bidirectional wire to be shared for both TX and RX.

## Hardware Implementation

### Tri-State Buffer Logic

The `ttl_serial.sv` module implements half-duplex using a tri-state buffer:

```systemverilog
// TX enable signal - active when transmitting
assign serial_tx_en = half_duplex_en && (tx_busy || tx_valid);

// Tri-state buffer: drive the line when TX is active, otherwise high-Z for RX
assign serial = serial_tx_en ? tx_out : 1'bz;
assign rx_in = serial;
```

**Key Points:**
- When `serial_tx_en` is HIGH: TX drives the `serial` line
- When `serial_tx_en` is LOW: `serial` line is high-impedance (Z), allowing RX to listen
- `tx_busy` signal indicates when the transmitter is actively sending data
- UART idle state is HIGH (mark state)

### Pull-Up Resistor

The serial line requires a pull-up resistor to maintain the idle HIGH state when the transmitter is inactive (high-Z).

**Option 1: Internal Pull-Up (Already Configured)**

The `tang9k.cst` constraint file enables the FPGA's internal pull-up:

```tcl
IO_LOC "serial" 25;
IO_PORT "serial" IO_TYPE=LVCMOS33 PULL_MODE=UP DRIVE=8;
```

✅ **This is already configured - no external resistor needed!**

**Option 2: External Pull-Up (More Reliable for Long Wires)**

If you have long wires or need stronger pull-up, add an external resistor:

```
                    +3.3V
                      |
                     [R] 4.7kΩ - 10kΩ external pull-up
                      |
    Tang9K ----o------+------ ESC Signal Wire
               |
             Serial
          (Tri-state)
```

**Why Pull-Up is Needed:**
- When TX is inactive (high-Z), the pull-up ensures the line stays HIGH (idle state)
- Without pull-up, the line would float and cause communication errors
- The ESC also uses open-drain/open-collector output, so pull-up is essential
- UART idle state is logic HIGH (mark state)

### Constraint File

The serial pin is defined in `tang9k.cst` with internal pull-up enabled:

```tcl
# Half-duplex serial line (shared TX/RX for ESC BLHeli)
IO_LOC "serial" 25;
IO_PORT "serial" IO_TYPE=LVCMOS33 PULL_MODE=UP DRIVE=8;
```

**Configuration:**
- **Pin 25:** Adjust to match your board layout
- **PULL_MODE=UP:** Enables internal pull-up resistor (weak ~10kΩ typical)
- **DRIVE=8:** 8mA drive strength (sufficient for short traces)
- **IO_TYPE=LVCMOS33:** 3.3V logic level

**Note:** The internal pull-up is sufficient for connections up to ~10cm. For longer wires or noisy environments, consider adding an external 4.7kΩ pull-up resistor.

## Software Control

### Wishbone Register (wb_ttl_serial.sv)

The `half_duplex_en` signal is controlled via Wishbone register 0x10 (Control Register):

```systemverilog
// Address 0x10: Control Register
// Bit 0: half_duplex_en (1 = enable half-duplex)
```

### Python Control

```python
# Enable half-duplex mode
spi.write_wishbone(0x0110, 0x00000001)  # Set bit 0 high

# Disable half-duplex mode (full duplex)
spi.write_wishbone(0x0110, 0x00000000)  # Set bit 0 low
```

### Default State

The module defaults to **half-duplex enabled** on reset:

```systemverilog
if (!rst) begin
    half_duplex_en <= 1'b1;  // Default to half-duplex
end
```

## Timing Considerations

### TX-to-RX Turnaround

When switching from TX to RX, there's a brief period where:
1. TX finishes sending stop bit
2. `tx_busy` goes LOW
3. `serial_tx_en` goes LOW
4. Line goes high-Z (pulled up by resistor)
5. RX can now listen

**Turnaround time:**
- Stop bit duration: 1/115200 ≈ 8.68μs
- Plus propagation delay: < 1μs
- **Total:** ~10μs

This is fast enough for BLHeli protocol.

### RX-to-TX Turnaround

When switching from RX to TX:
1. RX finishes receiving
2. Software loads TX data
3. `tx_valid` asserted
4. `serial_tx_en` goes HIGH immediately
5. TX drives the line

**Turnaround time:**
- Software delay: varies (typically < 100μs)
- TX start immediately when data loaded

## BLHeli ESC Communication

### Protocol

BLHeli uses **half-duplex serial** for configuration:
1. **Computer → ESC:** Send command (e.g., read EEPROM)
2. **Wait:** ESC processes command
3. **ESC → Computer:** ESC responds with data
4. **Repeat:** Next command

### Connection

```
┌─────────────┐           ┌─────────────┐
│             │           │             │
│  Tang9K     │           │    ESC      │
│  FPGA       │           │  (BLHeli)   │
│             │           │             │
│   Serial ───┼───────────┼─── Signal   │
│  (Pin 25)   │           │   Wire      │
│             │  4.7kΩ↑   │             │
│   GND ──────┼───────────┼─── GND      │
│             │           │             │
└─────────────┘           └─────────────┘
                +3.3V
```

### Mux Control

The serial line is shared with DSHOT. Use the mux register to switch:

```python
# Serial mode (for BLHeli configuration)
spi.write_wishbone(0x0400, 0)  # Mux = 0

# DSHOT mode (for motor control)
spi.write_wishbone(0x0400, 1)  # Mux = 1
```

## Testing

### Loopback Test

To test half-duplex operation, create a physical loopback:

```
Tang9K Serial Pin ──┐
                     │
                    [R] 4.7kΩ pull-up to 3.3V
                     │
                    └── Connect to self (loopback)
```

**Test code:**
```python
# Send a byte
spi.write_wishbone(0x0100, ord('A'))

# Read it back
rx_data = spi.read_wishbone(0x0100)
assert rx_data == ord('A'), "Loopback failed!"
```

### ESC Test

1. **Connect ESC** to Tang9K serial pin
2. **Power ESC** (must be powered to respond)
3. **Set mux to serial mode:** `spi.write_wishbone(0x0400, 0)`
4. **Enable half-duplex:** `spi.write_wishbone(0x0110, 1)`
5. **Use BLHeli tool** to connect via `/dev/ttyUSB0` (if using USB serial adapter)

## Troubleshooting

### Communication Errors

**Problem:** Data corruption, framing errors

**Check:**
1. **Pull-up resistor:** Is it connected? (4.7kΩ - 10kΩ)
2. **Baud rate:** Verify 115200 baud (625 cycles @ 72 MHz)
3. **Half-duplex enabled:** Check register 0x0110
4. **Mux setting:** Should be 0 for serial mode

### No RX Data

**Problem:** TX works but no RX

**Check:**
1. **Tri-state control:** Ensure `tx_busy` signal working correctly
2. **Pull-up:** Line must return to HIGH when TX inactive
3. **ESC powered:** ESC must have power to respond
4. **Timing:** Allow ESC time to respond after command

### TX Collisions

**Problem:** TX and RX interfere with each other

**Cause:** This shouldn't happen with proper half-duplex control

**Check:**
1. **`serial_tx_en` logic:** Should be HIGH only when transmitting
2. **State machine:** TX should not activate during RX
3. **Software timing:** Wait for TX to complete before expecting RX

## Advantages of Half-Duplex

✅ **Single wire** - Simpler wiring, fewer pins
✅ **ESC compatible** - BLHeli ESCs use half-duplex
✅ **Shared with DSHOT** - Same pin for motor control and configuration
✅ **Industry standard** - Common in embedded systems

## See Also

- [USB_SERIAL_BRIDGE.md](USB_SERIAL_BRIDGE.md) - Using USB serial adapter
- [BLHELI_PASSTHROUGH.md](../../BLHELI_PASSTHROUGH.md) - BLHeli configuration guide
- [SYSTEM_OVERVIEW.md](../../SYSTEM_OVERVIEW.md) - Complete system architecture
