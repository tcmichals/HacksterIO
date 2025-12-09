# TTL Serial UART Module

A flexible SystemVerilog UART module for TTL serial communication with configurable baud rates and half-duplex support.

## Features

- **Configurable Baud Rate**: Default 115200 bps, but supports any standard rate (9600, 19200, 38400, etc.)
- **Configurable Clock Frequency**: Default 27 MHz, adaptable for different FPGA platforms
- **Half-Duplex Mode**: Optional support for single-wire serial communication (default enabled)
- **Full-Duplex Mode**: Can be disabled for dedicated TX/RX lines
- **Standard 8-N-1 Format**: 8 data bits, no parity, 1 stop bit (actually 2 stop bits for safety)
- **Clean Handshake Signals**: `tx_valid`/`tx_ready` and `rx_valid` strobes

## Module Hierarchy

```
ttl_serial (top-level, handles half-duplex control)
├── ttl_serial_tx (transmitter)
└── ttl_serial_rx (receiver)
```

## Port Descriptions

### ttl_serial (Top Level)

**Parameters:**
- `CLK_FREQ_HZ`: System clock frequency (default: 27,000,000 Hz)
- `BAUD_RATE`: Serial baud rate (default: 115,200 bps)
- `HALF_DUPLEX`: Enable half-duplex mode (default: 1)

**Inputs:**
- `clk`: System clock
- `rst_n`: Active-low synchronous reset
- `tx_data[7:0]`: Data to transmit
- `tx_valid`: Transmit strobe (valid for one clock cycle)
- `rx_in`: Serial receive input (for full-duplex mode)
- `half_duplex_en`: When high, transmitter drives the line; when low, receiver listens

**Outputs:**
- `tx_ready`: Transmitter ready for new data
- `rx_data[7:0]`: Received data (valid when `rx_valid` is high)
- `rx_valid`: Receive data strobe (valid for one clock cycle)

**Bidirectional:**
- `serial`: TTL serial line (open-drain output in half-duplex mode)

## Usage Examples

### Basic 115200 Baud Half-Duplex Setup

```verilog
ttl_serial #(
    .CLK_FREQ_HZ(27_000_000),
    .BAUD_RATE(115_200),
    .HALF_DUPLEX(1)
) u_uart (
    .clk(clk),
    .rst_n(rst_n),
    .tx_data(tx_byte),
    .tx_valid(tx_valid),
    .tx_ready(tx_ready),
    .rx_data(rx_byte),
    .rx_valid(rx_valid),
    .serial(serial_pin),
    .half_duplex_en(1'b1)  // Always transmit enabled
);
```

### Alternative Baud Rate (9600)

```verilog
ttl_serial #(
    .BAUD_RATE(9_600)
) u_uart (
    // ... other connections
);
```

### Full-Duplex Mode (Separate TX/RX Lines)

```verilog
ttl_serial #(
    .HALF_DUPLEX(0)
) u_uart (
    // ... connections
    // Note: Would need separate tx_out and rx_in pins
);
```

## Transmitter (ttl_serial_tx)

**State Machine:**
```
IDLE -> START_BIT -> DATA_BITS (×8) -> STOP_BIT -> STOP_BIT2 -> IDLE
```

- **START_BIT**: Drives line low (0) for one bit period
- **DATA_BITS**: Transmits 8 data bits LSB-first
- **STOP_BIT**: Drives line high (1) for one bit period
- **STOP_BIT2**: Additional stop bit for safety (can be combined if needed)

**Handshake:**
- Asserts `tx_ready` when idle and either not in half-duplex mode or `half_duplex_en` is high
- Accepts `tx_valid` strobe to load new data and start transmission

## Receiver (ttl_serial_rx)

**State Machine:**
```
IDLE -> START_BIT -> DATA_BITS (×8) -> STOP_BIT -> DATA_READY -> IDLE
```

