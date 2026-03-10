# Implementation Options: Tang Nano 9K vs Raspberry Pi Pico

This document compares implementation approaches for the SPIQuadCopter project:

1. **Tang Nano 9K + Pure SystemVerilog** - Hardware state machines (current approach)
2. **Tang Nano 9K + SERV RISC-V** - Soft CPU firmware on FPGA
3. **Raspberry Pi Pico (RP2040)** - ARM Cortex-M0+ with PIO state machines

---

# Part 1: SystemVerilog vs SERV on Tang Nano 9K

## Executive Summary

| Aspect | SystemVerilog | SERV + C Firmware |
|--------|---------------|-------------------|
| **FPGA Resources** | ~200-400 LUTs | ~400-600 LUTs (incl. RAM) |
| **Code Size** | ~500 lines Verilog | ~300 LUTs + 100 lines C |
| **Debugging** | Waveforms, assertions | printf, GDB, waveforms |
| **Flexibility** | Recompile FPGA | Recompile C only |
| **Latency** | 1-2 cycles/byte | ~32 cycles/byte (bit-serial) |
| **Development Time** | Longer | Shorter for complex logic |

---

## 1. Code Size Comparison

### SystemVerilog Approach (Current)

```
src/msp_v2/
├── msp_rx.sv          ~180 lines  (packet receiver FSM)
├── msp_responder.sv   ~175 lines  (command handler FSM)
├── msp_tx.sv          ~165 lines  (response transmitter FSM)
└── msp_handler_v2.sv  ~130 lines  (pipeline wrapper)
                       ─────────
                       ~650 lines total
```

Each module is a hand-crafted state machine with:
- Explicit state encoding
- Timeout counters
- Checksum calculation
- Packed array management for payload

### SERV + C Firmware Approach

**Hardware (Verilog):**
```
serv/                  ~300 LUTs (SERV core)
├── servile.sv         Wishbone wrapper (from FuseSoC)
├── wb_ram.sv          2KB instruction RAM
└── wb_ram.sv          2KB data RAM
                       ─────────
                       ~500 LUTs + 2 BRAMs
```

**Firmware (C):**
```c
// msp_handler.c - ~100 lines
#include <stdint.h>

#define UART_RX  (*(volatile uint8_t*)0x80000000)
#define UART_TX  (*(volatile uint8_t*)0x80000004)
#define UART_ST  (*(volatile uint8_t*)0x80000008)

typedef struct {
    uint8_t cmd;
    uint8_t len;
    uint8_t payload[16];
} msp_packet_t;

// Simple MSP parser
int msp_receive(msp_packet_t *pkt) {
    if (uart_getc() != '$') return -1;
    if (uart_getc() != 'M') return -1;
    if (uart_getc() != '<') return -1;
    
    pkt->len = uart_getc();
    pkt->cmd = uart_getc();
    
    uint8_t crc = pkt->len ^ pkt->cmd;
    for (int i = 0; i < pkt->len; i++) {
        pkt->payload[i] = uart_getc();
        crc ^= pkt->payload[i];
    }
    
    return (uart_getc() == crc) ? 0 : -1;
}

void msp_send_response(uint8_t cmd, uint8_t *data, uint8_t len) {
    uart_putc('$');
    uart_putc('M');
    uart_putc('>');
    uart_putc(len);
    uart_putc(cmd);
    
    uint8_t crc = len ^ cmd;
    for (int i = 0; i < len; i++) {
        uart_putc(data[i]);
        crc ^= data[i];
    }
    uart_putc(crc);
}

void main(void) {
    msp_packet_t pkt;
    
    while (1) {
        if (msp_receive(&pkt) == 0) {
            switch (pkt.cmd) {
                case MSP_IDENT:
                    uint8_t resp[] = {0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
                    msp_send_response(MSP_IDENT, resp, 7);
                    break;
                // ... other commands
            }
        }
    }
}
```

---

## 2. Debugging Comparison

### SystemVerilog Debugging

**Tools:**
- GTKWave / Surfer for waveform viewing
- Icarus Verilog / Verilator for simulation
- Hardware debug pins (current approach)

**Challenges:**
- Must add explicit debug signals to RTL
- State machine transitions visible only in waveforms
- Adding `$display` requires rebuild
- Protocol errors hard to trace through FSM

**Example Debug Session:**
```bash
# Run testbench
cd src/msp_v2
make sim

# View waveforms
gtkwave msp_handler_v2_tb.vcd &

# Check state transitions manually in waveform viewer
```

**Pros:**
- Cycle-accurate visibility
- See all signal transitions
- Can catch race conditions

**Cons:**
- Steep learning curve for complex FSMs
- Every debug point requires RTL changes
- No breakpoints or stepping

### SERV + C Firmware Debugging

**Tools:**
- GDB with RISC-V target (via JTAG or simulation)
- printf debugging (via UART)
- Verilator + C firmware co-simulation
- Standard C debuggers

**Debug Approaches:**

#### 1. Printf Debugging (Easiest)
```c
void msp_receive(msp_packet_t *pkt) {
    uint8_t c = uart_getc();
    printf("Got: 0x%02X\n", c);  // Debug output
    if (c != '$') return -1;
    // ...
}
```

#### 2. GDB Debugging (Most Powerful)
```bash
# Start Verilator simulation with GDB stub
./Vservant --gdb-port 3333 &

# Connect GDB
riscv32-unknown-elf-gdb firmware.elf
(gdb) target remote :3333
(gdb) break msp_receive
(gdb) continue
(gdb) print pkt->cmd
(gdb) step
```

