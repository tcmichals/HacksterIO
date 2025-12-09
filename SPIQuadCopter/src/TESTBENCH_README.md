# UART Passthrough Bridge Testbench

## Overview

This testbench verifies the UART passthrough bridge functionality, which is critical for BLHeli ESC configuration.

## Test Coverage

The testbench includes the following tests:

1. **Passthrough Disabled Test**
   - Verifies serial line is tri-stated when `enable=0`
   - Ensures no data flows when disabled

2. **PC → ESC Data Flow**
   - Tests USB UART RX to Serial TX path
   - Verifies byte-level forwarding

3. **ESC → PC Data Flow**
   - Tests Serial RX to USB UART TX path
   - Verifies response forwarding

4. **Bidirectional Conversation**
   - Simulates BLHeli command-response sequence
   - Tests realistic communication pattern

5. **Half-Duplex Tri-State Verification**
   - Monitors serial line during transmission
   - Verifies automatic switching to high-Z after TX

6. **Multi-byte Message**
   - Tests consecutive byte transmission
   - Verifies no data corruption or loss

7. **Disable During Operation**
   - Tests disabling passthrough mid-transmission
   - Verifies clean shutdown behavior

## Running the Testbench

### Quick Start

```bash
cd src/
./run_passthrough_tb.sh
```

### Using Make

```bash
cd src/
make -f Makefile.passthrough_tb sim
```

### Manual Compilation

```bash
# Compile
iverilog -g2012 -Wall -Wno-timescale \
    -o uart_passthrough_bridge_tb.vvp \
    uart_passthrough_bridge_tb.sv \
    uart_passthrough_bridge.sv \
    uart_rx.sv \
    uart_tx.sv

# Run
vvp uart_passthrough_bridge_tb.vvp

# View waveforms
gtkwave uart_passthrough_bridge_tb.vcd
```

## Requirements

- **Icarus Verilog** (iverilog) - Verilog compiler
- **GTKWave** (optional) - Waveform viewer

Install on Ubuntu/Debian:
```bash
sudo apt-get install iverilog gtkwave
```

## Dependencies

The testbench requires these modules (ensure they're in the same directory or update paths):

- `uart_passthrough_bridge.sv` - DUT (Device Under Test)
- `uart_rx.sv` - UART receiver module
- `uart_tx.sv` - UART transmitter module

## Expected Output

Successful test run should show:

```
========================================
UART Passthrough Bridge Testbench
========================================

TEST 1: Passthrough Disabled
----------------------------------------
PASS: Serial line is tri-stated when disabled

TEST 2: PC → ESC (USB UART to Serial)
----------------------------------------
PC → FPGA: Sending 0x41 ('A')
FPGA → ESC: Received 0x41 ('A')
PASS: Byte forwarded correctly (0x41)

TEST 3: ESC → PC (Serial to USB UART)
----------------------------------------
ESC → FPGA: Sending 0x42 ('B')
FPGA → PC: Received 0x42 ('B')
PASS: Byte forwarded correctly (0x42)

...

All Tests Complete!
========================================
```

## Viewing Waveforms

The testbench generates a VCD file: `uart_passthrough_bridge_tb.vcd`

**First time viewing:**
```bash
# Open GTKWave
gtkwave uart_passthrough_bridge_tb.vcd
```

In GTKWave:
1. Expand the signal tree on the left
2. Select signals you want to view
3. Drag them to the waveform window
4. Arrange and group signals as desired
5. **Save your configuration**: File → Write Save File → `uart_passthrough_bridge_tb.gtkw`

**Subsequent viewing with saved configuration:**
```bash
gtkwave uart_passthrough_bridge_tb.vcd uart_passthrough_bridge_tb.gtkw
```

### Recommended Signal Groups

For best debugging experience, organize signals into these groups:

**Control Signals:**
- `enable` - Passthrough enable control
- `active` - Activity indicator

**USB UART Interface (PC Side):**
- `usb_uart_rx` - Data from PC
- `usb_uart_tx` - Data to PC

**Half-Duplex Serial (ESC Side):**
- `serial` - Bidirectional serial line (watch tri-state!)
- `serial_drive` - Test harness drive signal
- `serial_drive_value` - Test harness value

**DUT Internal - USB UART:**
- `dut.usb_rx_valid` / `dut.usb_rx_data[7:0]`
- `dut.usb_tx_valid` / `dut.usb_tx_data[7:0]`
- `dut.usb_tx_ready`

**DUT Internal - Serial (ESC):**
- `dut.serial_tx_valid` / `dut.serial_tx_data[7:0]`
- `dut.serial_tx_active` - **Important: Controls tri-state**
- `dut.serial_rx_valid` / `dut.serial_rx_data[7:0]`

**DUT Internal - Tri-State:**
- `dut.serial_oe` - Output enable
- `dut.serial_out` - Output value

### Key Signals to Monitor

- `usb_uart_rx` / `usb_uart_tx` - USB UART interface
- `serial` - Half-duplex serial line (note tri-state behavior)
- `enable` - Passthrough enable control
- `active` - Activity indicator
- `dut.serial_tx_active` - Internal TX active signal (controls tri-state)

## Timing Parameters

- **Clock Frequency**: 72 MHz (13.888 ns period)
- **Baud Rate**: 115200 (8.68 μs bit period)
- **Bit Period**: 8680 ns

## Debugging Tips

1. **Check timing**: Verify UART bit timing matches 115200 baud (8.68 μs)
2. **Monitor tri-state**: Serial line should be high-Z when not transmitting
3. **Verify half-duplex**: Only one direction active at a time
4. **Check enable logic**: Data should only flow when `enable=1`

## Common Issues

### Compilation Errors

**Missing UART modules:**
```
Error: uart_rx.sv not found
```
**Solution:** Ensure `uart_rx.sv` and `uart_tx.sv` are in the same directory or update paths in Makefile/script.

### Simulation Errors

**Tri-state conflicts:**
If you see 'X' on the serial line, check that:
- Only one driver is active at a time
- `serial_tx_active` correctly controls tri-state buffer
- ESC driver is disabled during FPGA transmission

**Timing mismatches:**
If bytes are corrupted, verify:
- Baud rate calculation is correct (72 MHz / 115200)
- Bit period is accurate (8680 ns)
- Sample timing is centered in bit period

## Test Results Interpretation

- **PASS**: Test completed successfully
- **FAIL**: Test failed with error details
- **INFO**: Informational message
- **ERROR**: Critical error occurred

## Extending the Testbench

To add new tests:

1. Add test section in `uart_passthrough_bridge_tb.sv`
2. Use provided tasks: `send_usb_byte()`, `send_serial_byte()`, `receive_usb_byte()`, `receive_serial_byte()`
3. Follow existing test pattern with display messages
4. Verify expected vs. actual results

## See Also

- [uart_passthrough_bridge.sv](uart_passthrough_bridge.sv) - DUT source code
- [BLHELI_PASSTHROUGH_SETUP.md](../python/test/BLHELI_PASSTHROUGH_SETUP.md) - Usage guide
- [HARDWARE_PINS.md](../HARDWARE_PINS.md) - Pin connections
