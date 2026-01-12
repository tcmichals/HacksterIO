# busMaster Architecture Diagram

## System Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          EXTERNAL INTERFACES                             │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│   SPI Master              Serial Master         Wishbone Slave           │
│   (e.g., μC)              (e.g., UART)          (e.g., Memory/IP)       │
│        │                        │                      │                 │
│        ▼                        ▼                      ▼                 │
│   ┌─────────────┐          ┌─────────────┐      ┌──────────────┐       │
│   │  SPI Slave  │          │ UART RX/TX  │      │ Wishbone     │       │
│   │  (CS, CLK,  │          │ (RX, TX)    │      │ Slave Port   │       │
│   │   MOSI,     │          │             │      │ (CYC, STB,   │       │
│   │   MISO)     │          │             │      │  ACK, etc)   │       │
│   └─────┬───────┘          └─────┬───────┘      └──────▲───────┘       │
│         │                        │                     │                 │
└─────────┼────────────────────────┼─────────────────────┼─────────────────┘
          │                        │                     │
          │                        │                     │
┌─────────▼─────────────────────────▼──────────────────────────────────────┐
│                        PROTOCOL BRIDGES (FPGA)                            │
├───────────────────────────────────────────────────────────────────────────┤
│                                                                            │
│  ┌──────────────────────┐         ┌──────────────────────┐               │
│  │ spi_axis_bridge.sv   │         │serial_axis_bridge.sv │               │
│  ├──────────────────────┤         ├──────────────────────┤               │
│  │ • SPI Clock Sync     │         │ • UART Receiver      │               │
│  │ • MOSI Shift Reg     │         │ • Async Clock Sync   │               │
│  │ • MISO Shift Reg     │         │ • Baud Rate Support  │               │
│  │ • 8-entry Async FIFO │         │ • Frame Termination  │               │
│  │ • CS Edge Detection  │         │ • Break Byte (0xFF)  │               │
│  │ • CDC with Gray Code │         │ • Configurable Rate  │               │
│  └─────────┬────────────┘         └────────┬─────────────┘               │
│            │                               │                              │
│            │  M_AXIS (MOSI → Wishbone)    │  M_AXIS (RX → Wishbone)    │
│            │  (TDATA, TVALID, TLAST,      │  (TDATA, TVALID, TLAST,    │
│            │   TREADY)                     │   TREADY)                   │
│            │                               │                              │
│            └───────────────┬────────────────┘                             │
│                            │                                              │
│                            │ AXIS Multiplexing                            │
│                            │ (frame-based selection)                      │
│                            │                                              │
│            ┌───────────────▼────────────────┐                             │
│            │  wishbone_master_axis.sv       │                             │
│            ├────────────────────────────────┤                             │
│            │ • AXIS Input Demux             │                             │
│            │ • Wishbone State Machine       │                             │
│            │ • Timeout Protection           │                             │
│            │ • Error Handling               │                             │
│            │ • Back-pressure Management     │                             │
│            │ • Frame Boundary Detection     │                             │
│            │ • Multi-cycle Transactions     │                             │
│            └───────────────┬────────────────┘                             │
│                            │                                              │
│            ┌───────────────▼────────────────┐                             │
│            │  Wishbone Master Output        │                             │
│            │  (CYC, STB, WE, ADR, DAT_O,  │                             │
│            │   SEL, ACK, DAT_I, ERR)       │                             │
│            └────────────────────────────────┘                             │
│                                                                            │
└────────────────────────────────────────────────────────────────────────────┘
```

## Data Flow: Frame-Based Processing

### Frame 1: SPI Write Command
```
SPI Master                 spi_axis_bridge              wishbone_master_axis
    │                            │                              │
    │ CS=0, sends command        │                              │
    ├─────────────────────────────►                              │
    │ (MOSI: 0x01 0x1000 0xFF)   │                              │
    │                            │ Constructs AXIS frame        │
    │                            ├─ TDATA=0x01, TVALID          │
    │                            ├─ TDATA=0x10, TVALID          │
    │                            ├─ TDATA=0x00, TVALID          │
    │                            ├─ TDATA=0xFF, TLAST, TVALID   │
    │                            │                              │
    │                            └──────────────────────────────►
    │                                                  Decodes as:
    │                                                  • Command: WRITE
    │                                                  • Address: 0x1000
    │                                                  • Data: 0xFF
    │ CS=1 (falling edge)        │                              │
    │                            │                   Issues WB transaction:
    │                            │                   CYC=1, STB=1, WE=1
    │ (MISO: response bytes)     │                   ADR=0x1000
    │◄─────────────────────────────────────────────  DAT_O=0xFF
    │                            │                   Waits for ACK
    │                            │                   Returns ACK + response
    │ CS=0, next frame           │                   via MISO path
