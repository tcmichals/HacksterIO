# Implementation Summary: Error Handling & Timeout

## What Was Added

### 1. New Parameter

```systemverilog
parameter integer TIMEOUT_CYCLES = 1000     // Timeout in clock cycles
```

Configurable timeout threshold. Default is 1000 cycles (~10µs @ 100MHz).

### 2. New Response Codes

```systemverilog
localparam [7:0] RSP_ACK     = 8'hA5;       // Command ACK
localparam [7:0] RSP_SUCCESS = 8'h01;       // Success response
localparam [7:0] RSP_ERROR   = 8'hFF;       // Error/Timeout response
```

### 3. New States

```systemverilog
ST_RSP_ERROR      // Wishbone error (wb_err_i = 1)
ST_TIMEOUT_ERROR  // Timeout (no response within TIMEOUT_CYCLES)
```

### 4. Timeout Counter

```systemverilog
logic [15:0]     timeout_cnt;
logic            timeout_expired;

assign timeout_expired = (timeout_cnt >= TIMEOUT_CYCLES);
```

Monitors Wishbone wait time and detects when threshold exceeded.

### 5. Error Flag

```systemverilog
logic wb_error;  // Captured from wb_err_i
```

Records error condition for later reporting.

---

## Error Handling Flow

```
State: ST_WB_WAIT (waiting for Wishbone response)
         │
         ├─ wb_ack_i = 1 (ACK received)
         │   └─ Continue transaction (ST_RSP_DATA or ST_WB_START)
         │
         ├─ wb_err_i = 1 (Error asserted by slave)
         │   └─ Abort transaction → ST_RSP_ERROR
         │       Send: [ACK] [ERROR=0xFF] [TLAST]
         │
         ├─ timeout_expired = 1 (No response in time)
         │   └─ Abort transaction → ST_TIMEOUT_ERROR
         │       Send: [ACK] [ERROR=0xFF] [TLAST]
         │
         └─ (No change, keep waiting)
             timeout_cnt++
```

---

## Timeout Detection Logic

```systemverilog
// Timeout counter management
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        timeout_cnt <= 0;
    end else begin
        // Start timeout when entering WB_WAIT state
        if (state == ST_WB_START) begin
            timeout_cnt <= 0;
        end
        // Increment timeout counter while waiting for Wishbone ACK
        else if (state == ST_WB_WAIT) begin
            if (!wb_ack_i && !wb_err_i) begin
                timeout_cnt <= timeout_cnt + 1;
            end
        end
        else begin
            timeout_cnt <= 0;
        end
    end
end

// Check if timeout exceeded
assign timeout_expired = (timeout_cnt >= TIMEOUT_CYCLES);
```

---

## State Machine Changes

### ST_WB_WAIT (Before)
```systemverilog
ST_WB_WAIT: begin
    wb_cyc_o = 1;
    wb_stb_o = 1;
    wb_we_o  = cmd_is_write;
    if (wb_ack_i) begin  // ← Only checked ACK
        // Continue...
    end
end
```

### ST_WB_WAIT (After - WITH Error Handling)
```systemverilog
ST_WB_WAIT: begin
    wb_cyc_o = 1;
    wb_stb_o = 1;
    wb_we_o  = cmd_is_write;
    
    // Check for timeout
    if (timeout_expired) begin
        state_next = ST_TIMEOUT_ERROR;
    end
    // Check for Wishbone error
    else if (wb_err_i) begin
        state_next = ST_RSP_ERROR;
    end
    // Handle successful ACK
    else if (wb_ack_i) begin
        // Continue transaction...
    end
end
```

---

## Response States

### ST_RSP_ERROR (New)
Wishbone slave asserted error signal.

```systemverilog
ST_RSP_ERROR: begin
    m_axis_tvalid = 1;
    m_axis_tdata = RSP_ERROR;  // 0xFF
    m_axis_tlast = 1;
    if (m_axis_tready) begin
        state_next = ST_IDLE;
    end
end
```

### ST_TIMEOUT_ERROR (New)
Wishbone transaction exceeded timeout threshold.

