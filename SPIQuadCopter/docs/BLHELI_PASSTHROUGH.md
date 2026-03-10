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
2. The SERV firmware responds to **MSP_BATTERY_STATE** (CMD 130) requests from the configurator (required for ESC Configurator PWA to establish connection).
3. When a **MSP_SET_PASSTHROUGH** command (CMD 245) is received, the SERV firmware:
   - Responds with `0x04` (4 motor channels available).
   - Switches the motor pin mux to UART mode.
   - Enters 4-Way protocol bridging mode.
3. **4-Way binary frames** (`0x2F` header) from the PC are validated, stripped, and forwarded to the ESC at 19200 baud via the half-duplex ESC UART.
4. ESC responses are captured and wrapped in `0x2E` response frames for the PC.
5. When complete, the SERV firmware restores DSHOT mode.

### Key Registers (SERV Wishbone Bus)

| Address       | Register    | Description                         |
|---------------|-------------|-------------------------------------|
| 0x4000_0400   | Mux Reg     | `mux_sel` (bit 0), `mux_ch` (bits 2:1), `force_low` (bit 4) |
| 0x4000_0800   | USB UART    | MSP from PC (115200 baud)           |
| 0x4000_0900   | ESC UART    | Half-duplex to ESC (19200 baud)     |

> **Note:** The Mux Register is on the SERV Wishbone bus, not the SPI bus. The SPI bus has a **read-only Mux Mirror** at `0x0500` for status monitoring only.

### Required MSP Messages

The SERV firmware must respond to these MSP commands for ESC Configurator to connect:

| MSP Command       | CMD ID | Description                                      |
|-------------------|--------|--------------------------------------------------|
| MSP_API_VERSION   | 1      | API version (required for discovery)             |
| MSP_FC_VARIANT    | 2      | Flight controller variant ("T9K-FC")             |
| MSP_FC_VERSION    | 3      | Flight controller version                        |
| MSP_BATTERY_STATE | 130    | Battery status (**required for ESC Configurator PWA**) |
| MSP_MOTOR         | 104    | Motor values (optional)                          |
| MSP_SET_PASSTHROUGH | 245  | Enter 4-way passthrough mode                     |

> **Important:** The `MSP_BATTERY_STATE` message is polled continuously by ESC Configurator PWA. Without a valid response, the configurator will fail to establish a connection. The SERV firmware returns a minimal 9-byte response with zeroed values (no battery monitoring).

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

### Protocol Flow (Re-encapsulation)

After MSP_SET_PASSTHROUGH, the protocol changes from MSP to **4-Way binary protocol**. ESC responses must be re-encapsulated by the SERV firmware:

```
PC (ESC Configurator)          Tang9K (SERV)              ESC
       |                            |                       |
       |-- [0x2F][CMD][...][CRC] -->|                       |
       |                            |-- raw bootloader cmd-->|
       |                            |<-- raw response -------|
       |<-- [0x2E][CMD][...][ACK][CRC] --|                   |
```

**PC → Tang9K (USB UART):**
```
[0x2F][CMD][ADDR_H][ADDR_L][LEN][PARAMS...][CRC_H][CRC_L]
```

**Tang9K → ESC (Motor Pin UART):**
- Strips 4-way envelope, sends **raw BLHeli bootloader command**
- Commands: 0x01 (erase), 0x02 (write), 0x03 (read), 0x04 (read EEPROM), 0x05 (write EEPROM)

**ESC → Tang9K:**
- Raw bootloader response bytes (signature, data, ACK)

**Tang9K → PC:**
```
[0x2E][CMD][ADDR_H][ADDR_L][LEN][PARAMS...][ACK][CRC_H][CRC_L]
```

### 4-Way Commands

