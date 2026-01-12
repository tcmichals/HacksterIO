# AXIS ↔ Wishbone Master Bridge

Production-ready SystemVerilog implementation of an AXI Stream to Wishbone B4 master bridge with SPI and Serial protocol adapters.

## Overview

This project provides:
- **Main Bridge** (`wishbone_master_axis.sv`) - AXIS ↔ Wishbone master protocol converter
- **SPI Adapter** (`spi_axis_bridge.sv`) - SPI slave to AXIS master
- **Serial Adapter** (`serial_axis_bridge.sv`) - UART RX to AXIS master
- **Error Handling** - Timeout detection and error response codes
- **Python Test Scripts** - Command-line testing for both protocols
- **Comprehensive Documentation** - Timing diagrams, examples, integration guides

## Quick Start

### 1. Run Tests

```bash
# SPI protocol tests
python3 tests/spi_test.py --run-all

# Serial protocol tests  
python3 tests/serial_test.py --run-all

# Or individual tests
python3 tests/spi_test.py --command write --address 0x1000 --data 0xDEADBEEF
python3 tests/serial_test.py --command read --address 0x2000
```

### 2. Build and Simulate

```bash
# Build SPI bridge
iverilog -g2009 -o tb/spi_sim.vvp spi_axis_bridge.sv tb/tb_spi_axis_bridge.sv
vvp tb/spi_sim.vvp

# Build Serial bridge
iverilog -g2009 -o tb/serial_sim.vvp serial_axis_bridge.sv tb/tb_serial_axis_bridge.sv
vvp tb/serial_sim.vvp
```

## Directory Structure

```
busMaster/
├── README.md                       # This file
├── Makefile                        # Build automation
├── Core RTL files
├── spi_axis_bridge.sv              # SPI slave to AXIS master
├── serial_axis_bridge.sv           # UART RX to AXIS master
├── wishbone_master_axis.sv         # Main AXIS ↔ Wishbone bridge
├── tb/                             # Testbenches (sv files)
├── tests/                          # Python test scripts
└── docs/                           # Documentation (markdown)
```

## Documentation

📖 **Start Here**: [BRIDGES_SUMMARY.md](docs/BRIDGES_SUMMARY.md) (5-min quick reference)

📖 **Full Guide**: [BRIDGES_GUIDE.md](docs/BRIDGES_GUIDE.md) (comprehensive specification)

📖 **Protocol**: [AXIS_PROTOCOL.md](docs/AXIS_PROTOCOL.md) (AXI Stream details)

📖 **Error Handling**: [error_handling_timeout.md](docs/error_handling_timeout.md)

📖 **Transactions**: [TRANSACTION_WALKTHROUGH.md](docs/TRANSACTION_WALKTHROUGH.md)

See [docs/DOCUMENTATION_INDEX.md](docs/DOCUMENTATION_INDEX.md) for complete documentation map.

## Features

✅ Main bridge with Wishbone B4 master interface  
✅ SPI protocol adapter (full-duplex, CDC safe)  
✅ Serial protocol adapter (UART, configurable baud)  
✅ Error handling with timeout protection  
✅ Comprehensive testbenches (11 test scenarios)  
✅ Command-line Python testing utilities  
✅ Production-ready code with full documentation

## Command-Line Testing

```bash
# SPI tests
python3 tests/spi_test.py --run-all
python3 tests/spi_test.py --command write --address 0x1000 --data 0xDEADBEEF

# Serial tests
python3 tests/serial_test.py --run-all
python3 tests/serial_test.py --command read --address 0x2000 --baud 230400
```

## Compilation

```bash
# Make targets
make all          # Compile all testbenches
make sim          # Run simulations
make clean        # Clean build artifacts

# Manual compilation
iverilog -g2009 -o tb/spi_sim.vvp spi_axis_bridge.sv tb/tb_spi_axis_bridge.sv
vvp tb/spi_sim.vvp
```

## Key Features

| Aspect | SPI Bridge | Serial Bridge |
|--------|-----------|---------------|
| **Interface** | Full-duplex SPI | UART RX |
| **Speed** | 10-20 MHz | 115200 baud |
| **Frame End** | CS falling edge | 0xFF break byte |
| **CDC** | Gray-code FIFO | Dual-stage sync |

## Status

✅ Production Ready  
✅ All testbenches passing  
✅ CDC safety verified  
✅ Comprehensive documentation  

**For full documentation, see [docs/](docs/) directory.**

---

**Repository**: `tcmichals/busMaster` on GitHub  
**Last Updated**: January 11, 2026
