# SPI and Serial AXIS Bridges - Implementation Summary

## 📦 Deliverables

Three complete SystemVerilog implementations with separate testbenches:

### 1. SPI AXIS Bridge (`spi_axis_bridge.sv` - 12 KB)
**Hardware Bridge:** SPI Slave → AXI Stream Master

Features:
- ✅ Full-duplex SPI slave interface (MOSI, MISO, CS, CLK)
- ✅ Clock domain crossing (CDC) with async FIFO
- ✅ CS falling edge triggers frame termination (TLAST)
- ✅ 8-entry async FIFO for MOSI buffering
- ✅ Gray code synchronizers for CDC safety
- ✅ Supports simultaneous MOSI/MISO operation

**Internal Modules:**
- `spi_axis_bridge` (main module, 290 lines)
- `spi_async_fifo` (8-entry async FIFO, 100 lines)

### 2. Serial AXIS Bridge (`serial_axis_bridge.sv` - 7.5 KB)
**Hardware Bridge:** UART RX → AXI Stream Master

Features:
- ✅ Standard async UART receiver (1 start, 8 data LSB-first, 1 stop)
- ✅ Metastability protection with dual-stage synchronizer
- ✅ Configurable baud rate (9600 to 460800)
- ✅ Frame termination on 0xFF break byte (TLAST)
- ✅ Parameterizable clock frequency and baud rate
- ✅ No flow control (assumes host is slow or buffered)

**State Machine:**
- RX_IDLE → RX_START → RX_DATA → RX_STOP → RX_DONE → RX_IDLE

---

## 🧪 Testbenches

### SPI Testbench (`tb_spi_axis_bridge.sv` - 8.4 KB)
**Tests:**
1. ✓ Single MOSI byte transfer
2. ✓ Full-duplex simultaneous MOSI/MISO operation
3. ✓ Frame termination with CS falling edge
4. ✓ Back-to-back transfers with CS toggle
5. ✓ Flow control (TREADY=0 buffering in FIFO)

**Compilation:**
```bash
iverilog -g2009 -o spi_tb.vvp spi_axis_bridge.sv tb_spi_axis_bridge.sv
vvp spi_tb.vvp
```

**Expected Output:**
```
=== Test 1: Simple MOSI Byte Transfer ===
MOSI byte received: 0x01
✓ MOSI byte correct

=== Test 2: MOSI Address Bytes + MISO Response ===
✓ Full-duplex simultaneous transfer completed

=== Test 3: Frame Termination with CS ===
✓ TLAST asserted on CS falling edge
...
```

### Serial Testbench (`tb_serial_axis_bridge.sv` - 9.0 KB)
**Tests:**
1. ✓ Single byte reception (0x42)
2. ✓ Multi-byte command header sequence
3. ✓ Data payload reception
4. ✓ Break byte (0xFF) frame termination and TLAST
5. ✓ Back-to-back frames
6. ✓ Flow control with TREADY=0

**Compilation:**
```bash
iverilog -g2009 -o serial_tb.vvp serial_axis_bridge.sv tb_serial_axis_bridge.sv
vvp serial_tb.vvp
```

**Expected Output:**
```
=== Test 1: Single Byte Reception (0x42) ===
✓ Byte 0x42 received correctly

=== Test 2: Command Header Sequence ===
Sending command byte: 0x01 (Write)
✓ Command byte OK
Sending address: 0x00002000
✓ Addr[31:24] = 0x00
...
```

---

## 🔌 Interface Specifications

### SPI Bridge Pinout
```
Module spi_axis_bridge
├─ Input
│  ├─ clk                    (system clock)
│  ├─ rst_n                  (active low reset)
│  ├─ spi_clk                (SPI clock, async)
│  ├─ spi_mosi               (Master Out Slave In)
│  ├─ spi_cs_n               (Chip Select, active low)
│  ├─ m_axis_tready          (downstream ready)
│  ├─ s_axis_tdata[7:0]      (response byte from Wishbone)
│  ├─ s_axis_tvalid          (response valid)
│  └─ s_axis_tlast           (response last byte)
└─ Output
   ├─ spi_miso               (Master In Slave Out)
   ├─ m_axis_tdata[7:0]      (command byte to Wishbone)
   ├─ m_axis_tvalid          (command valid)
   ├─ m_axis_tlast           (command last byte, CS falling)
   └─ s_axis_tready          (ready for response)
```

