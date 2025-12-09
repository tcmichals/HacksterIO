#!/usr/bin/env python3
"""
Test hex dump display format
"""

def log_hex_dump(label: str, data: bytes) -> None:
    """Display data as hex dump with ASCII representation"""
    
    # Header
    print(f"\033[1;36m──── {label} ({len(data)} bytes) ────\033[0m")
    
    # Process in 16-byte chunks
    for offset in range(0, len(data), 16):
        chunk = data[offset:offset+16]
        
        # Hex representation
        hex_part = ' '.join(f'{b:02X}' for b in chunk)
        # Pad to 16 bytes worth of hex display (47 chars: "XX " * 16 - 1)
        hex_part = hex_part.ljust(47)
        
        # ASCII representation
        ascii_part = ''.join(chr(b) if 32 <= b < 127 else '.' for b in chunk)
        
        # Combined line
        print(f"\033[33m{offset:04X}:\033[0m  {hex_part}  \033[32m|{ascii_part}|\033[0m")
    
    print()  # Empty line for spacing


if __name__ == "__main__":
    print("\n=== Hex Dump Display Test ===\n")
    
    # Test 1: Simple ASCII message
    print("Test 1: Simple ASCII message")
    log_hex_dump("TX", b"Hello, World!")
    
    # Test 2: Longer message with newline
    print("Test 2: Message with newline")
    log_hex_dump("TX", b"This is a test message\n")
    
    # Test 3: Binary data
    print("Test 3: Binary data (DSHOT frame)")
    log_hex_dump("DSHOT", bytes([0x7D, 0x0A, 0x00, 0x00]))
    
    # Test 4: Mixed ASCII and control characters
    print("Test 4: Mixed content")
    test_data = b"Status: OK\r\nTemp: 25C\x00\x01\x02\x03"
    log_hex_dump("RX", test_data)
    
    # Test 5: Long data spanning multiple lines
    print("Test 5: Multi-line data")
    long_data = bytes(range(0, 80))
    log_hex_dump("RX", long_data)
    
    print("\n=== Test Complete ===\n")
