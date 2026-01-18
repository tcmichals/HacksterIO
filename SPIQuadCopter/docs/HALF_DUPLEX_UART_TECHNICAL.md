# Half-Duplex UART Passthrough - Technical Deep Dive

## Overview

This document explains how the Tang9K FPGA implements **half-duplex UART communication** by bridging a **full-duplex USB UART** to a **half-duplex serial line** using tri-state buffers. This enables BLHeli ESC configuration through the motor output pins.

---

## Architecture Overview

### System Block Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         Tang9K FPGA                              │
│                                                                  │
│  ┌──────────────┐      ┌─────────────────────┐                 │
│  │ USB UART     │      │ uart_passthrough_   │                 │
│  │ (Full Duplex)│◄────►│ bridge.sv           │                 │
│  │ Pins 19-20   │      │ (Full→Half Duplex)  │                 │
│  └──────────────┘      └──────────┬──────────┘                 │
│                                   │                              │
│                          ┌────────▼────────┐                    │
│                          │ wb_serial_dshot_│                    │
│                          │ mux.sv          │                    │
│                          │ (Tri-State Mux) │                    │
│                          └────────┬────────┘                    │
│                                   │                              │
│                          ┌────────▼────────┐                    │
│                          │  Motor Pins     │                    │
│                          │  (Bidirectional)│                    │
│                          │  Pins 32-35     │                    │
└──────────────────────────┼─────────────────┼───────────────────┘
                           │                 │
                    ┌──────▼──────┐   ┌──────▼──────┐
                    │ ESC 1       │   │ ESC 2       │
                    │ (BLHeli)    │   │ (BLHeli)    │
                    └─────────────┘   └─────────────┘
```

### Data Flow

**PC → ESC (Command):**
```
USB UART RX → uart_passthrough_bridge → serial_tx_out → 
  wb_serial_dshot_mux → Motor Pin (TX mode) → ESC
```

**ESC → PC (Response):**
```
ESC → Motor Pin (RX mode) → wb_serial_dshot_mux → serial_rx_in → 
  uart_passthrough_bridge → USB UART TX → PC
```

---

## Full-Duplex to Half-Duplex Conversion

### The Challenge

**Full-Duplex UART** (USB interface):
- Separate TX and RX wires
- Can transmit and receive simultaneously
- No tri-state needed

**Half-Duplex UART** (ESC interface):
- Single shared wire for TX and RX
- Can only transmit OR receive at one time
- Requires tri-state control

### The Solution

The [`uart_passthrough_bridge.sv`](file:///media/tcmichals/projects/Tang9K/HacksterIO/SPIQuadCopter/src/uart_passthrough_bridge.sv) module bridges these two modes:

```systemverilog
// Full-duplex USB UART side
input  logic usb_uart_rx,    // Receive from PC
output logic usb_uart_tx,    // Transmit to PC

// Half-duplex serial side (split signals)
output logic serial_tx_out,  // Data to drive onto shared line
output logic serial_tx_oe,   // Output Enable (tri-state control)
input  logic serial_rx_in,   // Data read from shared line
```

---

## Tri-State Buffer Control

### What is Tri-State?

A tri-state buffer has **three possible output states**:
1. **Logic 0** (drive low)
2. **Logic 1** (drive high)
3. **High-Z** (high impedance - electrically disconnected)

### Why Tri-State?

On a shared half-duplex line:
- **When transmitting:** Drive the line (0 or 1)
- **When receiving:** Release the line (high-Z) so the ESC can drive it

### SystemVerilog Implementation

#### Module: `uart_passthrough_bridge.sv`

**Tri-state control signal:**
```systemverilog
// Synchronize enable signal (2-FF synchronizer) to prevent metastability
logic enable_meta;
logic enable_sync;

always_ff @(posedge clk) begin
    if (rst) begin
        enable_meta <= 1'b0;
        enable_sync <= 1'b0;
    end else begin
        enable_meta <= enable;
        enable_sync <= enable_meta;
    end
end