#### 3. Memory Inspection
```c
// Dump state at any point
volatile uint32_t *debug_reg = (uint32_t*)0x90000000;
*debug_reg = current_state;  // Visible on Wishbone bus
```

**Pros:**
- Familiar C debugging workflow
- Breakpoints, watchpoints, stepping
- printf without FPGA rebuild
- Easy protocol-level debugging

**Cons:**
- Hardware timing less visible
- SERV is slow (32 cycles/instruction)
- Additional abstraction layer

---

## 3. Testing & Simulation

### SystemVerilog Testing

**Testbench Structure:**
```
src/msp_v2/
├── msp_handler_v2_tb.sv    # Main testbench
├── Makefile                # Build rules
└── msp_handler_v2_tb.vcd   # Output waveforms
```

**Running Tests:**
```bash
cd src/msp_v2
make sim          # Compile and run
make waves        # Open GTKWave
```

**Example Testbench:**
```systemverilog
// Send MSP_IDENT command
task send_msp_ident();
    send_byte(8'h24);  // '$'
    send_byte(8'h4D);  // 'M'
    send_byte(8'h3C);  // '<'
    send_byte(8'h00);  // len=0
    send_byte(8'h64);  // cmd=MSP_IDENT (100)
    send_byte(8'h64);  // checksum
endtask

initial begin
    @(negedge rst);
    send_msp_ident();
    
    // Wait for response
    wait(tx_valid);
    // Check response...
end
```

### SERV + C Firmware Testing

**Directory Structure:**
```
serv/
├── firmware/
│   ├── msp_handler.c       # Main firmware
│   ├── msp_handler_test.c  # Unit tests (host)
│   ├── Makefile
│   └── linker.ld
├── sim/
│   └── tb_servant.cpp      # Verilator testbench
└── rtl/
    └── servant.sv          # SERV + peripherals
```

#### Testing C Code on Host (Fastest)

```c
// msp_handler_test.c - Runs on Linux, no FPGA needed
#include <stdio.h>
#include <assert.h>
#include "msp_handler.h"

// Mock UART for testing
static uint8_t rx_buffer[256];
static int rx_idx = 0;
uint8_t uart_getc(void) { return rx_buffer[rx_idx++]; }

void test_msp_ident(void) {
    // Setup: MSP_IDENT request
    rx_buffer[0] = '$';
    rx_buffer[1] = 'M';
    rx_buffer[2] = '<';
    rx_buffer[3] = 0;    // len
    rx_buffer[4] = 100;  // MSP_IDENT
    rx_buffer[5] = 100;  // checksum
    rx_idx = 0;
    
    msp_packet_t pkt;
    int result = msp_receive(&pkt);
    
    assert(result == 0);
    assert(pkt.cmd == 100);
    assert(pkt.len == 0);
    printf("PASS: test_msp_ident\n");
}

int main(void) {
    test_msp_ident();
    // More tests...
    return 0;
}
```

**Running Host Tests:**
```bash
cd serv/firmware
gcc -o test msp_handler_test.c msp_handler.c
./test
# PASS: test_msp_ident
```

#### Testing in Verilator Simulation

```bash
# Build SERV with firmware
cd serv
fusesoc run --target=verilator_tb servant \
    --firmware=firmware/msp_handler.bin \
    --uart_baudrate=115200 \
    --timeout=10000000

# Output appears on simulated UART
```

#### Testing on Real Hardware

```bash
# Build and flash
cd serv/firmware
make                    # Cross-compile for RISC-V
make flash              # Program to Tang Nano 9K

# Test via USB serial
python3 -c "
import serial
s = serial.Serial('/dev/ttyUSB1', 115200)
s.write(b'\$M<\x00\x64\x64')  # MSP_IDENT
print(s.read(10))              # Read response
"
```

---

## 4. Development Workflow Comparison

### SystemVerilog Workflow

```
┌─────────────────┐
│ Edit .sv files  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Run simulation  │ ◄─── Fix bugs
│ (iverilog/veri) │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Synthesize      │ ◄─── Fix timing
│ (yosys/nextpnr) │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Program FPGA    │
│ Test on hardware│
└─────────────────┘

Time per iteration: 2-5 minutes (synthesis)
```

### SERV + C Workflow

```
┌─────────────────┐     ┌─────────────────┐
│ Edit .c files   │     │ Edit .sv (rare) │
└────────┬────────┘     └────────┬────────┘
         │                       │
         ▼                       ▼
┌─────────────────┐     ┌─────────────────┐
│ Host unit tests │     │ Full synthesis  │
│ (gcc, instant)  │     │ (once per HW    │
└────────┬────────┘     │  change)        │
         │              └────────┬────────┘
         ▼                       │
┌─────────────────┐              │
│ Cross-compile   │◄─────────────┘
│ riscv32-gcc     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Upload firmware │ ◄─── No FPGA rebuild!
│ via SPI/UART    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Test on hardware│
└─────────────────┘

Time per iteration: <10 seconds (firmware only)
```

---

## 5. When to Use Each Approach

### Use Pure SystemVerilog When:
- ✅ Ultra-low latency required (1-2 cycles)
- ✅ Minimal FPGA resources critical
- ✅ Simple, fixed protocol
- ✅ No future protocol changes expected
- ✅ Team has strong RTL skills

### Use SERV + C Firmware When:
- ✅ Protocol is complex or evolving
- ✅ Multiple protocol variants needed
- ✅ Rapid iteration important
- ✅ Team has C experience
- ✅ Debugging ease prioritized
- ✅ Slight latency acceptable (32+ cycles/op)

