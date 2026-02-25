# SPI-to-Wishbone Master Design

## Overview

A simplified SPI-to-Wishbone master bridge that provides direct register access over SPI. The protocol uses distinctive byte patterns for easy debugging with a logic analyzer.

## Protocol Bytes

| Code | Binary | Meaning |
|------|--------|---------|
| 0xDA | 11011010 | Sync/Ready/Terminate |
| 0xA1 | 10100001 | Read Request |
| 0xA2 | 10100010 | Write Request |
| 0x21 | 00100001 | Read Response (A1 ^ 0x80) |
| 0x22 | 00100010 | Write Response (A2 ^ 0x80) |
| 0x55 | 01010101 | Pad byte |
| 0xEE | 11101110 | Write acknowledge |

## Endianness

**All multi-byte values are little-endian** (LSB first) - matches RISC-V native byte order.

## Length Constraints

Length must be a multiple of 4 bytes (32-bit word aligned):
- Valid: 4, 8, 12, 16, 20, ...
- Invalid: 1, 2, 3, 5, 6, 7, ...

## Frame Format

SPI is full-duplex and synchronous - TX and RX happen simultaneously. The response is shifted by 1 byte because the slave must pre-load its TX before each transfer.

### Request Frame (Master TX)

| Offset | Field | Size | Description |
|--------|-------|------|-------------|
| 0 | cmd | 1 | 0xA1 (read) or 0xA2 (write) |
| 1-2 | len | 2 | Byte count (LE, must be multiple of 4) |
| 3-6 | addr | 4 | Wishbone address (LE) |
| 7-(7+len-1) | data/pad | len | Write data or 0x55 pad bytes |
| 7+len | term | 1 | 0xDA terminator |

### Response Frame (Master RX) - shifted by 1 byte

| Offset | Field | Size | Description |
|--------|-------|------|-------------|
| 0 | sync | 1 | 0xDA (ready) |
| 1 | resp | 1 | 0x21 (read) or 0x22 (write) |
| 2-3 | len | 2 | Echo of length field |
| 4-7 | addr | 4 | Echo of address field |
| 8-(8+len-1) | data/ack | len | Read data or 0xEE write ack |

## Read Transaction

**4-Byte Read from address 0x00000100 (returns 0xDEADBEEF):**

| Byte | TX | Description | RX | Description |
|------|-----|-------------|-----|-------------|
| 0 | A1 | Read cmd | DA | Slave ready |
| 1 | 04 | Len LSB | 21 | Read response |
| 2 | 00 | Len MSB | 04 | Len echo LSB |
| 3 | 00 | Addr byte 0 | 00 | Len echo MSB |
| 4 | 01 | Addr byte 1 | 00 | Addr echo 0 |
| 5 | 00 | Addr byte 2 | 01 | Addr echo 1 |
| 6 | 00 | Addr byte 3 | 00 | Addr echo 2 |
| 7 | 55 | Pad | 00 | Addr echo 3 |
| 8 | 55 | Pad | EF | Data byte 0 |
| 9 | 55 | Pad | BE | Data byte 1 |
| 10 | 55 | Pad | AD | Data byte 2 |
| 11 | DA | Terminate | DE | Data byte 3 |

**Result: 0xDEADBEEF (little-endian: EF BE AD DE)**

## Write Transaction

**4-Byte Write of 0xDEADBEEF to address 0x00000200:**

| Byte | TX | Description | RX | Description |
|------|-----|-------------|-----|-------------|
| 0 | A2 | Write cmd | DA | Slave ready |
| 1 | 04 | Len LSB | 22 | Write response |
| 2 | 00 | Len MSB | 04 | Len echo LSB |
| 3 | 00 | Addr byte 0 | 00 | Len echo MSB |
| 4 | 02 | Addr byte 1 | 00 | Addr echo 0 |
| 5 | 00 | Addr byte 2 | 02 | Addr echo 1 |
| 6 | 00 | Addr byte 3 | 00 | Addr echo 2 |
| 7 | EF | Data byte 0 | 00 | Addr echo 3 |
| 8 | BE | Data byte 1 | EE | Write ack |
| 9 | AD | Data byte 2 | EE | Write ack |
| 10 | DE | Data byte 3 | EE | Write ack |
| 11 | DA | Terminate | EE | Write ack |

