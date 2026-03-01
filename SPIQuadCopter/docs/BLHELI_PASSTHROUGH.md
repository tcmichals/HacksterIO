# BLHeli Passthrough Configuration Guide

## Overview

The Tang9K FPGA uses the **SERV RISC-V CPU** to bridge BLHeli ESC configuration between a PC and the ESCs. The SERV firmware handles the MSP protocol discovery, 4-Way Interface protocol translation, and UART bridging — all in software.

## Architecture

```
PC (BLHeliSuite / ESC Configurator)
        ↓ USB (115200 baud)
   USB UART → SERV RISC-V CPU → ESC UART
                                   ↓ (19200 baud, half-duplex)
                              Motor Pin [mux_ch]
                                   ↓
                                  ESC
```

### How It Works

1. **SERV CPU monitors the USB UART** for MSP protocol frames (`$M<`).
2. When a **MSP_SET_PASSTHROUGH** command (CMD 245) is received, the SERV firmware:
   - Responds with `0x04` (4 motor channels available).
   - Switches the motor pin mux to UART mode.
   - Enters 4-Way protocol bridging mode.
3. **4-Way binary frames** (`0x2F` header) from the PC are validated, stripped, and forwarded to the ESC at 19200 baud via the half-duplex ESC UART.
4. ESC responses are captured and wrapped in `0x2E` response frames for the PC.
5. When complete, the SERV firmware restores DSHOT mode.

### Key Registers (SERV Wishbone Bus)

| Address       | Register    | Description                         |
|---------------|-------------|-------------------------------------|
| 0x4000_0700   | Mux Reg     | `mux_sel` (bit 0), `mux_ch` (bits 2:1) |
| 0x4000_0800   | USB UART    | MSP from PC (115200 baud)           |
| 0x4000_0900   | ESC UART    | Half-duplex to ESC (19200 baud)     |

> **Note:** The Mux Register is on the SERV Wishbone bus, not the SPI bus. The SPI bus has a **read-only Mux Mirror** at `0x0500` for status monitoring only.

## Hardware Setup

### Required Connections

1. **USB connection** to Tang9K for UART (connects to BLHeli tool on PC)
2. **ESC signal wires** connected to Tang9K motor pins (shared DSHOT/UART pins)
3. **Power** to ESCs (separate from FPGA)

### ESC Configuration Flow

1. Open BLHeliSuite, BLHeliConfigurator, or the [ESC Configurator PWA](https://esc-configurator.com)
2. Connect to the USB serial port created by the Tang9K
3. The tool sends MSP discovery commands → SERV firmware responds as "T9K-FC"
4. Click "Read Setup" → tool sends MSP_SET_PASSTHROUGH → SERV enables bridge
5. Configure ESC parameters normally
6. Disconnect → SERV restores DSHOT mode

## 4-Way Interface Protocol

Modern configurators wrap commands in the **Betaflight 4-Way Interface Protocol**:

| Byte  | Value  | Name    | Description                 |
|-------|--------|---------|-----------------------------|
| 0     | `0x2F` | Sync    | Header (PC → FC)            |
| 1     | `CMD`  | Command | 4-way command ID            |
| 2-3   | `ADDR` | Address | Target address              |
| 4     | `LEN`  | Length  | Length of parameters        |
| 5..   | `DATA` | Params  | Command parameters          |
| N-1..N| `CRC`  | CRC16   | CRC16-XMODEM checksum       |

The SERV firmware validates each frame, strips the 4-way envelope, and forwards the raw BLHeli command to the ESC.

## Serial Configuration

| Parameter  | USB UART (PC Side) | ESC UART (ESC Side) |
|------------|-------------------|---------------------|
| Baud Rate  | 115200            | 19200               |
| Data Bits  | 8                 | 8                   |
| Parity     | None              | None                |
| Stop Bits  | 1                 | 1                   |
| Mode       | Full-duplex       | Half-duplex (1-wire)|

## Safety Notes

⚠️ **IMPORTANT**:
- **Remove propellers** before configuring ESCs
- **Disconnect battery** or ensure motors cannot spin
- **Passthrough mode disables DSHOT**: Motors will not respond during configuration
- SERV firmware automatically restores DSHOT mode when configuration is complete

## Troubleshooting

### ESC Not Responding
1. Verify ESC power supply
2. Check signal wire connections to the correct motor pin
3. Confirm the SERV firmware is running (check debug GPIO)
4. Try resetting the Tang9K

### Communication Errors
- Verify USB serial connection to the PC
- Ensure no other program is using the USB serial port
- Check that ESC has BLHeli firmware installed

## References
- BLHeliSuite: https://github.com/bitdump/BLHeliSuite
- BLHeli Configurator: https://github.com/blheli-configurator/blheli-configurator
- ESC Configurator PWA: https://esc-configurator.com
