#!/usr/bin/env python3
"""
bin2coe.py - Convert binary file to Vivado COE format

Vivado Block RAM uses .coe files for initialization.
Format:
  memory_initialization_radix=16;
  memory_initialization_vector=
  DEADBEEF,
  CAFEBABE,
  ...;

Usage:
  python3 bin2coe.py firmware.bin firmware.coe [width]
  
  width: Word width in bits (default: 32)
"""

import sys
import struct

def bin2coe(bin_file, coe_file, width=32):
    """Convert binary file to Vivado COE format."""
    
    bytes_per_word = width // 8
    
    with open(bin_file, 'rb') as f:
        data = f.read()
    
    # Pad to word boundary
    if len(data) % bytes_per_word:
        data += b'\x00' * (bytes_per_word - (len(data) % bytes_per_word))
    
    words = []
    for i in range(0, len(data), bytes_per_word):
        if width == 32:
            word = struct.unpack('<I', data[i:i+4])[0]
            words.append(f'{word:08X}')
        elif width == 16:
            word = struct.unpack('<H', data[i:i+2])[0]
            words.append(f'{word:04X}')
        elif width == 8:
            word = data[i]
            words.append(f'{word:02X}')
        else:
            raise ValueError(f"Unsupported width: {width}")
    
    with open(coe_file, 'w') as f:
        f.write("; Vivado COE file generated from {}\n".format(bin_file))
        f.write("; {} words of {} bits\n".format(len(words), width))
        f.write("memory_initialization_radix=16;\n")
        f.write("memory_initialization_vector=\n")
        
        for i, word in enumerate(words):
            if i < len(words) - 1:
                f.write(f"{word},\n")
            else:
                f.write(f"{word};\n")
    
    print(f"Generated {coe_file}: {len(words)} words ({len(data)} bytes)")

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print("Usage: bin2coe.py <input.bin> <output.coe> [width]")
        sys.exit(1)
    
    bin_file = sys.argv[1]
    coe_file = sys.argv[2]
    width = int(sys.argv[3]) if len(sys.argv) > 3 else 32
    
    bin2coe(bin_file, coe_file, width)
