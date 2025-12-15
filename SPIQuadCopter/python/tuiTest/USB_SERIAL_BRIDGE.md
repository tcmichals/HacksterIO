# USB Serial Bridge for BLHeli Passthrough

## Overview

The **simplest and most compatible** way to use BLHeli tools (including the web-based ESC Configurator) is to connect a USB-to-TTL serial adapter directly to the Tang9K's UART pins.

This creates a **real hardware serial device** (`/dev/ttyUSB0` or `/dev/ttyACM0`) that:
- ✅ Works with ALL BLHeli tools (desktop and web)
- ✅ Works with ESC Configurator web app (https://esc-configurator.com/)
- ✅ No sudo required
- ✅ No PTY limitations
- ✅ Direct hardware connection

## Hardware Required

### USB-to-TTL Serial Adapter

Any common USB serial adapter will work:
- **FTDI FT232** (most common, reliable)
- **CP2102** (cheap, widely available)
- **CH340** (very cheap, works fine)
- **PL2303** (older, but works)

**Voltage:** Ensure the adapter is **3.3V compatible** (most are). The Tang9K operates at 3.3V logic levels.

### Wiring

You'll need 3 connections:

```
USB Serial Adapter          Tang9K FPGA
─────────────────          ────────────
    TX      ────────────→    UART_RX
    RX      ←────────────    UART_TX
    GND     ────────────     GND
```

**Important:** 
- Adapter TX goes to Tang9K RX
- Adapter RX comes from Tang9K TX
- Always connect GND

## Hardware Setup

### Step 1: Identify Tang9K UART Pins

Check your `tang9k.cst` constraint file for the serial pin assignment:

```tcl
// Half-Duplex Serial (for BLHeli ESC configuration)
IO_LOC "serial" 25;
IO_PORT "serial" IO_TYPE=LVCMOS33 PULL_MODE=UP DRIVE=8;
```

**Pin 25** is the half-duplex serial line (adjust if needed for your board).

**Note:** The internal pull-up is already enabled in the constraint file, so no external resistor is required for typical use (connections up to ~10cm).

### Step 2: Connect USB Serial Adapter

1. **Power off everything**
2. **Connect wires:**
   - Adapter TX (output) → Tang9K UART_RX pin
   - Adapter RX (input) → Tang9K UART_TX pin
   - Adapter GND → Tang9K GND
3. **Connect ESC:** ESC signal wire connects to Tang9K's half-duplex serial pin (same as UART_TX for half-duplex)
4. **Plug in USB adapter** to your computer

### Step 3: Verify Device

```bash
# Check that the device appears
ls -l /dev/ttyUSB*
# or
ls -l /dev/ttyACM*

# You should see something like:
crw-rw---- 1 root dialout 188, 0 Dec  8 12:00 /dev/ttyUSB0
```

If you don't have permission, add yourself to the `dialout` group:
```bash
sudo usermod -a -G dialout $USER
# Log out and back in for changes to take effect
```

## Software Setup

### Configure the Mux

The Tang9K has a mux register (0x0400) that switches between DSHOT and Serial modes:

**Option A: Using Python TUI**
```bash
cd python/test
python3 tang9k_tui.py --device /dev/spidev0.0

# In the TUI:
# Press 'p' to toggle passthrough mode
# This sets the mux to serial mode (0x0400 = 0)
```

**Option B: Direct SPI Command**
```python
from tang9k_tui import SPIMaster

spi = SPIMaster(bus=0, device=0)
spi.write_wishbone(0x0400, 0)  # Set mux to serial mode (0 = serial, 1 = DSHOT)
```

**Option C: Standalone Script**
```bash
# Create a simple script to set serial mode
echo "import spidev
spi = spidev.SpiDev()
spi.open(0, 0)
spi.max_speed_hz = 1000000
# Write to mux register: set to serial mode
spi.xfer2([0x04, 0x00, 0x00, 0x00, 0x00])
spi.close()" > set_serial_mode.py

python3 set_serial_mode.py
```

### Test the Connection

```bash
# Send test data to the serial port
echo "test" > /dev/ttyUSB0

# Or use screen/minicom to interact
screen /dev/ttyUSB0 115200
```

## Using BLHeli Tools

### Desktop Applications

**BLHeliSuite or BLHeliConfigurator:**

1. Set mux to serial mode (see above)
2. Open BLHeliSuite or BLHeliConfigurator
3. Select port: `/dev/ttyUSB0` (or whatever your adapter shows as)
4. Set baud rate: **115200**
5. Connect and configure your ESCs

### Web-Based ESC Configurator

**ESC Configurator (https://esc-configurator.com/):**

1. **Set mux to serial mode** (see above)

2. **Set up Chromium** (if using snap):
   ```bash
   sudo snap connect chromium:raw-usb
   ```

3. **Open ESC Configurator:**
   - Navigate to https://esc-configurator.com/ in Chrome/Chromium
   - Click **"Connect"**
   - Select `/dev/ttyUSB0` from the serial port list
   - Baud rate: **115200**
   - Click **"Connect"**

4. **Configure your ESCs** - the web app has full functionality!

## Architecture

### Data Flow

```
ESC Configurator Web App (Chrome)
         ↓
   Web Serial API
         ↓
   /dev/ttyUSB0 (USB Serial Adapter)
         ↓
   Tang9K UART (115200 baud, 8-N-1)
         ↓
   Half-Duplex Serial Line
         ↓
   ESC (BLHeli firmware)
```

### Key Points

- **No Python bridge needed** - direct hardware connection
- **No PTY limitations** - real serial device
- **No sudo needed** - just dialout group membership
- **Works with everything** - desktop and web tools

## Comparison: USB Serial vs PTY Bridge

| Feature | USB Serial Bridge | PTY Bridge (TUI) |
|---------|------------------|------------------|
| Hardware needed | USB-TTL adapter | SPI master only |
| Device created | `/dev/ttyUSB0` (real) | `/dev/ttyBLH0` (PTY symlink) |
| Works with web app | ✅ Yes | ❌ No |
| Works with desktop tools | ✅ Yes | ✅ Yes |
| Requires sudo | ❌ No | ✅ Yes |
| Setup complexity | Simple | Medium |
| Cost | ~$2-10 for adapter | $0 (if SPI already available) |

## Troubleshooting

### Port doesn't appear

**Problem:** `/dev/ttyUSB0` not showing up

**Check:**
```bash
# List all USB devices
lsusb

# Check kernel messages
dmesg | tail -n 20
```

**Common causes:**
- Adapter not plugged in properly
- Bad USB cable
- Driver not loaded (rare on modern Linux)

### Permission denied

**Error:** Cannot open `/dev/ttyUSB0`

**Solution:**
```bash
# Add yourself to dialout group
sudo usermod -a -G dialout $USER

# Log out and back in, then verify:
groups | grep dialout
```

### Wrong baud rate

**Problem:** Communication not working

**Solution:**
- Ensure Tang9K UART is configured for **115200 baud**
- Check your UART timing calculations at 72 MHz
- Verify: `72000000 / 115200 = 625 clocks per bit`

### Data corruption

**Problem:** Garbled data or communication errors

**Check:**
1. **Wiring:**
   - TX/RX not swapped?
   - GND connected?
   - Loose connections?

2. **Voltage levels:**
   - Adapter set to 3.3V (not 5V)?
   - Check with multimeter

3. **Mux mode:**
   - Is mux set to serial mode (0)?
   - Verify with: `spi.read_wishbone(0x0400)` should return 0

### ESC not responding

**Problem:** BLHeli tool connects but ESC doesn't respond

**Check:**
1. **ESC powered:** ESC must have power to respond
2. **ESC connected:** Signal wire to correct Tang9K pin?
3. **Half-duplex timing:** UART configured for half-duplex?
4. **Mux state:** Definitely in serial mode, not DSHOT?

## Recommended Setup

**For permanent installation:**

1. **Mount USB adapter** near Tang9K
2. **Solder connections** (more reliable than jumpers)
3. **Add connector** for easy ESC swapping
4. **Label the port** so you know which device to use
5. **Add udev rule** for consistent device name:

```bash
# Create udev rule for consistent naming
sudo nano /etc/udev/rules.d/99-tang9k-serial.rules

# Add this line (adjust ATTR values for your adapter):
SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", SYMLINK+="tang9k_serial"

# Reload rules
sudo udevadm control --reload-rules
sudo udevadm trigger
```

Now the device will always appear as `/dev/tang9k_serial` regardless of which `/dev/ttyUSBx` number it gets!

## See Also

- [BLHELI_PASSTHROUGH.md](../../docs/BLHELI_PASSTHROUGH.md) - Complete passthrough guide
- [BLHELI_PASSTHROUGH_SETUP.md](BLHELI_PASSTHROUGH_SETUP.md) - BLHeli passthrough mode details
- [ESC_CONFIGURATOR_WEBAPP.md](ESC_CONFIGURATOR_WEBAPP.md) - Web app details
- [SYSTEM_OVERVIEW.md](../../docs/SYSTEM_OVERVIEW.md) - Full system architecture
