# AXI Stream to Wishbone Bridge Protocol

## 1. Physical Layer & Signals
*   **Interface**: SPI (converted to AXI Stream).
*   **CS (Chip Select)**: Must be asserted (Low) for the **entire duration** of the frame (Command Header + Data + Status).
    *   Deasserting CS resets the FSM (if `s_axis_tlast` is mapped to CS).
*   **AXI Stream TLAST**:
    *   **RX (MOSI -> Core)**: An assertion of `s_axis_tlast` resets the internal FSM to IDLE.
    *   **TX (Core -> MISO)**: The Core asserts `m_axis_tlast` on the very last byte of the response (Data or Status).

## 2. Packet Structure
All multi-byte fields are **Big Endian**.

### 2.1 Command Header (7 Bytes)
Every transaction starts with a 7-byte header from the Host (MOSI).

| Byte | Field | Description |
| :--- | :--- | :--- |
| 0 | **Command** | `0x00`=Read, `0x01`=Write |
| 1 | **Addr[31:24]** | Address MSB |
| 2 | **Addr[23:16]** | |
| 3 | **Addr[15:8]** | |
| 4 | **Addr[7:0]** | Address LSB (Must be 4-byte aligned) |
| 5 | **Len[15:8]** | Length MSB (Count of 32-bit Words) |
| 6 | **Len[7:0]** | Length LSB. `0x0001` = 4 Bytes. |
| 7 | **Dummy** | 1 Byte | **Turnaround Byte**. Host sends `0x00`. Device ignores. |
| 8 | **Data** | N * 4 Bytes | Write Data Payloads (Only for Write Command). |

### 2.2 Response (MISO)
The Device sends data back on the MISO line.
*   **Immediate ACK**: The device sends `0xA5` immediately after receiving the Command Byte. This usually overlaps with the Host sending Address Byte 0.

## 3. Detailed Transaction Flows
The SPI interface is full-duplex. The tables below show the simultaneous state of MOSI and MISO lines.

### 3.1 Write Transaction
**Goal**: Write `2` Words (8 Bytes) to Address `0x1000`. `Len = 2`.

| Cycle | Host (MOSI) Sends | Device (MISO) Returns | Notes |
| :--- | :--- | :--- | :--- |
| **0** | `0x01` (Cmd Write) | *(Previous/Idle)* | Host starts transaction |
| **1** | `0x00` (Addr MSB) | `0xA5` (ACK) | Device acknowledges Cmd |
| **2** | `0x00` | `0x00` | |
| **3** | `0x10` | `0x00` | |
| **4** | `0x00` (Addr LSB) | `0x00` | |
| **5** | `0x00` (Len MSB) | `0x00` | |
| **6** | `0x02` (Len LSB) | `0x00` | Header Complete |
| **7** | `0x00` (Dummy) | `0x00` | Turnaround |
| **8** | `0xDD` (Data0 B3) | `0x00` | Host sends Data Word 0 |
| **8** | `0xAA` (Data0 B2) | `0x00` | |
| **9** | `0xBB` (Data0 B1) | `0x00` | |
| **10** | `0xCC` (Data0 B0) | `0x00` | |
| **11** | `0x11` (Data1 B3) | `0x00` | Host sends Data Word 1 |
| **12** | `0x22` (Data1 B2) | `0x00` | |
| **13** | `0x33` (Data1 B1) | `0x00` | |
| **14** | `0x44` (Data1 B0) | `0x00` | Data Complete |
| **15** | `0x00` (Dummy) | `0x01` (Status) | **Host must clock 1 extra byte for status** |

**Total Bytes exchanged**: 7 (Header) + 1 (Dummy) + 8 (Data) + 1 (Status) = **17 Bytes**.

---

### 3.2 Read Transaction
**Goal**: Read `1` Word (4 Bytes) from Address `0x2000`. `Len = 1`.

