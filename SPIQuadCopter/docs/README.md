# Tang9K FPGA Quadcopter Project

FPGA-based quadcopter flight controller using the Tang9K development board.

## Features
- **SPI-to-Wishbone Bridge**: All peripherals accessible via SPI interface
- **16650 UART**: Half-duplex serial with FIFO and interrupts (115200 baud)
- **DSHOT Motor Control**: 4-channel DSHOT150 ESC interface
- **PWM Decoder**: 6-channel PWM input from RC receiver
- **NeoPixel Controller**: WS2812 LED string with waterfall effects
- **Serial/DSHOT Mux**: Switchable motor pins for DSHOT or **ESC configuration** (channel-selectable)
- **BLHeli Passthrough**: Configure ESCs via **any motor pin** using BLHeliSuite/BLHeliConfigurator
- **Python TUI**: Full-featured terminal interface for control and monitoring
- **tcpSPIBridge**: TCP-to-SPI bridge for Raspberry Pi (headless operation)

## Quick Start
1. **Initialize submodules**: `git submodule update --init --recursive`
2. See `docs/START_HERE.txt` for initial setup
3. **Install toolchain**: `make install-tools` (or `make install-tools-local`)
4. **Build**: `make build`
5. **Program**: `make upload`
6. See `docs/BUILD_AND_PROGRAM.md` for detailed instructions

## Documentation

### Getting Started
- **[START_HERE.txt](docs/START_HERE.txt)** - Initial setup guide
- **[QUICK_START.md](docs/QUICK_START.md)** - Quick reference guide
- **[BUILD_AND_PROGRAM.md](docs/BUILD_AND_PROGRAM.md)** - Toolchain installation and build instructions

### Diagrams

- `docs/system_block_diagram.md` — Mermaid diagram (preview in VS Code with Mermaid or on GitHub when supported)
- `docs/system_block_diagram.puml` — PlantUML source (render with PlantUML to PNG/SVG)

Render commands (examples):

With PlantUML (Java):
```
java -jar plantuml.jar -tpng docs/system_block_diagram.puml -o docs/
```

With Mermaid CLI (install `@mermaid-js/mermaid-cli`):
```
mmdc -i docs/system_block_diagram.md -o docs/system_block_diagram.png
```

### Hardware & Pins
- **[HARDWARE_PINS.md](docs/HARDWARE_PINS.md)** - Complete pin assignments and mux details
- **[tang9k.cst](tang9k.cst)** - Pin constraint file

### System Architecture
- **[SYSTEM_OVERVIEW.md](docs/SYSTEM_OVERVIEW.md)** - Complete architecture and Wishbone address map
- **[WISHBONE_BUS.md](docs/WISHBONE_BUS.md)** - Wishbone integration details
- **[72MHZ_PLL.md](docs/72MHZ_PLL.md)** - PLL configuration

### BLHeli & ESC Configuration
- **[BLHELI_PASSTHROUGH.md](docs/BLHELI_PASSTHROUGH.md)** - ESC configuration guide (motor pin routing)
- **[BLHELI_QUICKSTART.md](docs/BLHELI_QUICKSTART.md)** - Quick BLHeli setup
- **[python/tuiTest/USB_SERIAL_BRIDGE.md](python/tuiTest/USB_SERIAL_BRIDGE.md)** - Hardware serial bridge (recommended)
- **[python/tuiTest/ESC_CONFIGURATOR_WEBAPP.md](python/tuiTest/ESC_CONFIGURATOR_WEBAPP.md)** - Web-based configurator

### Software & Python Tools
- **[python/tuiTest/README.md](python/tuiTest/README.md)** - Python TUI application guide
- **[python/tcpSPIBridge/tcpSPIBridge.py](python/tcpSPIBridge/tcpSPIBridge.py)** - TCP-to-SPI bridge for Raspberry Pi

### Development
- **[PROJECT_SUMMARY.md](docs/PROJECT_SUMMARY.md)** - Project overview
- **[src/TESTBENCH_README.md](src/TESTBENCH_README.md)** - Testbench documentation

## Python TUI Application
Located in `python/test/`:
```bash
cd python/test
pip install -r requirements.txt

python tang9k_tui.py
```

