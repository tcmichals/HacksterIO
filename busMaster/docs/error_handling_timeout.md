# Error Handling & Timeout Protection

This document explains the error handling and timeout mechanisms added to the `wishbone_master_axis` bridge.

---

## Overview

The bridge now handles two critical failure modes:

1. **Wishbone Errors** (`wb_err_i = 1`) — Slave device signals an error
2. **Timeout** — Wishbone slave doesn't respond within a configurable time window

Both error conditions cause the bridge to:
- ✅ Abort the current transaction gracefully
- ✅ Return error status (`0xFF`) to the host
- ✅ Return to IDLE state
- ✅ Accept the next command

---

## Parameter: TIMEOUT_CYCLES

```systemverilog
module wishbone_master_axis #(
    parameter integer TIMEOUT_CYCLES = 1000     // Timeout in clock cycles
)
```

### Calculating Timeout Duration

```
Timeout Duration = TIMEOUT_CYCLES / Clock Frequency

Examples:
- @ 100 MHz: 1000 cycles = 10 µs
- @ 100 MHz: 10000 cycles = 100 µs
- @ 50 MHz: 2500 cycles = 50 µs
```

### Recommended Values

| Scenario | Clock | TIMEOUT_CYCLES | Duration | Why |
|----------|-------|----------------|----------|-----|
| **BRAM** (fast) | 100 MHz | 100 | 1 µs | Zero-wait-state memory |
| **Local SRAM** | 100 MHz | 500 | 5 µs | 1-2 cycle latency |
| **DDR/External** | 100 MHz | 5000 | 50 µs | Many-cycle latency |
| **Slow Serial Device** | 25 MHz | 10000 | 400 µs | Cross-clock domain |
| **Safe Default** | Any | 1000 | Variable | Handles most slaves |

---

## Error Conditions

### 1. Wishbone Error (`wb_err_i`)

**Trigger**: Slave asserts `wb_err_i = 1` during transaction

**Timeline**:
```
wb_cyc_o:  ────┐                ┌──
                │                │
wb_stb_o:  ────┤                ├──
                │                │
wb_we_o:   ────┤  0 (READ)       ├──
                │                │
wb_adr_o:  [ADDRESS]            ├──
                │                │
wb_err_i:  ─────────────┐        │  ← Error asserted
                        │        │
           (Cycle continues until error detected)
           
State:     ...ST_WB_WAIT→ST_RSP_ERROR→ST_IDLE...
           
Response:  [ACK=0xA5] [ERROR=0xFF] [TLAST=1]
```

**Response to Host**:
```
S_AXIS input:  [CMD] [ADDR] [LEN] [DATA...]
M_AXIS output: [ACK:0xA5] [ERROR:0xFF] with TLAST
```

**Example Scenario**:
- Reading from non-existent address → Slave asserts `wb_err_i`
- Bridge receives error immediately
- Returns `0xFF` status to host
- Host knows read failed

### 2. Timeout Error (`timeout_expired`)

**Trigger**: `wb_stb_o` active for `TIMEOUT_CYCLES` without `wb_ack_i` or `wb_err_i`

**Timeline**:
```
Counter:     0   1   2   ... 998  999  1000  (TIMEOUT_CYCLES=1000)
             └───────────────────────────────┘
                  Counting...              → Timeout!

wb_ack_i:  ───────────────────────────────────  (Never asserts)
wb_err_i:  ───────────────────────────────────  (Never asserts)
timeout:   ───────────────────────────────────┐ ← Triggered
                                             │

State:     ...ST_WB_START→ST_WB_WAIT→...→ST_TIMEOUT_ERROR→ST_IDLE...

Response:  [ACK=0xA5] [ERROR=0xFF] [TLAST=1]
```

**Response to Host**:
```
S_AXIS input:  [CMD] [ADDR] [LEN] [DATA...]
M_AXIS output: [ACK:0xA5] [ERROR:0xFF] with TLAST
```

**Example Scenario**:
- Slave is hung or broken (clock stopped)
- No ACK ever returns
- After 1000 cycles, timeout fires
- Bridge returns error (`0xFF`)
- Host retries with different target

