# BLHeli Passthrough Setup

## Overview

BLHeli configuration tools (BLHeliSuite and BLHeliConfigurator) connect directly to the Tang9K's **USB UART interface** to configure ESCs. The Python TUI simply enables passthrough mode on the FPGA, which bridges the USB UART to the half-duplex ESC serial line in hardware.

**Hardware Architecture:**
```
PC (BLHeli Tool) ↔ USB-to-TTL Adapter ↔ Tang9K USB UART (pins 19-20) 
                                         ↓ (hardware passthrough)
                                      Serial Pin 25 ↔ ESC
```

**Key Features:**
- **Pure Hardware Passthrough**: No software data bridging - bytes flow directly through FPGA logic
- **No Wishbone Contention**: USB UART bridge bypasses Wishbone bus completely
- **Automatic Half-Duplex**: Hardware handles tri-state control for ESC communication
- **Fixed Baud Rate**: 115200 (both USB UART and ESC serial)

## Hardware Wiring

### USB-to-TTL Adapter Connection

Connect your USB-to-TTL adapter (CP2102, FT232, CH340) to the Tang9K:

| Adapter Pin | Tang9K Pin | Function          |
|-------------|------------|-------------------|
| TX          | Pin 19     | i_usb_uart_rx     |
| RX          | Pin 20     | o_usb_uart_tx     |
| GND         | GND        | Ground            |

**Important Notes:**
- Adapter TX → Tang9K RX (pin 19)
- Adapter RX → Tang9K TX (pin 20)
- Do NOT connect VCC/3.3V (Tang9K is self-powered)
- Pin 25 (serial) connects to ESC, not the USB adapter

### ESC Connection

The ESC connects to Tang9K pin 25 (half-duplex serial):

| ESC Wire | Tang9K Pin | Function          |
|----------|------------|-------------------|
| Signal   | Pin 25     | serial (bidir)    |
| GND      | GND        | Ground            |

## How It Works

The Tang9K contains a dedicated hardware passthrough bridge that:
1. Decodes USB UART RX bytes (from PC/BLHeli tool)
2. Transmits them on the half-duplex serial line (to ESC)
3. Receives ESC responses on the serial line
4. Encodes and transmits them via USB UART TX (back to PC)

**Python TUI Role:**
- Writes to Wishbone mux register (0x0400) to enable/disable passthrough
- When `mux_sel=0`: Passthrough bridge enabled, data flows USB ↔ ESC
- When `mux_sel=1`: Passthrough disabled, DSHOT controller drives motors

## Requirements

- **USB-to-TTL serial adapter** (CP2102, FT232, CH340, etc.)
- **BLHeliSuite** or **BLHeliConfigurator** software
- **Tang9K FPGA** programmed with latest bitstream (with USB UART support)

### Pin Configuration

The Tang9K constraint file (`tang9k.cst`) must have these pins defined:

```verilog
// USB UART Interface (for BLHeli passthrough to PC)
IO_LOC "i_usb_uart_rx" 19;
IO_PORT "i_usb_uart_rx" LVCMOS33;
IO_LOC "o_usb_uart_tx" 20;
IO_PORT "o_usb_uart_tx" LVCMOS33;

// Half-Duplex Serial (for BLHeli ESC configuration)
IO_LOC "serial" 25;
IO_PORT "serial" IO_TYPE=LVCMOS33 PULL_MODE=UP DRIVE=8;
### For ESC Configurator Web App

If you want to use the web-based ESC Configurator (https://esc-configurator.com/):

**Requirements:**
- Chrome or Chromium browser (required for Web Serial API)
- On Linux with snap-installed Chromium, enable raw USB access:

```bash
# Enable raw USB access for Chromium snap
sudo snap connect chromium:raw-usb

# Verify the connection
snap connections chromium | grep raw-usb
```

**Note:** The ESC Configurator uses the Web Serial API which is only available in Chrome/Chromium browsers. Firefox and other browsers are not supported.

## Using the TUI

### Enable Passthrough Mode

1. Start the TUI:
```bash
cd python/test
python3 tang9k_tui.py --device /dev/spidev0.0
```

2. Press `p` to toggle passthrough mode

3. The status panel shows:
   - **Passthrough:** ENABLED (in green)
   - **Serial Port:** Use /dev/ttyUSB0 or similar (your USB adapter)

### Configure BLHeliSuite/Configurator

1. In BLHeliSuite or BLHeliConfigurator:
   - Select your USB-to-TTL adapter's serial port (e.g., `/dev/ttyUSB0`, `/dev/ttyACM0`)
   - Set baud rate to **115200**
   - Click "Connect"

2. The Tang9K hardware bridge is now active - all data flows:
   - PC → USB adapter → Tang9K pins 19/20 → FPGA bridge → pin 25 → ESC

3. Configure your ESC as normal

### Disable Passthrough Mode

1. Press `p` again to toggle off

2. Tang9K switches back to DSHOT mode for normal flight operations
└──────────────┘         └─────────────┘         └──┬──┘
                                                     │
                                                     │ Half-duplex
                                                     ▼
                                                  ┌─────┐
                                                  │ ESC │
                                                  └─────┘
```

