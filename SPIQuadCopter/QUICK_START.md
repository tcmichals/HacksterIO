# Tang9K Build & Program - Quick Reference

## Installation (One-Time Setup)

```bash
# Install Python 3.6+
# Then install apio
pip install apio

# Install Gowin tools
apio install gowin

# Verify
apio system-info
```

## Build & Program (Standard Workflow)

```bash
# Navigate to project
cd /path/to/SPIQuadCopter

# Build design
apio build

# Connect Tang9K via USB
# Then program:
apio upload
```

## Check Status

```bash
# View build log
tail build/project.log

# Verify bitstream created
ls -la build/project.gw

# Check USB connection
lsusb | grep -i gowin
```

---

## Troubleshooting Checklist

| Problem | Solution |
|---------|----------|
| `apio` not found | `pip install apio` |
| Gowin tools missing | `apio install gowin` |
| Build fails | `tail build/project.log` / check `src/tang9k_top.sv` |
| USB not found | Check connection / `lsusb` / `sudo chmod 666 /dev/ttyUSB0` |
| Pin errors | Verify `tang9k.cst` matches module ports |
| Synthesis error | Run `iverilog -g2009 -t null src/*.sv` for syntax check |

---

## File Locations

```
Project Root: /media/tcmichals/projects/Tang9K/hacksterio/HacksterIO/SPIQuadCopter/

Key Files:
├── apio.ini           ← Board configuration
├── tang9k.cst         ← Pin assignments
├── src/tang9k_top.sv  ← Top module (synthesized)
└── build/project.gw   ← Bitstream (programmed to FPGA)
```

---

## Essential Commands

```bash
# Build
apio build

# Build (verbose)
apio build --verbose

# Build (incremental - faster)
apio build --incremental

# Program
apio upload

# Program (verbose)
apio upload --verbose

# Clean
apio clean

# System info
apio system-info

# Help
apio --help
```

---

## Common Errors & Fixes

### Error: "Apio not installed"
```bash
pip install --upgrade apio
```

### Error: "Board not found"
```bash
# Check apio.ini
cat apio.ini

# Should show:
# [env]
# board = Tang9K
```

### Error: "Module not found"
```bash
# Verify all .sv files in src/
ls -la src/*.sv

# Check top module includes all modules
grep "include" src/tang9k_top.sv
```

### Error: "USB device not found"
```bash
# Linux: check USB
lsusb
ls -la /dev/ttyUSB*
sudo chmod 666 /dev/ttyUSB0

# Try again
apio upload
```

### Error: "Pin not in constraints"
```bash
# Check pins match
grep "output logic\|input logic" src/tang9k_top.sv
grep "=" tang9k.cst | grep "BANK"
```

---

## Performance Tips

```bash
# Faster incremental build
apio build --incremental

# Parallel synthesis (edit apio.ini)
[build]
threads = 4

# Lower optimization (faster builds)
[build]
opt_level = 1
```

---

## Testing & Simulation (Before Building)

```bash
# Simulate SPI slave
cd spiSlave
make simulate
make wave

# Simulate LED blinker
cd ../src
make simulate
make wave

# Back to project root
cd ..
```

---

## Verification Steps

After programming:

1. **Check LEDs**: Should blink in different patterns
   - LED0: Slow (~0.5 Hz)
   - LED1: Medium (~1 Hz)
   - LED2: Fast (~2 Hz)
   - LED3: Breathing effect

2. **Test SPI** (if master available):
   - Send commands
   - Monitor MISO output
   - Verify register reads/writes

3. **Monitor Timing**:
   - Connect oscilloscope
   - Verify clock frequencies
   - Check SPI timing

---

## Full Build Script

Save as `build.sh`:

```bash
#!/bin/bash
set -e
cd /path/to/SPIQuadCopter
echo "Building..."
apio build
echo "Connect board and press Enter..."
read
echo "Programming..."
apio upload
echo "Done! Check LEDs."
```

Run:
```bash
chmod +x build.sh
./build.sh
```

---

## Project Structure

```
SPIQuadCopter/
├── src/
│   ├── tang9k_top.sv        ← TOP LEVEL (synthesized)
│   └── pll.sv
├── spiSlave/
│   ├── spi_slave.sv
│   └── spi_slave_tb.sv
├── apio.ini                 ← BOARD CONFIG
├── tang9k.cst               ← PIN CONSTRAINTS
├── Makefile
├── BUILD_AND_PROGRAM.md     ← Full guide
└── build/                   ← Generated files
    ├── project.gw           ← BITSTREAM
    └── project.log          ← Build log
```

---

## One-Liner Commands

```bash
# Full cycle: build + program
apio build && apio upload

# Build with timing
time apio build

# Build with output saved
apio build > build.log 2>&1

# Check if tools installed
apio system-info | grep -i "gowin\|version"

# List available boards
apio boards --list | head -20

# View build report
less build/project.rpt
```

---

## Pin Assignment Format

File: `tang9k.cst`

```cst
# Format: <Signal_Name> = <Pin_Number> : <Bank> : <IO_Standard>;
# Comment: #

i_sys_clk      = 52 : BANK3 : LVCMOS33;     # Input example
o_led0         = 8  : BANK1 : LVCMOS33;     # Output example
```

Find pin numbers in Tang9K datasheet.

---

## Next Steps

1. ✅ Install apio: `pip install apio`
2. ✅ Install tools: `apio install gowin`
3. ✅ Build project: `apio build`
4. ✅ Program board: `apio upload`
5. ✅ Verify LEDs blink

---

**Apio Docs**: https://apiodocs.readthedocs.io/
**Support**: Check BUILD_AND_PROGRAM.md for detailed guide

