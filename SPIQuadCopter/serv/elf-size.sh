#!/bin/bash
# elf-size.sh - Display firmware size information
# Usage: ./elf-size.sh [firmware.elf]

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ELF_FILE="${1:-$SCRIPT_DIR/firmware/firmware.elf}"

# Toolchain path (same as Makefile)
XPACK_VERSION="15.2.0-1"
XPACK_DIR="$HOME/.local/tools/xpack-riscv-none-elf-gcc-$XPACK_VERSION"
SIZE="$XPACK_DIR/bin/riscv-none-elf-size"
NM="$XPACK_DIR/bin/riscv-none-elf-nm"
OBJDUMP="$XPACK_DIR/bin/riscv-none-elf-objdump"

# RAM size from linker script (8K)
RAM_SIZE=8192

if [ ! -f "$ELF_FILE" ]; then
    echo "Error: ELF file not found: $ELF_FILE"
    echo "Run 'make firmware' first."
    exit 1
fi

if [ ! -x "$SIZE" ]; then
    echo "Error: Toolchain not found. Run 'make install-toolchain' first."
    exit 1
fi

echo "=== Firmware Size Report ==="
echo "File: $ELF_FILE"
echo ""

# Standard size output
echo "--- Section Sizes ---"
$SIZE -A "$ELF_FILE"
echo ""

# Calculate totals
TEXT=$($SIZE -A "$ELF_FILE" | grep '\.text' | awk '{print $2}')
RODATA=$($SIZE -A "$ELF_FILE" | grep '\.rodata' | awk '{print $2}')
DATA=$($SIZE -A "$ELF_FILE" | grep '\.data' | awk '{print $2}')
BSS=$($SIZE -A "$ELF_FILE" | grep '\.bss' | awk '{print $2}')

# Handle empty sections
TEXT=${TEXT:-0}
RODATA=${RODATA:-0}
DATA=${DATA:-0}
BSS=${BSS:-0}

CODE_SIZE=$((TEXT + RODATA))
RAM_USED=$((TEXT + RODATA + DATA + BSS))
RAM_REMAINING=$((RAM_SIZE - RAM_USED))

echo "--- Summary ---"
printf "Code (.text + .rodata): %6d bytes\n" $CODE_SIZE
printf "Data (.data):           %6d bytes\n" $DATA
printf "BSS  (.bss):            %6d bytes\n" $BSS
echo "-----------------------------------"
printf "Total RAM used:         %6d bytes\n" $RAM_USED
printf "RAM available:          %6d bytes\n" $RAM_SIZE
printf "RAM remaining:          %6d bytes (%d%%)\n" $RAM_REMAINING $((RAM_REMAINING * 100 / RAM_SIZE))
echo ""

# Last function (highest address in .text)
echo "--- Last Function (end of code) ---"
$NM --numeric-sort "$ELF_FILE" 2>/dev/null | grep -E ' [Tt] ' | tail -3
echo ""

# Last data element (highest address in .data/.bss)
echo "--- Last Data Elements (end of data/bss) ---"
$NM --numeric-sort "$ELF_FILE" 2>/dev/null | grep -E ' [BbDd] ' | tail -3
echo ""

# Stack info
echo "--- Memory Map ---"
printf "RAM Start:  0x%08X\n" 0
printf "RAM End:    0x%08X\n" $RAM_SIZE
STACK_START=$((RAM_SIZE))
printf "Stack Top:  0x%08X (grows down)\n" $STACK_START
echo ""

# Warning if low on memory
if [ $RAM_REMAINING -lt 512 ]; then
    echo "⚠️  WARNING: Less than 512 bytes remaining!"
elif [ $RAM_REMAINING -lt 1024 ]; then
    echo "⚠️  WARNING: Less than 1KB remaining!"
fi