```

### Frame 2: Serial Read Command
```
Serial Master              serial_axis_bridge          wishbone_master_axis
    │                            │                              │
    │ Sends bytes at 115200 baud:│                              │
    ├─ 0x00 (READ)              │                              │
    ├─ 0x2000 (Address High)     │                              │
    ├─ 0x00 (Address Low)        │                              │
    ├─ 0xFF (Frame Terminator)   │                              │
    │                            │ Constructs AXIS frame        │
    │                            ├─ TDATA=0x00, TVALID          │
    │                            ├─ TDATA=0x20, TVALID          │
    │                            ├─ TDATA=0x00, TVALID          │
    │                            ├─ TDATA=0xFF, TLAST, TVALID   │
    │                            │                              │
    │                            └──────────────────────────────►
    │                                                  Decodes as:
    │                                                  • Command: READ
    │                                                  • Address: 0x2000
    │                                                  • Data: (read from WB)
    │                            │                              │
    │                            │                   Issues WB transaction:
    │                            │                   CYC=1, STB=1, WE=0
    │                            │                   ADR=0x2000
    │                            │                   Waits for ACK + DAT_I
    │                            │                              │
    │ Reads response bytes:      │                   Returns read data
    │◄─────────────────────────────────────────────  via TX path
    ├─ Status byte              │                   Frames response bytes
    ├─ Data high                │                   Sends back to Serial
    ├─ Data low                 │
```

## Clock Domain Separation

```
┌──────────────────────────┐
│   SPI Clock Domain       │
│  (spi_clk from master)   │
│                          │
│  • MOSI shift register   │
│  • MISO shift register   │
│  • Bit counting          │
│  • CS edge detection     │
│                          │
│  (SPI ops at up to 100MHz) Fast
└────────────┬─────────────┘
             │
             │ 2-FF Synchronizers
             │ Gray Code FIFO
             │ Edge Detection
             │
             ▼
┌──────────────────────────┐
│   System Clock Domain    │
│  (clk from FPGA)         │
│                          │
│  • AXIS Multiplexing     │
│  • Wishbone FSM          │
│  • Timeout Counters      │
│  • Flow Control Logic    │
│                          │
│  (Main ops at ~100MHz)   Synced
└──────────────────────────┘
```

## AXIS Protocol Between Bridges

```
Master (spi/serial bridge)                  Slave (wishbone_master_axis)
      │                                              │
      │ TVALID=1, TDATA=0x01 (Command)              │
      ├─────────────────────────────────────────────►
      │                                   TREADY=1
      │
      │ TVALID=1, TDATA=0x10 (Addr Hi)              │
      ├─────────────────────────────────────────────►
      │                                   TREADY=1
      │
      │ TVALID=1, TDATA=0x00 (Addr Lo)              │
      ├─────────────────────────────────────────────►
      │                                   TREADY=1
      │
      │ TVALID=1, TDATA=0xFF (Data), TLAST=1        │
      ├─────────────────────────────────────────────► Frame End
      │                                   TREADY=1
      │
      │ TVALID=0 (Wait)                             │
      │◄─────────────────────────────────────────────┤ Processing WB
      │                                              │ Transaction
      │ TVALID=0 (Still waiting)                    │
      │                                              │
      │                                   Ready for │
      │ TVALID=1, TDATA=0xAA (Response)             │
      │◄─────────────────────────────────────────────┤ (if S_AXIS)
      │
```

## Key Signal Paths

### SPI Path: MOSI → Wishbone Write
```
MOSI Bit Stream
    │
    ▼
┌──────────────────────┐
│ MOSI Shift Register  │ (Captures 8 bits)
│ (mosi_shift_reg)     │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│  Async FIFO (8-entry)│ (CDC with Gray codes)
│  (mosi_fifo)         │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ M_AXIS Output        │ TDATA, TVALID, TLAST
│ (m_axis_tdata)       │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ Wishbone FSM         │ Collects frame bytes
│ (wishbone_master_)   │ Decodes command
│ (axis.sv)            │ Issues WB transaction
└──────────┬───────────┘
           │
           ▼
    Wishbone Bus
    (CYC, STB, WE, ADR, DAT_O)
```

### Wishbone Path: Response → MISO
```
Wishbone Bus
(DAT_I, ACK)
    │
    ▼
┌──────────────────────┐
│ Wishbone FSM         │ Receives WB response
│ (response buffering) │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ S_AXIS Input         │ TDATA, TVALID, TLAST
│ (s_axis_tdata)       │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ MISO Shift Register  │ Serializes response
│ (miso_shift_reg)     │ Shifts out MSB first
└──────────┬───────────┘
           │
           ▼
   MISO Bit Stream
   (to SPI Master)