### Hybrid Approach (Recommended):
- **Time-critical paths**: Pure RTL (DSHOT timing, SPI slave)
- **Protocol parsing**: SERV firmware (MSP handler, state management)
- **Configuration**: SERV reads config, writes to RTL registers

---

## 6. SERV Integration for This Project

### Proposed Architecture (SERV as SPI-Wishbone Bridge + MSP Handler)

SERV replaces `axis_wb_master` and `msp_handler_v2`, becoming the central processor:

```
                          ┌─────────────────────────────────────────────────┐
                          │                   SERV CPU                      │
   SPI Master             │  ┌─────────┐                    ┌───────────┐  │
   (STM32)                │  │  AXI-S  │    ┌──────────┐    │ Wishbone  │  │
      │                   │  │  RX     │    │ Firmware │    │  Master   │  │
      ▼                   │  │  FIFO   │───►│  - SPI   │───►│ Interface │  │
┌──────────┐    AXI-S     │  └─────────┘    │  - MSP   │    └─────┬─────┘  │
│spi_slave │──────────────┼────────────────►│  - WB    │          │        │
│   .sv    │◄─────────────┼─────────────────│  proto   │◄─────────┘        │
└──────────┘    AXI-S TX  │  ┌─────────┐    └──────────┘                   │
   10 MHz                 │  │  AXI-S  │          │                        │
                          │  │  TX     │◄─────────┘                        │
                          │  │  FIFO   │                                   │
                          │  └─────────┘                                   │
                          │                                                 │
                          │  ┌──────────┐    ┌──────────┐                  │
                          │  │  2KB     │    │  2KB     │                  │
                          │  │  IRAM    │    │  DRAM    │                  │
                          │  └──────────┘    └──────────┘                  │
                          └───────────────────────┬─────────────────────────┘
                                                  │
                    ┌─────────────────────────────┴─────────────────────────┐
                    │                    Wishbone Bus                       │
                    └───┬───────┬───────┬───────┬───────┬───────┬──────────┘
                        │       │       │       │       │       │
                   ┌────┴──┐ ┌──┴──┐ ┌──┴──┐ ┌──┴──┐ ┌──┴──┐ ┌──┴──┐
                   │  LED  │ │ PWM │ │DSHOT│ │ Neo │ │ Ver │ │UART │
                   │ Ctrl  │ │Decod│ │Ctrl │ │ Px  │ │ Reg │ │Wrap │
                   └───────┘ └─────┘ └─────┘ └─────┘ └─────┘ └─────┘
```

### What SERV Replaces

| Current Module | Function | SERV Equivalent |
|----------------|----------|-----------------|
| `axis_wb_master` | SPI→WB protocol | C firmware function |
| `msp_handler_v2` | MSP parsing | C firmware function |
| `msp_rx.sv` | MSP RX state machine | C code (~30 lines) |
| `msp_responder.sv` | MSP command handler | C switch statement |
| `msp_tx.sv` | MSP TX framing | C code (~20 lines) |

### What Stays in RTL

| Module | Reason |
|--------|--------|
| `spi_slave.sv` | Bit-level timing at 10 MHz |
| `wb_dshot_controller.sv` | Microsecond-accurate motor timing |
| `wb_neoPx.sv` | 800 kHz LED protocol timing |
| `pwmdecoder.sv` | Edge detection timing |
| `wb_led_controller.sv` | Simple, no benefit from SW |
| `wb_version.sv` | Simple register |
| `uart_rx.sv` / `uart_tx.sv` | Bit-level UART timing |

### SERV Firmware Overview

```c
// main.c - SERV firmware for SPI-Wishbone bridge + MSP handler
#include <stdint.h>

// Memory-mapped peripherals
#define AXIS_RX_FIFO  (*(volatile uint8_t*)0x80000000)
#define AXIS_RX_STAT  (*(volatile uint8_t*)0x80000004)
#define AXIS_TX_FIFO  (*(volatile uint8_t*)0x80000008)
#define WB_ADDR       (*(volatile uint32_t*)0x80001000)
#define WB_DATA       (*(volatile uint32_t*)0x80001004)
#define WB_CTRL       (*(volatile uint32_t*)0x80001008)

// Protocol commands
#define CMD_WB_READ   0xA1
#define CMD_WB_WRITE  0xA2
#define CMD_MSP_START 0x24  // '$'

static inline uint8_t fifo_read(void) {
    while (!(AXIS_RX_STAT & 0x01));  // Wait for data
    return AXIS_RX_FIFO;
}

static inline void fifo_write(uint8_t b) {
    AXIS_TX_FIFO = b;
}

void handle_wb_read(void) {
    // Read address (4 bytes, big-endian)
    uint32_t addr = (fifo_read() << 24) | (fifo_read() << 16) |
                    (fifo_read() << 8)  | fifo_read();
    uint16_t len = (fifo_read() << 8) | fifo_read();
    fifo_read();  // Skip pad
    
    // Perform Wishbone read
    WB_ADDR = addr;
    WB_CTRL = 0x01;  // Start read
    while (WB_CTRL & 0x80);  // Wait for completion
    
    // Send response (little-endian)
    uint32_t data = WB_DATA;
    for (int i = 0; i < len; i++) {
        fifo_write(data & 0xFF);
        data >>= 8;
    }
}

void handle_wb_write(void) {
    uint32_t addr = (fifo_read() << 24) | (fifo_read() << 16) |
                    (fifo_read() << 8)  | fifo_read();
    uint16_t len = (fifo_read() << 8) | fifo_read();
    
    // Read data (little-endian)
    uint32_t data = 0;
    for (int i = 0; i < len; i++) {
        data |= ((uint32_t)fifo_read() << (i * 8));
    }
    fifo_read();  // Skip pad
    
    // Perform Wishbone write
    WB_ADDR = addr;
    WB_DATA = data;
    WB_CTRL = 0x02;  // Start write
    while (WB_CTRL & 0x80);
}

void handle_msp_packet(void) {
    if (fifo_read() != 'M') return;
    if (fifo_read() != '<') return;
    
    uint8_t len = fifo_read();
    uint8_t cmd = fifo_read();
    uint8_t crc = len ^ cmd;
    
    uint8_t payload[16];
    for (int i = 0; i < len; i++) {
        payload[i] = fifo_read();
        crc ^= payload[i];
    }
    
    if (fifo_read() != crc) return;  // CRC error
    
    // Process and respond
    msp_respond(cmd, payload, len);
}

void main(void) {
    while (1) {
        if (AXIS_RX_STAT & 0x01) {
            uint8_t cmd = fifo_read();
            
            switch (cmd) {
                case CMD_WB_READ:
                    handle_wb_read();
                    break;
                case CMD_WB_WRITE:
                    handle_wb_write();
                    break;
                case CMD_MSP_START:  // '$'
                    handle_msp_packet();
                    break;
            }
        }
    }
}
```

