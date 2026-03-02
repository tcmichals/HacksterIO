# Tang9K SPI Quadcopter FPGA Project

A complete FPGA-based quadcopter flight controller implementation for the Tang Nano 9K, featuring SPI control interface, PWM decoding, DSHOT motor control, BLHeli ESC configuration, and NeoPixel LED support.

## 📚 Documentation

**See the [docs/](docs/) directory for complete documentation.**

Quick links:
- **[Documentation Index](docs/README.md)** - Complete documentation listing
- **[Quick Start Guide](docs/QUICK_START.md)** - Get started quickly
- **[TangNano 9K Pinout](docs/PINOUT.md)** - Clear motor, PWM, and NeoPixel pin mapping
- **[BLHeli Passthrough](docs/BLHELI_PASSTHROUGH.md)** - ESC configuration guide

# 🚀 Quick Start

```bash
# 1. Build the FPGA bitstream
make build

# 2. Program the FPGA
make upload

# 3. Run the Python TUI
cd python/tuiExample
python tui_app.py
```

## 🎯 Features

- ✅ **SERV RISC-V CPU** - Bit-serial 32-bit core (~2.25 MIPS at 72 MHz)
- ✅ **SPI Slave Interface** - Control via SPI from external host
- ✅ **Wishbone Bus** - Standard peripheral integration
- ✅ **6-Channel PWM Decoder** - RC receiver input
- ✅ **4-Channel DSHOT Output** - ESC motor control
- ✅ **USB UART** - 115200 baud for MSP protocol via SERV CPU
- ✅ **ESC UART** - Half-duplex 19200 baud for BLHeli ESC configuration
- ✅ **NeoPixel Controller** - WS2812 LED support
- ✅ **72 MHz System Clock** - PLL-based clock generation

## 🏗️ Project Structure

```
SPIQuadCopter/
├── docs/                    # 📚 Complete documentation
├── src/                     # RTL source files
│   ├── tang9k_top.sv       # Top-level module
│   └── tb/                 # Testbenches
├── serv/                    # SERV RISC-V CPU core + firmware
├── python/                  # Python control software
│   └── tuiExample/          # Main terminal UI application
├── dshot/                   # DSHOT motor controller
├── pwmDecoder/             # PWM decoder
├── neoPXStrip/             # NeoPixel controller
├── verilog-uart/           # UART cores
├── verilog-wishbone/       # Wishbone components
└── Makefile                # Build system
```

## 🔧 Hardware

- **FPGA:** Tang Nano 9K (Gowin GW1NR-9)
- **Clock:** 72 MHz (PLL from 27 MHz crystal)
- **Interface:** SPI slave, 6x PWM in, 4x DSHOT out
- **Extras:** USB UART, NeoPixel, 5x LEDs

## 💻 Software

- **Toolchain:** OSS CAD Suite (Yosys, nextpnr, openFPGALoader)
- **Python:** 3.7+ with `spidev`
- **TUI Documentation:** [Python TUI README](python/tuiExample/README.md)

## 📖 Key Documentation

| Topic | Document |
|-------|----------|
| Getting Started | [Quick Start](docs/QUICK_START.md) |
| System Design | [System Overview](docs/SYSTEM_OVERVIEW.md) |
| SPI Protocol | [SPI Slave WB Bridge Design](docs/SPI_SLAVE_WB_BRIDGE_DESIGN.md) |
| Hardware Setup | [Detailed Pinout](docs/PINOUT.md) |
| ESC Config | [BLHeli Passthrough](docs/BLHELI_PASSTHROUGH.md) |
| SERV Firmware | [SERV MSP Bridge](serv/firmware/README.md) |
| Python TUI | [TUI Module](python/tuiExample/README.md) |

## 🧪 Testing

```bash
# SPI Wishbone testbenches
make tb-spi-wb           # SPI-WB Master protocol (read/write/burst)
make tb-spi-pwm          # SPI→PWM integration test
make tb-spi-all          # Run all SPI testbenches
```

## 📝 License

See individual component directories for licensing information.

---

**Status:** ✅ Active Development | **FPGA:** Tang Nano 9K | **Clock:** 72 MHz | **Bus:** Wishbone B4

For complete documentation, see **[docs/README.md](docs/README.md)**
