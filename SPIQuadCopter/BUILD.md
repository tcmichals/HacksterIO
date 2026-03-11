# Building the SPI Quadcopter FPGA Project

This project uses CMake for building both the FPGA bitstream and VexRiscv firmware.

## Prerequisites

### Tang Nano 20K (Gowin GW2AR-18)

Install OSS CAD Suite:

```bash
# Download latest release
curl -LO https://github.com/YosysHQ/oss-cad-suite-build/releases/download/2024-01-01/oss-cad-suite-linux-x64-20240101.tgz

# Extract to ~/.local
mkdir -p ~/.local
tar -xzf oss-cad-suite-*.tgz -C ~/.local

# Add to PATH (add to ~/.bashrc)
export PATH="$HOME/.local/oss-cad-suite/bin:$PATH"
```

### Arty S7-50 (Xilinx XC7S50)

Install Xilinx Vivado 2023.2 or later. Set the environment:

```bash
source /opt/Xilinx/Vivado/2023.2/settings64.sh
```

### VexRiscv Firmware (Both Platforms)

Install RISC-V GCC toolchain:

```bash

# xPack prebuilt toolchain
curl -LO https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases/download/v13.2.0-2/xpack-riscv-none-elf-gcc-13.2.0-2-linux-x64.tar.gz
mkdir -p ~/.local
tar -xzf xpack-riscv-none-elf-gcc-*.tar.gz -C ~/.local
export PATH="$HOME/.local/xpack-riscv-none-elf-gcc-13.2.0-2/bin:$PATH"
```

### VexRiscv CPU Core Generation (One-time setup)

The VexRiscv RISC-V CPU core must be generated from SpinalHDL before building the bitstream.

**Requirements:**
- Java 11 or Java 17 (Java 21+ is NOT compatible with Scala 2.12)
- sbt (Scala Build Tool)

```bash
# Install Java 11 (Ubuntu/Debian)
sudo apt install openjdk-11-jdk

# Install sbt
echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | sudo tee /etc/apt/sources.list.d/sbt.list
curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | sudo apt-key add
sudo apt update && sudo apt install sbt
```

**Generate VexRiscv.v:**

```bash
# Set Java 11 (if multiple Java versions installed)
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

# Run the generator script
./scripts/generate_vexriscv.sh

# Or manually:
cd vexriscv
sbt "runMain vexriscv.demo.GenSPICopterCpu"
```

Output: `src/cpu/VexRiscv.v`

## Quick Start

### Tang Nano 20K

```bash
# Configure for Tang Nano 20K
cmake -B build -DPLATFORM=tangnano20k

# Build everything (firmware + bitstream) with parallel jobs
cmake --build build --target bitstream -j$(nproc)

# Program the board
cmake --build build --target upload
```

### Arty S7-50

```bash
# Configure for Arty S7-50
cmake -B build -DPLATFORM=artys7

# Build everything
cmake --build build --target bitstream -j$(nproc)

# Program the board
cmake --build build --target upload
```

## Build Targets

| Target | Description |
|--------|-------------|
| `bitstream` | Full build: firmware + synthesis + P&R + bitstream |
| `firmware` | Build VexRiscv firmware only |
| `synth` | Run synthesis only |
| `place` | Run place & route only |
| `upload` | Program FPGA (volatile) |
| `upload-flash` | Program FPGA flash (Tang Nano 20K only) |
| `stats` | Show resource utilization report |
| `test` | Run all testbenches |

## Build Options

| Option | Default | Description |
|--------|---------|-------------|
| `PLATFORM` | `tangnano20k` | Target: `tangnano20k` or `artys7` |
| `BUILD_FIRMWARE` | `ON` | Build VexRiscv firmware |
| `PNR_SEED` | `42` | Place & route seed (Tang Nano 20K) |

Example with options:

```bash
cmake -B build \
    -DPLATFORM=tangnano20k \
    -DBUILD_FIRMWARE=ON \
    -DPNR_SEED=123
```

## Parallel Build

The CMake build system has proper dependencies for parallel builds:

```
firmware (C++)  ─┬─► bitstream
                 │
synth ──► place ─┘
```

- `synth` and `firmware` can run in parallel
- `place` depends on `synth`
- `bitstream` depends on `place` and `firmware`

Use `-j` flag for parallel builds:

```bash
cmake --build build --target bitstream -j8
```

## Directory Structure

```
build/
├── firmware/              # VexRiscv firmware build
│   ├── firmware.elf       # ELF executable
│   ├── firmware.bin       # Raw binary
│   └── firmware.mem       # Verilog memory file (for FPGA)
├── hardware.json          # Synthesis output (Tang Nano 20K)
├── hardware.pnr.json      # P&R output (Tang Nano 20K)
├── hardware.fs            # Bitstream (Tang Nano 20K)
└── hardware.bit           # Bitstream (Arty S7)
```

## Firmware Only

To build just the firmware without FPGA synthesis:

```bash
cmake --build build --target firmware
```

The firmware output is in `build/firmware/firmware.mem`.

## Running Testbenches

```bash
# All testbenches
cmake --build build --target test

# Individual testbenches
cmake --build build --target tb-spi-wb
cmake --build build --target tb-version
```

## Troubleshooting

### "yosys not found"

Ensure OSS CAD Suite is in your PATH:

```bash
export PATH="$HOME/.local/oss-cad-suite/bin:$PATH"
```

### "riscv-none-elf-gcc not found"

Install RISC-V toolchain or disable firmware build:

```bash
cmake -B build -DPLATFORM=tangnano20k -DBUILD_FIRMWARE=OFF
```

### "Timing not met"

Try a different P&R seed:

```bash
cmake -B build -DPLATFORM=tangnano20k -DPNR_SEED=999
cmake --build build --target bitstream -j$(nproc)
```

### "Device not found" (upload)

Check USB connection and udev rules. For Tang Nano 20K:

```bash
# Add udev rules
sudo cp scripts/udev/99-openfpgaloader.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules
sudo udevadm trigger
```

## Clean Build

```bash
# Remove build directory
rm -rf build

# Or use CMake
cmake --build build --target clean-all
```
