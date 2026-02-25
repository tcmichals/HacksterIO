#!/usr/bin/env python3
"""
Convert objcopy verilog hex format to $readmemh compatible format.

Input format (objcopy -O verilog):
  @00000000
  17 21 00 00 13 01 01 00 ...

Output format ($readmemh for 32-bit memory):
  @00000000
  00002117
  00010113
  ...
"""

import sys

def convert_hex(input_file, output_file):
    with open(input_file, 'r') as f:
        lines = f.readlines()
    
    with open(output_file, 'w') as out:
        for line in lines:
            line = line.strip()
            if not line:
                continue
            
            if line.startswith('@'):
                # Address line - convert byte address to word address
                addr = int(line[1:], 16)
                word_addr = addr // 4
                out.write(f'@{word_addr:08X}\n')
            else:
                # Data line - parse bytes and combine into 32-bit words (little-endian)
                bytes_str = line.split()
                bytes_list = [int(b, 16) for b in bytes_str]
                
                # Process 4 bytes at a time
                for i in range(0, len(bytes_list), 4):
                    chunk = bytes_list[i:i+4]
                    # Pad if needed
                    while len(chunk) < 4:
                        chunk.append(0)
                    # Little-endian: byte[0] is LSB
                    word = chunk[0] | (chunk[1] << 8) | (chunk[2] << 16) | (chunk[3] << 24)
                    out.write(f'{word:08X}\n')

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} input.hex output.mem")
        sys.exit(1)
    convert_hex(sys.argv[1], sys.argv[2])
    print(f"Converted {sys.argv[1]} -> {sys.argv[2]}")
