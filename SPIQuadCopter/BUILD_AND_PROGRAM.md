# Tang9K FPGA - Build and Programming Guide

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installation](#installation)
3. [Project Structure](#project-structure)
4. [Building with Apio](#building-with-apio)
5. [Programming the FPGA](#programming-the-fpga)
6. [Troubleshooting](#troubleshooting)
7. [Advanced Topics](#advanced-topics)

---

## Prerequisites

### Hardware Requirements

- **Tang9K Development Board** (GW1N-9K FPGA)
- **USB Cable** (USB Type-B or USB-C, depending on board variant)
- **Computer** (Linux, macOS, or Windows)

### Software Requirements

- **Python 3.6+** installed
- **pip** package manager
- **Git** (optional, for version control)
- **Make** (for running build targets)

---

## Installation

### 1. Install Python and pip

#### Ubuntu/Debian
```bash
sudo apt-get update
sudo apt-get install python3 python3-pip python3-venv
```

#### macOS
```bash
brew install python3
```

#### Windows
Download and install from [python.org](https://www.python.org/downloads/)

### 2. Install Apio

Apio is an open-source FPGA toolchain manager that simplifies building and uploading designs.

```bash
pip install apio
```

Verify installation:
```bash
apio --version
apio boards --list
```

### 3. Install Gowin Tools

Apio manages Gowin EDA tools automatically. Install the Gowin toolchain:

```bash
apio install gowin
```

This downloads and installs:
- Gowin EDA Suite (synthesis, place & route)
- Gowin IDE (optional, not needed for CLI)
- Programmer support

Monitor the installation progress - it may take 10-15 minutes.

### 4. Verify Installation

```bash
apio system-info
```

Output should show:
```
apio v0.x.x
----
System: Linux/macOS/Windows
Python: 3.x.x
...
```

---

## Project Structure

The Tang9K project is organized as follows:

```
SPIQuadCopter/
├── apio.ini                    # Apio configuration (board & device settings)
├── tang9k.cst                  # Pin constraint file (pin assignments)
├── Makefile                    # Build automation
├── README.md                   # Project documentation
├── PROJECT_SUMMARY.md          # Project overview
├── (example LED blinker removed)
│
├── spiSlave/                   # SPI Slave IP Core
│   ├── spi_slave.sv            # SPI slave implementation
│   ├── spi_slave_tb.sv         # Testbench
│   └── Makefile                # Test targets
│
├── src/                        # FPGA Source Files (synthesis target)
│   ├── tang9k_top.sv           # Top-level module (MUST EXIST)
│   ├── pll.sv                  # PLL configuration
│   ├── Makefile                # Simulation targets (module-specific)
│   └── *.vcd                   # Waveform files (generated)
│
└── build/                      # Generated output files (apio creates this)
    ├── project.json            # Apio project metadata
    ├── project.fs              # Synthesis output
    ├── project.net             # Netlist
    ├── project.sdc             # Timing constraints (generated)
    ├── project.cst             # Constraints (copy of tang9k.cst)
    ├── project.fs_tcl          # Tcl script
    └── project.gw              # Compiled bitstream
```

### Important Files

| File | Purpose |
|------|---------|
| `apio.ini` | Board and FPGA configuration |
| `tang9k.cst` | Pin assignments and constraints |
| `src/tang9k_top.sv` | Top-level module for synthesis |
| `build/` | Output directory (auto-created) |

---

## Building with Apio

### Step 1: Configure the Project

The `apio.ini` file should exist in the project root:

```ini
[env]
board = Tang9K

[build]
fpga = GW1N-9K
device = GW1N-9K
pack = LQFP144
freq = 27
```

Verify configuration:
```bash
apio boards --list | grep -i tang
```

### Step 2: Prepare Source Files

Ensure all Verilog files are in the `src/` directory:

```bash
ls -la src/
```

- Expected files:
- `tang9k_top.sv` (top-level module - **required**)
- `pll.sv`
- Any other supporting modules

**Important**: The top-level module must match the board name or be explicitly named `tang9k_top.sv`.

### Step 3: Add Pin Constraints

The `tang9k.cst` file contains pin assignments:

```cst
## Pin Format: <Signal_Name> = <Pin_Number> : <Bank> : <IO_Standard>;

i_sys_clk      = 52 : BANK3 : LVCMOS33;
i_rst_n        = 3  : BANK1 : LVCMOS33;
o_led0         = 8  : BANK1 : LVCMOS33;
o_led1         = 9  : BANK1 : LVCMOS33;
...
```

Verify pins match your module I/O:
```bash
grep "output logic\|input logic" src/tang9k_top.sv | head -20
```

### Step 4: Build the Project

Navigate to project root:
```bash
cd /path/to/SPIQuadCopter
```

Run full build:
```bash
apio build
```

Or use the Makefile:
```bash
make build
```

#### Build Output

```
Starting synthesis...
$ gowin_eda synthesis project.v
Elaborating design 'tang9k_top'...
... (synthesis log) ...
Synthesis complete in 5.2s

Starting place & route...
$ gowin_eda router project.net
... (routing log) ...
Routing complete in 12.3s

Build finished successfully!
Generated: build/project.gw
```

#### Build Artifacts Generated

| File | Description |
|------|-------------|
| `build/project.gw` | **Bitstream** (program this to FPGA) |
| `build/project.fs` | Netlist after synthesis |
| `build/project.net` | Placed & routed netlist |
| `build/project.sdc` | Timing constraints |
| `build/project.log` | Build log |
| `build/project.rpt` | Place & route report |

### Step 5: Verify Build Success

Check for errors:
```bash
tail -20 build/project.log
```

Look for:
```
Build finished successfully!
```

If errors occur, see [Troubleshooting](#troubleshooting) section.

---

## Programming the FPGA

### Method 1: Using Apio (Recommended)

#### Prerequisites for Programming

1. **Connect Tang9K to Computer**
   - Use USB cable (Type-B or USB-C)
   - Ensure power LED lights up (red)
   - Check USB connection: `lsusb` (Linux) or Device Manager (Windows)

2. **Identify USB Device**

   **Linux:**
   ```bash
   lsusb | grep -i gowin
   ```
   
   Output example:
   ```
   Bus 002 Device 003: ID 2b1c:559 Anlogic Digital Technology Co., Ltd USB Serial
   ```
   
   Or check `/dev/ttyUSB*`:
   ```bash
   ls -la /dev/ttyUSB*
   chmod 666 /dev/ttyUSB0  # May need sudo
   ```

   **Windows:**
   - Check Device Manager → Ports (COM & LPT)
   - Should show something like "USB Serial Device (COM3)"

   **macOS:**
   ```bash
   ls -la /dev/tty.usbserial*
   ```

#### Program the FPGA

```bash
apio upload
```

Or via Makefile:
```bash
make upload
```

#### Expected Output

```
Preparing to upload...
Programming device...
Verifying...
100% |████████████████████| Time: 0:00:05
Upload completed successfully!
```

#### Verify Programming

1. **Check LED Behavior**
   - LED0, LED1, LED2, LED3 should blink at different rates
   - LED3 should show breathing effect
   - Status LEDs may indicate activity

2. **Test SPI Interface** (if configured)
   - Connect SPI master
   - Send test commands
   - Monitor MISO output

### Method 2: Manual Programming with Programmer

If apio upload fails, use the Tang Programmer GUI:

```bash
# Linux/macOS - if installed via Gowin EDA
/path/to/Gowin/IDE/bin/openFPGALoader \
    -b tang9k \
    -f build/project.gw
```

### Method 3: Using openFPGALoader (Alternative)

Install openFPGALoader:
```bash
# Ubuntu/Debian
sudo apt-get install openfpgaloader

# macOS
brew install openfpgaloader

# Or build from source
git clone https://github.com/trabucayre/openFPGALoader.git
cd openFPGALoader && mkdir build && cd build
cmake .. && make && sudo make install
```

Program device:
```bash
openFPGALoader -b tang9k -f build/project.gw
```

---

## Complete Build & Program Workflow

### Quick Start (Recommended)

```bash
# Navigate to project
cd /media/tcmichals/projects/Tang9K/hacksterio/HacksterIO/SPIQuadCopter

# 1. Verify installation
apio system-info

# 2. Build project
apio build

# 3. Check build succeeded
ls -la build/project.gw

# 4. Connect board via USB

# 5. Program FPGA
apio upload

# 6. Observe LEDs blinking!
```

### Using Make Targets

```bash
# Syntax check
make lint

# Simulation (SPI slave)
cd spiSlave && make simulate

# Simulation (LED blinker)
cd src && make simulate

# Build design
cd .. && make build

# Program board
make upload

# Clean build artifacts
make clean
```

### Full Build Script

Create `build_and_program.sh`:

```bash
#!/bin/bash

set -e  # Exit on error

PROJECT_DIR="/media/tcmichals/projects/Tang9K/hacksterio/HacksterIO/SPIQuadCopter"
cd "$PROJECT_DIR"

echo "=========================================="
echo "Tang9K Build & Program Script"
echo "=========================================="

# Step 1: Verify tools
echo "[1/4] Verifying apio installation..."
apio --version
apio system-info

# Step 2: Check syntax
echo "[2/4] Running syntax checks..."
iverilog -g2009 -t null src/tang9k_top.sv src/pll.sv spiSlave/spi_slave.sv

# Step 3: Build design
echo "[3/4] Building FPGA design..."
apio build

# Step 4: Program board
echo "[4/4] Programming FPGA board..."
echo "Please ensure Tang9K is connected via USB"
read -p "Press Enter to continue or Ctrl+C to cancel..."
apio upload

echo "=========================================="
echo "Build and programming complete!"
echo "Check LEDs on the board - they should blink"
echo "=========================================="
```

Make it executable:
```bash
chmod +x build_and_program.sh
./build_and_program.sh
```

---

## Troubleshooting

### Common Issues & Solutions

#### 1. "Apio not found"

```
Command 'apio' not found
```

**Solution:**
```bash
# Reinstall apio
pip install --upgrade apio

# Verify installation
which apio
apio --version
```

#### 2. "Gowin tools not installed"

```
Error: Gowin toolchain not found
```

**Solution:**
```bash
apio install gowin
# Wait for download/installation to complete
apio system-info  # Verify installation
```

#### 3. "Board not found"

```
Error: Board 'Tang9K' not supported
```

**Solution:**
```bash
# Check apio configuration
cat apio.ini

# Verify board support
apio boards --list | grep -i tang

# Update apio
pip install --upgrade apio
```

#### 4. "Module not found during build"

```
Error: Cannot find module 'spi_slave'
```

**Solution:**
1. Ensure all `.sv` files are in `src/` directory:
   ```bash
   ls -la src/*.sv
   ```

2. Check that `tang9k_top.sv` includes all modules:
   ```bash
   grep "spi_slave" src/tang9k_top.sv
   ```

3. Verify module names match:
   ```bash
   grep "^module " src/*.sv
   ```

#### 5. "USB device not found"

```
Error: No USB device detected
```

**Solution:**

**Linux:**
```bash
# Check USB connection
lsusb

# Check serial devices
ls -la /dev/ttyUSB*

# Give permissions
sudo chmod 666 /dev/ttyUSB0

# Try upload again
apio upload
```

**Windows:**
- Check Device Manager for COM port
- Install USB drivers if needed
- Use full COM port path: `COMx`

**macOS:**
```bash
ls -la /dev/tty.usbserial*
brew install libusb
```

#### 6. "Pin not found in constraints"

```
Error: Pin 'o_led0' not in constraints file
```

**Solution:**
```bash
# Check pin definitions
grep "o_led" tang9k.cst

# Compare with module ports
grep "output logic" src/tang9k_top.sv

# Update tang9k.cst if needed
```

#### 7. "Synthesis fails"

```
Error in synthesis: Elaboration failed
```

**Solution:**
```bash
# Check syntax
iverilog -g2009 -t null src/tang9k_top.sv src/*.sv

# Check for invalid Verilog
grep -n "logic \[.*:0\]" src/tang9k_top.sv | head

# View synthesis log
tail -50 build/project.log
```

### Debug Commands

```bash
# Show apio configuration
apio projects --info

# Show build settings
cat build/project.json

# Check pin assignments
cat tang9k.cst | grep -v "^#"

# View synthesis report
cat build/project.rpt

# Check USB connectivity
apio system-info

# Clean and rebuild
apio clean
apio build
```

---

## Advanced Topics

### Custom Build Configuration

Edit `apio.ini` for advanced settings:

```ini
[env]
board = Tang9K

[build]
fpga = GW1N-9K
device = GW1N-9K
pack = LQFP144
freq = 27

[upload]
# Specify upload method
# Options: jtag, gowin, openFPGALoader
method = gowin
```

### Using Custom PLL

For higher clock speeds, use Gowin PLL core:

```bash
# Generate PLL IP
# Use Gowin EDA GUI to create PLL
# Save to src/gowin_pll.v
# Include in tang9k_top.sv
```

### Timing Constraints (Advanced)

Create `tang9k.sdc` for timing specifications:

```sdc
create_clock -period 37ns -name sys_clk [get_ports i_sys_clk]
set_input_delay -clock sys_clk -max 5ns [get_ports i_*]
set_output_delay -clock sys_clk -max 5ns [get_ports o_*]
```

### Incremental Build

For faster iterative builds:

```bash
apio build --incremental
```

### Debugging with Logic Analyzer

Insert debug signals into constraints:

```cst
# Debug signals to check on oscilloscope/analyzer
debug_sig0 = 40 : BANK1 : LVCMOS33;
debug_sig1 = 41 : BANK1 : LVCMOS33;
```

---

## Performance Optimization

### Reduce Build Time

1. **Incremental builds:**
   ```bash
   apio build --incremental
   ```

2. **Parallel synthesis:**
   ```bash
   # Edit apio.ini
   [build]
   threads = 4
   ```

3. **Lower optimization level:**
   ```ini
   [build]
   opt_level = 1  # 0-3, default 2
   ```

### Reduce FPGA Area

1. **Remove unused modules** from `tang9k_top.sv`
2. **Use parameterized modules** with smaller data widths
3. **Optimize logic** with constant propagation

### Improve Timing

1. **Increase clock period** in `apio.ini`:
   ```ini
   freq = 20  # Slower = easier to meet timing
   ```

2. **Add timing constraints** in `.sdc` file
3. **Place critical paths** with `.cst` directives

---

## Frequently Asked Questions

### Q1: Can I program without installing full Gowin EDA?

**A:** Yes! Apio installs only the necessary tools. You don't need the GUI.

### Q2: How do I see verbose build output?

**A:** Check `build/project.log` after build completes.

### Q3: Can I use a different USB programmer?

**A:** Yes, use openFPGALoader or Tang Programmer alternative tools.

### Q4: How do I revert to a previous build?

**A:** Bitstreams aren't version-controlled. Keep `build/` backups:
```bash
cp build/project.gw backup/project_v1.0.gw
```

### Q5: What's the difference between .gw and .fs files?

- **.gw**: Compiled bitstream (program this to FPGA)
- **.fs**: Formatted stream after synthesis (intermediate)

---

## Useful Commands Reference

```bash
# Project Management
apio projects --list
apio projects --info
apio boards --list

# Building
apio build                          # Full build
apio build --verbose               # Verbose output
apio clean                          # Clean build artifacts

# Programming
apio upload                         # Program via USB
apio upload --verbose              # Show upload progress

# System
apio system-info                    # System information
apio install gowin                  # Install Gowin tools
apio uninstall gowin                # Remove Gowin tools

# Help
apio --help
apio build --help
apio upload --help
```

---

## Additional Resources

- **Apio Documentation**: https://apiodocs.readthedocs.io/
- **Gowin FPGA**: http://www.gowinsemi.com/
- **Tang9K Datasheet**: Search for "Tang9K GW1N-9K datasheet"
- **openFPGALoader**: https://github.com/trabucayre/openFPGALoader
- **iverilog**: http://iverilog.icarus.com/

---

## Getting Help

If you encounter issues:

1. Check this guide's [Troubleshooting](#troubleshooting) section
2. Review build logs: `tail build/project.log`
3. Check system info: `apio system-info`
4. Verify USB connection: `lsusb | grep -i gowin`
5. Ask in community forums:
   - [Apio Issues](https://github.com/FPGAwars/apio/issues)
   - [Gowin Community](http://www.gowinsemi.com/)
   - [EEVblog Forums](https://www.eevblog.com/forum/)

---

**Last Updated**: December 7, 2025
**Project**: Tang9K SPI Slave with LED Blinker
**Author**: Documentation System