---

## Error Response Codes

| Response | Value | Meaning |
|----------|-------|---------|
| **ACK** | `0xA5` | Command acknowledged (always sent first) |
| **SUCCESS** | `0x01` | Transaction completed successfully |
| **ERROR** | `0xFF` | Wishbone error OR timeout |

**Error Response Format**:
```
Beat 0: [0xA5]  (ACK, m_axis_tlast=0)
Beat 1: [0xFF]  (ERROR, m_axis_tlast=1)
        ↑       ↑
    Always sent  Marks end of response
```

---

## Example Scenarios

### Scenario 1: Successful Transaction (No Error)

```
Host sends read command for address 0x1000

Timeline:
Beat 0: CMD=0x00 (READ) → Bridge ACKs (0xA5)
Beat 1-4: Address bytes → Captured
Beat 5-6: Length=0x0001 → Captured
Beat 7: Dummy byte → Captured

Wishbone bus:
- wb_adr_o = 0x1000
- wb_we_o = 0 (READ)
- wb_stb_o = 1, wb_cyc_o = 1

Cycle 0-3: Wishbone is waiting...
Cycle 4: wb_ack_i = 1, wb_dat_i = 0xDEADBEEF

Response to host:
Beat 0: [0xA5] ACK
Beat 1: [0xDE] Data MSB
Beat 2: [0xAD]
Beat 3: [0xBE]
Beat 4: [0xEF] Data LSB + TLAST

Success! ✓
```

### Scenario 2: Wishbone Error (Bad Address)

```
Host sends read command for address 0x99999999 (unmapped)

Timeline:
Beat 0-7: Command packet received normally
          Bridge ACKs with 0xA5

Wishbone bus:
- wb_adr_o = 0x99999999
- wb_we_o = 0 (READ)
- wb_stb_o = 1, wb_cyc_o = 1

Cycle 0: wb_ack_i = 0, wb_err_i = 0 (normal)
Cycle 1: wb_ack_i = 0, wb_err_i = 0 (normal)
Cycle 2: wb_ack_i = 0, wb_err_i = 1  ← ERROR!
                     ↑ Slave says "I don't have this address!"

State machine: ST_WB_WAIT → (detect wb_err_i) → ST_RSP_ERROR

Response to host:
Beat 0: [0xA5]  ACK (already sent earlier)
Beat 1: [0xFF]  ERROR + TLAST

Host knows: "Read failed - bad address or device error"
Bridge returns to IDLE, ready for next command.
```

### Scenario 3: Timeout (Hung Slave)

```
Host sends write command to address 0x2000

Timeline:
Beat 0-11: Command + data packet received
           Bridge ACKs with 0xA5

Wishbone bus:
- wb_adr_o = 0x2000
- wb_dat_o = 0xCAFEBABE
- wb_we_o = 1 (WRITE)
- wb_stb_o = 1, wb_cyc_o = 1

Timeout counter starts: 0, 1, 2, 3, ...

Cycle 0:   timeout_cnt = 0,   wb_ack_i = 0, wb_err_i = 0
Cycle 1:   timeout_cnt = 1,   wb_ack_i = 0, wb_err_i = 0
Cycle 2:   timeout_cnt = 2,   wb_ack_i = 0, wb_err_i = 0
...
Cycle 999: timeout_cnt = 999, wb_ack_i = 0, wb_err_i = 0
Cycle 1000: timeout_cnt = 1000 → TIMEOUT EXPIRED!
                         ↑ (TIMEOUT_CYCLES exceeded)

State machine: ST_WB_WAIT → (timeout_expired) → ST_TIMEOUT_ERROR

Response to host:
Beat 0: [0xA5]  ACK (already sent)
Beat 1: [0xFF]  ERROR (timeout) + TLAST

Host knows: "Write timed out - slave not responding"
Host can:
  - Retry with longer timeout
  - Try different slave
  - Report hardware error
```

### Scenario 4: Timeout in Burst Write