### Resource Estimate

| Component | LUTs | BRAMs |
|-----------|------|-------|
| Current design | ~3500 | 4 |
| SERV core | +300 | - |
| Instruction RAM 2KB | - | +1 |
| Data RAM 2KB | - | +1 |
| **Total** | ~3800 | 6 |
| Tang Nano 9K capacity | 8640 | 26 |
| **Utilization** | 44% | 23% |

Plenty of headroom for SERV integration.

---

## 7. SERV Performance: SPI-Wishbone Protocol Analysis

This section analyzes SERV's ability to replace `axis_wb_master` and handle the SPI-to-Wishbone protocol.

### Current Protocol Format

| Operation | TX Bytes | RX Bytes |
|-----------|----------|----------|
| **Read (0xA1)** | 8 (cmd+addr+len+pad) | N (data) |
| **Write (0xA2)** | 8+N (cmd+addr+len+data+pad) | 0 |

### SERV Instruction Count per Operation

At 72 MHz, SERV executes **1 instruction per 32 clocks = 444 ns/instruction**

#### Read Command (0xA1) - 4-byte register read

| Step | Instructions | Time |
|------|--------------|------|
| Poll FIFO for byte | 4 | 1.8 µs |
| Check cmd == 0xA1 | 2 | 0.9 µs |
| Read 4 addr bytes, assemble | 20 | 8.9 µs |
| Read 2 len bytes | 10 | 4.4 µs |
| Skip pad byte | 4 | 1.8 µs |
| Wishbone read (32-bit) | 8 | 3.6 µs |
| Write 4 bytes to TX FIFO | 16 | 7.1 µs |
| **Total** | **~64** | **~29 µs** |

#### Write Command (0xA2) - 4-byte register write

| Step | Instructions | Time |
|------|--------------|------|
| Poll FIFO for byte | 4 | 1.8 µs |
| Check cmd == 0xA2 | 2 | 0.9 µs |
| Read 4 addr bytes | 20 | 8.9 µs |
| Read 2 len bytes | 10 | 4.4 µs |
| Read 4 data bytes | 20 | 8.9 µs |
| Skip pad byte | 4 | 1.8 µs |
| Wishbone write | 6 | 2.7 µs |
| **Total** | **~66** | **~30 µs** |

### Throughput Comparison

| Metric | RTL (axis_wb_master) | SERV Firmware |
|--------|---------------------|---------------|
| Read latency (4B) | ~1 µs | ~29 µs |
| Write latency (4B) | ~1 µs | ~30 µs |
| Max reads/sec | ~1,000,000 | ~34,000 |
| Max writes/sec | ~1,000,000 | ~33,000 |

### Practical Impact

**Typical flight controller use case:**
- Motor update rate: 1000 Hz (4 motors × 2 bytes = 8 writes/loop)
- Time budget per loop: 1 ms
- SERV write overhead: 8 × 30 µs = **240 µs** (24% of budget)
- **Verdict: ✅ Acceptable**

**Worst case (burst reads):**
- Reading all 6 PWM channels + 4 motor statuses = 10 reads
- Time: 10 × 29 µs = **290 µs**
- **Verdict: ✅ Still fast enough**

**SPI wire time vs SERV processing:**
- At 10 MHz SPI: 8 bytes = 6.4 µs wire time
- SERV processing: 29 µs
- SERV is the bottleneck, but **still under 50 µs per transaction**

### Capability Matrix

| Use Case | SERV Support |
|----------|--------------|
| ✅ Typical flight controller (1 kHz) | Works |
| ✅ Configuration reads/writes | Works |
| ✅ MSP protocol handling | Works |
| ✅ Status queries | Works |
| ⚠️ High-frequency bursts (>30 kHz) | Marginal |
| ❌ Sub-microsecond response | Not suitable |

### Optimization Options (if needed)

1. **Use QERV (4-bit)**: ~4× faster → ~7 µs per transaction
2. **Batch commands**: Firmware processes multiple commands per poll
3. **DMA-style buffering**: Hardware prefills FIFO, SERV processes in batches
4. **Dedicated fast-path**: Critical registers in RTL, SERV handles complex ones

### Bottom Line

**SERV @ 72 MHz can handle ~33,000 Wishbone transactions/second**, which is plenty for:
- 1 kHz motor control loop with 10 transactions = 10,000 trans/sec
- MSP protocol (~50 Hz × ~10 transactions = 500 trans/sec)
- Configuration (occasional)