- **IDLE**: Waits for falling edge (start bit detection)
- **START_BIT**: Waits for center of start bit
- **DATA_BITS**: Samples data bits at center of each bit period
- **STOP_BIT**: Waits for stop bit
- **DATA_READY**: Asserts `rx_valid` for one clock cycle with received data

**Features:**
- Input synchronization (2-FF synchronizer for metastability)
- Over-sampling at 16× baud rate (starts at half rate to center in start bit)

## Baud Rate Calculations

The module automatically calculates the baud rate divisor:

```
BAUD_DIV = CLK_FREQ_HZ / BAUD_RATE
```

**Examples for 27 MHz clock:**
- 115,200 bps: divisor = 234 clock cycles
- 9,600 bps: divisor = 2,812 clock cycles
- 19,200 bps: divisor = 1,406 clock cycles

## Simulation

Run behavioral simulation with Iverilog:

```bash
cd ttlSerial
make simulate              # Default: 115200 baud, 27 MHz
make simulate BAUD_RATE=9600
make wave                  # View in gtkwave
```

The testbench (`ttl_serial_tb.sv`) includes:
- Initialization and reset
- Basic transmission tests
- Loopback verification
- Waveform capture to VCD file

## Half-Duplex Mode

When `HALF_DUPLEX=1`:
- The `serial` line is implemented as an open-drain output
- Set `half_duplex_en=1` to allow transmission
- Set `half_duplex_en=0` to listen (receiver only)
- The receiver can detect echoed data during transmission (useful for collision detection)

Example usage:
```verilog
always_ff @(posedge clk) begin
    if (start_transmit) begin
        half_duplex_en <= 1'b1;  // Switch to TX mode
    end else if (tx_complete) begin
        half_duplex_en <= 1'b0;  // Switch to RX mode
    end
end
```

## Integration with Tang9K Project

To use this module in your top-level design:

1. Add to your RTL sources in the main Makefile
2. Create a wrapper that connects your FPGA pins to the `serial` port
3. Manage `half_duplex_en` with your application logic

Example wrapper:
```verilog
// In your tang9k_top.sv
wire serial_rx;
ttl_serial #(.BAUD_RATE(115_200)) u_uart (
    .clk(sys_clk),
    .rst_n(sys_rst_n),
    .tx_data(uart_tx_byte),
    .tx_valid(uart_tx_valid),
    .tx_ready(uart_tx_ready),
    .rx_data(uart_rx_byte),
    .rx_valid(uart_rx_valid),
    .serial(serial_rx),
    .half_duplex_en(1'b1)
);
```

## Synthesis Considerations

- **Area**: ~1K LUTs for full module (TX + RX)
- **Timing**: No critical paths; designed for low-speed serial operation
- **Resources**: Minimal DSP/BRAM usage; mostly logic
- **Parameterization**: Divisor is computed as a constant; no dynamic recalculation

## Known Limitations

1. **No Parity**: 8-N-1 format only (no parity bit support)
2. **No Flow Control**: No RTS/CTS implementation
3. **Limited Error Detection**: No framing error reporting (stop bit validation could be added)
4. **Single Character**: RX doesn't buffer (application must handle `rx_valid` strobe)

## Future Enhancements

- [ ] Add RX FIFO buffer for burst reception
- [ ] Add error flags (framing error, overrun)
- [ ] Optional parity support
- [ ] RTS/CTS flow control
- [ ] Baud rate divider lookup table for non-standard clock frequencies
- [ ] Optional 9-bit mode (for addressing in multi-drop)

## Testing Notes

When simulating:
- Clock frequency: 27 MHz (CLK_PERIOD = 37.037 ns)
- Baud period at 115200: 8,680.6 ns ≈ 234 clock cycles
- Full 8-N-1 frame (with 2 stop bits): ~11 bits = 95,487 ns

VCD waveform can be inspected with:
```bash
gtkwave ttlSerial/ttl_serial_tb.vcd
```

Look for:
- `serial`: The TTL line (idle=1, active=0 for data/start)
- `tx_valid`/`tx_ready`: TX handshake
- `rx_valid`: RX data strobe
- `rx_data`: Received byte value