```

## Module Dependencies

```
┌────────────────────────────────────────────────────────┐
│                  Top-Level Integration                │
├────────────────────────────────────────────────────────┤
│                                                        │
│   ┌─────────────────────────────────────────────┐     │
│   │   spi_axis_bridge.sv                        │     │
│   ├─────────────────────────────────────────────┤     │
│   │ Contains:                                   │     │
│   │  • spi_async_fifo (FIFO module)            │     │
│   │  • Synchronizers                           │     │
│   └────────────────┬────────────────────────────┘     │
│                    │                                   │
│                    │ M_AXIS output                     │
│                    │                                   │
│   ┌────────────────┴────────────────────────────┐     │
│   │   serial_axis_bridge.sv                     │     │
│   ├─────────────────────────────────────────────┤     │
│   │ (No embedded submodules)                    │     │
│   │ Integrates UART RX logic inline            │     │
│   └────────────────┬────────────────────────────┘     │
│                    │                                   │
│                    │ M_AXIS output                     │
│                    │                                   │
│   ┌────────────────▼────────────────────────────┐     │
│   │   wishbone_master_axis.sv                   │     │
│   ├─────────────────────────────────────────────┤     │
│   │ • Receives AXIS from both bridges           │     │
│   │ • Multiplexes based on frame boundaries    │     │
│   │ • Drives Wishbone master output            │     │
│   │ • No external submodules                   │     │
│   └─────────────────────────────────────────────┘     │
│                                                        │
└────────────────────────────────────────────────────────┘
```

## Error/Timeout Flow

```
Protocol Bridge                  Wishbone Master
      │                                │
      │ Frame received (TLAST)         │
      └───────────────────────────────►│
                                       │
                        Timeout Counter Starts
                        (Waits for WB ACK)
                        │
                        ├─ Increments each clock
                        ├─ Compares to TIMEOUT_CYCLES
                        │
                        ▼
                 WB Slave Responds (ACK=1)?
                 │
        ┌────────┴────────┐
        │ YES             │ NO
        ▼                 ▼
    Set ACK           Timeout?
    Return to         │
    Protocol          ├─ YES: Set ERROR flag
    (MISO)            │       Return to Protocol
                      │       (with error status)
                      │
                      └─ NO: Keep waiting
```

## Integration Example

```
System with Multiple Interfaces:

    ┌─────────────────────────────────────────────────┐
    │                  Microcontroller                │
    │  (SPI Master + UART Master + Wishbone Slave)    │
    ├──────────────────┬──────────────────────────────┤
    │                  │                              │
    │   SPI Interface  │  UART Interface   WB Slave   │
    │   (CLK, MOSI,    │  (TX, RX)         (Port)     │
    │    MISO, CS)     │                              │
    └────────┬─────────┴──────────────┬───────────────┘
             │                        │
             │                        │
    ┌────────▼────────────────────────▼───────────────┐
    │              FPGA (busMaster)                    │
    │                                                  │
    │  SPI Slave → AXIS ┐                             │
    │                   ├─► Wishbone Master ──────┐   │
    │  Serial Slave → AXIS ┘                      │   │
    │                                              │   │
    │                                         Wishbone │
    │                                         Slave    │
    │                    ┌────────────────────────┘    │
    │                    │                             │
    │  ┌────────────────▼─────────────────┐           │
    │  │  On-Chip Peripherals/Memory      │           │
    │  │  • SRAM (0x0000-0x7FFF)         │           │
    │  │  • Registers (0x8000-0xFFFF)    │           │
    │  │  • Control/Status (via WB)      │           │
    │  └──────────────────────────────────┘           │
    │                                                  │
    └──────────────────────────────────────────────────┘
```

## Performance Characteristics

```
┌───────────────────────────────────────────────────────────┐
│         Throughput & Latency by Protocol                 │
├───────────────────────────────────────────────────────────┤
│                                                           │
│ SPI (10 MHz):                                             │
│   • Byte time: 0.8 μs (8 bits @ 10 MHz)                 │
│   • 4-byte frame: 3.2 μs                                 │
│   • WB cycles: 4-8 (typical)                             │
│   • Throughput: ~312 KB/s (max)                          │
│                                                           │
│ Serial (115200 baud):                                     │
│   • Byte time: 86.8 μs (10 bits @ 115200)               │
│   • 4-byte frame: 347 μs                                 │
│   • WB cycles: 4-8 (typical)                             │
│   • Throughput: ~3.3 KB/s (max)                          │
│                                                           │
│ Wishbone (100 MHz):                                       │
│   • Min cycles per transaction: 4                         │
│   • Timeout: 65536 cycles (655 μs)                       │
│   • Error recovery: 1 cycle assert                        │
│                                                           │
└───────────────────────────────────────────────────────────┘
```

## Summary

**busMaster** provides a flexible multi-protocol bridge system:

1. **Input Protocols**: SPI Slave + Serial Slave (independent)
2. **Transport Layer**: AXI Stream (AXIS) for protocol adaptation
3. **Output Protocol**: Wishbone Master for standard SoC integration
4. **Key Features**:
   - Clock domain crossing with proper CDC
   - Buffering (SPI) and flow control (AXIS)
   - Timeout protection on Wishbone transactions
   - Frame-based command/response demultiplexing
   - Error handling and reporting

This architecture decouples protocol handling from bus transactions, making it easy to add new input protocols or change the output bus interface.