```systemverilog
ST_TIMEOUT_ERROR: begin
    m_axis_tvalid = 1;
    m_axis_tdata = RSP_ERROR;  // 0xFF
    m_axis_tlast = 1;
    if (m_axis_tready) begin
        state_next = ST_IDLE;
    end
end
```

Both send `0xFF` error code with TLAST asserted.

---

## Configuration Examples

### Slow/Safe Setting (Recommended for Most Systems)
```systemverilog
wishbone_master_axis #(
    .ADDR_WIDTH(32),
    .DATA_WIDTH(32),
    .TIMEOUT_CYCLES(1000)     // 10 µs @ 100 MHz
) wb_bridge (
    // ...
);
```

### Fast Setting (Zero-Wait-State BRAM)
```systemverilog
wishbone_master_axis #(
    .ADDR_WIDTH(32),
    .DATA_WIDTH(32),
    .TIMEOUT_CYCLES(100)      // 1 µs @ 100 MHz
) wb_bridge (
    // ...
);
```

### Very Safe Setting (Slow or CDC Slaves)
```systemverilog
wishbone_master_axis #(
    .ADDR_WIDTH(32),
    .DATA_WIDTH(32),
    .TIMEOUT_CYCLES(100000)   // 1 ms @ 100 MHz
) wb_bridge (
    // ...
);
```

---

## Error Response Format

Both error conditions (wb_err_i or timeout) return the same response:

```
Host sends:   [CMD] [ADDR] [LEN] [DATA/DUMMY...]
Bridge sends: [ACK:0xA5] [ERROR:0xFF + TLAST]
                         └──────┬──────┘
                            Only 1 byte!
                            (No data payload)
```

**Key Point**: The ACK (`0xA5`) is sent **before** the bridge knows if the transaction will fail. This is correct AXIS behavior—the ACK indicates "command received", not "command succeeded".

---

## Testing

### Compile
```bash
cd /home/tcmichals/projects/busMaster
iverilog -g2009 -o sim.vvp wishbone_master_axis.sv tb_wishbone_master_axis.sv
```

### Run
```bash
vvp sim.vvp
```

### View Waveforms
```bash
gtkwave waveform.vcd &
```

Monitor signals:
- `state` — See ST_RSP_ERROR and ST_TIMEOUT_ERROR transitions
- `timeout_cnt` — Watch counter increment during WB_WAIT
- `wb_err_i` — Slave error signal
- `m_axis_tdata` — Check for `0xFF` on error

---

## What Happens Now vs Before

| Scenario | Before | After |
|----------|--------|-------|
| **Normal read** | ✓ Returns data | ✓ Returns data (same) |
| **Bad address** | ❌ Hangs (no response) | ✓ Returns 0xFF error |
| **Hung slave** | ❌ Hangs forever | ✓ Returns 0xFF after timeout |
| **Slow slave** | ⚠️ May timeout if TIMEOUT_CYCLES too small | ✓ Configurable timeout |

---

## Integration Notes

### For SPI Bridges
The SPI adapter sees error responses the same as success:
```
[0xA5] (ACK) [0xFF] (ERROR or 0x01 SUCCESS) [BREAK_BYTE]
```

Host software should check the second byte to detect errors.

### For Serial Bridges  
Same as SPI—error code is transparent to the physical layer.

```
Serial RX: [CMD] [ADDR] [LEN] [DATA...]
Serial TX: [0xA5] [0xFF or 0x01] [BREAK]
                   ↑
              Error vs Success
```

---

## Summary of Changes to RTL

**Lines Added**: ~80
**Lines Modified**: ~20
**New States**: 2 (ST_RSP_ERROR, ST_TIMEOUT_ERROR)
**New Logic**: Timeout counter, error handling in ST_WB_WAIT

**Total Impact**: 
- ✅ Prevents hang-on-error (critical fix)
- ✅ Graceful degradation (returns error code)
- ✅ Configurable timeout (adapts to system speed)
- ✅ Backward compatible (default parameter works for most systems)

