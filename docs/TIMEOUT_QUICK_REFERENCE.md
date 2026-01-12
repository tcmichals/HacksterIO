# Quick Reference: Timeout Configuration

## TL;DR - Which TIMEOUT_CYCLES Should I Use?

```systemverilog
// Unsure? Use this (works for 90% of cases)
.TIMEOUT_CYCLES(1000)      // 10 µs @ 100 MHz, 20 µs @ 50 MHz

// Fast paths only (BRAM, on-chip)
.TIMEOUT_CYCLES(100)       // 1 µs @ 100 MHz

// Slow/external devices
.TIMEOUT_CYCLES(10000)     // 100 µs @ 100 MHz

// Very slow or CDC
.TIMEOUT_CYCLES(100000)    // 1 ms @ 100 MHz
```

---

## Timeout Values vs System Speed

| Clock | 100 cycles | 1K cycles | 10K cycles | 100K cycles |
|-------|-----------|-----------|-----------|------------|
| **25 MHz** | 4 µs | 40 µs | 400 µs | 4 ms |
| **50 MHz** | 2 µs | 20 µs | 200 µs | 2 ms |
| **100 MHz** | 1 µs | 10 µs | 100 µs | 1 ms |
| **200 MHz** | 0.5 µs | 5 µs | 50 µs | 500 µs |

**How to calculate**: Duration = TIMEOUT_CYCLES / Clock_MHz × 1 µs

**Example**: TIMEOUT_CYCLES=2500 @ 100 MHz = 2500 / 100 = 25 µs

---

## Error Response Timing

### Best Case (No Error)
```
Beat 0: [ACK]  (0xA5)
Beat 1-4: [DATA] (if read)
Beat 5: [SUCCESS] (0x01) with TLAST
```
**Total**: 5-6 beats (depends on read/write)

### Worst Case (Timeout)
```
Beat 0: [ACK]  (0xA5) - sent immediately
Beat 1-N: (waiting for WB response, counting timeout)
Beat N+1: [ERROR] (0xFF) with TLAST - when TIMEOUT_CYCLES exceeded
```
**Total**: ACK_latency + TIMEOUT_CYCLES + response_latency

**Example**: TIMEOUT_CYCLES=1000, ACK_latency=2 beats
- Error arrives after ~1002-1010 clock cycles

---

## Real-World Examples

### Example 1: Read from BRAM

```
Clock: 100 MHz
Target: Block RAM (0 wait states)
TIMEOUT_CYCLES: 100
```

**What happens**:
- Cycle 0-1: WB_START, STB asserted
- Cycle 2: BRAM responds with ACK (fast path)
- Cycle 3-6: Data returned to host
- **Total**: ~8 cycles = 80 ns (very fast!)

### Example 2: Read from DDR Memory

```
Clock: 100 MHz
Target: DDR3 via AXI slave (~20 cycle latency)
TIMEOUT_CYCLES: 5000
```

**What happens**:
- Cycle 0-1: WB_START, STB asserted
- Cycle 1-20: Waiting... (timeout_cnt = 0-19)
- Cycle 20: DDR slave responds with ACK
- Cycle 21-24: Data returned to host
- **Total**: ~26 cycles = 260 ns

**If timeout**: Would trigger at cycle 5001, return 0xFF error

### Example 3: Cross-Clock Domain (Slow)

```
Clock: 100 MHz (WB side)
Clock: 10 MHz (Slave side, CDC sync)
TIMEOUT_CYCLES: 50000
```

**What happens**:
- Cycle 0-1: WB_START, STB asserted
- Cycle 1-2000: Waiting for CDC sync + slave response
- Cycle 2000: Slave responds with ACK (via CDC)
- Cycle 2001-2004: Data returned
- **Total**: ~2010 cycles = 20.1 µs

**Margin**: timeout_cycles=50000 gives 500 µs buffer

---

## How to Detect Which Timeout You Need

### Step 1: Know Your Target Latency

Use Wishbone analyzer or simulation:
```verilog
// In testbench, monitor response time
logic [15:0] response_time;

always_ff @(posedge clk) begin
    if (wb_stb_o && !wb_ack_i && !response_time_started)
        response_timer <= 1;
    
    if (response_timer)
        response_time <= response_time + 1;
    
    if (wb_ack_i) begin
        $display("Response took %d cycles", response_time);
        response_timer <= 0;
    end
end
```

### Step 2: Add Safety Margin

```
TIMEOUT_CYCLES = measured_latency × 2  (or 3x for very variable slaves)

Examples:
- BRAM (measured: 2 cycles) → use 100 (50x margin)
- DDR (measured: 20 cycles) → use 200 (10x margin)  
- Cross-domain (measured: 2000 cycles) → use 5000 (2.5x margin)
```