Features:
- Serial console for debug/communication
- LED counter control
- NeoPixel waterfall animation
- PWM channel monitoring
- BLHeli ESC configuration mode
  - Works with BLHeliSuite/BLHeliConfigurator desktop apps
  - Creates `/dev/ttyBLH0` device (requires sudo for device creation)
  - ⚠️ **Note:** Web-based ESC Configurator cannot detect PTY devices - use desktop tools

## Project Structure

```
SPIQuadCopter/
├── tang9k.cst                  # Pin constraint file for Tang9K
├── Makefile                    # Build automation (make build, make upload)
├── SYSTEM_OVERVIEW.md          # Complete system documentation
├── BLHELI_PASSTHROUGH.md       # ESC configuration guide
├── BUILD_AND_PROGRAM.md        # Toolchain + build instructions
├── HARDWARE_PINS.md            # Pin assignments and mux details
├── spiSlave/                   # SPI Slave module (Mode 0)
│   ├── spi_slave.sv
│   ├── spi_slave_tb.sv
│   └── Makefile
├── ttlSerial/                  # TTL serial UART (16650-style)
│   ├── ttl_serial.sv
│   ├── ttl_serial_tb.sv
│   └── Makefile
├── dshot/                      # DSHOT motor controller
│   ├── dshot_output.v
│   └── Makefile
├── pwmDecoder/                 # PWM input decoder (6 channels)
│   ├── pwmdecoder.v
│   ├── pwmdecoder_wb.v
│   └── Makefile
├── neoPXStrip/                 # NeoPixel WS2812 driver
│   ├── wb_neoPx.v
│   ├── sendPx.v
│   ├── neopixels.v
│   └── Makefile
├── src/                        # Top-level and Wishbone peripherals
│   ├── tang9k_top.sv           # Top-level integration
│   ├── spi_axis_adapter.sv     # SPI to AXI Stream bridge
│   ├── wb_led_controller.sv    # LED controller
│   ├── wb_dshot_controller.sv  # DSHOT Wishbone wrapper
│   ├── wb_serial_dshot_mux.sv  # Mux register
│   └── pll.sv                  # 72 MHz PLL
├── python/test/                # Python TUI application
│   ├── tang9k_tui.py           # Main TUI app
│   ├── blheli_passthrough.py   # BLHeli passthrough bridge
│   ├── requirements.txt        # Python dependencies
│   └── README.md               # Application guide
└── verilog-wishbone/           # Wishbone library (axis_wb_master)
    └── rtl/
        └── axis_wb_master.v
```

## Hardware Requirements
- Tang9K FPGA board (GW1N-9K)
- 27 MHz oscillator (on-board)
- SPI master (e.g., Raspberry Pi) for host communication
- ESCs with BLHeli firmware (optional, for passthrough)
- RC receiver with PWM outputs (optional)
- WS2812 NeoPixel strip (optional)

## Features Detail

### SPI Slave Mode 0
- CPOL=0, CPHA=0
- 2-FF clock domain synchronization
- 8-bit data width
- Command-based interface

- **SPI Slave Mode 0** (CPOL=0, CPHA=0)
- **2-FF Clock Domain Synchronization** for metastability protection
- **8-bit data width** (configurable)
- **Command-based register file** interface
- Pin assignments for Tang9K (GW1N-9K FPGA)

## Pin Assignments (tang9k.cst)

| Signal | FPGA Pin | Bank | Function |
|--------|----------|------|----------|
| i_sys_clk | 52 | BANK3 | System clock (27 MHz) |
| i_rst_n | 3 | BANK1 | Active-low reset |
| i_spi_clk | 4 | BANK1 | SPI clock input |
| i_spi_cs_n | 5 | BANK1 | SPI chip select (active low) |
| i_spi_mosi | 6 | BANK1 | Master Out Slave In |
| o_spi_miso | 7 | BANK1 | Master In Slave Out |
| o_led[3:0] | 8-11 | BANK1 | LED outputs |
| i_btn[1:0] | 15-16 | BANK1 | Button inputs |
| i/o_uart_rx/tx | 17-18 | BANK1 | UART interface |
| i/o_gpio[7:0] | 19-26 | BANK1 | General purpose I/O |

