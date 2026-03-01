# Tang9K FPGA Quadcopter - Documentation

## Quick Navigation

| Document | Description |
|----------|-------------|
| [SYSTEM_OVERVIEW.md](SYSTEM_OVERVIEW.md) | **Start here** — Dual-bus architecture, address maps, and peripheral details |
| [SPI_WB_MASTER_DESIGN.md](SPI_WB_MASTER_DESIGN.md) | SPI-to-Wishbone protocol specification |
| [system_block_diagram.md](system_block_diagram.md) | Mermaid block diagram of the system |
| [BLHELI_PASSTHROUGH.md](BLHELI_PASSTHROUGH.md) | BLHeli ESC configuration via SERV CPU |
| [BLHELI_QUICKSTART.md](BLHELI_QUICKSTART.md) | Quick BLHeli setup reference |
| [PINOUT.md](PINOUT.md) | Motor, PWM, and NeoPixel pin mapping |
| [HARDWARE_PINS.md](HARDWARE_PINS.md) | Detailed hardware wiring and mux details |
| [BUILD_AND_PROGRAM.md](BUILD_AND_PROGRAM.md) | Toolchain installation and build instructions |
| [QUICK_START.md](QUICK_START.md) | Quick reference for building and programming |
| [INSTALL_OSS_CAD.md](INSTALL_OSS_CAD.md) | OSS CAD Suite installation |
| [72MHZ_PLL.md](72MHZ_PLL.md) | PLL configuration details |
| [TIMING_OPTIMIZATION.md](TIMING_OPTIMIZATION.md) | Timing closure and optimization notes |
| [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) | Technical project summary |
| [IMPLEMENTATION_OPTIONS.md](IMPLEMENTATION_OPTIONS.md) | Design trade-off analysis (SystemVerilog vs SERV vs RP2040) |
| [START_HERE.txt](START_HERE.txt) | Initial setup guide |

## Architecture

The system uses a **dual Wishbone bus** design:

- **SPI Bus** (`wb_mux_6`) — External flight controller reads/writes peripherals (Version, LED, PWM, DSHOT, NeoPixel, Mux Mirror)
- **SERV Bus** (`wb_mux_5`) — SERV RISC-V CPU handles MSP protocol, ESC configuration, and motor pin mux control

Both buses share the DSHOT controller via `wb_arbiter_2`.

See [SYSTEM_OVERVIEW.md](SYSTEM_OVERVIEW.md) for the full architecture and address map.

## Related Documentation

- **[SERV Firmware](../serv/firmware/README.md)** — SERV RISC-V firmware (MSP bridge, ESC passthrough)
- **[Python TUI](../python/tuiExample/README.md)** — Terminal UI for monitoring and control
