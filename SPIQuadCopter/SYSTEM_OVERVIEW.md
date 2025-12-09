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
| 0x0400         | Serial/DSHOT Mux   | Selects passthrough or DSHOT mode  |
| 0x0500-0x05FF  | NeoPixel Controller| WS2812 LED string controller       |

## Peripherals
### LED Controller
- 4 output LEDs, Wishbone-mapped.

### PWM Decoder
- 6 input channels, Wishbone-mapped.

### DSHOT Controller
- 4 motor outputs, Wishbone-mapped.
- DSHOT150 protocol, 16-bit frame.

### Serial/DSHOT Mux
- Wishbone register at 0x0400 selects between two operating modes:
  - **Write 0**: Passthrough Mode - USB UART bridge to ESC serial (for BLHeli configuration)
  - **Write 1**: DSHOT Mode - DSHOT controller drives motor outputs (for flight)

### USB UART Passthrough Bridge
- **Hardware-only bridge** that bypasses Wishbone entirely
- Connects USB UART (pins 19-20) to half-duplex ESC serial (pin 25)
- Enabled when mux register = 0, disabled when mux register = 1
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
1. **Python TUI** writes to mux register (0x0400) to enable passthrough (value = 0)
2. **Hardware bridge activates** - direct UART-to-serial forwarding in FPGA logic
3. **BLHeli tools** connect to USB-to-TTL adapter's serial port (e.g., `/dev/ttyUSB0`)
4. **Data flows in hardware** - no software intervention, no virtual devices
5. **ESC configuration** happens through pure hardware passthrough at 115200 baud

### Pin Configuration
| Function | Pin | Direction | Description |
|----------|-----|-----------|-------------|
| USB UART RX | 19 | Input | Receives data from PC (adapter TX) |
| USB UART TX | 20 | Output | Sends data to PC (adapter RX) |
| ESC Serial | 25 | Bidir | Half-duplex to ESC |

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
1. Enable passthrough mode in Python TUI
2. Mux automatically switches to Serial mode
3. BLHeliSuite connects to virtual serial port
4. Configure ESC parameters, flash firmware, etc.
5. Disable passthrough mode
6. Mux returns to DSHOT mode for flight

### Debugging/Development
1. Use serial console for debug output
2. Monitor PWM inputs in real-time
3. Test motor outputs safely via DSHOT
4. Display status on NeoPixel LEDs

## Extensibility
- Add new Wishbone peripherals by assigning new address ranges and connecting to the bus mux in `tang9k_top.sv`.

---
For more details, see individual module files and comments.
