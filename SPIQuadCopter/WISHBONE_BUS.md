# Wishbone Bus Integration

## Overview

The Tang9K design now includes Wishbone B3 compliant slave modules for device control and monitoring. This allows for a unified register-based interface to peripherals like LEDs and the TTL Serial UART.

## Wishbone Specification

The implementation follows the **Wishbone B3** specification:
- **Data Width**: 32 bits
- **Address Width**: 32 bits
- **Select Width**: 4 bits (byte enables)
- **Interface**: Master-to-Slave (SPI slave or CPU acts as master)

### Wishbone Signals

| Signal | Direction | Purpose |
|--------|-----------|---------|
| `clk` | Input | Wishbone clock |
| `rst` | Input | Active-high synchronous reset |
| `adr_i[31:0]` | Input | Address bus |
| `dat_i[31:0]` | Input | Data input (write data) |
| `dat_o[31:0]` | Output | Data output (read data) |
| `we_i` | Input | Write enable (1=write, 0=read) |
| `sel_i[3:0]` | Input | Byte select (one bit per byte) |
| `stb_i` | Input | Strobe (indicates valid cycle) |
| `cyc_i` | Input | Cycle (indicates bus cycle in progress) |
| `ack_o` | Output | Acknowledge (cycle complete) |
| `err_o` | Output | Error (invalid address or error condition) |
| `rty_o` | Output | Retry (slave not ready, try again) |

## Device Modules

### 1. LED Controller (`wb_led_controller.sv`)

Provides Wishbone access to LED control registers.

**Parameters:**
- `DATA_WIDTH`: 32 bits
- `ADDR_WIDTH`: 32 bits
- `SELECT_WIDTH`: 4 bits

**Address Map:**

```
0x00: LED Output Register (RW)
   Bits [3:0] = LED outputs (1=on, 0=off)
   Bits [31:4] = Reserved

0x04: LED Mode Register (RW)
   Bits [3:0] = LED mode select
      0 = Manual control (from output register)
      1 = Blink mode
      2-15 = Reserved for future use
   Bits [31:4] = Reserved
```

**Example Usage (pseudo-C):**

```c
// Turn on LED 0 and 2
write_word(LED_BASE + 0x00, 0x5);  // 0101 binary

// Set LED 1 to blink mode
write_word(LED_BASE + 0x04, 0x2);  // Mode 1 for LED 1
```

*Note:* The TTL Serial Controller (`wb_ttl_serial.sv`) was removed from this repository. Use the `ttlSerial/` module directly or restore from git history if needed.

## Integration with SPI Slave

The Wishbone bus can be accessed through the existing SPI slave interface by:

1. **Creating a Wishbone Master from SPI commands**
   - Use the SPI slave as a bridge to generate Wishbone cycles
   - Encode address/data in SPI packets

2. **Using a dedicated Wishbone Arbiter**
   - Route both SPI and direct CPU access to Wishbone slaves

Example architecture:

```
┌─────────────┐
│  SPI Master │ (External host)
└──────┬──────┘
       │ SPI
       ▼
┌──────────────────────┐
│  SPI Slave (Master)  │ ← Can be extended to Wishbone master
└──────┬───────────────┘
       │
       ├─────────────────┐
       ▼                 ▼
   [Optional]      ┌─────────────┐
  Wishbone         │    Mux      │
  Master           └──┬──────┬───┘
                      │      │
                      ▼      ▼
                   [LED]  [Serial]
```

## Implementing Wishbone Master from SPI

To read/write Wishbone registers via SPI:

```python
# Python pseudo-code for SPI to Wishbone

def wb_read(address):
    """Read 32-bit word from Wishbone address via SPI"""
    cmd = 0x01  # Read command
    spi_write([cmd, (address >> 24) & 0xFF, (address >> 16) & 0xFF, 
                      (address >> 8) & 0xFF, address & 0xFF])
    return spi_read(4)

def wb_write(address, data):
    """Write 32-bit word to Wishbone address via SPI"""
    cmd = 0x00  # Write command
    spi_write([cmd, (address >> 24) & 0xFF, (address >> 16) & 0xFF,
                      (address >> 8) & 0xFF, address & 0xFF,
                      (data >> 24) & 0xFF, (data >> 16) & 0xFF,
                      (data >> 8) & 0xFF, data & 0xFF])
```

## Timing Characteristics

**Wishbone Cycle Timing:**
- Minimum setup time: 1 clock cycle
- Acknowledgment: Usually within 1-2 clock cycles for simple slaves
- Max address: 32-bit (0x0000_0000 to 0xFFFF_FFFF)

**Device Access Times:**

| Device | Read Access | Write Access |
|--------|------------|-------------|
| LED Controller | 1 cycle | 1 cycle |
| TTL Serial (TX) | N/A | 1 cycle (triggers TX) |
| TTL Serial (RX) | 1 cycle | N/A |
| TTL Serial (Status) | 1 cycle | N/A |

## Error Handling

The Wishbone slaves currently implement:
- **Always ACK**: All cycles are acknowledged
- **No Errors**: `err_o` is always 0
- **No Retry**: `rty_o` is always 0

Future enhancements:
- Address decode errors
- Timeout handling for hung slaves
- Parity/CRC error reporting

## Future Extensions

### SPI to Wishbone Bridge Module

Create a `spi_wb_master.sv` that converts SPI commands to Wishbone cycles:

```verilog
module spi_wb_master (
    // SPI interface (as slave)
    input spi_clk, spi_mosi, input spi_cs_n,
    output spi_miso,
    
    // Wishbone master interface
    output [31:0] wb_addr, wb_data_out,
    output wb_we, wb_stb, wb_cyc,
    input [31:0] wb_data_in, wb_ack
);
```

### GPIO Port Expander

Extend the LED controller to support:
- Read-back of output state
- Interrupt on change
- Pull-up/pull-down control

### UART with FIFO

Enhance TTL Serial with:
- RX FIFO buffer
- TX FIFO buffer
- Interrupt signals on FIFO events
- Hardware flow control (RTS/CTS)

## Testing

Simulate the Wishbone interface:

```bash
# Compile with Wishbone modules (TTL serial wrapper removed)
cd src
iverilog -g2012 -o tb_wb.vvp pll.sv \
   wb_led_controller.sv tang9k_top.sv

# Run simulation
vvp tb_wb.vvp
```

## References

- Wishbone B3 Spec: http://opencores.org/opencores,wishbone,b3
- Alex Forencich's Wishbone Library: https://github.com/alexforencich/verilog-wishbone
- OpenCores Wishbone Resources: http://opencores.org/opencores,wishbone
