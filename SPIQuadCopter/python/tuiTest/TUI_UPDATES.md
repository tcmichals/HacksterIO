# Tang9K TUI Updates

## Recent Enhancements

### 1. Fixed NeoPixel Waterfall Worker Error

**Problem:** `WorkerError: Request to run a non-async function as an async worker`

**Solution:** Converted `run_waterfall()` to `run_waterfall_async()` using async/await pattern.

```python
async def run_waterfall_async(self) -> None:
    """Run NeoPixel waterfall effect (async worker)"""
    import asyncio
    offset = 0
    while self.waterfall_running:
        for i in range(8):
            color = COLORS_RAINBOW[(i + offset) % len(COLORS_RAINBOW)]
            self.tang9k.neopixel_set_color(i, color)
        
        self.tang9k.neopixel_update()
        offset = (offset + 1) % len(COLORS_RAINBOW)
        await asyncio.sleep(0.1)  # Non-blocking sleep
```

### 2. Hex/ASCII Dump Display for Serial Traffic

All serial traffic (TX and RX) is now displayed in professional hex dump format:

```
──── TX (23 bytes) ────
0000:  54 68 69 73 20 69 73 20 61 20 74 65 73 74 20 6D  |This is a test m|
0010:  65 73 73 61 67 65 0A                             |essage.|
```

**Features:**
- **Offset column**: Shows byte position in hex (0000, 0010, etc.)
- **Hex bytes**: 16 bytes per line in hexadecimal
- **ASCII column**: Printable characters shown, non-printable as '.'
- **Color coding**: 
  - Yellow: Offset
  - White: Hex bytes
  - Green: ASCII representation
  - Cyan: Header with byte count

### 3. Automatic RX Data Monitoring

The TUI now automatically checks for incoming serial data every 100ms and displays it in hex dump format.

```python
def check_serial_rx(self) -> None:
    """Check for incoming serial data"""
    try:
        data = self.tang9k.serial_read_available()
        if data:
            self.log_hex_dump("RX", data)
    except Exception as e:
        pass  # Silently ignore errors
```

### 4. New Tang9K Method: `serial_read_available()`

Added to `tang9k.py`:

```python
def serial_read_available(self, max_bytes: int = 256) -> bytes:
    """
    Read all available bytes from serial port
    
    Args:
        max_bytes: Maximum number of bytes to read (default 256)
        
    Returns:
        Bytes object with all available data (empty if none)
    """
    data = bytearray()
    for _ in range(max_bytes):
        byte = self.serial_read_byte()
        if byte is None:
            break
        data.append(byte)
    return bytes(data)
```

## Usage Examples

### Viewing Serial Traffic

1. **Start the TUI:**
   ```bash
   cd python/test
   python3 tang9k_tui.py
   ```

2. **Send a message:**
   - Type message in the input field
   - Press Enter or click "Send"
   - See hex dump in the log window

3. **Receive data:**
   - Any incoming serial data is automatically displayed
   - Shows in real-time with hex/ASCII format

### Example Serial Session

**Sending "Hello, World!":**
```
──── TX (14 bytes) ────
0000:  48 65 6C 6C 6F 2C 20 57 6F 72 6C 64 21 0A        |Hello, World!.|
```

**Receiving response:**
```
──── RX (12 bytes) ────
0000:  52 65 63 65 69 76 65 64 21 0D 0A                 |Received!..|
```

### NeoPixel Waterfall (No More Errors!)

- Click "NeoPixel Waterfall" or press 'w'
- Waterfall effect runs smoothly without worker errors
- Click "Stop Waterfall" to stop

## Technical Details

### Hex Dump Format Specification

```
[HEADER: "──── {label} ({byte_count} bytes) ────"]
[OFFSET]:  [HEX BYTES (16 per line)]  |[ASCII]|

Example:
──── TX (23 bytes) ────
0000:  54 68 69 73 20 69 73 20 61 20 74 65 73 74 20 6D  |This is a test m|
0010:  65 73 73 61 67 65 0A                             |essage.|
       ^    ^                                               ^
       |    |                                               |
    Offset  Hex bytes (space-separated)              ASCII (printable only)
```

### Character Display Rules

- **Printable ASCII (32-126)**: Shown as-is
- **Control characters (0-31, 127-255)**: Shown as '.'
- **Common control chars**:
  - `0A` (LF): `.`
  - `0D` (CR): `.`
  - `00` (NUL): `.`
  - `09` (TAB): `.`

### Performance

- **RX polling**: Every 100ms (10 Hz)
- **Max bytes per read**: 256 bytes
- **Display**: Non-blocking, doesn't freeze UI
- **Buffer**: Handles bursts of data gracefully

## Files Modified

1. **`python/test/tang9k_tui.py`**:
   - Fixed `run_waterfall()` → `run_waterfall_async()`
   - Added `log_hex_dump()` method
   - Added `check_serial_rx()` method
   - Updated `send_serial_message()` to use hex dump
   - Added 100ms interval for RX checking

2. **`python/test/tang9k.py`**:
   - Added `serial_read_available()` method
   - Reads all available bytes from UART
   - Returns as bytes object

3. **`python/test/test_hex_dump.py`** (NEW):
   - Test program for hex dump display
   - Shows various data formats
   - Validates output formatting

## Benefits

✅ **No more worker errors** - Async waterfall runs smoothly  
✅ **Professional hex display** - Easy to debug binary protocols  
✅ **Automatic RX monitoring** - See incoming data without manual refresh  
✅ **Non-blocking** - UI remains responsive during data display  
✅ **Readable format** - Both hex and ASCII for easy interpretation  
✅ **Color-coded** - Quick visual parsing of data  

## Testing

Run the hex dump test:
```bash
cd python/test
python3 test_hex_dump.py
```

Expected output shows various data formats in hex dump style.
