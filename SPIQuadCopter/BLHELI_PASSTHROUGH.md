# BLHeli Passthrough Configuration Guide

## Overview
The Tang9K quadcopter FPGA supports direct ESC configuration through BLHeliSuite and BLHeliConfigurator using a serial passthrough mode. **Serial passthrough is now routed through the motor output pins** (pins 32-35), allowing you to configure ESCs without disconnecting them from the flight controller.

**Key Changes:**
- ✅ Motor pins (`o_motor1`..`o_motor4`) are **bi directional** (support DSHOT and serial)
- ✅ Select which motor pin via **mux register** (0x0400 bits 2:1)
- ❌ Dedicated `serial` pin (pin 25) **removed**

**Mux Register (0x0400)**:
```
Bit 2:1: mux_ch (0-3 selects motor pin)
Bit 0:   mux_sel (0=Passthrough, 1=DSHOT)

Examples:
  0x00 = Passthrough on Motor 1 (Pin 32)
  0x02 = Passthrough on Motor 2 (Pin 33)
  0x04 = Passthrough on Motor 3 (Pin 34)
  0x06 = Passthrough on Motor 4 (Pin 35)
  0x01 = DSHOT mode
```

## Important: Device Compatibility

BLHeli configuration tools work with serial devices. There are two approaches:

### Approach 1: Hardware Serial Bridge (Recommended for Web App)

Connect a **USB-to-TTL serial adapter** to the Tang9K's UART pins:
- This creates a real `/dev/ttyUSB0` or `/dev/ttyACM0` device
- Works with **all** BLHeli tools including the web-based ESC Configurator
- No sudo required, no PTY limitations
- Direct hardware connection

**Setup:**
1. Connect USB-TTL adapter to Tang9K UART pins (TX, RX, GND)
2. Adapter appears as `/dev/ttyUSB0` (or similar)
3. Enable serial mode via SPI: Write 0 to mux register (0x0400)
4. Connect BLHeli tool directly to `/dev/ttyUSB0`
5. Configure ESCs normally

### Approach 2: SPI Bridge with PTY (Python TUI)

Uses the Python TUI to create a virtual serial port via SPI:
- Creates `/dev/ttyBLH0` symlink (requires sudo)
- Works with **desktop** BLHeli tools only (BLHeliSuite/Configurator)
- Does NOT work with web-based ESC Configurator (Web Serial API limitation)
- Useful when no USB serial adapter is available

See [SOCAT_SETUP.md](python/test/SOCAT_SETUP.md) for PTY setup details.

## Architecture

### System Components
1. **Tang9K FPGA**: Half-duplex serial interface (16650 UART)
2. **Serial/DSHOT Mux**: Switches between motor control (DSHOT) and configuration (Serial)
3. **Python Bridge**: Creates virtual serial port and handles SPI communication
4. **BLHeli Tools**: BLHeliSuite or BLHeliConfigurator

### Data Flow
```
BLHeliSuite/Configurator
        ↓
Virtual Serial Port (PTY: /tmp/blheli_passthrough)
        ↓
Python Bridge (blheli_passthrough.py)
        ↓
SPI Master → Tang9K SPI Slave
        ↓
Wishbone Bus (Serial registers at 0x0100)
        ↓
Half-Duplex Serial (115200 baud, 8-N-1)
        ↓
ESC (BLHeli firmware)
```

## Hardware Setup

### Method 1: USB Serial Adapter (For Web App Support)

**Best for:** ESC Configurator web app, simplest setup

**Hardware Required:**
- USB-to-TTL serial adapter (FTDI, CP2102, CH340, etc.)
- Jumper wires

**Connections:**
1. **USB Serial Adapter → Tang9K UART:**
   - Adapter TX → Tang9K UART RX pin
   - Adapter RX → Tang9K UART TX pin  
   - Adapter GND → Tang9K GND

