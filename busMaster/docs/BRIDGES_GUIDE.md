% SPI and Serial AXIS Bridges Documentation
# SPI and Serial AXIS Bridges

## Overview

Two protocol adapters that convert common serial interfaces (SPI and UART) to AXI Stream (AXIS) format, enabling integration with the AXIS↔Wishbone bridge.

```
┌─────────────────────────────────────────────────────────────┐
│  SPI/Serial Host                                            │
│  (Master/Transmitter)                                       │
└────────────────┬────────────────────────────────────────────┘
                 │
        ┌────────┴────────┐
        │                 │
    ┌───▼────────┐   ┌───▼────────────┐
    │ SPI Bridge │   │ Serial Bridge   │
    │ (Slave)    │   │ (Receiver)      │
    └───┬────────┘   └───┬────────────┘
        │                 │
        └────────┬────────┘
                 │
            ┌────▼──────────────────┐
            │ wishbone_master_axis   │
            │ (Wishbone Master)      │
            └────┬──────────────────┘
                 │
        ┌────────▼────────┐
        │ Wishbone Slaves │
        │ (BRAM, Devices) │
        └─────────────────┘
```

---

## 1. SPI AXIS Bridge (`spi_axis_bridge.sv`)

### Purpose
Converts SPI slave interface to AXI Stream master interface, allowing SPI hosts to command the Wishbone master.

### Interface Signals

#### SPI Slave (Input)
| Signal | Direction | Description |
|--------|-----------|-------------|
| `spi_clk` | Input | SPI clock (max speed: design dependent) |
| `spi_mosi` | Input | Master Out, Slave In (command/data from host) |
| `spi_miso` | Output | Master In, Slave Out (response to host) |
| `spi_cs_n` | Input | Chip Select, active low |

#### AXI Stream Master (MOSI Output)
| Signal | Direction | Description |
|--------|-----------|-------------|
| `m_axis_tdata[7:0]` | Output | Byte from MOSI line |
| `m_axis_tvalid` | Output | Byte is valid and ready |
| `m_axis_tready` | Input | Downstream ready to accept byte |
| `m_axis_tlast` | Output | Last byte of frame (CS falling edge) |

#### AXI Stream Slave (MISO Input)
| Signal | Direction | Description |
|--------|-----------|-------------|
| `s_axis_tdata[7:0]` | Input | Byte to send on MISO line |
| `s_axis_tvalid` | Input | Byte is valid |
| `s_axis_tready` | Output | Bridge ready for next byte |
| `s_axis_tlast` | Input | Last byte of response |

### Key Features

✅ **Full-Duplex Operation** - MOSI and MISO simultaneous  
✅ **CS Frame Termination** - CS falling edge triggers TLAST  
✅ **CDC (Clock Domain Crossing)** - SPI clock async to system clock  
✅ **FIFO Buffering** - 8-entry async FIFO for MOSI bytes  
✅ **No Flow Control** - Assumes response is always available (or buffered)

### Protocol Timing

```
       CS ___________________________________________________________________
           ‾‾
                                              ___________
      CLK ___/‾‾‾‾\___/‾‾‾‾\___/‾‾‾‾\___/‾‾‾ ... ___/‾‾‾‾\___

     MOSI  xxx  d7  xx  d6  xx  d5  xx  ... d0  xxx
            ↓                                 ↓
    TDATA  [byte 0]                    [byte n]
    TVALID  ▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔

     MISO  xxx  r7  xx  r6  xx  r5  xx  ... r0  xxx
            ↓                                 ↓
    TDATA  [response byte 0]           [response byte m]
    TVALID  ▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔

            │                                    │
            └────────── Frame Duration ─────────┘
                      (ends with CS↑)
```

### Example: SPI Write Command

```
Byte  MOSI    MISO      Meaning
────────────────────────────────────────────────
  0   0x01    ----      Command: Write
  1   0x00    0xA5      Addr[31:24], ACK response
  2   0x00    0x00      Addr[23:16]
  3   0x20    0x00      Addr[15:8]
  4   0x00    0x00      Addr[7:0]
  5   0x00    0x00      Len[15:8]
  6   0x01    0x00      Len[7:0] (1 word)
  7   0x00    0x00      Dummy/Turnaround
  8   0xAA    0x00      Data[31:24]
  9   0xBB    0x00      Data[23:16]
 10   0xCC    0x00      Data[15:8]
 11   0xDD    0x00      Data[7:0]
 12   0x00    0x01      Status (last byte, TLAST↑)
      
      CS falls → TLAST asserted in AXIS
```

