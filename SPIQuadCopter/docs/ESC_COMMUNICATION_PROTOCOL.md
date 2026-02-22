# ESC Communication Protocol Documentation

## Overview
This document describes the communication protocols used for configuring BLHeli-compatible Electronic Speed Controllers (ESCs) through the Tang9K FPGA's serial passthrough. The system implements the FourWay protocol for bootloader communication and includes BLHeli_S specific commands for ESC configuration.

## Architecture
```
Host (Tang9K FPGA) ↔ Serial Passthrough ↔ ESC Bootloader
        ↓
   SPI/Wishbone Bus
```

The Tang9K FPGA provides hardware serial passthrough, allowing direct communication with ESCs connected to motor output pins. The FPGA acts as a **Smart FC Translator** for the Betaflight 4-Way protocol:

### **Handshake & Discovery**
Modern configurators use a two-step handshake to enable high-speed configuration:
1.  **MSP Handshake**: The tool sends `MSP_SET_PASSTHROUGH` (CMD 245).
2.  **4-Way Transition**: The FPGA responds with `0x04`, signaling 4 available motor channels.
3.  **Binary Framing**: The configurator immediately switches from MSP to the **4-Way Protocol** (`0x2F` binary frames).

### **FPGA Protocol Handling**
Once in 4-Way mode, the FPGA performs active translation:
*   **Validation**: Each `0x2F` frame is checked against its CRC16-XMODEM footer.
*   **Forwarding**: If valid, the FPGA strips the 4-way headers and sends the internal BLHeli command to the ESC at 19200 baud.
*   **Response**: The ESC's serial reply is captured, wrapped in a `0x2E` header, and sent back to the browser.

This hardware-accelerated "Smart Bridge" makes the Tang9K look like a standard Betaflight Flight Controller to any configurator tool.

The hardware implementation ensures nanosecond-level turnaround timing, which is critical for 1-wire half-duplex reliability.

## **Detailed Handshake Flow**

The `esc-configurator` tool (and most Betaflight-compatible configurators) follows a two-stage discovery process to identify and enable the 4-Way interface.

### **Stage 1: MSP Handshake**
Initially, the configurator assumes it is talking to a standard Betaflight Flight Controller. It sends a series of **MSP (MultiWii Serial Protocol)** commands to identify the device:
1.  **`MSP_API_VERSION` (CMD 1)**: Verifies the device supports MSP.
2.  **`MSP_FC_VARIANT` (CMD 2)**: Identifies the firmware (Tang9K reports as "T9K-FPGA").
3.  **`MSP_BOARD_INFO` (CMD 4)**: Identifies the hardware target.

### **Stage 2: Enabling Passthrough**
When the user clicks "Read Setup", the configurator attempts to "upgrade" the connection to 4-Way mode by sending:
*   **`MSP_SET_PASSTHROUGH` (CMD 245)**: This is the critical "mode switch".

The FPGA responds to this command with a single byte payload (e.g., `0x04`), which indicates the **number of available motor channels**. Once the configurator receives this response, it:
1.  Disables the MSP state machine.
2.  Transitions to the **4-Way Protocol** framing (`0x2F` binary headers).
3.  Begins sending individual ESC commands (Alive, Read, Write) wrapped in 4-Way frames.

## FourWay Protocol

The FourWay protocol is the standard bootloader interface for BLHeli ESCs. It provides low-level access to flash memory and EEPROM for firmware updates and configuration.

### Message Format

All FourWay messages follow this structure:

#### TX Message (Host → ESC)
```
+--------+--------+--------+--------+--------+--------+--------+--------+--------+
|  CMD   | ADDRESS[0] | ADDRESS[1] | ADDRESS[2] | ADDRESS[3] | PARAM_LEN | PARAMS... |   CRC   |
+--------+--------+--------+--------+--------+--------+--------+--------+--------+
```

#### RX Message (ESC → Host)
```
+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+
|  ACK   | ADDRESS[0] | ADDRESS[1] | ADDRESS[2] | ADDRESS[3] | PARAM_LEN | PARAMS... |   CRC   |
+--------+--------+--------+--------+--------+--------+--------+--------+--------+
```

### Field Descriptions

- **CMD/ACK**: Command byte (TX) or acknowledgment byte (RX)
- **ADDRESS**: 32-bit big-endian address (4 bytes)
- **PARAM_LEN**: Number of parameter bytes (0-255)
- **PARAMS**: Variable-length parameter data
- **CRC**: 8-bit checksum (sum of all previous bytes & 0xFF)

### Acknowledgment Codes