2. **ESC Signal Wire:** Connect to Tang9K's half-duplex serial pin (shared with DSHOT)

3. **Configure Mux via SPI:**
   - Write 0 to mux register (0x0400) for serial mode
   - Or use Python TUI to switch modes

**Result:** USB adapter creates `/dev/ttyUSB0` (or `/dev/ttyACM0`) that all BLHeli tools can use, including the web app!

### Method 2: SPI Bridge Only (Python TUI Required)

**Best for:** When no USB serial adapter available, desktop tools only

**Connections:**
1. **ESC Signal Wire**: Connect to Tang9K's half-duplex serial pin (shared with DSHOT)
2. **SPI Interface**: Connect SPI master (e.g., Raspberry Pi) to Tang9K
   - MOSI → Tang9K SPI MOSI
   - MISO → Tang9K SPI MISO
   - SCK → Tang9K SPI CLK
   - CS → Tang9K SPI CS

**Result:** Python TUI creates `/dev/ttyBLH0` via PTY. Works with desktop tools only.

### Mux Register (0x0400)
```
Bit 31-3: Reserved (read as 0)
Bit 2:1:  mux_ch (Motor channel select: 0-3)
Bit 0:    mux_sel (Mode: 0=Passthrough, 1=DSHOT)

Configuration Examples:
  Write 0x00: Passthrough on Motor 1 (Pin 32) - Front Right
  Write 0x02: Passthrough on Motor 2 (Pin 33) - Rear Right
  Write 0x04: Passthrough on Motor 3 (Pin 34) - Rear Left
  Write 0x06: Passthrough on Motor 4 (Pin 35) - Front Left
  Write 0x01: DSHOT mode (normal flight)
```

**Python Example:**
```python
# Configure ESC on Motor 3
spi.write(0x0400, 0x04)  # Passthrough + Channel 2 (Motor 3)

# Back to DSHOT mode
spi.write(0x0400, 0x01)  # DSHOT mode
```

## Software Setup

### Prerequisites
```bash
cd python/test
pip install -r requirements.txt

# Install socat for proper serial device creation
sudo apt-get install socat
```

### Dependencies
- Python 3.7+
- textual (TUI framework)
- spidev (SPI communication)
- socat (for /dev/ttyBLH0 device creation)

### Optional: ESC Configurator Web App
For https://esc-configurator.com/ (Chrome/Chromium only):
```bash
# Enable raw USB access for snap-installed Chromium
sudo snap connect chromium:raw-usb
```

## Usage

### Method 1: Python TUI (Recommended)

1. **Start the TUI application**:
   ```bash
   cd python/test
   python tang9k_tui.py
   ```

2. **Enable Passthrough Mode**:
   - Click "Enable Passthrough" button, OR
   - Press `p` key
   - If using socat, enter your sudo password when prompted

3. **Note the Serial Device**:
   - The TUI displays the serial device path
   - With socat: `/dev/ttyBLH0` (recommended)
   - Fallback PTY: `/tmp/blheli_passthrough`

4. **Connect BLHeli Tool**:
   
   **Option A: BLHeliSuite or BLHeliConfigurator (desktop apps)**
   - Open BLHeliSuite or BLHeliConfigurator
   - Select the serial port: `/dev/ttyBLH0`
   - Set baud rate: 115200
   - Configure your ESCs normally
   
   **Option B: ESC Configurator Web App**
   - Open https://esc-configurator.com/ in Chrome/Chromium
   - Click "Connect"
   - Select `/dev/ttyBLH0` from the serial port list
   - Configure your ESCs in the browser
   - **Note:** Only Chrome/Chromium browsers supported (Web Serial API required)

5. **Disable Passthrough Mode**:
   - Click "Disable Passthrough" button, OR
   - Press `p` key again

### Method 2: Standalone Script