```
Host sends burst WRITE of 4 words to address 0x3000

Timeline:
Beat 0-23: 4 words of data sent

Wishbone bus:
Word 0: wb_adr_o = 0x3000, wb_dat_o = 0x11111111
         → ACK received @ cycle 2

Word 1: wb_adr_o = 0x3004, wb_dat_o = 0x22222222
         → ACK received @ cycle 2

Word 2: wb_adr_o = 0x3008, wb_dat_o = 0x33333333
         → ACK received @ cycle 2

Word 3: wb_adr_o = 0x300C, wb_dat_o = 0x44444444
         → timeout_cnt = 0, 1, 2, ... (no ACK!)
         → timeout_cnt = 1000 → TIMEOUT!

State machine: 
  (3 successful writes) → ST_WB_WAIT → (timeout on word 4) → ST_TIMEOUT_ERROR

Response to host:
Beat 0: [0xA5]  ACK (word setup)
Beat N: [0xFF]  ERROR (timeout on word 4) + TLAST

Host knows: "Write timed out after 3 words - partial failure possible"
```

---

## Integration with Bridge Adapters (SPI/Serial)

### SPI Bridge with Error Handling

```systemverilog
module spi_axis_adapter_with_errors (
    input  logic         clk,
    input  logic [7:0]   s_axis_tdata,
    input  logic         s_axis_tvalid,
    output logic         s_axis_tready,
    output logic         s_axis_tlast,
    
    input  logic [7:0]   m_axis_tdata,
    input  logic         m_axis_tvalid,
    input  logic         m_axis_tlast,  ← Now can be error!
    output logic         m_axis_tready
);

    always_ff @(posedge clk) begin
        if (m_axis_tvalid && m_axis_tready) begin
            // Check if response byte indicates error
            if (m_axis_tdata == 8'xFF) begin
                $display("ERROR: Bridge reported failure!");
                // Could set error flag, log, etc.
            end else if (m_axis_tdata == 8'h01) begin
                $display("SUCCESS: Transaction completed");
            end
            
            // TLAST marks end of response
            if (m_axis_tlast) begin
                $display("Response complete");
            end
        end
    end

endmodule
```

### Serial Host Code (Python) with Error Detection

```python
import serial
import time

def read_via_serial_with_error_handling(port, address):
    """Read from Wishbone with error detection"""
    
    BREAK_BYTE = 0x7F
    ERROR_CODE = 0xFF
    ACK_CODE = 0xA5
    
    # Build read packet
    packet = bytearray()
    packet.append(0x00)                          # READ
    packet.extend(address.to_bytes(4, 'big'))   # Address
    packet.append(0x00)
    packet.append(0x01)                          # Length = 1 word
    packet.append(0x00)                          # Dummy
    packet.append(BREAK_BYTE)                    # Terminator
    
    # Send
    port.write(packet)
    time.sleep(0.001)  # Allow bridge to process
    
    # Read response
    try:
        ack = port.read(1)[0]
        if ack != ACK_CODE:
            raise RuntimeError(f"No ACK: got {ack:02x}")
        
        # Read status/data
        status = port.read(1)[0]
        
        if status == ERROR_CODE:
            print(f"✗ READ FAILED: Address 0x{address:08x} error")
            return None
        
        elif status == 0x01:  # Success
            # Read 4 data bytes
            data_bytes = port.read(4)
            data = int.from_bytes(data_bytes, 'big')
            print(f"✓ READ OK: Address 0x{address:08x} = 0x{data:08x}")
            return data
        
        else:
            print(f"? Unknown status: 0x{status:02x}")
            return None
            
    except Exception as e:
        print(f"✗ COMMUNICATION ERROR: {e}")
        return None

# Usage
port = serial.Serial('/dev/ttyUSB0', baudrate=9600)

# Try to read from valid address
read_via_serial_with_error_handling(port, 0x1000)

# Try to read from invalid address (will fail)
read_via_serial_with_error_handling(port, 0x99999999)

port.close()
```

**Output**:
```
✓ READ OK: Address 0x00001000 = 0xDEADBEEF
✗ READ FAILED: Address 0x99999999 error
```

