# Tang9K FPGA Quadcopter System Overview

## Architecture
- All peripherals are accessible via SPI slave interface, bridged to a Wishbone bus using axis_wb_master.
- Top-level module (`tang9k_top.sv`) integrates:
  - SPI slave
  - SPI-to-AXI Stream adapter
  - axis_wb_master (AXI Stream to Wishbone bridge)
  - Wishbone peripherals: LED, Serial, PWM, DSHOT, NeoPixel
  - Serial/DSHOT mux for shared output line

## Wishbone Address Map
| Address Range   | Peripheral         | Description                           |
|----------------|--------------------|------------------------------------|
| 0x0000-0x00FF  | LED Controller     | 4 output LEDs, counter display     |
| 0x0200-0x02FF  | PWM Decoder        | 6-channel PWM input decoder        |
| 0x0300-0x03FF  | DSHOT Controller   | 4-channel DSHOT150 motor outputs   |
| 0x0400         | Serial/DSHOT Mux   | Motor pin mode + channel select    |
|                |                    | Bit 0: mux_sel (0=Passthrough, 1=DSHOT) |
|                |                    | Bit 2:1: mux_ch (Motor channel 0-3) |
|                |                    | Routes serial to motor pin 32-35   |
| 0x0500-0x05FF  | NeoPixel Controller| WS2812 LED string controller       |

## Peripherals
### LED Controller
- 4 output LEDs, Wishbone-mapped.

### PWM Decoder
- 6 input channels, Wishbone-mapped.

### DSHOT Controller
- 4 motor outputs, Wishbone-mapped.
- DSHOT150 protocol, 16-bit frame.

### Serial/DSHOT Mux (0x0400)
- Register at 0x0400 selects operating mode:
  - **Bit 0 (mux_sel)**: Default Mode (0=Passthrough, 1=DSHOT)  
  - **Bit 2:1 (mux_ch)**: Motor channel (0-3) for manual passthrough
  - **Bit 3 (msp_mode)**: 1=Force MSP Discovery Mode
  
**Automatic Override (Recommended):**
Modern configurators use the **4-Way Interface Protocol**. The FPGA automatically hijacks the USB UART TX line and selects the correct motor pin whenever protocol activity is detected, making manual register writes optional for discovery.

### USB UART Passthrough Bridge
- **Hardware-only bridge** that bypasses Wishbone entirely
- Connects USB UART (pins 19-20) to **selected motor pin** (pins 32-35)
- Enabled when mux_sel=0, disabled when mux_sel=1
- **Module**: `uart_passthrough_bridge.sv`
- **Baud Rate**: 115200 (fixed)
- **Features**:
  - Automatic tri-state control for half-duplex communication
  - Direct byte-level forwarding with minimal latency
  - No software data bridging required
  - No Wishbone bus contention

### NeoPixel Controller
- Wishbone-mapped, outputs pixel data to NeoPixel driver.
- Uses AXI-like handshake to feed pixel data to `sendPx` driver.
- System clock: 72 MHz, fast enough for WS2812 timing.
- `sendPx.v` generates correct WS2812 bitstream (0.4/0.8 μs high, 0.85/0.45 μs low).

## BLHeli ESC Configuration Support
The system supports configuring BLHeli ESCs using BLHeliSuite or BLHeliConfigurator through a **hardware passthrough bridge**:

### Hardware Architecture
```
PC (BLHeli Tool)
    ↓ USB
USB-to-TTL Adapter (CP2102/FT232/CH340)
    ↓ UART (115200 baud)
Tang9K Pins 19-20 (USB UART Interface)
    ↓ Hardware Bridge (uart_passthrough_bridge.sv)
Tang9K Pin 25 (Half-Duplex Serial)
    ↓ Serial (115200 baud)
ESC (BLHeli Firmware)
```