## Error Handling

**Invalid Command (first byte is not 0xA1 or 0xA2):**

| Byte | TX | RX |
|------|-----|-----|
| 0 | ?? | DA |
| 1 | ?? | DA |

If slave receives an invalid command byte, it stays in sync mode and continues echoing 0xDA. The slave ignores the invalid byte and waits for a valid A1/A2 command.

## Burst Transactions

### 8-Byte Read (2 words from 0x100)

| Byte | TX | RX |
|------|-----|-----|
| 0 | A1 | DA |
| 1 | 08 | 21 |
| 2 | 00 | 08 |
| 3 | 00 | 00 |
| 4 | 01 | 00 |
| 5 | 00 | 01 |
| 6 | 00 | 00 |
| 7 | 55 | 00 |
| 8 | 55 | d0 (word0[0]) |
| 9 | 55 | d1 (word0[1]) |
| 10 | 55 | d2 (word0[2]) |
| 11 | 55 | d3 (word0[3]) |
| 12 | 55 | d4 (word1[0]) |
| 13 | 55 | d5 (word1[1]) |
| 14 | 55 | d6 (word1[2]) |
| 15 | DA | d7 (word1[3]) |

## Wishbone Bus Timing

The SPI-to-Wishbone bridge generates Wishbone B3 compliant bus cycles.

### Wishbone Signals

| Signal | Width | Direction | Description |
|--------|-------|-----------|-------------|
| wb_cyc_o | 1 | M→S | Bus cycle active |
| wb_stb_o | 1 | M→S | Strobe (valid transaction) |
| wb_we_o | 1 | M→S | Write enable (1=write, 0=read) |
| wb_adr_o | 32 | M→S | Address |
| wb_dat_o | 32 | M→S | Write data |
| wb_sel_o | 4 | M→S | Byte select (always 0xF) |
| wb_dat_i | 32 | S→M | Read data |
| wb_ack_i | 1 | S→M | Acknowledge |
| wb_err_i | 1 | S→M | Error |

### Read Cycle Timing

```
SPI byte:     | 6   | 7   | 8   | 9   | 10  | 11  |
              | adr | pad | pad | pad | pad | DA  |
              +-----+-----+-----+-----+-----+-----+
                    |     |
                    v     v
         ___________       _______________________
wb_cyc_o            \_____/
         ___________       _______________________
wb_stb_o            \_____/
         _____________________________________________
wb_we_o  (low = read)
         ___________       _______________________
wb_adr_o            \_0x100_/
                          |
                          v wb_ack_i pulse
         _________________   _____________________
wb_dat_i                  \_DEADBEEF_/
```

**Sequence:**
1. Address complete after byte 6
2. Assert wb_cyc_o, wb_stb_o, wb_adr_o
3. Slave responds with wb_ack_i + wb_dat_i
4. Capture data, deassert signals
5. Data appears in RX bytes 8-11

### Write Cycle Timing

```
SPI byte:     | 7   | 8   | 9   | 10  | 11  |
              | d0  | d1  | d2  | d3  | DA  |
              +-----+-----+-----+-----+-----+
                                |     |
                                v     v
         _______________________       ___________
wb_cyc_o                        \_____/
         _______________________       ___________
wb_stb_o                        \_____/
         _______________________       ___________
wb_we_o                         \_____/
         _______________________       ___________
wb_adr_o                        \_0x200_/
         _______________________       ___________
wb_dat_o                        \_DEADBEEF_/
                                      |
                                      v wb_ack_i pulse
```

**Sequence:**
1. Data complete after byte 10
2. Assert wb_cyc_o, wb_stb_o, wb_we_o, wb_adr_o, wb_dat_o
3. Slave responds with wb_ack_i
4. Deassert all signals
5. 0xEE pattern confirms write in RX bytes 8-11

### Burst Timing (2 words)

For burst reads, back-to-back Wishbone cycles occur with auto-incrementing address (+4 per word).

### Timing Constraints

