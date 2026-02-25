# Tang Nano 9K Quadcopter FPGA - Project Summary

## Overview

The Tang Nano 9K Quadcopter FPGA project implements a Flight Controller (FC) bridge on a Gowin GW1N-9C FPGA. The design features a **dual Wishbone bus architecture** with:

- **SERV RISC-V CPU**: Handles protocol processing (MSP, 4-Way Interface, ESC configuration)
- **SPI-to-Wishbone Bridge**: Provides external flight controller access to peripherals

The system operates at 72 MHz and uses an arbiter to share DSHOT access between both buses.

## Project Structure

```
SPIQuadCopter/
├── Makefile                    # Top-level build management
├── tang9k.cst                  # Pin constraints (LQFP144)
├── tang9k_timing.sdc           # Timing constraints (72 MHz)
│
├── src/                        # Core RTL Source
│   ├── tang9k_top.sv           # Top-level I/O, buses, arbiter
│   ├── pll.sv                  # 27→72 MHz clock generation
│   ├── spi_slave.sv            # SPI slave interface
│   ├── spi_wb_master.sv        # SPI-to-Wishbone protocol
│   ├── wb_mux_5.v              # SERV bus mux (5 peripherals)
│   ├── wb_mux_6.v              # SPI bus mux (6 peripherals)
│   ├── wb_arbiter_2.sv         # 2-master DSHOT arbiter
│   ├── wb_debug_gpio.sv        # 3-bit debug output
│   ├── wb_dshot_controller.sv  # 4-channel DSHOT150 output
│   ├── wb_led_controller.sv    # 6-LED PWM controller
│   ├── wb_usb_uart.sv          # USB UART (115200 baud)
│   ├── wb_esc_uart.sv          # ESC UART (19200 baud, half-duplex)
│   └── wb_neoPx.v              # NeoPixel controller
│
├── serv/                       # SERV RISC-V CPU
│   ├── serv-core/              # Bit-serial RV32I core
│   └── firmware/               # C++ firmware (MSP, 4-Way bridge)
│
├── dshot/                      # DSHOT protocol implementation
├── pwmDecoder/                 # RC PWM signal decoding
├── neoPXStrip/                 # NeoPixel (WS2812B) driver
├── spiSlave/                   # SPI slave module
└── python/                     # Host-side tools and tests
```

## Architecture

### Dual Wishbone Bus Design

```
                    ┌─────────────────────────────────────────────┐
                    │              Tang Nano 9K FPGA              │
                    ├─────────────────────────────────────────────┤
                    │                                             │
  SPI (from FC) ──► │  SPI Slave ─► wb_mux_6 ──┬─► LED (0x100)   │
                    │                          ├─► PWM (0x200)   │
                    │                          ├─► DSHOT ◄──┐    │
                    │                          ├─► NeoPixel │    │
                    │                          └─► Mux Mirror│    │
                    │                                       │    │
                    │                          wb_arbiter_2 ┤    │
                    │                                       │    │
  USB UART ◄──────► │  SERV CPU ──► wb_mux_5 ──┬─► Debug GPIO   │
                    │                          ├─► DSHOT ◄──┘    │
                    │                          ├─► Mux Reg       │
                    │                          ├─► USB UART      │
                    │                          └─► ESC UART ───► │ ──► Motor Pin
                    └─────────────────────────────────────────────┘
```

### SERV Bus Address Map (wb_mux_5)

| Address | Peripheral | Description |
|---------|------------|-------------|
| 0x40000100 | Debug GPIO | 3-bit output for debugging |
| 0x40000400 | DSHOT | Motor control (via arbiter) |
| 0x40000700 | Mux Reg | ESC channel selection |
| 0x40000800 | USB UART | PC communication (115200) |
| 0x40000900 | ESC UART | ESC config (19200, half-duplex) |

### SPI Bus Address Map (wb_mux_6)

| Address | Peripheral | Description |
|---------|------------|-------------|
| 0x0000 | Version | Hardware version (read-only) |
| 0x0100 | LED | 6-channel LED controller |
| 0x0200 | PWM | 6-channel PWM decoder (read-only) |
| 0x0300 | DSHOT | Motor control (via arbiter) |
| 0x0400 | NeoPixel | WS2812 LED strip |
| 0x0500 | Mux Mirror | ESC channel (read-only) |

## Key Features

### 1. SERV RISC-V CPU
- **Bit-serial RV32I**: Minimal area (~300 LUTs)
- **Performance**: ~2.25 MIPS at 72 MHz
- **Memory**: 8 KB BRAM for firmware
- **Role**: Protocol handling, ESC configuration bridging

### 2. BLHeli ESC Configuration
- **SERV-based**: Firmware handles MSP and 4-Way protocol
- **Baud Translation**: USB UART (115200) ↔ ESC UART (19200)
- **Channel Selection**: Mux register selects motor pin 0-3

### 3. Shared DSHOT Access
- **wb_arbiter_2**: Round-robin arbitration
- **Both buses**: SERV and SPI can write motor commands
- **Flight mode**: SPI master controls motors
- **Config mode**: SERV can stop motors during ESC flash

### 4. Peripheral Suite
- **DSHOT150**: 4-channel digital ESC protocol
- **PWM Decoder**: 6-channel RC input capture
- **NeoPixel**: Wishbone-controlled LED strips
- **Debug GPIO**: Fast 3-bit output for debugging

## Getting Started

### Build & Program
```bash
make build    # Synthesize for GW1N-9C
make pack     # Generate bitstream
make upload   # Program Tang Nano 9K
```

### Build SERV Firmware
```bash
cd serv/firmware
make          # Build main.elf
```

### Simulation
```bash
make tb-spi   # Test SPI-to-Wishbone
make tb-dshot # Test DSHOT waveforms
```

## Safety

- **Propellers Off**: Always remove propellers during ESC configuration
- **Motor Commands**: DSHOT outputs are active - verify safe state

---
**Status**: Active development
