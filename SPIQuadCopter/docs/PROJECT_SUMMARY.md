# Tang Nano 9K Quadcopter FPGA - Project Summary

## Overview
The Tang Nano 9K Quadcopter FPGA project implements a high-performance Flight Controller (FC) bridge on a Gowin GW1N-9C FPGA. It serves as an intermediary between a host (via SPI) and quadcopter peripherals (Motors, RC Receivers, LEDs).

The design is optimized for high system throughput (72MHz) and low resource utilization through the strategic use of Block RAM (BRAM) and sequential processing.

## Project Structure

```
SPIQuadCopter/
├── Makefile                    # Top-level build and simulation management
├── tang9k.cst                  # Pin constraints (LQFP144)
├── tang9k_timing.sdc           # Timing constraints (72MHz targeting)
│
├── src/                        # Core RTL Source
│   ├── tang9k_top.sv           # Top-level I/O and PLL instantiation
│   ├── coredesign.sv           # System integration and Wishbone bus muxing
│   ├── msp_handler.sv          # MSP (MultiWii Serial Protocol) implementation
│   ├── four_way_handler.sv     # Betaflight 4-Way Interface Protocol handler
│   ├── shared_buffer_ram.sv    # Generic BRAM inference module (Optimized)
│   ├── wb_dshot_controller.sv  # DSHOT 600 motor output control
│   ├── wb_serial_dshot_mux.sv  # Runtime mux between DSHOT and Passthrough
│   └── uart_passthrough_bridge.sv # Baud rate conversion (115200 <-> 19200)
│
├── dshot/                      # DSHOT protocol implementation
├── pwmDecoder/                 # RC PWM signal decoding
├── neoPXStrip/                 # NeoPixel (WS2812B) control logic
├── spiSlave/                   # SPI to Wishbone bridge
├── verilog-wishbone/           # Standard Wishbone interconnect IP
└── python/                     # Host-side TUI and configuration tools
```

## Key Features

### 1. "Hands-Free" BLHeli Passthrough
- **Hardware Translation**: Automatically detects Betaflight 4-Way protocol frames (`0x2F` header).
- **Protocol Stripping**: Validates CRC, strips 4-way headers, and forwards raw commands to ESCs.
- **Baud Rate Conversion**: Bridging 115200 (USB) to 19200 (BLHeli_S Bootloader) via 512-byte FIFOs.
- **Micro-Timing Logic**: Nanosecond-level half-duplex direction switching for reliable ESC flashing.

### 2. Optimized Resource Utilization
- **BRAM Inference**: Large message buffers (128 bytes for 4-Way, 64 bytes for MSP) utilize dedicated Block RAM instead of Flip-Flops.
- **Sequential Processing**: CRC calculations are performed one byte per clock, reducing combinational path depth and ensuring 72MHz timing closure.
- **Shared Memory Architecture**: Streamlined memory access patterns reduce LUT usage by over 40% compared to register-array implementations.

### 3. Peripheral Suite
- **DSHOT 600**: 4-channel digital ESC protocol.
- **PWM Decoding**: 4-channel RC input capture with 1µs resolution.
- **NeoPixel Drive**: Wishbone-controlled LED strips with runtime color updates.
- **Version Tracking**: Hardware-baked version registers for host-side compatibility checks.

## Architecture Highlights

### Clocking
- **Input**: 27 MHz OSC
- **Internal**: 72 MHz (Generated via PLL)
- **SPI**: Synchronized to local 72MHz domain via 2-FF synchronizers.

### Wishbone Interconnect
The system uses a 6-master, 11-slave Wishbone crossbar (muxed) to manage peripheral access:
- **Address 0x0100**: UART/Passthrough Bridge
- **Address 0x0200**: DSHOT Motor Controller
- **Address 0x0300**: PWM Decoder
- **Address 0x0400**: Serial/DSHOT Mux Control
- **Address 0x0500**: LED Controller
- **Address 0x0600**: NeoPixel Controller
- **Address 0xFFFF**: Version Register

## Getting Started

### Synthesis & Build
```bash
make build    # Synthesize, Place, and Route (targets GW1N-9C)
make pack     # Generate bitstream (_build/default/hardware.fs)
make upload   # Program the Tang Nano 9K
```

### Simulation
Comprehensive test suites are available for all core modules:
```bash
make tb-all      # Run all testbenches
make tb-dshot    # Test DSHOT waveforms
make tb-spi      # Test SPI-to-Wishbone bridge
```

## Safety & Compliance
- **Propellers Off**: Always remove propellers when using Passthrough/Configurator.
- **Baud Rates**: Host communication must be set to 115200, 8-N-1.

---
**Last Updated**: February 8, 2026
**Status**: Stable - All core testbenches passing.
