#!/usr/bin/env python3
"""
Test Rich Text formatting for TUI
"""

from rich.text import Text
from rich.console import Console

console = Console()

print("\n=== Rich Text Formatting Test ===\n")

# Test different styles
console.print(Text("This is cyan text", style="cyan"))
console.print(Text("This is yellow text", style="yellow"))
console.print(Text("This is green text", style="green"))
console.print(Text("This is red text", style="red"))
console.print(Text("This is magenta text", style="magenta"))
console.print(Text("This is bold cyan text", style="bold cyan"))

# Test combined text
line = Text()
line.append("Offset: ", style="yellow")
line.append("0000")
line.append("  Data: ")
line.append("48 65 6C 6C 6F")
line.append("  ", style="green")
line.append("|Hello|", style="green")
console.print(line)

# Test hex dump style
print("\n=== Hex Dump Style ===\n")
header = Text("──── TX (13 bytes) ────", style="bold cyan")
console.print(header)

data = b"Hello, World!"
for offset in range(0, len(data), 16):
    chunk = data[offset:offset+16]
    hex_part = ' '.join(f'{b:02X}' for b in chunk)
    hex_part = hex_part.ljust(47)
    ascii_part = ''.join(chr(b) if 32 <= b < 127 else '.' for b in chunk)
    
    line = Text()
    line.append(f"{offset:04X}:", style="yellow")
    line.append(f"  {hex_part}  ")
    line.append(f"|{ascii_part}|", style="green")
    console.print(line)

print("\n=== Test Complete ===\n")
