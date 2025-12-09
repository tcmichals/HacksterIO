#!/bin/bash
# Run UART Passthrough Bridge Testbench

set -e

echo "=========================================="
echo "UART Passthrough Bridge Testbench Runner"
echo "=========================================="
echo ""

# Check if Icarus Verilog is installed
if ! command -v iverilog &> /dev/null; then
    echo "Error: Icarus Verilog (iverilog) not found!"
    echo "Install with: sudo apt-get install iverilog"
    exit 1
fi

# Check for required source files
REQUIRED_FILES="uart_passthrough_bridge.sv uart_passthrough_bridge_tb.sv"
MISSING=0

for file in $REQUIRED_FILES; do
    if [ ! -f "$file" ]; then
        echo "Error: Missing required file: $file"
        MISSING=1
    fi
done

# Check for UART modules (may need adjustment based on your project)
if [ ! -f "uart_rx.sv" ] && [ ! -f "../uart_rx.sv" ]; then
    echo "Warning: uart_rx.sv not found in current or parent directory"
    echo "Please ensure UART modules are available"
fi

if [ $MISSING -eq 1 ]; then
    echo ""
    echo "Please ensure all required files are present."
    exit 1
fi

# Create build directory
mkdir -p build

echo "Compiling testbench..."
# Adjust the source paths based on where your UART modules are located
iverilog -g2012 -Wall -Wno-timescale \
    -o build/uart_passthrough_bridge_tb.vvp \
    uart_passthrough_bridge_tb.sv \
    uart_passthrough_bridge.sv \
    uart_rx.sv \
    uart_tx.sv \
    2>&1 | tee build/compile.log

if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo ""
    echo "Compilation failed! See build/compile.log for details."
    exit 1
fi

echo ""
echo "Compilation successful!"
echo ""
echo "Running simulation..."
echo "=========================================="

vvp build/uart_passthrough_bridge_tb.vvp | tee build/simulation.log

echo "=========================================="
echo ""

if [ -f "uart_passthrough_bridge_tb.vcd" ]; then
    echo "Simulation complete!"
    echo "VCD file generated: uart_passthrough_bridge_tb.vcd"
    echo ""
    echo "View waveforms with:"
    echo "  gtkwave uart_passthrough_bridge_tb.vcd"
    echo ""
    
    # Ask if user wants to open GTKWave
    if command -v gtkwave &> /dev/null; then
        read -p "Open waveform viewer now? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            # Open GTKWave and load the save file if it exists
            if [ -f "uart_passthrough_bridge_tb.gtkw" ]; then
                echo "Loading signal configuration from uart_passthrough_bridge_tb.gtkw..."
                gtkwave uart_passthrough_bridge_tb.vcd uart_passthrough_bridge_tb.gtkw &
            else
                gtkwave uart_passthrough_bridge_tb.vcd &
            fi
        fi
    fi
else
    echo "Warning: VCD file not generated"
fi

echo ""
echo "Logs saved in build/ directory:"
echo "  - build/compile.log"
echo "  - build/simulation.log"
