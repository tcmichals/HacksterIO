#!/usr/bin/env python3
"""
Convert binary file to Verilog memory initialization format (.mem)
Usage: bin2mem.py input.bin output.mem [--width 32]
"""

import sys
import argparse

def bin_to_mem(input_path, output_path, width=32):
    """Convert binary to hex memory file"""
    bytes_per_word = width // 8
    
    with open(input_path, 'rb') as f:
        data = f.read()
    
    # Pad to word boundary
    while len(data) % bytes_per_word != 0:
        data += b'\x00'
    
    with open(output_path, 'w') as f:
        f.write(f"// Generated from {input_path}\n")
        f.write(f"// {len(data)} bytes, {len(data) // bytes_per_word} words\n")
        
        for i in range(0, len(data), bytes_per_word):
            word = data[i:i + bytes_per_word]
            # Little-endian word
            hex_val = ''.join(f'{b:02X}' for b in reversed(word))
            f.write(f"{hex_val}\n")
    
    print(f"Generated {output_path}: {len(data)} bytes ({len(data) // bytes_per_word} words)")

def main():
    parser = argparse.ArgumentParser(description='Convert binary to Verilog memory format')
    parser.add_argument('input', help='Input binary file')
    parser.add_argument('output', help='Output .mem file')
    parser.add_argument('--width', type=int, default=32, help='Word width in bits (default: 32)')
    
    args = parser.parse_args()
    bin_to_mem(args.input, args.output, args.width)

if __name__ == '__main__':
    main()