**Total utilization: ~30% of SERV capacity** at typical flight controller rates.

---

## 8. Quick Start: Testing SERV Locally

```bash
# 1. Install prerequisites
pip3 install fusesoc

# 2. Create workspace
mkdir serv_test && cd serv_test

# 3. Add FuseSoC libraries
fusesoc library add fusesoc-cores https://github.com/fusesoc/fusesoc-cores
fusesoc library add serv https://github.com/olofk/serv

# 4. Run Verilator simulation
fusesoc run --target=verilator_tb servant \
    --uart_baudrate=57600 \
    --timeout=10000000

# 5. See "Hello World" output from SERV running Zephyr
```

---

## 9. Conclusion

For the SPIQuadCopter project, SERV integration provides:

### Architecture Summary

**SERV replaces:**
- `axis_wb_master` (SPI→Wishbone protocol interpreter)
- `msp_handler_v2` (MSP parsing state machines)
- `msp_rx.sv`, `msp_responder.sv`, `msp_tx.sv`

**In RTL remain:**
- `spi_slave.sv` (bit-level timing)
- All Wishbone peripherals (DSHOT, NeoPixel, PWM, LED, Version)
- UART TX/RX (physical layer)

### Benefits

1. **Unified protocol handling** - SPI commands and MSP both processed in C firmware
2. **Easier debugging** - printf, GDB, host-side unit tests
3. **Rapid iteration** - Change firmware without FPGA rebuild
4. **Proven performance** - 33,000+ transactions/sec, sufficient for 1 kHz flight control

### Trade-offs

| Factor | RTL | SERV |
|--------|-----|------|
| Latency per transaction | ~1 µs | ~30 µs |
| Code flexibility | Resynthesize | Recompile C |
| Debug tools | Waveforms | printf + GDB |
| Learning curve | RTL expertise | C programming |

### Recommendation

Implement SERV as the SPI-Wishbone bridge with MSP handler in firmware. This gives software flexibility for protocol handling while keeping timing-critical peripherals (DSHOT, SPI, NeoPixel) in RTL where they belong.

---

# Part 2: Tang Nano 9K vs Raspberry Pi Pico

## Overview

The Raspberry Pi Pico (RP2040) offers an alternative architecture using ARM Cortex-M0+ cores with PIO (Programmable I/O) state machines for timing-critical tasks.

## Hardware Comparison

| Spec | Tang Nano 9K | Raspberry Pi Pico |
|------|--------------|-------------------|
| **Processor** | Gowin GW1NR-9C FPGA | RP2040 dual ARM Cortex-M0+ |
| **Clock** | 72 MHz (PLL) | 125 MHz |
| **Logic** | 8640 LUT4 | N/A (fixed silicon) |
| **BRAM** | 26 × 18Kbit | 264 KB SRAM |
| **Flash** | External | 2 MB onboard |
| **PIO State Machines** | N/A (use RTL) | 8 (2 blocks × 4) |
| **Price** | ~$15 | ~$4 |

## Feature Implementation Comparison

| Feature | Tang 9K (RTL) | Pico (PIO + C) |
|---------|---------------|----------------|
| **DSHOT × 4 motors** | `dshot_out.v` | ✅ PIO state machines |
| **PWM Decode × 6 ch** | `pwmdecoder.v` | ✅ PIO pulse measurement |
| **NeoPixel** | `wb_neoPx.v` | ✅ PIO (standard library) |
| **SPI Slave 10MHz** | ✅ `spi_slave.sv` | ⚠️ HW SPI (works, tighter) |
| **MSP Protocol** | Complex RTL FSM | ✅ Simple C code |
| **BLHeli Passthrough** | Complex RTL | ✅ PIO + C (~80 lines) |
| **All simultaneous** | ✅ | ✅ (8 PIO SMs) |

## SPI Slave: The Key Differentiator

| SPI Aspect | Tang 9K | Pico |
|------------|---------|------|
| **Max slave clock** | 36 MHz (half sys_clk) | ~10 MHz (HW SPI) |
| **Your target** | 10 MHz | 10 MHz |
| **Reliability** | ✅ Rock solid RTL | ⚠️ Should work, less proven |
| **MISO timing** | Cycle-accurate | "Good enough" |
| **Deterministic** | ✅ Always | ⚠️ Interrupt jitter possible |
| **Future: 20MHz SPI** | ✅ Easy | ❌ Not possible |

## PIO Resource Allocation (Pico)

| PIO | SM | Function | Instructions |
|-----|-----|----------|--------------|
| PIO0 | SM0 | DSHOT Motor 1 | ~8 |
| PIO0 | SM1 | DSHOT Motor 2 | ~8 |
| PIO0 | SM2 | DSHOT Motor 3 | ~8 |
| PIO0 | SM3 | DSHOT Motor 4 | ~8 |
| PIO1 | SM0 | PWM Decode CH1-2 | ~10 |
| PIO1 | SM1 | PWM Decode CH3-4 | ~10 |
| PIO1 | SM2 | PWM Decode CH5-6 | ~10 |
| PIO1 | SM3 | NeoPixel | ~8 |

**All 8 state machines run in parallel with zero CPU intervention.**

## Performance Comparison

| Task | Tang 9K RTL | Pico PIO + ARM |
|------|-------------|----------------|
| DSHOT bit timing | Cycle-accurate | ✅ PIO cycle-accurate |
| PWM measurement | Parallel capture | ✅ PIO continuous |
| NeoPixel timing | RTL state machine | ✅ PIO handles it |
| MSP parsing | RTL FSM (~800 lines) | ✅ C code (~100 lines) |
| SPI Slave 10MHz | ✅ Easy | ⚠️ Works but tighter |

