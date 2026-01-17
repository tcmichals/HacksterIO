# Tang9K FPGA - Build and Programming Guide

## Quick Start

```bash
# 1. Install toolchain
make install-tools-local    # Install OSS CAD Suite to ~/.local/oss-cad-suite/

# 2. Add to PATH (add to ~/.bashrc for persistence)
export PATH="$HOME/.local/oss-cad-suite/bin:$PATH"

# 3. Build project
make build

# 4. Program FPGA
make upload
```

---

## Prerequisites

### Hardware
- **Tang9K Development Board** (GW1N-9K FPGA)
- **USB Cable** for programming
- **Computer** (Linux, macOS, or Windows)

### Software
- **Python 3.6+** and **pip**
- **Make** (build automation)
- **OSS CAD Suite** (installed via Makefile)

---

## Toolchain Installation

### Option 1: Install via System Package Manager (Recommended)

```bash
make install-tools
```

This installs:
- `yosys` - Synthesis
- `nextpnr-himbaechel` - Place & Route
- `gowin_pack` - Bitstream generation
- `openFPGALoader` - Programming

### Option 2: Install Locally to ~/.local/oss-cad-suite

```bash
make install-tools-local
```

Downloads and installs OSS CAD Suite to `~/.local/oss-cad-suite`.

**Add to PATH:**
```bash
echo 'export PATH="$HOME/.local/oss-cad-suite/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Verify Installation

```bash
yosys -V
nextpnr-himbaechel --version
gowin_pack --help
openFPGALoader --help
```

---

## Building the FPGA Design

### Build Commands

```bash
# Full build (synthesis + place & route + pack)
make build

# Individual steps
make synth    # Synthesis only
make place    # Place & route only  
make pack     # Bitstream packing only

# Syntax check
make lint

# Clean artifacts
make clean
```

### Build Output

```
_build/default/
├── hardware.json        # Yosys synthesis output
├── hardware.pnr.json    # nextpnr place & route
└── hardware.fs          # Final bitstream (THIS IS THE FILE YOU PROGRAM)
```

### Build Process

1. **Synthesis** (`yosys`): Converts SystemVerilog → netlist
2. **Place & Route** (`nextpnr-himbaechel`): Maps netlist → FPGA fabric
3. **Packing** (`gowin_pack`): Generates `.fs` bitstream file

---

## Programming the FPGA

### Step 1: Connect Board

1. Connect Tang9K to computer via USB
2. Verify connection:
   ```bash
   lsusb | grep -i gowin
   ```

### Step 2: Program

```bash
make upload
```

**Or manually**:
```bash
openFPGALoader -b tangnano9k -f _build/default/hardware.fs
```

### Step 3: Verify

- Check LED behavior (should match your design)
- Monitor with logic analyzer if needed

---

## Project Structure

```
SPIQuadCopter/
├── tang9k.cst           # Pin constraints (CRITICAL)
├── Makefile             # Build automation
├── src/                 # SystemVerilog sources
│   ├── tang9k_top.sv    # Top-level module
│   ├── coredesign.sv    # Core logic
│   ├── wb_*.sv          # Wishbone peripherals
│   └── *.sv             # Other modules
├── _build/              # Build artifacts (generated)
└── src/tb/              # Testbenches
```

### Important Files

| File | Purpose |
|------|---------|
| `tang9k.cst` | Pin assignments and I/O standards |
| `src/tang9k_top.sv` | Top-level FPGA module |
| `Makefile` | Build rules and targets |
| `_build/default/hardware.fs` | **Final bitstream** |

---

## Troubleshooting

### "yosys not found"

```bash
# Install toolchain
make install-tools-local

# Add to PATH
export PATH="$HOME/.local/oss-cad-suite/bin:$PATH"
```

### "USB device not found"

```bash
# Linux: Check permissions
lsusb
sudo chmod 666 /dev/ttyUSB0

# List devices
openFPGALoader --detect
```

### "Synthesis failed"

```bash
# Check syntax first
make lint

# View full error log
less _build/default/hardware.json

