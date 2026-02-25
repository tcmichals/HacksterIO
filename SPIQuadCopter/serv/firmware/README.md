# SERV Firmware MSP Bridge

This firmware implements the MultiWii Serial Protocol (MSP) bridge for the SERV RISC-V CPU.

## Protocol
- **MSP framing:** `$ M <` (host-to-device), `$ M >` (device-to-host)
- **Packet:**
  - Header: 3 bytes (`$`, `M`, `<` or `>`)
  - Payload size: 1 byte
  - Command: 1 byte
  - Payload: N bytes
  - CRC: 1 byte (XOR of payload size, command, payload)

## Response Table
| Command      | Code | Payload Size | Handler         |
|-------------|------|-------------|----------------|
| MSP_IDENT   | 100  | 7           | ident_handler   |
| MSP_STATUS  | 101  | 10          | status_handler  |
| MSP_DEBUG   | 254  | 4           | debug_handler   |

## Example
- Host sends MSP_IDENT (code 100)
- SERV responds with 7-byte payload (version, type, etc.)

## Files
- `main.c`         - Main loop, SPI stub
- `msp_bridge.c`   - MSP parser, response table, handlers
- `msp_bridge.h`   - Protocol definitions

## To extend
- Add more commands to `msp_response_table`
- Implement SPI RX/TX hardware access
- Add Wishbone peripheral access in handlers
