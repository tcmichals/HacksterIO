# Wishbone Master Protocol Walkthrough

## Protocol Overview
The module acts as a bridge between an byte-oriented AXI Stream (from SPI) and a 32-bit Wishbone Bus.
- **Input**: Command (1 Byte) + Address (4 Bytes) + [Data (4 Bytes for Write)]
- **Output**: Immediate ACK (1 Byte) + [Data (4 Bytes for Read) / Status (1 Byte for Write)]

## Write Transaction Example
**Scenario**: Write value `0xCAFEBABE` to Address `0x00000010`.

| Step | Stream | Byte Value | Description |
| :--- | :--- | :--- | :--- |
| 1 | **MOSI** (Cmd) | `0x01` | **Command**: Write |
| 2 | **MISO** (Ack) | `0xA5` | **Response**: Immediate ACK (Wait for this before sending Address) |
| 3 | **MOSI** (Addr) | `0x00` | Address Byte 3 (MSB) |
| 4 | **MOSI** (Addr) | `0x00` | Address Byte 2 |
| 5 | **MOSI** (Addr) | `0x00` | Address Byte 1 |
| 6 | **MOSI** (Addr) | `0x10` | Address Byte 0 (LSB) |
| 7 | **MOSI** (Dum) | `0x00` | Dummy/Turnaround Byte |
| 8 | **MOSI** (Data) | `0xCA` | Data Byte 3 (MSB) |
| 9 | **MOSI** (Data) | `0xFE` | Data Byte 2 |
| 10 | **MOSI** (Data) | `0xBA` | Data Byte 1 |
| 11 | **MOSI** (Data) | `0xBE` | Data Byte 0 (LSB) |
| 12 | **Wait** | ... | Internal Wishbone Transaction Occurs |
| 13 | **MISO** (Sts) | `0x01` | **Response**: Write Complete Status |

**Total MOSI Bytes**: 1 + 4 + 1 + 4 = 10 Bytes.
**Total MISO Bytes**: 1 (Ack) + 1 (Status) = 2 Bytes.

---

## Read Transaction Example
**Scenario**: Read from Address `0x00000010`. Assumes target contains `0xCAFEBABE`.

| Step | Stream | Byte Value | Description |
| :--- | :--- | :--- | :--- |
| 1 | **MOSI** (Cmd) | `0x00` | **Command**: Read |
| 2 | **MISO** (Ack) | `0xA5` | **Response**: Immediate ACK |
| 3 | **MOSI** (Addr) | `0x00` | Address Byte 3 (MSB) |
| 4 | **MOSI** (Addr) | `0x00` | Address Byte 2 |
| 5 | **MOSI** (Addr) | `0x00` | Address Byte 1 |
| 6 | **MOSI** (Addr) | `0x10` | Address Byte 0 (LSB) |
| 7 | **Wait** | ... | Internal Wishbone Transaction Occurs |
| 8 | **MISO** (Dum) | `0x00` | Dummy/Turnaround Byte (Consumed) |
| 9 | **MISO** (Data)| `0xCA` | Data Byte 3 (MSB) |
| 10 | **MISO** (Data)| `0xFE` | Data Byte 2 |
| 11 | **MISO** (Data)| `0xBA` | Data Byte 1 |
| 12 | **MISO** (Data)| `0xBE` | Data Byte 0 (LSB) |

**Total MOSI Bytes**: 1 + 4 + 1 = 6 Bytes.
**Total MISO Bytes**: 1 (Ack) + 4 (Data) = 5 Bytes.

## Burst Write Example (8 Bytes)
**Target**: Write `0xCAFEBABE` and `0xDEADBEEF` to start address `0x10`.
**Length**: 2 Words (8 Bytes).

| Step | Stream | Value | Description |
| :--- | :--- | :--- | :--- |
| 1 | **MOSI** | `0x01` | Command: Write |
| 2 | **MISO** | `0xA5` | **Ack** |
| 3 | **MOSI** | `0x00`..`0x10` | Address (4 Bytes) |
| 4 | **MOSI** | `0x00`, `0x02` | **Length**: 2 Words |
| 5 | **MOSI** | `0x00` | **Dummy** |
| 6 | **MOSI** | `0xCA`, `0xFE`... | Data Word 0 (4 Bytes) |
| 7 | **MOSI** | `0xDE`, `0xAD`... | Data Word 1 (4 Bytes) |
| 8 | **Wait** | ... | Internal Loops |
| 9 | **MISO** | `0x01` | **Status**: Complete |

## Burst Read Example (8 Bytes)
**Target**: Read 2 Words from `0x10`.

| Step | Stream | Value | Description |
| :--- | :--- | :--- | :--- |
| 1 | **MOSI** | `0x00` | Command: Read |
| 2 | **MISO** | `0xA5` | **Ack** |
| 3 | **MOSI** | `0x00`..`0x10` | Address (4 Bytes) |
| 4 | **MOSI** | `0x00`, `0x02` | **Length**: 2 Words |
| 5 | **MOSI** | `0x00` | **Dummy** |
| 6 | **Wait** | ... | Internal Loops |
| 7 | **MISO** | `[Data0]` | 4 Bytes (Word 0) |
| 8 | **MISO** | `[Data1]` | 4 Bytes (Word 1) |

> [!NOTE]
> The SPI Host must send dummy bytes to clock out the 8 bytes of data + any internal latency.


