# HacksterIO Projects

A collection of FPGA projects for the Tang Nano 9K development board, featuring various serial communication interfaces and peripheral controllers. All projects are designed to demonstrate different communication protocols and hardware control techniques on the GW1N-9K FPGA.

## 📋 Table of Contents
- [Projects Overview](#projects-overview)
- [Quick Start](#quick-start)
- [Project Details](#project-details)
- [Hardware Requirements](#hardware-requirements)
- [Related Resources](#related-resources)
- [License](#license)

## 🎯 Projects Overview

This repository contains four main projects, with detailed tutorials available on [Hackster.io](https://www.hackster.io/MichalsTC):

> [!TIP]
> **Featured Article Series**: [TangNano 9K Controlling Multiple LED Targets](https://www.hackster.io/MichalsTC/tangnano-9k-controlling-multiple-led-targets-part-1-of-3-2313f9) - A comprehensive 3-part series covering the SerialLED and SerialWishbone projects.

### 1. **SerialLED**
Control LEDs on the Tang Nano 9K using UART serial communication.
- Simple serial command interface
- LED pattern control via serial port
- Demonstrates basic UART implementation with [verilog-uart](https://github.com/alexforencich/verilog-uart)
- **[View Project →](./SerialLED)**
- **📝 Hackster.io Articles:**
  - [Using Serial to Control LEDs on Tang Nano 9K](https://www.hackster.io/MichalsTC/using-serial-to-control-the-leds-on-a-tang-nano-9k-fpga-fb632c) - Basic serial LED control
  - [Part 1: Wishbone Bus Introduction](https://www.hackster.io/MichalsTC/tangnano-9k-controlling-multiple-led-targets-part-1-of-3-2313f9) - Multi-target LED control series

### 2. **SerialWishbone**
Full-featured Wishbone bus interface controlled via serial port.
- Wishbone bus master/slave architecture
- Serial-to-Wishbone bridge implementation
- Peripheral control via standardized bus protocol
- Uses [verilog-uart](https://github.com/alexforencich/verilog-uart) and [verilog-wishbone](https://github.com/alexforencich/verilog-wishbone)
- **[View Project →](./SerialWishbone)**
- **📝 Hackster.io Articles:**
  - [Part 1: Wishbone Bus Introduction](https://www.hackster.io/MichalsTC/tangnano-9k-controlling-multiple-led-targets-part-1-of-3-2313f9)
  - [Part 2: NeoPixel Control](https://www.hackster.io/MichalsTC/tangnano-9k-controlling-multiple-led-targets-part-2-of-3-6d2252)
  - [Part 3: Blinkt! LED Board](https://www.hackster.io/MichalsTC/tangnano-9k-controlling-multiple-led-targets-part-3-of-3-3db342)

### 3. **SerialPIO**
Programmable I/O (PIO) state machines controlled via serial interface.
- Raspberry Pi Pico-style PIO implementation for FPGA
- Flexible GPIO control with state machines
- Based on [fpga_pio](https://github.com/lawrie/fpga_pio) by Lawrie Griffiths
- **[View Project →](./SerialPIO)**

### 4. **SPIQuadCopter**
Advanced FPGA-based quadcopter flight controller with SPI interface.
- Complete flight controller implementation
- DSHOT ESC control
- PWM input decoding (RC receiver)
- NeoPixel LED control
- BLHeli passthrough for ESC configuration
- Python TUI for monitoring and control
- TCP-to-SPI bridge for Raspberry Pi integration
- **[View Project →](./SPIQuadCopter)** | **[Detailed README](./SPIQuadCopter/README.md)**

## 🚀 Quick Start

### Prerequisites
- **Hardware**: Tang Nano 9K FPGA development board (GW1N-9K)
- **Tools**: OSS CAD Suite (Yosys, nextpnr, openFPGALoader)
- **Optional**: USB-to-Serial adapter, Raspberry Pi (for SPI projects)

### Initial Setup

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd HacksterIO
   ```

2. **Initialize submodules** (required for all projects):
   ```bash
   git submodule update --init --recursive
   ```

3. **Install build tools** (for SPIQuadCopter):
   ```bash
   cd SPIQuadCopter
   make install-tools
   # OR for local installation:
   make install-tools-local
   export PATH="$HOME/.tools/oss-cad-suite/bin:$PATH"
   ```

4. **Navigate to a specific project and follow its README:**
   ```bash
   cd SerialLED     # or SerialWishbone, SerialPIO, SPIQuadCopter
   # See project-specific README for build instructions
   ```

## 📖 Project Details

### SerialLED
A beginner-friendly project demonstrating UART communication and LED control.

**Key Files:**
- `src/` - Verilog source files
- `tangnano9k.cst` - Pin constraints
- `serialProject.lushay.json` - Project configuration

**Features:**
- 115200 baud UART communication
- Simple command protocol
- LED patterns and control

---

### SerialWishbone
Intermediate project showcasing industry-standard Wishbone bus architecture.

**Key Files:**
- `src/` - Top-level modules
- `verilog-uart/` - UART submodule
- `verilog-wishbone/` - Wishbone bus submodule
- `tangnano9k.cst` - Pin constraints

**Features:**
- Wishbone B4 compliant bus
- Multiple peripheral support
- Modular architecture with NeoPixel LED control
- Python test utilities (`blinkt.py`, `neo.py`, `ledTester.py`, etc.)

**Peripherals:**
- NeoPixel (WS2812) LED strip controller
- Blinkt LED bar support
- Extensible peripheral framework

---

### SerialPIO
Advanced project bringing Raspberry Pi Pico's PIO concept to FPGA.

**Key Files:**
- `fpga_pio/` - PIO implementation submodule

**Features:**
- Programmable state machines
- Flexible I/O control
- Compatible with PIO assembly language concepts

---

### SPIQuadCopter
Professional-grade flight controller with extensive features.

**Key Files:**
- `src/tang9k_top.sv` - Top-level integration
- `python/tuiTest/` - Python control interface
- `python/tcpSPIBridge/` - Raspberry Pi TCP bridge
- See **[Full Documentation](./SPIQuadCopter/README.md)**

**Features:**
- SPI-to-Wishbone bridge
- DSHOT150 motor control (4 channels)
- PWM decoder (6 channels) for RC input
- NeoPixel status LEDs with effects
- BLHeli passthrough (ESC configuration)
- 72 MHz PLL clock generation
- Comprehensive Python TUI application

**Documentation:**
- [Build Instructions](./SPIQuadCopter/BUILD_AND_PROGRAM.md)
- [Hardware Pins](./SPIQuadCopter/HARDWARE_PINS.md)
- [System Overview](./SPIQuadCopter/SYSTEM_OVERVIEW.md)
- [BLHeli Setup](./SPIQuadCopter/BLHELI_PASSTHROUGH.md)

## 🔧 Hardware Requirements

### Common to All Projects
- **FPGA Board**: Tang Nano 9K (Sipeed)
  - FPGA: Gowin GW1N-9K
  - On-board 27 MHz oscillator
  - USB Type-C for programming
  - 6 user LEDs, 2 buttons
  
### Project-Specific Hardware

| Project | Additional Hardware |
|---------|-------------------|
| **SerialLED** | USB-to-Serial adapter (3.3V) |
| **SerialWishbone** | USB-to-Serial adapter, WS2812 LED strip (optional) |
| **SerialPIO** | USB-to-Serial adapter |
| **SPIQuadCopter** | Raspberry Pi (SPI host), ESCs, RC receiver, motors, WS2812 LEDs |

## 📚 Related Resources

### Hackster.io Articles by Tim Michals
- [Using Serial to Control LEDs on Tang Nano 9K](https://www.hackster.io/MichalsTC/using-serial-to-control-the-leds-on-a-tang-nano-9k-fpga-fb632c) - Introduction to serial LED control
- [TangNano 9K Controlling Multiple LED Targets - Part 1](https://www.hackster.io/MichalsTC/tangnano-9k-controlling-multiple-led-targets-part-1-of-3-2313f9) - Wishbone bus basics and serial control
- [TangNano 9K Controlling Multiple LED Targets - Part 2](https://www.hackster.io/MichalsTC/tangnano-9k-controlling-multiple-led-targets-part-2-of-3-6d2252) - NeoPixel LED implementation
- [TangNano 9K Controlling Multiple LED Targets - Part 3](https://www.hackster.io/MichalsTC/tangnano-9k-controlling-multiple-led-targets-part-3-of-3-3db342) - Blinkt! board control
- [View All Projects](https://www.hackster.io/MichalsTC) - Tim Michals' Hackster.io profile

### FPGA Development Tools
- [OSS CAD Suite](https://github.com/YosysHQ/oss-cad-suite-build) - Open-source FPGA toolchain
- [openFPGALoader](https://github.com/trabucayre/openFPGALoader) - Universal FPGA programmer
- [GTKWave](https://github.com/gtkwave/gtkwave) - Waveform viewer

### Tang Nano 9K Resources
- [Sipeed Tang Nano 9K Wiki](https://wiki.sipeed.com/hardware/en/tang/Tang-Nano-9K/Nano-9K.html)
- [Gowin FPGA Documentation](http://www.gowinsemi.com/en/support/home/)

### Verilog/SystemVerilog Libraries (Submodules)
- [verilog-uart](https://github.com/alexforencich/verilog-uart) by Alex Forencich - High-quality UART implementation
- [verilog-wishbone](https://github.com/alexforencich/verilog-wishbone) by Alex Forencich - Wishbone bus components
- [fpga_pio](https://github.com/lawrie/fpga_pio) by Lawrie Griffiths - PIO state machines for FPGA

### Communication Protocols
- [Wishbone B4 Specification](https://opencores.org/howto/wishbone) - Open-source bus standard
- [DSHOT Protocol](https://github.com/betaflight/betaflight/wiki/DSHOT-ESC-Protocol) - Digital ESC protocol
- [WS2812 Protocol](https://cdn-shop.adafruit.com/datasheets/WS2812.pdf) - NeoPixel LED timing

### Flight Controller Resources (SPIQuadCopter)
- [BLHeliSuite](https://github.com/bitdump/BLHeliSuite) - ESC configuration tool
- [Betaflight](https://betaflight.com/) - Popular flight controller firmware (for reference)

## 📄 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](./LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Each project has its own structure and requirements. Please:
1. Check the project-specific README
2. Follow existing code style
3. Test on real hardware when possible
4. Submit pull requests with clear descriptions

## 📧 Contact

For questions, issues, or project ideas, please open an issue on the repository.

---

**Note:** All projects use Git submodules. Always run `git submodule update --init --recursive` after cloning or when switching branches.