| Code | Name | Description |
|------|------|-------------|
| 0x00 | ACK_OK | Command executed successfully |
| 0x01 | ACK_I_UNKNOWN_ERROR | Unknown interface error |
| 0x02 | ACK_I_INVALID_CMD | Invalid command |
| 0x03 | ACK_I_INVALID_CRC | CRC mismatch |
| 0x04 | ACK_I_VERIFY_ERROR | Verification failed |
| 0x05 | ACK_D_INVALID_COMMAND | Invalid device command |
| 0x06 | ACK_D_COMMAND_FAILED | Device command failed |
| 0x07 | ACK_D_UNKNOWN_ERROR | Unknown device error |
| 0x08 | ACK_I_INVALID_CHANNEL | Invalid channel |
| 0x09 | ACK_I_INVALID_PARAM | Invalid parameter |
| 0x0F | ACK_D_GENERAL_ERROR | General device error |

## FourWay Commands

### Interface Commands

| Command | Code | Description |
|---------|------|-------------|
| CMD_INTERFACE_TEST_ALIVE | 0x30 | Test if ESC is responding |
| CMD_PROTOCOL_GET_VERSION | 0x31 | Get FourWay protocol version |
| CMD_INTERFACE_GET_NAME | 0x32 | Get interface name |
| CMD_INTERFACE_GET_VERSION | 0x33 | Get interface version |
| CMD_INTERFACE_EXIT | 0x34 | Exit FourWay interface |
| CMD_INTERFACE_SET_MODE | 0x3F | Set interface mode |

### Device Commands

| Command | Code | Description |
|---------|------|-------------|
| CMD_DEVICE_RESET | 0x35 | Reset device |
| CMD_DEVICE_INIT_FLASH | 0x37 | Initialize flash access |
| CMD_DEVICE_ERASE_ALL | 0x38 | Erase entire flash |
| CMD_DEVICE_PAGE_ERASE | 0x39 | Erase flash page |
| CMD_DEVICE_READ | 0x3A | Read from flash |
| CMD_DEVICE_WRITE | 0x3B | Write to flash |
| CMD_DEVICE_READ_EEPROM | 0x3D | Read EEPROM |
| CMD_DEVICE_WRITE_EEPROM | 0x3E | Write EEPROM |

## BLHeli_S Protocol

BLHeli_S uses the FourWay protocol for bootloader access but has specific EEPROM layouts and firmware structures.

### EEPROM Layout

BLHeli_S EEPROM is 256 bytes containing firmware settings:

```
Offset  Length  Description
0x00    1       MAIN_REVISION
0x01    1       SUB_REVISION
0x02    1       LAYOUT_REVISION
0x03    1       P_GAIN
0x04    1       I_GAIN
0x05    1       GOVERNOR_MODE
0x06    1       LOW_VOLTAGE_LIMIT
0x07    1       MOTOR_GAIN
...     ...     Additional settings
0x80    16      FIRMWARE_NAME (ASCII)
```

### Firmware Detection

ESC firmware is identified by:
1. EEPROM content analysis
2. Signature scanning for known strings ("JESC", "BLHeli_M", etc.)
3. Version number validation

## Protocol Examples

### Example 1: Interface Test (CMD_INTERFACE_TEST_ALIVE)

**TX Message:**
```
30 00 00 00 00 00 CRC
```
- CMD: 0x30 (CMD_INTERFACE_TEST_ALIVE)
- ADDRESS: 0x00000000
- PARAM_LEN: 0x00
- PARAMS: (none)
- CRC: Calculated checksum

**RX Message (Success):**
```
00 00 00 00 00 00 CRC
```
- ACK: 0x00 (ACK_OK)
- ADDRESS: 0x00000000
- PARAM_LEN: 0x00
- PARAMS: (none)

**RX Message (No Response):**
```
(timeout - ESC not in bootloader mode)
```

### Example 2: Get Protocol Version (CMD_PROTOCOL_GET_VERSION)

**TX Message:**
```
31 00 00 00 00 00 CRC
```

**RX Message:**
```
00 00 00 00 00 02 00 01 CRC
```
- ACK: 0x00 (ACK_OK)
- ADDRESS: 0x00000000
- PARAM_LEN: 0x02
- PARAMS: 0x00 0x01 (version 0.1)
- CRC: Checksum

### Example 3: Initialize Flash (CMD_DEVICE_INIT_FLASH)

**TX Message:**
```
37 00 00 00 00 01 00 CRC
```
- PARAMS: 0x00 (target ESC 0)

**RX Message (Success):**
```
00 00 00 00 00 00 CRC
```