| Command | Value  | Description                    |
|---------|--------|--------------------------------|
| InterfaceTestAlive  | 0x30 | Keep-alive ping             |
| ProtocolGetVersion  | 0x31 | Get protocol version        |
| InterfaceGetName    | 0x32 | Get interface name ("T9K-4WAY") |
| InterfaceGetVersion | 0x33 | Get interface version       |
| InterfaceExit       | 0x34 | Exit 4-way mode, restore DSHOT |
| DeviceReset         | 0x35 | Reset ESC                   |
| DeviceInitFlash     | 0x37 | Initialize ESC for programming |
| DeviceEraseAll      | 0x38 | Erase all flash             |
| DevicePageErase     | 0x39 | Erase flash page            |
| DeviceRead          | 0x3A | Read flash/EEPROM           |
| DeviceWrite         | 0x3B | Write flash                 |
| DeviceReadEEPROM    | 0x3D | Read EEPROM                 |
| DeviceWriteEEPROM   | 0x3E | Write EEPROM                |
| InterfaceSetMode    | 0x3F | Set bootloader mode         |

### ACK Codes

| ACK  | Value | Meaning                     |
|------|-------|-----------------------------|
| OK   | 0x00  | Success                     |
| Unknown Error | 0x01 | Unknown error          |
| Invalid CMD   | 0x02 | Invalid command        |
| Invalid CRC   | 0x03 | CRC mismatch           |
| Verify Error  | 0x04 | Verification failed    |
| General Error | 0x0F | Device-level error     |

## Serial Configuration

| Parameter  | USB UART (PC Side) | ESC UART (ESC Side) |
|------------|-------------------|---------------------|
| Baud Rate  | 115200            | 19200               |
| Data Bits  | 8                 | 8                   |
| Parity     | None              | None                |
| Stop Bits  | 1                 | 1                   |
| Mode       | Full-duplex       | Half-duplex (1-wire)|

### Bootloader Software UART Timing

The BLHeli bootloader uses **bit-banged (software) UART** at 19200 baud on the motor signal wire. From Betaflight `serial_4way_avrootloader.c`:

```c
#define BIT_TIME         (52)      // 52µs per bit (1/19200 ≈ 52.08µs)
#define BIT_TIME_HALVE   (26)      // Half bit time
#define BIT_TIME_3_4     (39)      // 3/4 bit time (center of start bit)
#define START_BIT_TIMEOUT_MS 2     // Timeout waiting for start bit
```

**Byte Frame Format (19200 8N1):**
```
    ┌─────┬───┬───┬───┬───┬───┬───┬───┬───┬─────┐
    │START│ 0 │ 1 │ 2 │ 3 │ 4 │ 5 │ 6 │ 7 │STOP │
    │ LOW │LSB│   │   │   │   │   │   │MSB│HIGH │
    └─────┴───┴───┴───┴───┴───┴───┴───┴───┴─────┘
    │<─────────── 10 bits × 52µs = 520µs ────────>│
```

**Half-Duplex Protocol:**
1. **TX**: Drive pin LOW for start bit, shift out data LSB first, drive HIGH for stop bit
2. **RX**: Wait for LOW edge (start bit), sample at bit centers, verify stop bit HIGH
3. **Direction**: SERV firmware controls direction via mux/tristate

**Critical Timing:**
- Break signal: ~100-250ms LOW (SERV uses 100ms)
- Byte-to-byte gap: Minimal (bootloader reads continuously)
- Response timeout: 2ms for start bit, then continuous read

## Safety Notes

⚠️ **IMPORTANT**:
- **Remove propellers** before configuring ESCs
- **Disconnect battery** or ensure motors cannot spin
- **Passthrough mode disables DSHOT**: Motors will not respond during configuration
- SERV firmware automatically restores DSHOT mode when configuration is complete

## BLHeli_S Bootloader Protocol (ESC Side)

The **4-Way commands** (0x30-0x3F) are handled by the SERV firmware. When the SERV firmware needs to communicate with the ESC bootloader (e.g., DeviceInitFlash), it uses the **BLHeli_S bootloader protocol** over the half-duplex UART.

### Bootloader Entry Sequence