| Parameter | Value | Notes |
|-----------|-------|-------|
| System clock | 72 MHz | ~13.9 ns period |
| SPI clock | 1-10 MHz | 100-1000 ns per bit |
| SPI byte time | 800-8000 ns | 8 bits |
| WB cycle time | ~28-56 ns | 2-4 system clocks |
| WB timeout | 100 clocks | ~1.4 us |

Wishbone cycles complete well within one SPI byte time.

## Design Rationale

- **Distinctive patterns**: 0xDA, 0x55, 0xEE, 0xF5 are easily recognizable on logic analyzer
- **Response XOR**: Simple validation - response = request ^ 0x80
- **Echo fields**: Length and address echoed back for verification
- **0x55 pad**: Alternating bit pattern aids protocol integrity
- **0xEE write ack**: Confirms write completion
- **0xF5 error**: Invalid command detection

## Python Driver Example

```python
import spidev

class WishboneSPI:
    SYNC = 0xDA
    CMD_READ = 0xA1
    CMD_WRITE = 0xA2
    RESP_READ = 0x21
    RESP_WRITE = 0x22
    PAD = 0x55
    WRITE_ACK = 0xEE
    ERR_INVALID = 0xF5
    
    def __init__(self, bus=0, device=0, speed_hz=1000000):
        self.spi = spidev.SpiDev()
        self.spi.open(bus, device)
        self.spi.max_speed_hz = speed_hz
        self.spi.mode = 0
    
    def read(self, addr, length=4):
        """Read 'length' bytes (must be multiple of 4)."""
        assert length % 4 == 0, "Length must be multiple of 4"
        
        # Build TX: cmd + len(2B LE) + addr(4B LE) + pad(length) + DA
        tx = [self.CMD_READ]
        tx += [length & 0xFF, (length >> 8) & 0xFF]
        tx += [addr & 0xFF, (addr >> 8) & 0xFF, 
               (addr >> 16) & 0xFF, (addr >> 24) & 0xFF]
        tx += [self.PAD] * length
        tx += [self.SYNC]
        
        rx = self.spi.xfer2(tx)
        
        # Check for errors
        assert rx[0] == self.SYNC, f"Expected DA, got {rx[0]:02X}"
        if rx[1] == self.ERR_INVALID:
            raise ValueError("Invalid command error (0xF5)")
        assert rx[1] == self.RESP_READ, f"Expected 21, got {rx[1]:02X}"
        
        return bytes(rx[8:8+length])
    
    def write(self, addr, data):
        """Write 'data' bytes (must be multiple of 4)."""
        length = len(data)
        assert length % 4 == 0, "Length must be multiple of 4"
        
        # Build TX: cmd + len(2B LE) + addr(4B LE) + data + DA
        tx = [self.CMD_WRITE]
        tx += [length & 0xFF, (length >> 8) & 0xFF]
        tx += [addr & 0xFF, (addr >> 8) & 0xFF,
               (addr >> 16) & 0xFF, (addr >> 24) & 0xFF]
        tx += list(data)
        tx += [self.SYNC]
        
        rx = self.spi.xfer2(tx)
        
        # Check for errors
        assert rx[0] == self.SYNC, f"Expected DA, got {rx[0]:02X}"
        if rx[1] == self.ERR_INVALID:
            raise ValueError("Invalid command error (0xF5)")
        assert rx[1] == self.RESP_WRITE, f"Expected 22, got {rx[1]:02X}"
        
        # Verify write ack pattern
        for i in range(8, 8 + length):
            assert rx[i] == self.WRITE_ACK, f"Expected EE at byte {i}"
        
        return True
```

## RTL Implementation Notes

```systemverilog
localparam SYNC_BYTE    = 8'hDA;  // Frame sync/ready/terminate
localparam CMD_READ     = 8'hA1;  // Read request
localparam CMD_WRITE    = 8'hA2;  // Write request  
localparam RESP_READ    = 8'h21;  // Read response (CMD_READ ^ 0x80)
localparam RESP_WRITE   = 8'h22;  // Write response (CMD_WRITE ^ 0x80)
localparam PAD_BYTE     = 8'h55;  // Pad byte
localparam WRITE_ACK    = 8'hEE;  // Write acknowledge
localparam ERR_INVALID  = 8'hF5;  // Invalid command error
```

Field parsing order: **cmd → length → address**
