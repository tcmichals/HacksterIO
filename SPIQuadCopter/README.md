# Tang9K SPI Quadcopter FPGA Project

A complete FPGA-based quadcopter flight controller implementation for the Tang Nano 9K, featuring SPI control interface, PWM decoding, DSHOT motor control, BLHeli ESC configuration, and NeoPixel LED support.

## 📚 Documentation

**See the [docs/](docs/) directory for complete documentation.**

Quick links:
- **[Documentation Index](docs/README.md)** - Complete documentation listing
- **[Quick Start Guide](docs/QUICK_START.md)** - Get started quickly
- **[System Overview](docs/SYSTEM_OVERVIEW.md)** - Architecture and design
- **[Half-Duplex UART Technical](docs/HALF_DUPLEX_UART_TECHNICAL.md)** - Tri-state UART implementation
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

- ✅ **SPI Slave Interface** - Control via SPI from external host
- ✅ **Wishbone Bus** - Standard peripheral integration
- ✅ **6-Channel PWM Decoder** - RC receiver input
- ✅ **4-Channel DSHOT Output** - ESC motor control
- ✅ **UART Passthrough Bridge** - BLHeli ESC configuration
- ✅ **NeoPixel Controller** - WS2812 LED support
- ✅ **72 MHz System Clock** - PLL-based clock generation

## 🏗️ Project Structure

```
SPIQuadCopter/
├── docs/                    # 📚 Complete documentation
├── src/                     # RTL source files
│   ├── tang9k_top.sv       # Top-level module
│   ├── coredesign.sv       # Core system design
│   └── tb/                 # Testbenches
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
| Hardware Setup | [Hardware Pins](docs/HARDWARE_PINS.md) |
| ESC Config | [BLHeli Passthrough](docs/BLHELI_PASSTHROUGH.md) |
| UART Details | [Half-Duplex UART Technical](docs/HALF_DUPLEX_UART_TECHNICAL.md) |
| Python TUI | [TUI Module](python/tuiExample/README.md) |
| Testing | [Testbench README](src/TESTBENCH_README.md) |

## 🧪 Testing

```bash
make test_version  # Test version register
make test_pwm      # Test PWM decoder
make test_led      # Test LED controller
```

## 📝 License

See individual component directories for licensing information.

---

**Status:** ✅ Active Development | **FPGA:** Tang Nano 9K | **Clock:** 72 MHz | **Bus:** Wishbone B4

For complete documentation, see **[docs/README.md](docs/README.md)**
