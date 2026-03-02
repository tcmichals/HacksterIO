# Tang9K FPGA Project - Documentation Index

## 📚 Documentation Overview

Complete documentation for building, programming, and understanding the Tang9K FPGA quadcopter flight controller.

### Getting Started
- **[QUICK_START.md](QUICK_START.md)** — Quick reference for build and program
- **[BUILD_AND_PROGRAM.md](BUILD_AND_PROGRAM.md)** — Detailed toolchain and build guide
- **[INSTALL_OSS_CAD.md](INSTALL_OSS_CAD.md)** — OSS CAD Suite installation
- **[START_HERE.txt](START_HERE.txt)** — Initial setup guide

### Architecture & Design
- **[SYSTEM_OVERVIEW.md](SYSTEM_OVERVIEW.md)** — Dual-bus architecture, address maps, peripherals
- **[system_block_diagram.md](system_block_diagram.md)** — Mermaid block diagram
- **[SPI_SLAVE_WB_BRIDGE_DESIGN.md](SPI_SLAVE_WB_BRIDGE_DESIGN.md)** — SPI-to-Wishbone protocol
- **[72MHZ_PLL.md](72MHZ_PLL.md)** — PLL configuration
- **[TIMING_OPTIMIZATION.md](TIMING_OPTIMIZATION.md)** — Timing closure notes
- **[IMPLEMENTATION_OPTIONS.md](IMPLEMENTATION_OPTIONS.md)** — Design trade-offs (SV vs SERV vs RP2040)

### Hardware
- **[PINOUT.md](PINOUT.md)** — Motor, PWM, and NeoPixel pin mapping
- **[HARDWARE_PINS.md](HARDWARE_PINS.md)** — Detailed hardware wiring and mux details

### BLHeli & ESC Configuration
- **[BLHELI_PASSTHROUGH.md](BLHELI_PASSTHROUGH.md)** — ESC configuration via SERV CPU
- **[BLHELI_QUICKSTART.md](BLHELI_QUICKSTART.md)** — Quick BLHeli setup

### Reference
- **[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)** — Technical project summary

---

## 🔍 Which Document Should I Read?

| Goal | Read |
|------|------|
| Get started quickly | QUICK_START.md |
| Understand the system architecture | SYSTEM_OVERVIEW.md |
| Understand the SPI protocol | SPI_SLAVE_WB_BRIDGE_DESIGN.md |
| Configure ESCs | BLHELI_PASSTHROUGH.md |
| Check pin assignments | PINOUT.md or HARDWARE_PINS.md |
| Fix a build error | BUILD_AND_PROGRAM.md |
| Understand design trade-offs | IMPLEMENTATION_OPTIONS.md |

---

## 💻 Common Commands

```bash
# Build
make build

# Program
make upload

# Run SPI testbenches
make tb-spi-all
```