From [Betaflight serial_4way_avrootloader.c](https://github.com/betaflight/betaflight/blob/master/src/main/io/serial_4way_avrootloader.c):

1. **Break Signal**: Hold the motor pin LOW for ~100-250ms
2. **Send BootInit**: Send 8 zeros + 0x0D + "BLHeli" + CRC16 (17 bytes total)
3. **Receive Response**: ESC bootloader sends 8 bytes:
   - `BOOT_MSG`: 4 bytes - e.g., "471c" or "471d"
   - `SIGNATURE_001`: 1 byte - device signature high byte
   - `SIGNATURE_002`: 1 byte - device signature low byte
   - `BOOT_VERSION`: 1 byte - always 6
   - `BOOT_PAGES`: 1 byte - number of flash pages

**Critical**: The identifier frame includes **leading zeros** and **0x0D** before "BLHeli"! See Betaflight source.

### Bootloader Identifier Frame (BootInit)

From Betaflight `serial_4way_avrootloader.c`:

```c
uint8_t BootInit[] = {0,0,0,0,0,0,0,0,0x0D,'B','L','H','e','l','i',0xF4,0x7D};
BL_SendBuf(BootInit, 17);
```

Frame breakdown:
```
[0x00][0x00][0x00][0x00][0x00][0x00][0x00][0x00]  // 8 zero bytes
[0x0D]                                            // Carriage return
[B][L][H][e][l][i]                                // "BLHeli" (6 bytes)
[0xF4][0x7D]                                      // Pre-calculated CRC16
```

Total: 17 bytes

**The CRC (0x7DF4, sent LSB first as 0xF4 0x7D) is pre-calculated over the first 15 bytes.**

### Bootloader Response Format (8 bytes)

```c
#define BootMsgLen 4
#define DevSignHi  4  // Index of SIGNATURE_001
#define DevSignLo  5  // Index of SIGNATURE_002

uint8_t BootInfo[8];
// After BL_ReadBuf:
// BootInfo[0-3] = BOOT_MSG (e.g., "471c")
// BootInfo[4]   = SIGNATURE_001 (sig high)
// BootInfo[5]   = SIGNATURE_002 (sig low)
// BootInfo[6]   = BOOT_VERSION (always 6)
// BootInfo[7]   = BOOT_PAGES
```

### 4-Way DeviceInfo Response (4 bytes)

The 4-way `init_flash` command returns a 4-byte DeviceInfo:

```c
DeviceInfo.bytes[0] = BootInfo[5];  // SIGNATURE_002 (sig low)
DeviceInfo.bytes[1] = BootInfo[4];  // SIGNATURE_001 (sig high)
DeviceInfo.bytes[2] = BootInfo[3];  // BOOT_MSG last byte ('c', 'd', etc.)
DeviceInfo.bytes[3] = 1;            // interfaceMode (1 = imSIL_BLB = SiLabs)
```

**Interface Mode Values:**
- `imSIL_BLB = 1`: SiLabs bootloader (BLHeli_S, Bluejay)
- `imATM_BLB = 2`: Atmel bootloader
- `imARM_BLB = 3`: ARM bootloader

### Device Signature Check (SiLabs)

From Betaflight:
```c
#define SILABS_DEVICE_MATCH ((pDeviceInfo->words[0] > 0xE800) && (pDeviceInfo->words[0] < 0xF900))
```

Valid SiLabs EFM8 signatures are in range 0xE801 - 0xF8FF.

### Decoding Device Signatures (EFM8 BB21 vs BB51)

The device signature identifies the specific SiLabs EFM8 MCU variant:

| Signature Range | MCU Family     | Notes                              |
|-----------------|----------------|-----------------------------------|
| 0xE800 - 0xE8FF | EFM8BB10/BB21  | Original BLHeli_S ESCs            |
| 0xF800 - 0xF8FF | EFM8BB51       | Newer ESCs, Bluejay compatible    |

**Common Signatures:**

| Signature | MCU             | Flash | RAM  | Package | Common ESCs          |
|-----------|-----------------|-------|------|---------|----------------------|
| 0xE807    | EFM8BB21F16G-C  | 16KB  | 2KB  | QFN20   | Racerstar RS, most BLHeli_S |
| 0xE809    | EFM8BB21F16I-C  | 16KB  | 2KB  | QFN20   | Industrial temp range |
| 0xE812    | EFM8BB10F8G-A   | 8KB   | 512B | QFN20   | Smaller/cheaper ESCs |
| 0xF880    | EFM8BB51F16G-C  | 16KB  | 4KB  | QFN20   | AM32, newer Bluejay  |
| 0xF890    | EFM8BB51F8G-C   | 8KB   | 2KB  | QFN20   | Budget BB51 ESCs     |

**Signature Byte Order:**
```
DeviceInfo.bytes[0] = signature low  (e.g., 0x07)
DeviceInfo.bytes[1] = signature high (e.g., 0xE8)
Full signature = (high << 8) | low = 0xE807
```

**Python Decoding Example:**
```python
def decode_signature(params):
    """Decode 4-way init_flash response params"""
    sig_low = params[0]     # e.g., 0x07
    sig_high = params[1]    # e.g., 0xE8
    boot_ver = params[2]    # e.g., 0x63 = 'c'
    intf_mode = params[3]   # e.g., 0x01 = SiLabs
    
    signature = (sig_high << 8) | sig_low
    
    # Identify MCU family
    if 0xE800 <= signature <= 0xE8FF:
        family = "EFM8BB21 (BLHeli_S)"
    elif 0xF800 <= signature <= 0xF8FF:
        family = "EFM8BB51 (Bluejay/AM32)"
    else:
        family = "Unknown"
    
    print(f"Signature: 0x{signature:04X} ({family})")
    print(f"Bootloader version: '{chr(boot_ver)}'")
    print(f"Interface mode: {intf_mode} ({'SiLabs' if intf_mode == 1 else 'Other'})")
    
    return signature

# Example: params = bytes.fromhex("07e86301")
# decode_signature(params)
# Output:
#   Signature: 0xE807 (EFM8BB21 (BLHeli_S))
#   Bootloader version: 'c'
#   Interface mode: 1 (SiLabs)
```

### BLHeli_S vs Bluejay Firmware

Both BLHeli_S and Bluejay use the **same bootloader protocol**. The bootloader is baked into the ESC at the factory and is MCU-specific, not firmware-specific.

| Firmware  | MCU Support          | Source Code                                      |
|-----------|----------------------|--------------------------------------------------|
| BLHeli_S  | EFM8BB21, EFM8BB10   | https://github.com/bitdump/BLHeli/tree/master/BLHeli_S |
| Bluejay   | EFM8BB21, EFM8BB51   | https://github.com/mathiasvr/bluejay             |
| AM32      | EFM8BB51, AT32, STM32| https://github.com/AlkaMotors/AM32-MultiRotor-ESC-firmware |

**Key Differences:**
- **BLHeli_S**: Closed source (only HEX files), EFM8BB21 only, no longer actively developed
- **Bluejay**: Open source fork of BLHeli_S, supports BB21 and BB51, active development
- **AM32**: Completely new codebase, ARM-based MCUs, but also supports EFM8BB51

**Bootloader Compatibility:**
```
Bootloader Type    Signature Range    Supported By
──────────────────────────────────────────────────
SiLabs (imSIL_BLB) 0xE8xx, 0xF8xx     BLHeli_S, Bluejay, AM32 (partial)
```

The bootloader version character ('c', 'd', etc.) indicates the bootloader revision, not the firmware version. Common bootloader versions:
- `'c'` (0x63): Original BLHeli bootloader
- `'d'` (0x64): Updated bootloader with bug fixes

### Bootloader Commands (After Init)

Once the bootloader is active, commands use this format:

| Command | Value  | Description                    |
|---------|--------|--------------------------------|
| Run/Restart | 0x00 | Exit bootloader, run application |
| Program Flash | 0x01 | Write flash with buffer data |
| Erase Flash | 0x02 | Erase flash page at address |
| Read Flash | 0x03 | Read flash bytes |
| Set Address | 0xFF | Set flash address pointer |
| Set Buffer | 0xFE | Load data into write buffer |
| Keep Alive | 0xFD | Keep bootloader active |

### Detailed Bootloader Frame Formats

The BLHeli bootloader uses a simple command/response protocol over half-duplex UART at 19200 baud.

**General Frame Structure:**
```
TX: [CMD][PARAM][CRC_L][CRC_H]
RX: [DATA...][CRC_L][CRC_H][ACK]  (if connected)
RX: [ACK]                         (if not connected)
```

**CRC Calculation:**
- Uses CRC-16/IBM polynomial 0xA001 (bit-reversed 0x8005)
- CRC is sent LSB first
- CRC is calculated over command and data bytes (excluding CRC itself)

#### Keep Alive (0xFD)

Keep the bootloader active. Must be sent periodically to prevent bootloader timeout.

```
TX: [0xFD][0x00][CRC_L][CRC_H]
RX: [ACK]

ACK = 0xC1 (ERRORCOMMAND) means bootloader is alive
```

#### Set Address (0xFF)

Set the flash address pointer for subsequent read/write operations.

```
TX: [0xFF][0x00][ADDR_L][ADDR_H][CRC_L][CRC_H]
RX: [ACK]

ADDR is 16-bit, sent little-endian (low byte first)
ACK = 0x30 (SUCCESS)
```

Example - Set address to 0x1A00:
```
TX: FF 00 00 1A [CRC_L] [CRC_H]
```

#### Set Buffer (0xFE)

Load data into the write buffer before programming.

```
TX: [0xFE][0x00][COUNT_L][COUNT_H][CRC_L][CRC_H]
RX: [ACK_NONE]  (expects more data)

TX: [DATA...COUNT bytes...][CRC_L][CRC_H]
RX: [ACK]

COUNT is 16-bit, sent little-endian
ACK_NONE = no ack byte, just wait for data
ACK = 0x30 (SUCCESS) after data received
```

#### Program Flash (0x01)

Write the buffer contents to flash at the current address.

```
TX: [0x01][0x01][CRC_L][CRC_H]
RX: [ACK]

ACK = 0x30 (SUCCESS)
ACK = 0xC5 (ERRORPROG) if programming failed
```

#### Erase Flash (0x02)

Erase a flash page at the current address.

```
TX: [0x02][0x01][CRC_L][CRC_H]
RX: [ACK]

Timeout: Up to 3 seconds for erase completion
ACK = 0x30 (SUCCESS)
```

#### Read Flash (0x03)

Read flash contents from the current address.

```
TX: [0x03][COUNT][CRC_L][CRC_H]
RX: [DATA...COUNT bytes...][CRC_L][CRC_H][ACK]

COUNT = number of bytes to read (0 = 256)
ACK = 0x30 (SUCCESS)
```

#### Run Application (0x00)

Exit bootloader and start the main ESC application.

```
TX: [0x00][0x00][CRC_L][CRC_H]
RX: (no response - bootloader exits)
```

### Complete Programming Sequence

To write data to ESC flash:

```
1. Enter bootloader (break signal + BootInit)
2. Set Address to target location
3. Load data into buffer (Set Buffer)
4. Program flash (Program Flash)
5. Repeat 2-4 for additional pages
6. Run application (Run)
```

**Example - Write 64 bytes to address 0x1A00:**
```
→ Set Address:  FF 00 00 1A [CRC]
← ACK:          30
→ Set Buffer:   FE 00 40 00 [CRC]
← (wait)
→ Data:         [64 bytes] [CRC]
← ACK:          30
→ Program:      01 01 [CRC]
← ACK:          30
→ Run:          00 00 [CRC]
(ESC restarts)
```

### Bootloader Response Codes

| Response | Value  | Description                    |
|----------|--------|--------------------------------|
| SUCCESS  | 0x30   | Operation successful           |
| ERRORVERIFY | 0xC0 | Verify failed                 |
| ERRORCOMMAND | 0xC1 | Invalid command              |
| ERRORCRC | 0xC2   | CRC mismatch                   |
| ERRORPROG | 0xC5  | Programming error              |

### Bootloader CRC16 Algorithm

The bootloader uses **CRC-16/IBM** (polynomial 0xA001, bit-reversed 0x8005):

```c
uint16_t crc16_ibm(const uint8_t* data, uint16_t len) {
    uint16_t crc = 0;
    for (uint16_t i = 0; i < len; i++) {
        crc ^= data[i];
        for (int j = 0; j < 8; j++) {
            if (crc & 1)
                crc = (crc >> 1) ^ 0xA001;
            else
                crc >>= 1;
        }
    }
    return crc;  // Send LSB first
}
```

**Note**: This is different from CRC16-XMODEM (0x1021) used by the 4-Way protocol!

### Read/Write Command Format

**Read Flash** (command 0x03):
```
PC → ESC: [0x03][ADDR_H][ADDR_L][COUNT]
ESC → PC: [DATA...][CRC_L][CRC_H]
```

**Set Address** (command 0xFF):
```
PC → ESC: [0xFF][0x00][ADDR_L][ADDR_H][CRC_L][CRC_H]
ESC → PC: [SUCCESS/ERROR]
```

**Set Buffer** (command 0xFE):
```
PC → ESC: [0xFE][0x00][COUNT_L][COUNT_H][CRC_L][CRC_H][DATA...][CRC_L][CRC_H]
ESC → PC: [SUCCESS/ERROR]
```

**Program Flash** (command 0x01):
```
PC → ESC: [0x01][0x00][CRC_L][CRC_H]
ESC → PC: [SUCCESS/ERROR]
```

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

## Testing Commands

Test the 4-way protocol using the serialMSP.py script:

```bash
# Enter 4-way mode and test alive
python3 serialMSP.py --port /dev/ttyUSB1 fourway --passthrough --cmds test_alive

# Initialize ESC 0 for flashing (triggers bootloader)
python3 serialMSP.py --port /dev/ttyUSB1 fourway --passthrough --cmds test_alive init_flash --esc 0

# Full sequence: test_alive, init_flash, read flash, exit
python3 serialMSP.py --port /dev/ttyUSB1 fourway --passthrough --cmds test_alive init_flash read exit --esc 0 --address 0x0000 --length 128

# Exit 4-way mode
python3 serialMSP.py --port /dev/ttyUSB1 fourway --cmds exit
```

### Expected init_flash Response

On success, the response params should be 4 bytes:
- `params[0]` = signature low byte (e.g., 0x07 for EFM8BB21)
- `params[1]` = signature high byte (e.g., 0xE8)
- `params[2]` = BOOT_MSG last char (e.g., 0x63 = 'c')
- `params[3]` = interface mode (1 = SiLabs)

Example: `07 E8 63 01` = EFM8BB21 with bootloader version 'c', SiLabs mode.

## Implementation Notes

### SERV RISC-V Timing

At 54MHz with ~1.7 MIPS:
- 10000 delay loop iterations ≈ 72ms
- 14000 delay loop iterations ≈ 100ms

### Mux Register Bit Fields

```
bit[0] = mux_sel: 0 = UART mode, 1 = DSHOT mode
bits[2:1] = mux_ch: ESC channel 0-3
bit[4] = force_low: Force output LOW for break signal
```

Example:
```c
WB_MUX_REG = 0x00;  // UART mode, channel 0, normal
WB_MUX_REG = 0x10;  // UART mode, channel 0, force LOW (break)
WB_MUX_REG = 0x02;  // UART mode, channel 1, normal
WB_MUX_REG = 0x01;  // DSHOT mode
```

## References

- Betaflight 4-Way Source: https://github.com/betaflight/betaflight/blob/master/src/main/io/serial_4way.c
- Betaflight AVR Bootloader: https://github.com/betaflight/betaflight/blob/master/src/main/io/serial_4way_avrootloader.c
- BLHeli_S Source: https://github.com/betaflight/BLHeli_S
- BLHeliSuite: https://github.com/bitdump/BLHeliSuite
- BLHeli Configurator: https://github.com/blheli-configurator/blheli-configurator
- ESC Configurator PWA: https://esc-configurator.com