**RX Message (Failure - ESC not ready):**
```
06 00 00 00 00 00 CRC
```
- ACK: 0x06 (ACK_D_COMMAND_FAILED)

### Example 4: Read EEPROM (CMD_DEVICE_READ_EEPROM)

**TX Message:**
```
3D 00 00 00 00 02 00 00 CRC
```
- PARAMS: 0x00 0x00 (address 0, read all 256 bytes)

**RX Message (Success):**
```
00 00 00 00 00 FF [256 bytes EEPROM data] CRC
```
- PARAM_LEN: 0xFF (255 bytes, but actually 256 sent)
- PARAMS: EEPROM data bytes

**EEPROM Data Example (BLHeli_S):**
```
00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
10 11 12 13 14 15 16 17 18 19 1A 1B 1C 1D 1E 1F
...
80 42 4C 48 65 6C 69 5F 53 00 00 00 00 00 00 00  (BLHeli_S name)
...
FF (end of data)
```

### Example 5: Write EEPROM (CMD_DEVICE_WRITE_EEPROM)

**TX Message:**
```
3E 00 00 00 00 [2 + 256 bytes] [address] [data...] CRC
```
- PARAMS: [address_hi] [address_lo] [256 bytes data]

**RX Message (Success):**
```
00 00 00 00 00 00 CRC
```

### Example 6: Get Interface Name (CMD_INTERFACE_GET_NAME)

**TX Message:**
```
32 00 00 00 00 00 CRC
```

**RX Message:**
```
00 00 00 00 00 07 53 69 4C 61 62 73 CRC
```
- PARAMS: "SiLabs" (7 bytes ASCII)

## Timing and Flow Control

### Command Timing
- Minimum 10ms between commands
- EEPROM operations may take 50-200ms
- Flash operations can take several seconds

### Bootloader Entry
ESCs enter bootloader mode through:
1. Power-on with programming pin held low
2. Specific throttle signal sequence
3. Hardware reset with bootloader jumper

### Session Management
```
1. Test alive (CMD_INTERFACE_TEST_ALIVE)
2. Get protocol version (CMD_PROTOCOL_GET_VERSION)
3. Initialize flash (CMD_DEVICE_INIT_FLASH)
4. Perform operations (read/write EEPROM)
5. Exit interface (CMD_INTERFACE_EXIT)
```

## Error Handling

### Common Errors

**ACK_I_INVALID_CMD (0x02):**
- Command not supported by ESC
- Wrong protocol version

**ACK_D_COMMAND_FAILED (0x06):**
- ESC not in bootloader mode
- Flash/EEPROM access denied
- Invalid address

**Timeout/No Response:**
- ESC not powered
- Wrong motor channel
- Wiring issues

### Recovery Procedures

1. **Re-enter bootloader mode**
2. **Check wiring and power**
3. **Verify motor channel selection**
4. **Test with CMD_INTERFACE_TEST_ALIVE**

## Implementation Notes

### Tang9K FPGA Considerations
- Serial passthrough is half-duplex
- UART runs at 115200 baud (USB) / 19200 baud (ESC), 8-N-1
- Motor channel selection via mux register (0x0400)
- Hardware handles TX/RX direction switching

### Python Implementation
The `esc_configurator_emulator.py` script implements:
- FourWay message framing
- CRC calculation
- Timeout handling
- Error recovery

### Hardware Setup
```
Tang9K Motor Pin → ESC Signal Pin
Tang9K GND → ESC GND
ESC Power → Separate power source
```

## Troubleshooting

### No Response from ESC
1. Verify ESC is in bootloader mode
2. Check wiring connections
3. Confirm correct motor channel
4. Test with oscilloscope on signal line

### Invalid CRC Errors
1. Check message formatting
2. Verify CRC calculation
3. Ensure no transmission errors

### Command Failed Errors
1. Confirm ESC supports command
2. Check bootloader mode
3. Verify address ranges
4. Test with simpler commands first

## References

- [BLHeli Source Code](https://github.com/bitdump/BLHeli)
- [ESC Configurator](https://github.com/stylesuxx/esc-configurator)
- BLHeli_S Manual (SiLabs Rev16.x.pdf)
- FourWay Protocol Specification (internal BLHeli documentation)

## Protocol Testbench Coverage

The protocol testbench (`make tb-msp-proto`) exercises:
- All MSP handshake and passthrough commands
- FourWay protocol transition
- BLHeli passthrough and simulated ESC responses
- Error and edge cases (bad checksum, unknown command)

See [TESTBENCH_README.md](TESTBENCH_README.md) for details and usage.