// Output Enable: HIGH when actively transmitting
assign serial_tx_oe = serial_tx_active & enable_sync;
```

**Key Points:**
- `serial_tx_active` comes from the UART TX module - HIGH during transmission
- `enable_sync` is a synchronized version of the mode select (prevents glitches)
- When `serial_tx_oe = 1`: Drive the line
- When `serial_tx_oe = 0`: Release to high-Z

**Echo prevention:**
```systemverilog
// Serial RX → USB TX (ESC to PC)
// Prevent echo: do not forward received bytes while driving the serial pin
assign usb_tx_valid = serial_rx_valid & enable_sync & (~serial_tx_oe) & ...
```

This prevents the UART RX from seeing its own transmitted data.

---

#### Module: `wb_serial_dshot_mux.sv`

This module implements the actual tri-state buffer at the physical pin level:

```systemverilog
// For each motor pin
genvar i;
generate
    for (i = 0; i < 4; i++) begin : gen_pads
        wire is_target = (effective_mux_ch == i[1:0]);
        
        logic pad_out_data;
        logic pad_oe_active_high; // 1=Drive, 0=High-Z

        always_comb begin
            if (effective_mux_sel == 1'b1) begin
                // DSHOT Mode: Always drive
                pad_out_data       = dshot_val;
                pad_oe_active_high = 1'b1; 
            end else begin
                // Passthrough Mode
                if (is_target) begin
                    pad_out_data       = serial_tx_i;
                    pad_oe_active_high = serial_oe_i; // Tri-state control
                end else begin
                    // Safety: Drive unused pins LOW
                    pad_out_data       = 1'b0;
                    pad_oe_active_high = 1'b1;
                end
            end
        end
        
        // Apply global tri-state during mode changes
        wire final_drive_enable = ~global_tristate & pad_oe_active_high;
```

**Tri-state implementation (Gowin FPGA):**
```systemverilog
`ifdef GOWIN_FPGA
    // Gowin IOBUF: OEN is Active Low (0=Drive, 1=Z)
    wire gowin_oen = ~final_drive_enable;

    IOBUF io_inst (
        .O(pad_input_val),   // Output to fabric (RX)
        .I(pad_out_data),    // Input from fabric (TX)
        .OEN(gowin_oen),     // Output Enable (Active Low)
        .IO(pad_motor[i])    // Physical bidirectional pad
    );
`else
    // Generic simulation model
    assign pad_motor[i] = final_drive_enable ? pad_out_data : 1'bz;
    assign pad_input_val = pad_motor[i];
`endif
```

---

## Timing Diagrams

### TX Operation (PC → ESC)

```
Time:        t0      t1      t2      t3      t4      t5
             │       │       │       │       │       │
usb_uart_rx: ─┐     ┌───────────────┐       ┌───────
             │ └─────┘               └───────┘
             │ (Start) (Data bits)    (Stop)
             │
serial_tx_   │       ┌───────────────┐
active:      ────────┘               └───────────────
             │
serial_tx_oe:│       ┌───────────────┐
             ────────┘               └───────────────
             │       │               │
Motor Pin:   ─┐      │ ┌───────────┐ │       ┌──────
             │ └─────┴─┘           └─┴───────┘
             │ (Driven by FPGA)    │ (High-Z)
             │                     │
             │◄─── TX Active ─────►│◄─ Released ──►
```

**Sequence:**
1. **t0:** USB UART receives byte from PC
2. **t1:** `serial_tx_active` goes HIGH → `serial_tx_oe` goes HIGH
3. **t1-t3:** Motor pin driven by FPGA (transmitting to ESC)
4. **t3:** Transmission complete → `serial_tx_active` goes LOW
5. **t3+:** `serial_tx_oe` goes LOW → Motor pin returns to high-Z

### RX Operation (ESC → PC)

```
Time:        t0      t1      t2      t3      t4
             │       │       │       │       │
serial_tx_oe:│       │       │       │       │
             ──────────────────────────────────────
             │       │       │       │       │
Motor Pin:   ─┐      │ ┌───────────┐ │      ┌─────
(from ESC)   │ └─────┴─┘           └─┴──────┘
             │       │               │
serial_rx_   │       ┌───────────────┐
valid:       ────────┘               └──────────────
             │       │               │
usb_uart_tx: ─┐      │ ┌───────────┐ │      ┌─────
             │ └─────┴─┘           └─┴──────┘
             │
             │◄──── ESC Transmits ───►│
```

**Sequence:**
1. **t0:** Motor pin in high-Z (not driven by FPGA)
2. **t1:** ESC starts transmitting (drives the line)
3. **t1-t3:** FPGA reads data via `serial_rx_in`
4. **t2:** `serial_rx_valid` pulses when byte received
5. **t2:** Byte forwarded to USB UART TX (to PC)

---

## Safety Features

### 1. Enable Synchronization

```systemverilog
// 2-FF synchronizer prevents metastability
always_ff @(posedge clk) begin
    enable_meta <= enable;
    enable_sync <= enable_meta;
end
```

**Why needed:**
- The `enable` signal comes from a Wishbone register (different timing domain)
- Without synchronization, changing modes could cause glitches
- 2-FF synchronizer ensures clean signal transition

### 2. Global Tri-State on Mode Changes

```systemverilog
// Detect mode/channel change
if ((effective_mux_sel != prev_mux_sel) || (effective_mux_ch != prev_mux_ch)) begin
    global_tristate <= 1'b1;  // Force all pins to high-Z for 1 cycle
end
```

**Why needed:**
- Prevents contention when switching between DSHOT and Passthrough modes
- Ensures clean transition without bus conflicts

### 3. Unused Pin Safety

```systemverilog
// In passthrough mode, non-selected motor pins driven LOW
if (!is_target) begin
    pad_out_data       = 1'b0;
    pad_oe_active_high = 1'b1; // Actively drive LOW
end
```

**Why needed:**
- Prevents floating inputs on unused ESCs
- Ensures ESCs see a defined logic level (not noise)

### 4. Echo Prevention

```systemverilog
// Don't forward RX data while TX is active
assign usb_tx_valid = serial_rx_valid & enable_sync & (~serial_tx_oe) & ...
```

**Why needed:**
- In half-duplex, the RX can "hear" its own TX
- This filter prevents echoing transmitted data back to the PC

---

## Pull-Up Resistor Requirement

### Why Pull-Up?

UART idle state is **logic HIGH**. When both FPGA and ESC are in high-Z (not transmitting):
- Without pull-up: Line floats → undefined voltage → communication errors
- With pull-up: Line pulled to HIGH → proper idle state

### Implementation

**Option 1: Internal Pull-Up (Default)**
```tcl
# tang9k.cst constraint file
IO_PORT "o_motor1" IO_TYPE=LVCMOS33 PULL_MODE=UP DRIVE=8;
```

**Option 2: External Pull-Up**
```
                    +3.3V
                      |
                    [R] 4.7kΩ
                      |
FPGA Pin ────────────┴──────── ESC Signal
(Tri-state)
```

---

## Mode Switching

### Wishbone Mux Register (0x0400)

```
Bit 2:1: mux_ch (Motor channel: 0-3)
Bit 0:   mux_sel (0=Passthrough, 1=DSHOT)

Examples:
  0x00 = Passthrough on Motor 1
  0x02 = Passthrough on Motor 2
  0x04 = Passthrough on Motor 3
  0x06 = Passthrough on Motor 4
  0x01 = DSHOT mode (all motors)
```

### Switching Sequence

**DSHOT → Passthrough:**
1. Write `0x00` to register 0x0400
2. `mux_sel` changes from 1 → 0
3. `global_tristate` asserted for 1 cycle (safety)
4. Selected motor pin switches to passthrough mode
5. UART bridge enabled via `enable_sync`

**Passthrough → DSHOT:**
1. Write `0x01` to register 0x0400
2. `mux_sel` changes from 0 → 1
3. `global_tristate` asserted for 1 cycle
4. All motor pins switch to DSHOT mode
5. UART bridge disabled

---

## Code Walkthrough

### File: [`uart_passthrough_bridge.sv`](file:///media/tcmichals/projects/Tang9K/HacksterIO/SPIQuadCopter/src/uart_passthrough_bridge.sv)

**Purpose:** Bridges full-duplex USB UART to half-duplex serial interface

**Key Sections:**

1. **USB UART Instances (Lines 53-76):**
   - `uart_rx_wrapper`: Receives from PC
   - `uart_tx_wrapper`: Transmits to PC

2. **Enable Synchronization (Lines 93-106):**
   - 2-FF synchronizer for `enable` signal
   - Prevents metastability during mode changes

3. **Serial UART Instances (Lines 108-131):**
   - `uart_rx_wrapper`: Receives from ESC
   - `uart_tx_wrapper`: Transmits to ESC
   - `serial_tx_active` output indicates transmission in progress

4. **Tri-State Control (Line 135):**
   ```systemverilog
   assign serial_tx_oe = serial_tx_active & enable_sync;
   ```

5. **Bridging Logic (Lines 140-151):**
   - USB RX → Serial TX (with enable gating)
   - Serial RX → USB TX (with echo prevention)

### File: [`wb_serial_dshot_mux.sv`](file:///media/tcmichals/projects/Tang9K/HacksterIO/SPIQuadCopter/src/wb_serial_dshot_mux.sv)

**Purpose:** Multiplexes motor pins between DSHOT and Serial modes with tri-state control

**Key Sections:**

1. **Wishbone Register (Lines 48-66):**
   - Address decode for 0x0400
   - Stores `mux_sel` and `mux_ch`

2. **Global Tri-State Logic (Lines 91-106):**
   - Detects mode/channel changes
   - Asserts `global_tristate` for 1 cycle

3. **Per-Pin Tri-State (Lines 113-183):**
   - Generate loop for 4 motor pins
   - Mux between DSHOT and Serial sources
   - IOBUF primitive instantiation (Gowin/Xilinx/Generic)

4. **RX Path Synchronization (Lines 202-213):**
   - 2-FF synchronizer for serial RX
   - Gated by mode select

---

## Testing

### Loopback Test

Connect motor pin to itself (with pull-up):

```python
# Enable passthrough on Motor 1
spi.write_wishbone(0x0400, 0x00)

# Send byte via USB UART
uart.write(b'A')

# Should receive same byte back
assert uart.read(1) == b'A'
```

### ESC Communication Test

```python
# Select Motor 1 for passthrough
spi.write_wishbone(0x0400, 0x00)

# Use BLHeli tool to connect
# Should be able to read/write ESC configuration
```

---

## Summary

| Feature | Implementation |
|---------|---------------|
| **Full→Half Duplex** | `uart_passthrough_bridge.sv` |
| **Tri-State Control** | `serial_tx_oe` signal |
| **Physical Tri-State** | `wb_serial_dshot_mux.sv` IOBUF |
| **Echo Prevention** | Gate RX when TX active |
| **Mode Switching** | Wishbone register 0x0400 |
| **Safety** | Enable sync + global tri-state |
| **Pull-Up** | Internal (FPGA) or external |

**Result:** Robust half-duplex UART passthrough for BLHeli ESC configuration! 🚁