### Step 3: Test with Slow Slave

Deliberately slow down slave, verify timeout triggers:
```verilog
// In testbench
initial begin
    repeat(TIMEOUT_CYCLES + 100) @(posedge clk);
    // If we're still in ST_WB_WAIT, timeout should have fired
    assert(state == ST_TIMEOUT_ERROR) else $error("Timeout not detected!");
end
```

---

## Error Codes Explained

| Code | Hex | Meaning | Next Action |
|------|-----|---------|------------|
| **0xA5** | `0xA5` | Command ACK (always sent) | Expect data or status |
| **0x01** | `0x01` | Success | Transaction complete |
| **0xFF** | `0xFF` | Error or Timeout | Retry or fail |

**Remember**: Host sees `0xA5` regardless of error—this is correct! The ACK means "command received", not "command succeeded".

---

## Common Mistakes

❌ **Mistake 1: Setting TIMEOUT_CYCLES too low**
```systemverilog
.TIMEOUT_CYCLES(10)  // ← Too short! Will timeout on slow slaves
```
✅ **Fix**: Add margin
```systemverilog
.TIMEOUT_CYCLES(1000)  // Much safer
```

❌ **Mistake 2: Ignoring error responses**
```python
# Bad code
ack = port.read(1)  # 0xA5
data = port.read(4)  # May be garbage if error occurred!
```
✅ **Fix**: Check for error**
```python
# Good code
ack = port.read(1)
status = port.read(1)
if status == 0xFF:
    print("Error!")
else:
    data = port.read(4)  # Safe to read now
```

❌ **Mistake 3: Not scaling timeout with clock**
```systemverilog
// Running at 50 MHz but configured for 100 MHz
.TIMEOUT_CYCLES(1000)  // Now 20 µs instead of 10 µs!
```
✅ **Fix**: Recalculate or use conservative value
```systemverilog
.TIMEOUT_CYCLES(1000)  // Safe at any clock speed ≤ 100 MHz
```

---

## Debugging Timeout Issues

### Issue: "Timeout triggered too often"

**Cause 1**: Timeout too short for your slave
```bash
# Check actual slave latency
# In simulation: monitor response_time register
# Add 10x margin: TIMEOUT_CYCLES = measured × 10
```

**Cause 2**: Wishbone protocol violation
```verilog
// Check these signals during WB_WAIT
assert(wb_cyc_o == 1) else $error("CYC dropped!");
assert(wb_stb_o == 1) else $error("STB dropped!");
// Slave should assert either wb_ack_i or wb_err_i
```

**Solution**:
```systemverilog
// Increase TIMEOUT_CYCLES significantly
.TIMEOUT_CYCLES(10000)  // 100 µs instead of 10 µs
```

### Issue: "Timeout never triggers even when slave hangs"

**Cause 1**: Slave is responding (maybe with error)
```verilog
if (wb_err_i) begin
    // Won't timeout! wb_err_i was asserted first
    state_next = ST_RSP_ERROR;
end
```

**Cause 2**: STB/CYC dropped before timeout
```verilog
// If bridge goes back to IDLE before timeout_cnt reaches limit:
if (state == ST_WB_START)
    timeout_cnt <= 0;  // Counter resets!
```

**Solution**: Add monitoring
```verilog
if (timeout_expired && state == ST_WB_WAIT)
    $display("Timeout fired!");
else
    $display("Timeout did NOT fire - state=%s, count=%d", 
             state.name(), timeout_cnt);
```

---

## Recommended Starting Points

### New System (Don't Know Slave Latency)
```systemverilog
.TIMEOUT_CYCLES(1000)  // 10 µs @ 100 MHz
```
Safe default. If timeouts occur, increase; if not used, decrease.

### Simulation Only
```systemverilog
.TIMEOUT_CYCLES(100000)  // Very generous, 1 ms @ 100 MHz
```
Testing, not performance. Make sure code handles errors.

### Production System (Known Slave)
```systemverilog
.TIMEOUT_CYCLES(measured_latency * 5)  // 5x safety margin
```
Based on actual system characterization.

### Safety-Critical (Space, Medical, etc.)
```systemverilog
.TIMEOUT_CYCLES(measured_latency * 20)  // 20x safety margin
```
Much higher confidence in error detection.

---

## Verification Checklist

- [ ] Know your Wishbone slave's maximum latency
- [ ] Set TIMEOUT_CYCLES ≥ max_latency × 2
- [ ] Run simulation with stuck slave, verify timeout triggers
- [ ] Test error response in SPI/Serial host code
- [ ] Log all timeout events in production
- [ ] Have fallback behavior when error occurs (retry, fail-safe, etc.)