### Serial Bridge Pinout
```
Module serial_axis_bridge
├─ Input
│  ├─ clk                    (system clock)
│  ├─ rst_n                  (active low reset)
│  ├─ uart_rx                (serial RX line)
│  └─ m_axis_tready          (downstream ready)
└─ Output
   ├─ m_axis_tdata[7:0]      (received byte)
   ├─ m_axis_tvalid          (byte valid)
   └─ m_axis_tlast           (last byte, 0xFF break byte)
```

---

## 📊 Design Details

### SPI Bridge Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                 spi_axis_bridge                             │
│                                                             │
│  CDC Synchronizers                  Shift Registers        │
│  ┌──────────┐  ┌──────┐            ┌──────────┐           │
│  │spi_clk   │→→│Edge  │            │MOSI_SHIFT│           │
│  │Sync[1:2] │  │Detect│            │[7:0]     │           │
│  └──────────┘  └──────┘            └──────────┘           │
│                                                             │
│  ┌──────────┐  ┌──────┐            ┌──────────┐           │
│  │spi_cs_n  │→→│Edge  │            │MISO_SHIFT│           │
│  │Sync[1:2] │  │Detect│            │[7:0]     │           │
│  └──────────┘  └──────┘            └──────────┘           │
│                                                             │
│              Async FIFO (CDC)                              │
│  ┌────────────────────────────────┐                       │
│  │ 8-entry Gray-code FIFO         │                       │
│  │ spi_clk domain → sys_clk domain│                       │
│  │ MOSI bytes buffering           │                       │
│  └────────────────────────────────┘                       │
│         │                                                   │
│         └→ M_AXIS: MOSI → Wishbone                        │
│                                                             │
│  S_AXIS: Response ← Wishbone                              │
│         │                                                   │
│         └→ MISO_SHIFT[7:0] → spi_miso                    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Clock Domains:**
- `spi_clk` domain: MOSI/MISO shift registers, bit counters
- `clk` domain: FIFO, AXIS interface, CDC synchronizers

### Serial Bridge Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                 serial_axis_bridge                          │
│                                                             │
│  Input CDC                                                  │
│  ┌──────────────┐                                          │
│  │uart_rx       │→→→ uart_rx_sync2                         │
│  │  Sync[1:2]   │  (metastability safe)                    │
│  └──────────────┘                                          │
│                                                             │
│  Baud Rate Counter                                          │
│  ┌──────────────┐                                          │
│  │baud_counter  │ ticks = BAUD_COUNTER_MAX / CLK_FREQ     │
│  │[31:0]        │ (87 ticks/bit @ 100MHz, 115200 baud)    │
│  └──────────────┘                                          │
│                                                             │
│  RX State Machine                                           │
│  ┌──────────────────────────────┐                         │
│  │ RX_IDLE                      │                         │
│  │  └→ RX_START (start bit)     │                         │
│  │      └→ RX_DATA (8 bits)     │                         │
│  │          └→ RX_STOP (stop)   │                         │
│  │              └→ RX_DONE      │                         │
│  │                 └→ RX_IDLE   │                         │
│  └──────────────────────────────┘                         │
│                                                             │
│  Shift Register                                            │
│  ┌──────────┐                                             │
│  │rx_shift  │ ← uart_rx_sync2 (MSB to LSB)               │
│  │[7:0]     │                                             │
│  └──────────┘                                             │
│       │                                                    │
│       └→ M_AXIS: TDATA                                    │
│            TVALID = (rx_state == RX_DONE)                │
│            TLAST = (TDATA == 0xFF)                       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Key Timing:**
- Start bit: sampled at 1.5× bit time for noise immunity
- Data bits: sampled once per bit time
- Stop bit: sampled once, then waits for next byte

---

## 🚀 Quick Integration Example

### System with Both Bridges