# Check pin constraints match
grep "^module tang9k_top" src/tang9k_top.sv
```

### "Pin not found in constraints"

```bash
# Compare module ports with CST file
grep "output\|input" src/tang9k_top.sv
grep "IO_LOC" tang9k.cst

# Update tang9k.cst if needed
```

---

## Testing

### Run Testbenches

```bash
# Design testbench (full integration)
make tb-design

# UART pass through testbench
make tb-passthrough

# All testbenches
make test-tb
```

### Simulation

```bash
# SPI slave simulation
cd spiSlave && make simulate

# PWM decoder simulation
cd pwmDecoder && make simulate

# DSHOT simulation  
cd dshot && make simulate
```

---

## Advanced Topics

### Custom Timing Constraints

Create `tang9k.sdc`:
```sdc
create_clock -period 13.889ns -name sys_clk [get_ports i_sys_clk]  # 72MHz
set_input_delay -clock sys_clk -max 5ns [get_ports i_*]
set_output_delay -clock sys_clk -max 5ns [get_ports o_*]
```

### Incremental Builds

```bash
# Only rebuild changed files
make -j4 build  # Parallel build (4 jobs)
```

### Debug Signals

Add debug pins in `tang9k.cst`:
```cst
IO_LOC "debug_sig0" 40;
IO_PORT "debug_sig0" IO_TYPE=LVCMOS33;
```

---

## Makefile Targets Reference

```bash
# Building
make build           # Full synthesis + P&R + pack
make synth           # Synthesis only
make place           # Place & route only
make pack            # Pack bitstream only
make lint            # Syntax check

# Programming
make upload          # Program FPGA

# Testing
make tb-design       # Run design testbench
make tb-passthrough  # Run passthrough testbench
make test-tb         # Run all testbenches

# Maintenance
make clean           # Clean build artifacts
make help            # Show all targets

# Toolchain
make install-tools         # Install via package manager
make install-tools-local   # Install to ~/.tools
```

---

## Build Configuration

Edit `Makefile` to customize:

```makefile
# Change device
NEXTPNR_FLAGS := --device GW1NR-LV9QN88PC6/I5 ...

# Change optimization
YOSYS_FLAGS := -p "synth_gowin -top $(TOP) -json ..."

# Change programmer
OPENFPGALOADER := openFPGALoader
```

---

##Serial Passthrough Notes

**Motor pins are now bidirectional (inout) for BLHeli configuration:**

- Pins 32-35 (`o_motor1`..`o_motor4`) support both DSHOT and serial passthrough
- Select which motor pin via mux register (0x0400 bits 2:1)
- Pin 25 (`serial`) has been **removed**

**Mux Register (0x0400)**:
```
Bit 2:1: mux_ch (Channel select 0-3)
Bit 0:   mux_sel (0=Passthrough, 1=DSHOT)

Examples:
  0x00 = Passthrough on Motor 1 (Pin 32)
  0x02 = Passthrough on Motor 2 (Pin 33)
  0x04 = Passthrough on Motor 3 (Pin 34)
  0x06 = Passthrough on Motor 4 (Pin 35)
  0x01 = DSHOT mode (flight)
```

See [BLHELI_PASSTHROUGH.md](BLHELI_PASSTHROUGH.md) for BLHeli configuration details.

---

## Resources

- **OSS CAD Suite**: https://github.com/YosysHQ/oss-cad-suite-build
- **openFPGALoader**: https://github.com/trabucayre/openFPGALoader
- **Yosys Manual**: https://yosyshq.readthedocs.io/
- **Tang Nano 9K**: https://wiki.sipeed.com/hardware/en/tang/Tang-Nano-9K/Nano-9K.html

---

## Getting Help

If you encounter issues:

1. Check `make help` for available targets
2. Review build logs in `_build/default/`
3. Verify tool installation: `yosys -V`, `nextpnr-himbaechel --version`
4. Check pin constraints match module ports
5. Test with `make tb-design` before programming

For BLHeli passthrough issues, see [HARDWARE_PINS.md](HARDWARE_PINS.md).