```python
from blheli_passthrough import BLHeliPassthrough, create_symlink
from tang9k_tui import SPIMaster

# Create SPI master
spi = SPIMaster(bus=0, device=0)

# Create passthrough instance
blheli = BLHeliPassthrough(spi)

# Start PTY
pty_name = blheli.start()
symlink = create_symlink(pty_name)

print(f"Connect BLHeli tool to: {symlink}")

# Enable passthrough
blheli.enable_passthrough()

# ... use BLHeli tools ...

# Disable when done
blheli.disable_passthrough()
blheli.close()
spi.close()
```

## BLHeli Tool Configuration

### BLHeliSuite
1. Launch BLHeliSuite
2. Go to **Select ATMEL/SILABS** tab
3. Under "COM Port", select `/tmp/blheli_passthrough`
4. Click **Connect**
5. Click **Read Setup** to read ESC configuration
6. Make changes as needed
7. Click **Flash All** or **Flash** individual ESCs
8. Click **Disconnect** when done

### BLHeliConfigurator
1. Launch BLHeliConfigurator
2. Select `/tmp/blheli_passthrough` from the port dropdown
3. Click **Connect**
4. Click **Read Setup**
5. Configure ESC settings
6. Click **Write Setup** to apply changes
7. Click **Disconnect** when done

## Troubleshooting

### PTY Not Found
- Ensure Python TUI is running with passthrough enabled
- Check that `/tmp/blheli_passthrough` symlink exists
- Try using the full PTY path (e.g., `/dev/pts/3`)

### Communication Errors
- Verify SPI connections between host and Tang9K
- Check that mux is set to Serial mode (0x0400 = 0)
- Ensure ESC signal wire is connected properly
- Verify 115200 baud rate in both systems

### ESC Not Responding
- Check ESC power supply
- Verify signal wire connection
- Try resetting the ESC
- Ensure ESC has BLHeli firmware installed

### Python Errors
```bash
# If spidev not available
pip install spidev

# If textual not available
pip install textual

# If permission denied on SPI
sudo chmod 666 /dev/spidev0.0
```

## Technical Details

### Serial Configuration
- **Baud Rate**: 115200
- **Data Bits**: 8
- **Parity**: None
- **Stop Bits**: 1
- **Flow Control**: None
- **Mode**: Half-duplex

### Timing
- Bit period: 625 clock cycles at 72 MHz (~8.68 µs)
- FIFO depth: 16 bytes RX, 16 bytes TX
- Interrupt on RX ready, TX empty

### Wishbone Registers
| Offset | Register        | Access | Description                    |
|--------|----------------|--------|--------------------------------|
| 0x00   | DATA           | R/W    | TX/RX data FIFO                |
| 0x04   | IER            | R/W    | Interrupt enable               |
| 0x08   | IIR            | R      | Interrupt ID                   |
| 0x0C   | LSR            | R      | Line status (RX ready, TX empty)|

## Safety Notes

⚠️ **IMPORTANT**:
- **Remove propellers** before configuring ESCs
- **Disconnect battery** or ensure motors cannot spin
- **Passthrough mode disables DSHOT**: Motors will not respond to flight controller during configuration
- **Always disable passthrough** after ESC configuration to restore normal operation

## Advanced Usage

### Custom PTY Location
Modify the symlink path in the code:
```python
symlink = create_symlink(pty_name, "/dev/myblheli")
```

### Multiple ESCs
The passthrough works with one ESC at a time through the shared serial line. To configure multiple ESCs:
1. Configure ESC on output 1
2. Disconnect
3. Switch physical connection to next ESC
4. Reconnect and configure

### Logging
The Python bridge logs all TX/RX data. Check the TUI serial console for debug information.

## References
- BLHeliSuite: https://github.com/bitdump/BLHeliSuite
- BLHeli Configurator: https://github.com/blheli-configurator/blheli-configurator
- BLHeli Protocol Documentation: https://github.com/bitdump/BLHeli

---
For more information, see `SYSTEM_OVERVIEW.md` and `python/test/README.md`.