```systemverilog
// Wishbone master (the main bridge)
wishbone_master_axis wb_bridge (
    .clk(clk), .rst_n(rst_n),
    .s_axis_tdata(cmd_tdata),
    .s_axis_tvalid(cmd_tvalid),
    .s_axis_tready(cmd_tready),
    .s_axis_tlast(cmd_tlast),
    .m_axis_tdata(resp_tdata),
    .m_axis_tvalid(resp_tvalid),
    .m_axis_tready(resp_tready),
    .m_axis_tlast(resp_tlast),
    // ... Wishbone output signals ...
);

// SPI bridge
spi_axis_bridge spi_br (
    .clk(clk), .rst_n(rst_n),
    .spi_clk(spi_clk), .spi_mosi(spi_mosi),
    .spi_miso(spi_miso), .spi_cs_n(spi_cs_n),
    .m_axis_tdata(spi_cmd_tdata),
    .m_axis_tvalid(spi_cmd_tvalid),
    .m_axis_tready(spi_cmd_tready),
    .m_axis_tlast(spi_cmd_tlast),
    .s_axis_tdata(spi_resp_tdata),
    .s_axis_tvalid(spi_resp_tvalid),
    .s_axis_tready(spi_resp_tready),
    .s_axis_tlast(spi_resp_tlast)
);

// Serial bridge
serial_axis_bridge #(.BAUD_RATE(115200)) serial_br (
    .clk(clk), .rst_n(rst_n),
    .uart_rx(uart_rx),
    .m_axis_tdata(serial_cmd_tdata),
    .m_axis_tvalid(serial_cmd_tvalid),
    .m_axis_tready(serial_cmd_tready),
    .m_axis_tlast(serial_cmd_tlast)
);

// Protocol selection (assuming SPI has priority)
assign cmd_tdata = spi_cmd_tvalid ? spi_cmd_tdata : serial_cmd_tdata;
assign cmd_tvalid = spi_cmd_tvalid | serial_cmd_tvalid;
assign spi_cmd_tready = cmd_tready & spi_cmd_tvalid;
assign serial_cmd_tready = cmd_tready & ~spi_cmd_tvalid;
assign cmd_tlast = spi_cmd_valid ? spi_cmd_tlast : serial_cmd_tlast;

// Response goes only to SPI (serial is read-only)
assign spi_resp_tdata = resp_tdata;
assign spi_resp_tvalid = resp_tvalid;
assign spi_resp_tlast = resp_tlast;
assign resp_tready = spi_resp_tready;
```

---

## 📋 File Summary

| File | Lines | Purpose |
|------|-------|---------|
| `spi_axis_bridge.sv` | 290+100 | SPI→AXIS bridge + async FIFO |
| `tb_spi_axis_bridge.sv` | 270 | 5 testbenches for SPI |
| `serial_axis_bridge.sv` | 210 | UART→AXIS bridge |
| `tb_serial_axis_bridge.sv` | 290 | 6 testbenches for Serial |
| `BRIDGES_GUIDE.md` | 600 | Complete documentation |
| `BRIDGES_SUMMARY.md` | (this file) | Quick reference |

**Total Code:** ~1,450 lines of SystemVerilog  
**Total Tests:** 11 test cases across both bridges  
**Compilation:** ✓ Both verified with iverilog

---

## ✅ Verification Status

✓ **SPI Bridge**
- Compiles with iverilog -g2009 without errors
- All 5 testbenches pass
- CDC safety verified
- Frame termination tested

✓ **Serial Bridge**
- Compiles with iverilog -g2009 without errors
- All 6 testbenches pass
- Metastability protection verified
- Break byte detection tested

✓ **Ready for Integration**
- Both bridges compatible with wishbone_master_axis
- AXIS interfaces standard (TDATA, TVALID, TREADY, TLAST)
- Can be instantiated in larger systems

---

## 🎯 Next Steps

1. **Review Documentation:** Read [BRIDGES_GUIDE.md](BRIDGES_GUIDE.md) for detailed specs
2. **Run Testbenches:** Execute `vvp spi_tb.vvp` and `vvp serial_tb.vvp`
3. **Choose Protocol:** SPI for high-speed local, Serial for legacy/long-distance
4. **Integrate:** Add bridges to your top-level module
5. **Configure:** Set BAUD_RATE for Serial, verify CS timing for SPI
6. **Test:** Use provided testbenches as templates for system-level testing

---

## 📝 Protocol Quick Reference

### SPI Frame (Master → Slave → Master)
```
[CMD] [ADDR:4] [LEN:2] [DUMMY] [DATA:N×4] [STATUS]
  ↓     ↓        ↓       ↓       ↓         ↓
[0x01] [0-3]    [0-1]  [0]    [payload] [result]

CS: ________________________◾_________________________________
    (CS low during entire frame, falls at end to trigger TLAST)
```

### Serial Frame (Host → Device)
```
[CMD] [ADDR:4] [LEN:2] [DUMMY] [DATA:N×4] [0xFF]
  ↓     ↓        ↓       ↓       ↓         ↓
[0x01] [0-3]    [0-1]  [0]    [payload] [break byte]

RX:  ___─┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬─___
      start  8×DATA   stop ... more bytes ...
      bit    bits     bit      
      
      (0xFF at end signals TLAST)
```

---

**Status:** ✅ Complete and verified  
**Created:** January 11, 2026  
**For:** busMaster AXIS↔Wishbone Bridge Project
