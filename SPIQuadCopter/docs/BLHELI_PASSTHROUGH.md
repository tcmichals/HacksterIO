# BLHeli Passthrough Configuration Guide

## Automatic "Zero-Config" Passthrough
The Tang9K implementation features **Automatic Mode Switching**. You no longer need to manually write to SPI registers to enable passthrough for modern tools like the [ESC Configurator PWA](https://esc-configurator.com).

6. **How it works:**
7. **DSHOT Mode (Default)**: Upon power-up, the FPGA is in DSHOT mode, driving the motors normally.
8. **Auto-Discovery**: The hardware bridge internally converts USB traffic (115200) to serial traffic (19200). An internal "Sniffer" in the multiplexer monitors this 19200 stream for MSP headers (`$M<`).
9. **Automatic Hijack**: As soon as a valid MSP packet (like `MSP_IDENT` or `MSP_SET_PASSTHROUGH`) is detected, the FPGA **automatically** switches the motor pins to Passthrough mode and enables the bridge.
10. **Integrated Responder**: The FPGA identifies itself as **"T9K-FC"**, responding to the configurator's identity requests. This allows the software to unlock the ESC configuration menus without any manual register writes.
11. **Safety Watchdog**: If no serial activity is detected for 5 seconds, the system automatically reverts to DSHOT mode.

**Mux Register (0x0400) - Now Optional:**
While still available for manual control or default overrides, the register is no longer strictly required for discovery.
```
Bit 3:   msp_mode (0=Off, 1=Force Enable)
Bit 2:1: mux_ch (0-3 selects motor pin)
Bit 0:   mux_sel (0=Passthrough, 1=DSHOT)
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
3. **Automatic Discovery**: Simply connect the tool; the FPGA detects the MSP protocol and enables the bridge.
4. **Configure ESCs**: The tool will automatically request passthrough on each channel via the 4-Way protocol.

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

## **4-Way Interface Protocol (Automatic)**

Modern configurators (like the [ESC Configurator PWA](https://esc-configurator.com)) do not send raw serial bytes. Instead, they wrap commands in the **Betaflight 4-Way Interface Protocol**. The Tang9K handles this **autonomously in hardware**.

### **Handshake & Discovery**
The tool follows a specific sequence to enable passthrough:
1.  **Initial Contact**: The tool sends MSP commands (e.g., CMD 1, 2) to identify the "Flight Controller".
2.  **Mode Request**: The tool sends `MSP_SET_PASSTHROUGH` (MSP CMD 245).
3.  **FPGA Response**: The FPGA replies with `0x04`, indicating 4 motor channels are ready.
4.  **Protocol Switch**: The tool immediately transitions from MSP to **4-Way Binary Protocol** frames (starting with `0x2F`).

### **Protocol Encapsulation**
Each binary packet sent from the PC uses the following frame:

| Byte | Value | Name | Description |
|------|-------|------|-------------|
| 0 | `0x2F` | Sync | Header for PC -> FC |
| 1 | `CMD` | Command | 4-way command ID (e.g., 0x30 for Alive) |
| 2-3 | `ADDR` | Address | Target address (optional) |
| 4 | `LEN` | Length | Length of parameters |
| 5.. | `DATA` | Params | Command parameters |
| N-1..N | `CRC` | CRC16 | CRC16-XMODEM checksum |

### **FPGA Protocol Handling**
The Tang9K implements a **Smart Protocol Bridge**:
1.  **Detection**: The FPGA monitors for the `0x2F` sync byte.
2.  **Validation**: It buffers the packet and validates the CRC16-XMODEM checksum.
3.  **Stripping**: If valid, the FPGA strips the 4-way envelope and forwards the raw BLHeli command to the ESC at 19200 baud.
4.  **Response**: ESC replies are captured, wrapped in a `0x2E` (FC -> PC) header, and returned to the browser.

This allows the **ESC Configurator** to work seamlessly without needing any custom drivers.

## **Design Philosophy: Hardware-Accelerated Translation**

The Tang9K implementation uses a **Hardware-Accelerated Protocol Bridge** (the `four_way_handler`) rather than a simple transparent serial link. This "Smart Bridge" approach is considered a best practice for several reasons:

### **1. Protocol Stripping vs. Raw Bypass**
Modern configurators send 4-way protocol packets because that's how they handle multi-bridge routing (e.g., "Browser -> FC -> ESC #3"). 
- **The Problem**: If the FPGA were a "Raw Bypass," the ESC would receive the 4-way headers (`0x2F`, etc.). The ESC doesn't understand these and will stay silent.
- **The Solution**: The FPGA acts as a **Smart FC**. It validates the 4-way framing, strips the headers, and forwards only the raw BLHeli commands. This makes the FPGA "look" like a standard Betaflight Flight Controller to the browser.

### **2. Micro-Timing & Direction Switching**
BLHeli_S uses 1-wire half-duplex. 
- In RTL, we can switch the signal direction in **nanoseconds**. 
- Handling this in hardware ensures that the "turnaround" time (switching from TX to RX) is atomic and reliable, which is critical during high-speed operations like firmware flashing.

### **3. Synthesis Optimization: Sequential vs. Combinational**
To maintain a high system clock (72MHz) while keeping build times fast, the handler uses **Sequential CRC Calculation**.
- **The Problem**: Calculating a CRC for a 256-byte packet in one clock cycle requires a massive logic chain (hundreds of gates) which slows down the synthesis tool and can fail timing.
- **The Solution**: We process the checksum one byte per clock cycle. Trading a few clock cycles for a massive reduction in logic depth is the standard "Best Practice" for professional FPGA design.

## Technical Details

### BLHeli Protocol Structure
The BLHeli_S protocol uses a **command-reply** communication pattern:
- **Command packets**: ~32 bytes maximum (PC → ESC)
- **Reply packets**: ~32 bytes maximum (ESC → PC)
- **Transaction-based**: Each command receives a reply before the next command
- **Half-duplex**: Only one device transmits at a time

This simple protocol structure makes the passthrough implementation straightforward, as there's no need for complex flow control or large buffering.

### Serial Configuration

#### USB UART (PC Side)
- **Baud Rate**: 115200 (BLHeli tools standard interface)
- **Data Bits**: 8
- **Parity**: None
- **Stop Bits**: 1
- **Flow Control**: None

#### ESC Serial (ESC Side)
- **Baud Rate**: 19200 (BLHeli_S bootloader requirement)
- **Data Bits**: 8
- **Parity**: None
- **Stop Bits**: 1
- **Flow Control**: None
- **Mode**: Half-duplex (1-wire, bit-banged)

#### Baud Rate Conversion
The FPGA passthrough bridge automatically converts between 115200 baud (USB) and 19200 baud (ESC):
- **Speed ratio**: ~6:1 (115200 / 19200 = 6)
- **FIFO buffering**: 512 bytes (handles baud rate mismatch)
- **Why 512 bytes?**: Maximum burst is ~32 bytes at 6x speed = ~192 bytes buffered. 512 bytes provides ample margin.

### Timing
- **72 MHz System Clock**
- **USB UART**: 1 bit ≈ 625 cycles at 115200 baud (~8.68 µs per bit)
- **ESC Serial**: 1 bit ≈ 3750 cycles at 19200 baud (~52 µs per bit)
- **Echo suppression**: 2000 cycles (~27.8 µs) after TX to prevent loopback
- **Internal FIFO**: 512 bytes (TX direction, handles baud rate conversion)

### FPGA Passthrough Bridge
The UART passthrough bridge (`uart_passthrough_bridge.sv`) implements:
- Automatic baud rate conversion
- Echo suppression for half-duplex operation
- Tri-state control for bidirectional motor pins
- Enable/disable control for mode switching

### Wishbone Registers
| Address | Register        | Bits | Description                    |
|---------|----------------|------|--------------------------------|
| 0x0400  | Mux Control    | [0]  | Mode: 0=Passthrough, 1=DSHOT   |
|         |                | [2:1]| Channel select (0-3 = Motor 1-4)|
|         |                | [3]  | MSP mode: 0=Passthrough, 1=MSP |
|         |                | [31:4]| Reserved (read as 0)          |

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

## Protocol Testbench

A full protocol testbench is available to verify MSP and BLHeli passthrough/ESC handling. See [TESTBENCH_README.md](TESTBENCH_README.md) for usage and coverage.

- Simulates all MSP commands, including edge cases
- Simulates BLHeli passthrough and ESC replies
- Ensures automatic mode switching and watchdog behavior