## Build System

### Install OSS CAD Suite Toolchain
```bash
# Option 1: System package manager
make install-tools

# Option 2: Local install to ~/.tools
make install-tools-local
export PATH="$HOME/.tools/oss-cad-suite/bin:$PATH"
```

### Build the Project
```bash
make build    # Synthesis + Place & Route + Pack
```

### Program the FPGA
```bash
make upload   # Uses openFPGALoader
```

### Testing
```bash
make tb-design        # Run design testbench
make tb-passthrough   # Run UART passthrough testbench
make test-tb          # Run all testbenches
```

See `docs/BUILD_AND_PROGRAM.md` for detailed instructions.

## Testing with iverilog

### Run Testbench
```bash
cd spiSlave
make simulate
```

### View Waveforms with GTKWave
```bash
cd spiSlave
make wave
```

Or view existing waveform:
```bash
cd spiSlave
make view
```

### Clean simulation files
```bash
cd spiSlave
make clean
```

## SPI Interface Protocol

### SPI Timing (Mode 0)
- **CPOL=0**: Clock is low when idle
- **CPHA=0**: Data sampled on rising edge, changed on falling edge
- Data transmitted MSB first

### Register Map (via SPI Commands)

Command format: `CCCCXXXX` where `CCCC` = command, `XXXX` = data

| Command | Name | Function |
|---------|------|----------|
| 0x0X | CTRL_WR | Write control register |
| 0x1X | CTRL_RD | Read control register |
| 0x2X | STATUS_RD | Read status register |
| 0x3X | DATA_WR | Write data register |
| 0x4X | DATA_RD | Read data register |

## Module Interface

### spi_slave.sv Ports

```verilog
module spi_slave #(parameter DATA_WIDTH = 8) (
    // System
    input  logic i_clk,
    input  logic i_rst_n,
    
    // SPI Interface
    input  logic i_sclk,
    input  logic i_cs_n,
    input  logic i_mosi,
    output logic o_miso,
    
    // User Interface
    output logic [DATA_WIDTH-1:0] o_rx_data,
    output logic o_rx_valid,
    input  logic [DATA_WIDTH-1:0] i_tx_data,
    input  logic i_tx_valid,
    output logic o_busy
);
```

## Synchronization

The module uses **2-FF synchronizers** for all async inputs (sclk, cs_n, mosi) to safely cross clock domains and prevent metastability:

```
SPI Domain → FF1 → FF2 → System Clock Domain
```

This adds a 2-cycle latency but ensures reliable operation.

## Simulation Results

The testbench verifies:
1. Basic 8-bit SPI transfer
2. Multiple consecutive transfers
3. All zeros and all ones patterns
4. Clock synchronization and edge detection
5. Chip select timing

Sample output from simulation:
```
Test 1: Simple SPI Transfer
Master sends: 0xA5 (10100101)
Slave sends: 0x5A (01011010)

Test 2: Multiple Transfers
Transfer 1: Master sends 0x12, Slave sends 0x34
Transfer 2: Master sends 0xAB, Slave sends 0xCD

Test 3: Send All Zeros
Test 4: Send All Ones

All tests completed!
```

## Notes

- System clock: 27 MHz (Tang9K on-board oscillator)
- SPI clock in testbench: 25 MHz (slower than system clock for safer operation)
- All I/O is 3.3V LVCMOS
- Chip select is active low (standard SPI)

## Files Description

| File | Purpose |
|------|---------|
| `spi_slave.sv` | Core SPI slave implementation |
| `spi_slave_tb.sv` | Comprehensive testbench |
| `tang9k_top.sv` | Example top-level integration |
| `apio.ini` | Apio project settings |
| `tang9k.cst` | Pin constraints for synthesis |
| `Makefile` | Build targets (in spiSlave/) |

## Future Enhancements

- [ ] Add SPI Mode 1, 2, 3 support
- [ ] Implement FIFO for buffering
- [ ] Add interrupt signals
- [ ] Support configurable data width (16/32-bit)
- [ ] Add CRC/checksum functionality
- [ ] UART debug interface