| Cycle | Host (MOSI) Sends | Device (MISO) Returns | Notes |
| :--- | :--- | :--- | :--- |
| **0** | `0x00` (Cmd Read) | *(Previous/Idle)* | Host starts transaction |
| **1** | `0x00` (Addr MSB) | `0xA5` (ACK) | Device acknowledges Cmd |
| **2** | `0x00` | `0x00` | |
| **3** | `0x20` | `0x00` | |
| **4** | `0x00` (Addr LSB) | `0x00` | |
| **5** | `0x00` (Len MSB) | `0x00` | |
| **6** | `0x01` (Len LSB) | `0x00` | Header Complete. Device starts Read. |
| **7** | `0x00` (Dummy) | `0x00` | Turnaround |
| **8** | `0x00` (Dummy) | `0xRR` (Data B3) | Device returns Data MSB |
| **8** | `0x00` (Dummy) | `0xRR` (Data B2) | |
| **9** | `0x00` (Dummy) | `0xRR` (Data B1) | |
| **10** | `0x00` (Dummy) | `0xRR` (Data B0) | Device returns Data LSB |

**Total Bytes exchanged**: 7 (Header) + 1 (Dummy) + 4 (Data) = **12 Bytes**.

> [!IMPORTANT]
> **Latency**: If the Wishbone bus is slow, the Device might not have data ready by Cycle 7.
> The AXI Stream Master will assert `TVALID` only when data is ready.
> **SPI Bridge Handling**: The SPI Bridge must handle flow control (Clock Stretching if supported, or ensuring Bus is fast enough). If the Bridge simply clocks dummy bytes regardless of `TVALID`, invalid data (Underflow) may be read.
> *Recommendation*: Ensure Wishbone target is zero-wait-state or use a Bridge with "Wait for TVALID" support.

## 4. Pure AXI Stream Implementation View
If interacting directly via AXIS (bypassing SPI), the signal behavior is as follows:

### 4.1 Write Transaction (S_AXIS Input)
**Packet**: `[CMD] [ADDR...4] [LEN...2] [DATA.......N*4]`

| Beat | TDATA | TLAST | Description |
| :--- | :--- | :--- | :--- |
| 0 | `0x01` | 0 | Command Write |
| 1 | `0x00` | 0 | Addr 3 |
| 2 | `0x00` | 0 | Addr 2 |
| 3 | `0x00` | 0 | Addr 1 |
| 4 | `0x10` | 0 | Addr 0 |
| 5 | `0x00` | 0 | Len 1 |
| 6 | `0x02` | 0 | Len 0 (2 Words) |
| 7 | `0x00` | 0 | Dummy |
| 8 | `0xCA` | 0 | Data0 B3 |
| ... | ... | ... | ... |
| 14 | `0x44` | 1 | Data1 B0 (Last Byte) |
> TLAST is optional on input but good practice.

## 5. Latency & No Clock Stretching Support
**Constraint**: The SPI Slave (Device) **cannot** stretch the clock (hold SCL low) to pause the Host.
**Implication**: If the Wishbone Bus takes longer to respond than the time between the *Length LSB* and the *First Data Byte*, the SPI MISO line will likely transmit undefined data (Underflow) or zeros.

### Mitigation Strategies
1.  **Guaranteed Fast Access**: Ensure the target Wishbone Slave (e.g., BRAM) has zero wait states and the SPI Clock is sufficiently slow.
2.  **Host-Side Delay**: The SPI Host (Master) should insert a **Software Delay** (pause SCK activity) between sending the `Length` and clocking the `Data` if the target is slow.
    *   Sequence: `[Header]` -> **[Pause/Wait N us]** -> `[Clock Data]`.
3.  **Polling (Future Enhancement)**: If latency is highly variable, an explicit "Poll for Ready" token could be added to the protocol, but currently **Timing Access** is assumed.


### 4.2 Write Transaction Response (M_AXIS Output)
**Packet**: `[ACK] [STATUS]`

| Beat | TDATA | TLAST | Description |
| :--- | :--- | :--- | :--- |
| 0 | `0xA5` | 0 | Immediate Ack (Valid approx Beat 1 of Input) |
| 1 | `0x01` | 1 | Status (Valid after Beat 14 processing) |

### 4.3 Read Transaction Response (M_AXIS Output)
**Packet**: `[ACK] [DATA.........N*4]`

| Beat | TDATA | TLAST | Description |
| :--- | :--- | :--- | :--- |
| 0 | `0xA5` | 0 | Immediate Ack |
| 1 | `0xAA` | 0 | Data0 B3 |
| ... | ... | ... | ... |
| 8 | `0xDD` | 1 | Data1 B0 (Last Byte) |

