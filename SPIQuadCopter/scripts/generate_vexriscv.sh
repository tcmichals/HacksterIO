#!/bin/bash
# =============================================================================
# Generate VexRiscv Verilog from SpinalHDL
# =============================================================================
# Usage:
#   ./scripts/generate_vexriscv.sh          # Generate standard VexRiscv
#   ./scripts/generate_vexriscv.sh --jtag   # Generate VexRiscv with JTAG TAP
#
# Custom CPU generators are in scala/vexriscv/demo/ (checked into git).
# VexRiscv submodule provides the base CPU infrastructure.
# =============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
OUTPUT_DIR="$PROJECT_DIR/src/cpu"

# Check for --jtag flag
if [ "$1" = "--jtag" ]; then
    GENERATOR="GenSPICopterCpuJtag"
    GEN_FILE="VexRiscvJtag.v"
    echo "=== Generating VexRiscv with JTAG TAP ==="
    echo "Configuration: RV32IMC, Wishbone Bus, Hardware JTAG"
else
    GENERATOR="GenSPICopterCpu"
    GEN_FILE="VexRiscv.v"
    echo "=== Generating VexRiscv Verilog ==="
    echo "Configuration: RV32IMC, Wishbone Bus"
fi
echo ""

# Run sbt from project root (uses build.sbt that references vexriscv submodule)
cd "$PROJECT_DIR"

echo "Running sbt to generate Verilog..."
sbt "runMain vexriscv.demo.$GENERATOR"

# Copy generated file to destination
mkdir -p "$OUTPUT_DIR"

if [ -f "$GEN_FILE" ]; then
    mv "$GEN_FILE" "$OUTPUT_DIR/"
    # Also move the YAML file if generated
    [ -f "cpu0.yaml" ] && mv cpu0.yaml "$OUTPUT_DIR/"
else
    echo "Error: $GEN_FILE not found"
    exit 1
fi

echo ""
echo "=== VexRiscv generated successfully ==="
echo "Output: $OUTPUT_DIR/$GEN_FILE"
fi

echo ""
echo "=== VexRiscv generated successfully ==="
echo "Output: $OUTPUT_DIR/$GEN_FILE"