### Instantiation Example

```systemverilog
spi_axis_bridge #(
    .DATA_WIDTH(8)
) spi_bridge (
    .clk             (system_clk),
    .rst_n           (system_rst_n),
    
    // SPI interface
    .spi_clk         (spi_clk),
    .spi_mosi        (spi_mosi),
    .spi_miso        (spi_miso),
    .spi_cs_n        (spi_cs_n),
    
    // M_AXIS: MOSI → Wishbone Bridge
    .m_axis_tdata    (to_wb_tdata),
    .m_axis_tvalid   (to_wb_tvalid),
    .m_axis_tready   (to_wb_tready),
    .m_axis_tlast    (to_wb_tlast),
    
    // S_AXIS: Response ← Wishbone Bridge
    .s_axis_tdata    (from_wb_tdata),
    .s_axis_tvalid   (from_wb_tvalid),
    .s_axis_tready   (spi_ready),
    .s_axis_tlast    (from_wb_tlast)
);
```

### Testbench: `tb_spi_axis_bridge.sv`

Tests included:
1. ✓ Simple MOSI byte transfer
2. ✓ Full-duplex MOSI/MISO simultaneous operation
3. ✓ Frame termination with CS falling edge
4. ✓ Back-to-back transfers with CS toggle
5. ✓ Flow control (TREADY=0 buffering)

Run testbench:
```bash
iverilog -g2009 -o spi_tb.vvp spi_axis_bridge.sv tb_spi_axis_bridge.sv
vvp spi_tb.vvp
```

---

## 2. Serial AXIS Bridge (`serial_axis_bridge.sv`)

### Purpose
Converts UART/serial RX input to AXI Stream master interface, allowing serial terminals to command the Wishbone master.

### Interface Signals

#### UART Interface (Input)
| Signal | Direction | Description |
|--------|-----------|-------------|
| `uart_rx` | Input | Serial RX line (standard async UART) |

#### AXI Stream Master (Output)
| Signal | Direction | Description |
|--------|-----------|-------------|
| `m_axis_tdata[7:0]` | Output | Received byte |
| `m_axis_tvalid` | Output | Byte is valid |
| `m_axis_tready` | Input | Downstream ready |
| `m_axis_tlast` | Output | Last byte of frame (0xFF break byte) |

#### Parameters
| Parameter | Default | Description |
|-----------|---------|-------------|
| `CLK_FREQ_MHZ` | 100 | System clock frequency (MHz) |
| `BAUD_RATE` | 115200 | Serial baud rate (bits/sec) |

### Key Features

✅ **Standard UART** - 1 start, 8 data (LSB first), 1 stop bit  
✅ **Metastability Protection** - CDC synchronizers for uart_rx  
✅ **Break Byte Framing** - 0xFF byte triggers TLAST  
✅ **Configurable Baud** - Works with any BAUD_RATE  
✅ **No XON/XOFF** - Assumes host is always ready (or software buffered)

### UART Byte Format

```
Frame: [START BIT] [D0] [D1] [D2] [D3] [D4] [D5] [D6] [D7] [STOP BIT]
       ↓           ↑                                        ↓
      1'b0        LSB first                              1'b1
      
       1 cycle    (3/2 * BAUD_PERIOD) samples in middle
       
Example: 0x42 = 0100_0010 (binary)
Frame: 0 [0][1][0][0][0][0][1][0] 1
               └────────────────┘
               Transmitted LSB first
```

### Timing Example

Assuming 100 MHz clock, 115200 baud:
- `BAUD_PERIOD = 100,000,000 / 115,200 = 868 clocks/bit`
- Byte time = ~87 µs

```
uart_rx  1 ___0_01001101_1_______0_11000101_1___
             │ start│  0x42  │stop│  0x01   │stop
             ↓                                 ↓
    TDATA [0x42]                      [0x01]
    TVALID  ▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
    
    Time: ~87 µs per byte
```