### Passthrough Mode
1. **Zero-Config**: The FPGA continuously monitors the USB UART for MSP discovery packets.
2. **Automatic Hijack**: When a configurator tool (like the ESC Configurator web app) connects, the FPGA automatically switches to the MSP handler (`msp_handler.sv`).
3. **Smart Briding**: The 4-Way Protocol handler (`four_way_handler.sv`) automatically manages command stripping, CRC validation, and 19200 baud communication with the ESC.
4. **Hardware Performance**: Protocol handling and direction switching happen in RTL, ensuring sub-microsecond timing accuracy.

### Pin Configuration
| Function | Pin(s) | Direction | Description |
|----------|--------|-----------|-------------|
| USB UART RX | 19 | Input | Receives data from PC (adapter TX) |
| USB UART TX | 20 | Output | Sends data to PC (adapter RX) |
| **ESC Serial** | **32-35** | **Bidir** | **Half-duplex to ESC (motor pins)** |
|              |        |           | **Select via mux_ch bits 2:1** |

### Usage
```bash
cd python/test
python tang9k_tui.py
# Press 'p' to toggle passthrough mode
# Connect BLHeliSuite to your USB adapter (/dev/ttyUSB0 at 115200 baud)
# Configure ESCs
# Press 'p' again to disable passthrough when done
```

### Key Advantages
- **No software bridging**: Data flows entirely in hardware
- **No virtual devices**: BLHeli connects to real USB serial port
- **No Wishbone contention**: Bridge bypasses bus, only mux control uses Wishbone
- **Low latency**: Direct hardware forwarding with minimal delay
- **Simple and reliable**: Fewer moving parts, easier to debug

## SPI-to-Wishbone Bridge
- SPI slave receives bytes, passes to AXI Stream adapter.
- axis_wb_master parses commands and bridges to Wishbone bus.
- All peripherals are accessible via SPI commands.
- Protocol: IMPLICIT_FRAMING mode for simplified command structure

## Python TUI Application
Located in `python/test/`, provides a full-featured terminal UI for system control:

### Features
- **Serial Console**: Send/receive serial data via SPI/Wishbone
- **LED Counter**: Increment/reset LED display
- **NeoPixel Control**: Animated waterfall effects
- **PWM Monitoring**: Real-time display of all 6 PWM channels
- **BLHeli Passthrough**: Configure ESCs using BLHeliSuite/Configurator

### Installation
```bash
cd python/test
pip install -r requirements.txt
python tang9k_tui.py
```

### Keyboard Shortcuts
- `q`: Quit
- `c`: Clear serial log
- `w`: Toggle NeoPixel waterfall
- `p`: Toggle BLHeli passthrough mode

## Module Documentation
- All major modules have updated comments describing their interface, timing, and integration.
- See each module's header for details.

## Timing Notes
- Serial: 115200 baud, 8-N-1, correct bit timing at 72 MHz (625 clock cycles per bit).
- NeoPixel: WS2812 timing verified, 72 MHz clock is sufficient.
- DSHOT: DSHOT150 protocol, correct timing for 72 MHz clock.

## Use Cases

### Normal Flight Operation
1. Set mux to DSHOT mode (write 1 to 0x0400)
2. Send motor commands via DSHOT registers (0x0300-0x03FF)
3. Monitor PWM inputs from receiver (0x0200-0x02FF)
4. Update NeoPixel status LEDs (0x0500-0x05FF)

### ESC Configuration (BLHeli)
1. Open the **ESC Configurator PWA** (or desktop tool) and click "Connect".
2. The FPGA **automatically** detects the MSP discovery handshake and identifies as "TN9K".
3. The tool communicates via the **4-Way Interface Protocol**, and the FPGA automatically bridges to the ESC signal line (converting 115200 to 19200 baud).
4. Configure ESC parameters, flash firmware, etc.
5. Once complete, the system is ready to return to DSHOT mode for flight.

### Debugging/Development
1. Use serial console for debug output
2. Monitor PWM inputs in real-time
3. Test motor outputs safely via DSHOT
4. Display status on NeoPixel LEDs

## Extensibility
- Add new Wishbone peripherals by assigning new address ranges and connecting to the bus mux in `tang9k_top.sv`.

---
For more details, see individual module files and comments.