### Pin Connections

| Signal | USB-Serial Adapter | Tang9K Pin |
|--------|-------------------|------------|
| TX     | TX                | Pin 25     |
| RX     | RX                | Pin 25     |
| GND    | GND               | GND        |

**Note:** Pin 25 is half-duplex (shared TX/RX), so both adapter TX and RX connect to the same pin.

## Testing

### Test Passthrough

1. Enable passthrough in TUI (press `p`)
2. Check status panel shows "ENABLED"
3. Connect BLHeli tool to your USB-to-TTL adapter's serial port
4. Try reading ESC settings

### Verify Hardware

Check the USB-to-TTL adapter is recognized:

```bash
# List USB serial devices
ls -l /dev/ttyUSB* /dev/ttyACM*

# Should show your USB-serial adapter (e.g., /dev/ttyUSB0)

# Check device info
dmesg | tail -20  # Look for CP2102, FT232, or CH340 messages
```

### Verify Pin Connections

| Connection | From | To | Check |
|------------|------|-----|-------|
| USB UART RX | Adapter TX | Tang9K Pin 19 | Adapter transmits to FPGA |
| USB UART TX | Adapter RX | Tang9K Pin 20 | FPGA transmits to adapter |
| ESC Serial | ESC Signal Wire | Tang9K Pin 25 | Half-duplex bidirectional |
| Ground | Adapter GND + ESC GND | Tang9K GND | Common ground |

## Troubleshooting

### No serial port found

**Check:**
1. USB-to-TTL adapter is plugged into PC
2. Run `ls /dev/ttyUSB* /dev/ttyACM*` to see available ports
3. Check adapter drivers (most work automatically on Linux)
4. Try different USB port

### BLHeliSuite can't connect

**Check:**
1. Correct serial port selected in BLHeli tool (your USB adapter, not Tang9K)
2. Baud rate is set to **115200**
3. Passthrough is enabled in TUI (status shows "ENABLED")
4. USB adapter TX/RX wired to Tang9K pins 19/20 (not pin 25!)
5. ESC signal wire connected to Tang9K pin 25
6. ESC is properly powered (separate from Tang9K)

### Connection times out

**Check:**
1. Tang9K is programmed with latest bitstream (with USB UART support)
2. **Pin 19** receives data from adapter TX
3. **Pin 20** sends data to adapter RX
4. **Pin 25** connects to ESC (not USB adapter!)
5. Common ground between all devices
6. ESC is receiving power
7. No other program is using the serial port (BLHeliSuite exclusive access)

### Data corruption or garbage

**Check:**
1. Baud rate mismatch - must be 115200 on both sides
2. Loose connections on breadboard
3. Cable length too long (keep under 1 meter for 115200 baud)
4. Electrical noise - add 100nF capacitor near Tang9K pin 25
5. Ground loop - ensure single, solid ground connection

### Wrong baud rate

**The Tang9K USB UART and ESC serial are both fixed at 115200 baud.**
- Always set BLHeli tool to 115200
- Lower speeds won't work
- Higher speeds won't work

## Implementation Details

### BLHeliPassthrough Class

The `blheli_passthrough.py` module is very simple:

```python
# Enable passthrough
blheli = BLHeliPassthrough(tang9k)
blheli.enable_passthrough()  # Switches mux, enables half-duplex

# ESC communication happens through hardware serial port

# Disable passthrough
blheli.disable_passthrough()  # Switches back to DSHOT
```

**What it does:**
- Writes to Tang9K mux register (address 0x0400): Sets to 0 for serial mode
- Writes to serial control register: Enables half-duplex mode
- That's it! No threads, no PTY, no virtual devices

**What it doesn't do:**
- Doesn't create any virtual devices
- Doesn't bridge or proxy data
- Doesn't manage the serial port
- Just configures the FPGA hardware

## See Also

- [BLHELI_PASSTHROUGH.md](../../docs/BLHELI_PASSTHROUGH.md) - BLHeli passthrough architecture details
- [SYSTEM_OVERVIEW.md](../../docs/SYSTEM_OVERVIEW.md) - Complete Tang9K system documentation
- [USB_SERIAL_BRIDGE.md](USB_SERIAL_BRIDGE.md) - Alternative: Hardware USB-serial bridge setup
- [TANG9K_LIBRARY.md](TANG9K_LIBRARY.md) - Python Tang9K library API reference