---

## Testing Error Conditions

### Test 1: Verify Error Response on Bad Address

```systemverilog
// Testbench
initial begin
    // Try to read from bad address
    send_axis_packet(CMD_READ, BAD_ADDR, 1);
    
    // Wait for response
    @(posedge clk);
    assert(m_axis_tdata == 8'hA5) else $error("No ACK");
    @(posedge clk);
    
    // Should get error
    assert(m_axis_tdata == 8'hFF) else $error("Expected error 0xFF");
    assert(m_axis_tlast == 1) else $error("TLAST not set");
    
    $display("✓ Error response correct");
end
```

### Test 2: Verify Timeout Detection

```systemverilog
// Testbench with timeout monitoring
initial begin
    send_axis_packet(CMD_WRITE, ADDR, 1);
    
    // Simulate hung slave (never ACK or ERR)
    fork
        begin
            repeat (1100) @(posedge clk);  // Wait beyond timeout
            wb_ack_i = 0;  // Keep 0
            wb_err_i = 0;  // Keep 0
        end
    join
    
    // Wait for error response
    @(posedge clk);
    @(posedge clk);
    
    if (m_axis_tdata == 8'hFF && m_axis_tlast) begin
        $display("✓ Timeout detected, error returned");
    end else begin
        $display("✗ Timeout not detected!");
    end
end
```

---

## Configuration Examples

### Example 1: Fast BRAM Target

```systemverilog
wishbone_master_axis #(
    .ADDR_WIDTH(32),
    .DATA_WIDTH(32),
    .TIMEOUT_CYCLES(100)  // Very short: 1 µs @ 100 MHz
) fast_bridge (
    // Interface connections...
);
```

**Why**: BRAM has zero wait states, responds in ~1 cycle.

### Example 2: External DDR Memory

```systemverilog
wishbone_master_axis #(
    .ADDR_WIDTH(32),
    .DATA_WIDTH(32),
    .TIMEOUT_CYCLES(10000)  // Longer: 100 µs @ 100 MHz
) ddr_bridge (
    // Interface connections...
);
```

**Why**: DDR controllers have pipeline delays (10-20+ cycles).

### Example 3: Cross-Clock Domain

```systemverilog
wishbone_master_axis #(
    .ADDR_WIDTH(32),
    .DATA_WIDTH(32),
    .TIMEOUT_CYCLES(50000)  // Very long: 500 µs @ 100 MHz
) cdc_bridge (
    // Interface connections...
);
```

**Why**: CDC (clock domain crossing) synchronization adds latency.

---

## Summary Table

| Condition | Detected | Response | Cycle Count |
|-----------|----------|----------|-------------|
| **Normal Success** | `wb_ack_i = 1` | `0x01` | Variable |
| **Wishbone Error** | `wb_err_i = 1` | `0xFF` | Variable |
| **Timeout** | `timeout_cnt >= TIMEOUT_CYCLES` | `0xFF` | TIMEOUT_CYCLES |

All error responses include:
- ✅ Early ACK (`0xA5`) already sent
- ✅ Error/Status byte (`0xFF` or `0x01`)
- ✅ TLAST asserted on status byte
- ✅ FSM returns to IDLE

---

## Debugging Tips

1. **Monitor `timeout_cnt`** in simulation
   ```systemverilog
   always @(posedge clk) begin
       if (state == ST_WB_WAIT) 
           $display("timeout_cnt=%d, expired=%b", timeout_cnt, timeout_expired);
   end
   ```

2. **Check `wb_err_i` signals** from slaves
   ```systemverilog
   always @(posedge clk) begin
       if (wb_err_i) $display("WB ERROR asserted!");
   end
   ```

3. **Log all transitions to error states**
   ```systemverilog
   always @(state) begin
       if (state == ST_RSP_ERROR || state == ST_TIMEOUT_ERROR)
           $display("ERROR STATE ENTERED: %s", state.name());
   end
   ```

4. **Capture VCD waveforms** showing error scenarios
   ```bash
   make sim > test.log
   # Then view waveform.vcd in GTKWave
   ```