### Example: Serial Read Command

```
Byte  Value   Description
────────────────────────────────────────
  0   0x00    Command: Read
  1   0x00    Addr[31:24]
  2   0x00    Addr[23:16]
  3   0x20    Addr[15:8]
  4   0x00    Addr[7:0]
  5   0x00    Len[15:8]
  6   0x01    Len[7:0] (1 word)
  7   0x00    Dummy
  8   0x??    Response data[31:24] (from Wishbone)
  9   0x??    Response data[23:16]
 10   0x??    Response data[15:8]
 11   0x??    Response data[7:0]
 12   0xFF    Break Byte (TLAST asserted)
      
      Frame ends with 0xFF → TLAST triggered
```

### Baud Rate Configuration

| Baud Rate | @100MHz | @50MHz | Typical Use |
|-----------|---------|--------|------------|
| 9600 | 868 | 434 | Legacy systems, distance |
| 115200 | 868 | 434 | Standard terminal |
| 230400 | 434 | 217 | High-speed (short cable) |
| 460800 | 217 | 109 | Very high-speed |

Calculate for custom clock:
```
BAUD_PERIOD = CLK_FREQ_MHZ * 1,000,000 / BAUD_RATE
```

### Instantiation Example

```systemverilog
serial_axis_bridge #(
    .CLK_FREQ_MHZ(100),
    .BAUD_RATE(115200)
) serial_bridge (
    .clk           (system_clk),
    .rst_n         (system_rst_n),
    
    // UART input
    .uart_rx       (uart_rx_pin),
    
    // M_AXIS: Serial bytes → Wishbone Bridge
    .m_axis_tdata  (to_wb_tdata),
    .m_axis_tvalid (to_wb_tvalid),
    .m_axis_tready (to_wb_tready),
    .m_axis_tlast  (to_wb_tlast)
);
```

### Testbench: `tb_serial_axis_bridge.sv`

Tests included:
1. ✓ Single byte reception (0x42)
2. ✓ Multi-byte command header sequence
3. ✓ Data payload reception
4. ✓ Break byte (0xFF) frame termination and TLAST
5. ✓ Back-to-back frames
6. ✓ Flow control with TREADY=0

Run testbench:
```bash
iverilog -g2009 -o serial_tb.vvp serial_axis_bridge.sv tb_serial_axis_bridge.sv
vvp serial_tb.vvp
```

---

## 3. System Integration

### Full System Block Diagram

```
┌──────────────────────────────────────────────────────────────────┐
│                    Host System (FPGA/SoC)                        │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ wishbone_master_axis                                    │   │
│  │ ┌─────────────────────────────────────────────────────┐ │   │
│  │ │ AXIS Slave (Command In)  | AXIS Master (Response)  │ │   │
│  │ │ TDATA, TVALID, TLAST     | TDATA, TVALID, TLAST    │ │   │
│  │ │                          |                         │ │   │
│  │ └──────────────┬───────────────────┬─────────────────┘ │   │
│  │                │ Wishbone Master   │                    │   │
│  │                │ (Address, Data)   │                    │   │
│  │                │ (ACK, ERR)        │                    │   │
│  │                ▼                   ▼                    │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│                         ▲                                        │
│                         │                                        │
│                         │ Wishbone Bus                           │
│                         │                                        │
│       ┌─────────────────┼──────────────────┐                   │
│       │                 │                  │                   │
│   ┌───▼─────┐   ┌───────▼──────┐  ┌──────▼──┐                │
│   │  BRAM   │   │  Peripheral  │  │ Device  │                │
│   │ 0-1000  │   │   Registers  │  │  FIFO   │                │
│   └─────────┘   └──────────────┘  └─────────┘                │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ Protocol Bridges (demux by protocol)                    │   │
│  │                                                         │   │
│  │  ┌──────────────┐          ┌──────────────┐           │   │
│  │  │ SPI Bridge   │          │ Serial Bridge│           │   │
│  │  │ (SPI Slave)  │          │ (UART Slave) │           │   │
│  │  │              │          │              │           │   │
│  │  │ ┌──────────┐ │          │ ┌──────────┐│           │   │
│  │  │ │MOSI→AXIS │ │          │ │RX→AXIS   ││           │   │
│  │  │ │MISO←AXIS │ │          │ │          ││           │   │
│  │  │ └──────────┘ │          │ └──────────┘│           │   │
│  │  │              │          │              │           │   │
│  │  └──────────────┘          └──────────────┘           │   │
│  │         ▲                            ▲                │   │
│  └─────────┼────────────────────────────┼────────────────┘   │
│            │                            │                     │
│            │ From Wishbone Bridge       │                     │
│            │ (Response AXIS)            │                     │
│            │                            │                     │
└────────────┼────────────────────────────┼─────────────────────┘
             │                            │
    ┌────────┴────────┐                   │
    │                 │                   │
┌───▼──────┐    ┌────▼─────┐             │
│ SPI Host │    │ UART Host │  ◄──────────┘
│ (Master) │    │(Terminal) │
└──────────┘    └───────────┘
```