## Development Comparison

| Aspect | Tang 9K | Pico |
|--------|---------|------|
| **Toolchain** | Yosys + nextpnr + (FuseSoC) | ARM GCC + SDK |
| **Build time** | 2-5 min (synthesis) | ~5 sec (compile) |
| **Debugging** | Waveforms, debug pins | printf, GDB, SWD |
| **Timing closure** | Can be challenging | N/A |
| **Learning curve** | RTL expertise required | Standard embedded C |

## Decision Matrix

| Factor | Tang 9K | Pico | Winner |
|--------|---------|------|--------|
| **SPI Slave 10MHz** | ✅ Easy, proven | ⚠️ Works, tighter | 🏆 **Tang 9K** |
| **SPI reliability** | ✅ Deterministic | ⚠️ Good enough | 🏆 **Tang 9K** |
| **Price** | ~$15 | ~$4 | 🏆 Pico |
| **DSHOT/PWM/Neo** | ✅ RTL | ✅ PIO | Tie |
| **MSP/Passthrough** | ⚠️ Complex RTL | ✅ Easy C | 🏆 Pico |
| **Debugging** | ⚠️ Waveforms only | ✅ GDB + printf | 🏆 Pico |
| **Development speed** | ⚠️ Slower | ✅ Faster | 🏆 Pico |
| **Future scalability** | ✅ More headroom | ⚠️ 8 SMs limit | 🏆 Tang 9K |
| **Timing closure** | ⚠️ Can struggle | ✅ N/A | 🏆 Pico |

## Recommendations

### Choose Tang Nano 9K When:
- ✅ SPI slave at 10+ MHz is required with deterministic timing
- ✅ Future features may need more parallel I/O
- ✅ You want to learn/demonstrate FPGA skills
- ✅ Nanosecond-level timing precision matters
- ✅ You enjoy RTL development

### Choose Raspberry Pi Pico When:
- ✅ SPI at 5-10 MHz is acceptable (with slight timing flexibility)
- ✅ Faster development iteration is priority
- ✅ Debugging ease is important
- ✅ Current feature set is final (8 PIO SMs is enough)
- ✅ Cost matters (~$4 vs ~$15)
- ✅ C development preferred over RTL

### For This Project: Trade-off Summary

**If SPI 10 MHz with rock-solid timing is non-negotiable:**
→ **Stay with Tang Nano 9K**, accept RTL complexity

**If SPI speed can be reduced to 5 MHz, or slight timing jitter is acceptable:**
→ **Consider Pico** for simpler development, easier debugging

---

# Part 3: SERV on Tang 9K vs Pico

## Why SERV Doesn't Bridge the Gap

| Factor | Tang 9K + SERV | Pico RP2040 |
|--------|----------------|-------------|
| **Processor speed** | ~2.25 MIPS (32 cyc/instr) | ~125 MIPS per core |
| **Speed ratio** | 1× | **55× faster** |
| **Still need RTL?** | ✅ For timing-critical | ❌ PIO handles it |
| **Toolchain** | FPGA + RISC-V GCC | Just ARM GCC |
| **Debugging** | Limited UART printf | Full GDB + SWD |
| **Timing closure** | Still an issue | N/A |

**SERV adds complexity without removing FPGA disadvantages:**
- Still need FPGA synthesis for DSHOT, PWM, NeoPixel, SPI
- SERV is 55× slower than Pico's ARM cores
- Debugging is harder than both pure RTL and Pico
- Two toolchains to manage (FPGA + RISC-V)

**Bottom line:** If you're considering SERV to escape RTL complexity, Pico is a better choice. SERV makes sense only when you're committed to FPGA for other reasons and need a small control CPU.

---

# Final Recommendation

| Option | Verdict |
|--------|---------|
| **Pure RTL on Tang 9K** | 🟢 **Current approach** - Working, SPI is solid |
| **SERV on Tang 9K** | 🔴 Adds complexity, slow CPU, still need RTL |
| **Raspberry Pi Pico** | 🟡 Great alternative if SPI timing flexibility exists |

**For this project:** The Tang Nano 9K's SPI slave advantage justifies the RTL complexity. The timing closure issue (0.2% off) is solvable with minor optimizations. Continue with Tang 9K unless SPI requirements change.

---

# Part 4: CPU Options - SERV vs VexRiscv vs Ibex

## CPU Comparison for FPGA SoC

When picking a soft CPU for FPGA designs, three leading RISC-V options exist:

| Feature | SERV | VexRiscv | Ibex |
|---------|------|----------|------|
| **Architecture** | Bit-serial (1-bit ALU) | 2-5 stage pipeline | 2-stage pipeline |
| **Size (LUTs)** | ~200 | ~1500-3000 | ~1800 |
| **Performance** | ~0.03 DMIPS/MHz | ~1.0 DMIPS/MHz | ~0.7 DMIPS/MHz |
| **At 80 MHz** | ~2.4 MIPS | ~80 MIPS | ~56 MIPS |
| **Debug Support** | None (PC only) | Full JTAG/GDB | PULP riscv-dbg |
| **Language** | Verilog | SpinalHDL→Verilog | SystemVerilog |
| **M Extension** | Optional | Configurable | Yes |
| **C Extension** | Yes | Configurable | Yes |
| **Interrupts** | Optional Zicsr | Full CSR | Full CSR |
| **Wishbone Bus** | Yes | Yes (with wrapper) | AXI-Lite (needs bridge) |
| **OpenOCD Config** | No | Yes (well tested) | Yes |

