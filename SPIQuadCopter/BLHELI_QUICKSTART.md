# Tang9K FPGA BLHeli Passthrough - Quick Reference

## What You Need

1. **Tang9K FPGA board** (programmed with latest bitstream)
2. **USB-to-TTL serial adapter** (CP2102, FT232, or CH340)
3. **BLHeliSuite** or **BLHeliConfigurator** software
4. **3 wires** for connections

## Wiring (Critical!)

```
USB Adapter          Tang9K FPGA
───────────          ───────────
  TX      ────────►  Pin 19 (i_usb_uart_rx)
  RX      ◄────────  Pin 20 (o_usb_uart_tx)
  GND     ──────────  GND

ESC                  Tang9K FPGA
───────────          ───────────
Signal    ◄────────►  Pin 25 (serial)
GND       ──────────  GND
```

**Important:**
- ✓ Adapter TX → Pin 19
- ✓ Adapter RX → Pin 20
- ✓ ESC Signal → Pin 25 (NOT pins 19 or 20!)
- ✓ Common GND for all devices
- ✗ Do NOT connect VCC/power between devices

## Quick Start

### 1. Enable Passthrough
```bash
cd python/test
python3 tang9k_tui.py --device /dev/spidev0.0
# Press 'p' to enable passthrough
# Status shows: "Passthrough: ENABLED"
```

### 2. Find Serial Port
```bash
ls /dev/ttyUSB* /dev/ttyACM*
# Use the device that appears (e.g., /dev/ttyUSB0)
```

### 3. Configure BLHeli
- Open BLHeliSuite or BLHeliConfigurator
- Select your serial port (e.g., /dev/ttyUSB0)
- Set baud rate: **115200**
- Click "Connect" or "Read Setup"

### 4. Done!
- Configure your ESC settings
- Flash firmware if needed
- Press 'p' in TUI to disable passthrough when done

## How It Works

```
Your PC → USB → Adapter → Pins 19-20 → FPGA Hardware Bridge → Pin 25 → ESC
```

**Key Points:**
- All data flows in **hardware** (no software bridging)
- BLHeli tool connects to **real USB serial port** (not virtual device)
- Python app just enables/disables the FPGA bridge
- Fixed baud rate: **115200**

## Troubleshooting

| Problem | Check |
|---------|-------|
| BLHeli can't connect | ✓ Passthrough enabled in TUI<br>✓ Correct serial port selected<br>✓ Baud rate = 115200<br>✓ ESC has power |
| Wrong pin error | ✓ Adapter to pins 19-20<br>✓ ESC to pin 25 (separate!) |
| Garbage data | ✓ Common GND connected<br>✓ Wires not reversed<br>✓ Baud rate = 115200 |
| No serial port | ✓ USB adapter plugged in<br>✓ Run `dmesg | tail` to verify |

## Architecture

**Passthrough Mode (mux_sel = 0):**
- USB UART bridge **enabled**
- DSHOT outputs **disabled**
- Data flows: PC ↔ FPGA ↔ ESC

**DSHOT Mode (mux_sel = 1):**
- USB UART bridge **disabled**
- DSHOT outputs **enabled**
- Normal flight operations

Python TUI controls mode by writing to Wishbone register 0x0400.

## Files Reference

| File | Purpose |
|------|---------|
| [HARDWARE_PINS.md](HARDWARE_PINS.md) | Complete pin reference with diagrams |
| [BLHELI_PASSTHROUGH_SETUP.md](python/test/BLHELI_PASSTHROUGH_SETUP.md) | Detailed setup instructions |
| [SYSTEM_OVERVIEW.md](SYSTEM_OVERVIEW.md) | Full system architecture |
| [tang9k.cst](tang9k.cst) | Pin constraints |
| [uart_passthrough_bridge.sv](src/uart_passthrough_bridge.sv) | Hardware bridge module |
| [tang9k_top.sv](src/tang9k_top.sv) | Top-level FPGA module |

## Command Cheat Sheet

```bash
# Start TUI
cd python/test && python3 tang9k_tui.py

# List serial ports
ls /dev/ttyUSB* /dev/ttyACM*

# Check USB device
dmesg | tail -20

# Test serial loopback (short pins 19-20)
screen /dev/ttyUSB0 115200

# Install BLHeliSuite (if needed)
# Download from: https://github.com/bitdump/BLHeli
```

## Common Mistakes

1. **Wrong pins**: ESC must go to pin 25, not 19/20
2. **Reversed wires**: TX→RX and RX→TX (crossover)
3. **No common ground**: All GNDs must connect
4. **Wrong baud rate**: Must be 115200
5. **Passthrough not enabled**: Press 'p' in TUI first
6. **Wrong serial port**: Check with `ls /dev/tty*`

## Success Checklist

- [ ] USB adapter connected to pins 19-20 + GND
- [ ] ESC connected to pin 25 + GND
- [ ] All grounds connected together
- [ ] TUI running with passthrough enabled
- [ ] BLHeli tool sees /dev/ttyUSB0 (or similar)
- [ ] Baud rate set to 115200
- [ ] ESC has power from battery

If all checked, BLHeli should connect successfully!