### Connection Steps

1. **SPI Configuration:**
   ```systemverilog
   spi_axis_bridge spi_br(...);
   
   // Connect to Wishbone bridge
   assign wb_tdata = spi_br.m_axis_tdata;
   assign wb_tvalid = spi_br.m_axis_tvalid;
   assign spi_br.m_axis_tready = wb_tready;
   assign spi_br.m_axis_tlast = spi_br.m_axis_tlast;
   
   // Response path (optional mux if shared with other protocol)
   assign spi_br.s_axis_tdata = wb_resp_tdata;
   assign spi_br.s_axis_tvalid = wb_resp_tvalid;
   assign spi_br.s_axis_tlast = wb_resp_tlast;
   ```

2. **Serial Configuration:**
   ```systemverilog
   serial_axis_bridge serial_br(...);
   
   // Connect to Wishbone bridge
   assign wb_tdata = serial_br.m_axis_tdata;
   assign wb_tvalid = serial_br.m_axis_tvalid;
   assign serial_br.m_axis_tready = wb_tready;
   assign serial_br.m_axis_tlast = serial_br.m_axis_tlast;
   
   // No response needed (unidirectional)
   ```

3. **Protocol Selection (if shared):**
   ```systemverilog
   // Mux between SPI and Serial based on control signal
   assign wb_tdata = use_spi ? spi_br.m_axis_tdata : serial_br.m_axis_tdata;
   assign wb_tvalid = use_spi ? spi_br.m_axis_tvalid : serial_br.m_axis_tvalid;
   ```

---

## 4. Compilation & Testing

### Compile All Bridges
```bash
# Compile SPI bridge + testbench
iverilog -g2009 -o spi_tb.vvp spi_axis_bridge.sv tb_spi_axis_bridge.sv

# Compile Serial bridge + testbench
iverilog -g2009 -o serial_tb.vvp serial_axis_bridge.sv tb_serial_axis_bridge.sv

# Compile all together (with Wishbone bridge)
iverilog -g2009 -o full_system.vvp \
    wishbone_master_axis.sv \
    spi_axis_bridge.sv \
    serial_axis_bridge.sv \
    tb_spi_axis_bridge.sv \
    tb_serial_axis_bridge.sv
```

### Run Simulations
```bash
# Run SPI testbench
vvp spi_tb.vvp

# Run Serial testbench
vvp serial_tb.vvp
```

### View Waveforms (with VCD generation)
```bash
# Generate waveforms (modify testbenches to enable $dumpfile)
vvp spi_tb.vvp
gtkwave spi_tb.vcd &

vvp serial_tb.vvp
gtkwave serial_tb.vcd &
```

---

## 5. Design Considerations

### SPI Bridge

| Aspect | Consideration |
|--------|---------------|
| **Baud Rate** | Limited by MOSI/MISO propagation delay. Typically 10-20 MHz for 1-2m cable. |
| **Clock Domain** | SPI clock is async to system clock. CDC FIFOs handle sync. |
| **Response Latency** | MISO data must be available within (8 SPI bits) cycles of being requested. |
| **CS Handling** | CS falling edge triggers TLAST. Host must manage CS timing. |
| **Back-Pressure** | m_axis_tready low stalls MOSI capture (FIFO full). |

### Serial Bridge