## VexRiscv Advantages

**VexRiscv** is particularly attractive for this project:

1. **Full GDB/JTAG Debug** - Uses BSCANE2 on Xilinx, tunnels through existing JTAG
2. **Configurable Pipeline** - 2-5 stages, trade area for speed
3. **Well-Tested** - Used in LiteX, SpinalHDL ecosystem
4. **SpinalHDL Generated** - Pre-built Verilog available
5. **~33× faster than SERV** - Real-time capable

### VexRiscv Debug via JTAG

On Arty S7-50, VexRiscv debug uses the existing FTDI JTAG:

```
USB Cable → FTDI FT2232H → BSCANE2 → VexRiscv Debug Module
                ↓
         OpenOCD → GDB
```

**No external wiring** - tunnels through FPGA JTAG.

```tcl
# OpenOCD config for VexRiscv on Arty S7
adapter driver ftdi
adapter speed 10000

ftdi vid_pid 0x0403 0x6010
ftdi channel 0
ftdi layout_init 0x0088 0x008b

transport select jtag
jtag newtap xc7 tap -irlen 6 -expected-id 0x037c4093

target create vexriscv.cpu0 vexriscv -chain-position xc7.tap
vexriscv readWaitCycles 10
vexriscv cpuConfigFile cpu0.yaml

init
halt
```

### VexRiscv Plugin Configuration

VexRiscv is configured via SpinalHDL plugins. Minimal config for this project:

```scala
val config = VexRiscvConfig(
  plugins = List(
    new IBusSimplePlugin(
      resetVector = 0x80000000l,
      cmdForkOnSecondStage = false,
      cmdForkPersistence = false
    ),
    new DBusSimplePlugin(
      catchAddressMisaligned = false,
      catchAccessFault = false
    ),
    new DecoderSimplePlugin(
      catchIllegalInstruction = false
    ),
    new RegFilePlugin(
      regFileReadyKind = plugin.SYNC,
      zeroBoot = true
    ),
    new IntAluPlugin,
    new SrcPlugin(
      separatedAddSub = false
    ),
    new FullBarrelShifterPlugin,
    new HazardSimplePlugin(
      bypassExecute = true,
      bypassMemory = true,
      bypassWriteBack = true
    ),
    new BranchPlugin(
      earlyBranch = false,
      catchAddressMisaligned = false
    ),
    new CsrPlugin(
      config = CsrPluginConfig.smallest
    ),
    new YamlPlugin("cpu0.yaml"),
    new DebugPlugin(ClockDomain.current, 2)  // JTAG debug!
  )
)
```

## When to Use Each CPU

| Use Case | Recommended CPU |
|----------|-----------------|
| **Smallest possible** | SERV (~200 LUTs) |
| **Debug needed, medium performance** | VexRiscv (~2000 LUTs) |
| **Production, safety-critical** | Ibex (~1800 LUTs) |
| **Fastest execution** | VexRiscv 5-stage (~3000 LUTs) |

## Migration Path: SERV → VexRiscv

For this project, the migration path would be:

1. **Keep current SERV** for Tang boards (limited debug needed)
2. **Use VexRiscv** on Arty S7-50 for development/debug
3. **Same Wishbone peripherals** work with both CPUs
4. **Same firmware** (with minor HAL differences)

The `common_serv_spi_top` module can be parameterized to swap CPUs:

```verilog
module common_spi_top #(
    parameter CPU_TYPE = "SERV"  // or "VEXRISCV"
) (
    // ... ports
);

generate
    if (CPU_TYPE == "SERV") begin : gen_serv
        serv_wb_top u_cpu (...);
    end else if (CPU_TYPE == "VEXRISCV") begin : gen_vex
        VexRiscv u_cpu (...);
    end
endgenerate
```

---

# Part 5: Platform Comparison

## Supported Platforms

| Spec | Tang Nano 9K | Tang Nano 20K | Arty S7-50 |
|------|--------------|---------------|------------|
| **FPGA** | Gowin GW1NR-9C | Gowin GW2AR-18 | Xilinx XC7S50 |
| **LUTs** | 8,640 | 20,736 | 32,500 |
| **BRAM** | 26 × 18Kb | 46 × 18Kb | 75 × 36Kb |
| **Target Clock** | 54 MHz | 80 MHz | 80 MHz |
| **Toolchain** | OSS CAD Suite | OSS CAD Suite | Vivado |
| **JTAG Debug** | No (USB prog only) | No (USB prog only) | Yes (FTDI) |
| **Price** | ~$15 | ~$20 | ~$120 |
| **Debug Options** | UART printf, pins | UART printf, pins | ILA, JTAG, GDB |

## Resource Utilization

| Component | LUTs | Tang 9K | Tang 20K | Arty S7 |
|-----------|------|---------|----------|---------|
| SERV CPU | ~200 | ✅ | ✅ | ✅ |
| VexRiscv | ~2000 | ⚠️ 23% | ✅ 10% | ✅ 6% |
| wb_spisystem | ~3000 | ✅ 35% | ✅ 14% | ✅ 9% |
| Debug GPIO (32b) | ~100 | ✅ | ✅ | ✅ |
| **Total (SERV)** | ~3500 | 40% | 17% | 11% |
| **Total (VexRiscv)** | ~5300 | 61% | 26% | 16% |

## Debug Capabilities by Platform

