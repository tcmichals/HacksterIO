#!/bin/bash
# Runner for wb_serial_dshot_mux_tb
set -euo pipefail
cd "$(dirname "$0")"
# Build with iverilog if available, else try Makefile pattern
BUILD_DIR="build"
mkdir -p "$BUILD_DIR"
iverilog -g2012 -D SIM_CONTROL -o "$BUILD_DIR/wb_serial_dshot_mux_tb.vvp" wb_serial_dshot_mux_tb.sv wb_serial_dshot_mux.sv || { echo "iverilog build failed"; exit 1; }
vvp "$BUILD_DIR/wb_serial_dshot_mux_tb.vvp" | tee "$BUILD_DIR/wb_serial_dshot_mux_tb.log"