| Aspect | Consideration |
|--------|---------------|
| **Baud Rate** | 115200 typical, up to 460800 for short cables. |
| **Frame Timing** | 0xFF break byte signals end-of-frame (TLAST). |
| **Start Bit** | Sampled at 1.5× bit time for robustness. |
| **No Flow Control** | Assumes host sends slowly or has flow control externally. |
| **Latency** | Byte arrives ~87 µs after transmission (@ 115200 baud). |

### Shared Response Path

If both SPI and Serial share the Wishbone response:

```systemverilog
// Response mux (simple example, assumes SPI has priority)
assign spi_br.s_axis_tdata = wb_resp_tdata;
assign spi_br.s_axis_tvalid = use_spi & wb_resp_tvalid;
assign spi_br.s_axis_tlast = wb_resp_tlast;

// Serial doesn't consume response (unidirectional)
```

---

## 6. Quick Start Guide

### For SPI Users

1. **Configure PHY** (external to FPGA):
   - SPI Master device (CPU, MCU, FPGA)
   - MOSI → FPGA `spi_mosi`
   - MISO ← FPGA `spi_miso`
   - CLK → FPGA `spi_clk`
   - CS → FPGA `spi_cs_n`

2. **Instantiate Bridge:**
   ```systemverilog
   spi_axis_bridge spi_br(...);
   ```

3. **Send Command:**
   ```c
   // Host-side (SPI Master)
   uint8_t cmd[] = {0x01, 0x00, 0x00, 0x20, 0x00, 0x00, 0x01, 0x00, ...};
   spi_write(CS, cmd, length);
   ```

### For Serial Users

1. **Configure PHY:**
   - Serial terminal or microcontroller UART
   - TX → FPGA `uart_rx`
   - Ground connection required

2. **Instantiate Bridge:**
   ```systemverilog
   serial_axis_bridge #(.BAUD_RATE(115200)) serial_br(...);
   ```

3. **Send Command:**
   ```c
   // Host-side (Terminal or UART)
   printf("%c%c%c%c%c%c%c%c...", 0x01, 0x00, 0x00, 0x20, 0x00, 0x00, 0x01, 0x00);
   ```

---

## 7. Advanced Topics

### SPI Clock Stretching

**Not supported.** SPI bridge cannot hold CLK low. Ensure Wishbone slave responds within configured timeout or use host-side software delay.

### Serial Frame Recovery

If 0xFF byte is part of data (not frame terminator), don't use Serial bridge. Use SPI with explicit frame size instead.

### Multi-Protocol Arbitration

For systems with both SPI and Serial:

```systemverilog
// Priority decoder
assign wb_tdata = spi_active ? spi_m_axis_tdata : serial_m_axis_tdata;
assign wb_tvalid = spi_active ? spi_m_axis_tvalid : serial_m_axis_tvalid;
assign spi_m_axis_tready = spi_active & wb_tready;
assign serial_m_axis_tready = (~spi_active) & wb_tready;
```

---

## 8. Troubleshooting

### SPI Bridge Issues

**Problem:** M_AXIS never asserts TVALID
- **Cause:** CS not asserted (must be low)
- **Fix:** Check CS line voltage, ensure host pulls CS low during transfer

**Problem:** MISO data appears as zeros
- **Cause:** S_AXIS not providing data (TVALID=0)
- **Fix:** Ensure response source is connected and driven

**Problem:** Frame doesn't terminate (TLAST not asserted)
- **Cause:** CS stays low after data
- **Fix:** Host must deassert CS to trigger frame end

### Serial Bridge Issues

**Problem:** Bytes appear corrupted or wrong
- **Cause:** Baud rate mismatch
- **Fix:** Verify BAUD_RATE parameter matches host configuration

**Problem:** Frame never terminates
- **Cause:** No 0xFF byte sent
- **Fix:** Host must send 0xFF as final byte to end frame

**Problem:** Dropped bytes
- **Cause:** Host sending faster than bridge can process
- **Fix:** Slow host transmission rate or increase system clock

---

## Conclusion

These bridges provide simple, clean interfaces for integrating common serial protocols with the AXIS↔Wishbone infrastructure. Choose SPI for high-speed local connections and Serial for legacy or long-distance communication.