| Feature | Tang 9K | Tang 20K | Arty S7-50 |
|---------|---------|----------|------------|
| UART printf | ✅ | ✅ | ✅ |
| Debug pins (logic analyzer) | 3 bits | 3 bits | 32-bit ILA |
| PC trace (ILA) | ❌ | ❌ | ✅ 32-bit |
| JTAG (FPGA) | ❌ | ❌ | ✅ FTDI |
| GDB (CPU) | ❌ | ❌ | ✅ (with VexRiscv) |
| Hardware breakpoints | ❌ | ❌ | ✅ (with VexRiscv) |
| Register inspection | ❌ | ❌ | ✅ (with VexRiscv) |

## Recommended Usage

| Platform | Role | Why |
|----------|------|-----|
| **Arty S7-50** | Development/Debug | ILA, JTAG, GDB support |
| **Tang Nano 20K** | Production target | Cheap, sufficient resources |
| **Tang Nano 9K** | Legacy/minimal | Works but constrained |

## Architecture: 90% Code Sharing

All platforms share `common_serv_spi_top`:

```
┌─────────────────────────────────────────────────────────┐
│  Platform Top (board-specific)                          │
│  ├── PLL (Vivado Clock Wizard / Gowin IP)               │
│  ├── Reset synchronizer                                 │
│  ├── Heartbeat LED                                      │
│  └── Pin assignments                                    │
├─────────────────────────────────────────────────────────┤
│  common_serv_spi_top (shared)                           │
│  ├── SERV RISC-V CPU                                    │
│  ├── 8KB RAM                                            │
│  └── wb_spisystem (all Wishbone peripherals)            │
│      ├── wb_led_controller                              │
│      ├── wb_dshot_controller                            │
│      ├── wb_pwm_decoder                                 │
│      ├── wb_debug_gpio (32-bit)                         │
│      ├── wb_usb_uart                                    │
│      ├── wb_esc_uart                                    │
│      └── wb_version                                     │
└─────────────────────────────────────────────────────────┘
```

**Firmware is identical** - Same `.bin` file works on all platforms.

---

# Part 6: Debug Strategy

## Development Workflow

```
┌──────────────────┐
│  Arty S7-50      │  ← Primary development
│  - Full ILA      │
│  - GDB (VexRiscv)│
│  - Fast iteration│
└────────┬─────────┘
         │
         │ Debug & validate
         ▼
┌──────────────────┐
│  Tang Nano 20K   │  ← Production target
│  - UART printf   │
│  - Pin debugging │
└──────────────────┘
```

## Debug Signals on Arty S7-50

The following signals are marked for ILA:

```verilog
(* mark_debug = "true" *) output wire [31:0] debug_gpio;
(* mark_debug = "true" *) output wire [31:0] debug_pc;
(* mark_debug = "true" *) output wire        debug_pc_valid;
```

**In Vivado:**
1. Synthesize design
2. Open Synthesized Design
3. Set Up Debug → ILA appears with marked signals
4. Add triggers (e.g., `debug_pc == 0x80001234`)
5. Capture waveforms in Hardware Manager

## Firmware Debug Output

The 32-bit `debug_gpio` register is memory-mapped at `0x100`:

```c
// wb_regs.h
#define WB_DEBUG_GPIO_OUT  (*(volatile uint32_t*)0x100)
#define WB_DEBUG_GPIO_SET  (*(volatile uint32_t*)0x104)
#define WB_DEBUG_GPIO_CLR  (*(volatile uint32_t*)0x108)
#define WB_DEBUG_GPIO_TGL  (*(volatile uint32_t*)0x10C)

// Usage in firmware
void debug_checkpoint(uint8_t id) {
    WB_DEBUG_GPIO_OUT = (WB_DEBUG_GPIO_OUT & 0xFFFFFF00) | id;
}

void debug_pulse(uint8_t bit) {
    WB_DEBUG_GPIO_TGL = (1 << bit);
    WB_DEBUG_GPIO_TGL = (1 << bit);
}
```

**ILA trigger example:** Capture when `debug_gpio[7:0] == 0x42` (checkpoint 0x42)

## PC Trace Analysis

With `debug_pc` and `debug_pc_valid` in ILA:

1. **Set trigger:** `debug_pc_valid == 1 && debug_pc == <function_address>`
2. **Capture:** See execution flow
3. **Analyze:** Correlate PC values with disassembly

```bash
# Generate disassembly for PC correlation
riscv32-unknown-elf-objdump -d firmware.elf > firmware.dis

# In ILA, when PC = 0x800001A4, look up in firmware.dis
```

---

# Summary: Current Architecture

## What We Have Now

| Platform | Top Module | CPU | Debug |
|----------|------------|-----|-------|
| Tang Nano 9K | `tang9k_top.sv` | SERV | 3-bit pins + UART |
| Tang Nano 20K | `tangnano20k_top.sv` (TBD) | SERV | 3-bit pins + UART |
| Arty S7-50 | `arty_s7_spi_copter_top.v` | SERV | 32-bit ILA + UART |

## Future Options

| Upgrade | Effort | Benefit |
|---------|--------|---------|
| VexRiscv on Arty | Medium | Full GDB/JTAG debug |
| VexRiscv on Tang 20K | Medium | Better performance |
| DSHOT v2 (auto-repeat) | Low | Hardware motor refresh |

## Quick Reference

**Arty S7-50 ILA signals:**
- `debug_gpio[31:0]` — Firmware debug output  
- `debug_pc[31:0]` — SERV program counter
- `debug_pc_valid` — PC valid on instruction fetch

**Target clock:** 80 MHz (all platforms)

**Firmware:** Same binary for all platforms (SERV RV32IC)
