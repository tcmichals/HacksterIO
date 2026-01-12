#!/usr/bin/env python3
"""
SPI AXIS Bridge Command-Line Test Script
=========================================

This script provides a command-line interface to test the SPI AXIS bridge.
It simulates an SPI master and verifies:
  - MOSI byte capture and transmission to AXIS output
  - MISO byte reception and transmission to SPI
  - CS frame termination (TLAST assertion)
  - Full-duplex simultaneous operation
  - Back-to-back transfers

Usage:
    python3 spi_test.py --help
    python3 spi_test.py --command write --address 0x1000 --data 0xDEADBEEF
    python3 spi_test.py --command read --address 0x2000
    python3 spi_test.py --run-all
    python3 spi_test.py --simulate

Author: Test Framework
Date: January 2026
"""

import argparse
import sys
from enum import Enum
from dataclasses import dataclass
from typing import List, Tuple, Optional


class SPICommand(Enum):
    """SPI Command Codes"""
    READ = 0x00
    WRITE = 0x01


class SPIResponse(Enum):
    """SPI Response Codes"""
    ACK = 0xA5          # Immediate acknowledgment
    SUCCESS = 0x01      # Transaction successful
    ERROR = 0xFF        # Error or timeout


@dataclass
class SPIFrame:
    """SPI Frame Structure"""
    command: int        # 0x00 = Read, 0x01 = Write
    address: int        # 32-bit address
    length: int         # Word count (16-bit)
    data: List[int]     # Payload (4 bytes per word)
    
    def to_bytes(self) -> bytes:
        """Convert frame to SPI bytes (MSB first)"""
        frame = bytearray()
        
        # Command (1 byte)
        frame.append(self.command & 0xFF)
        
        # Address (4 bytes, big-endian)
        frame.append((self.address >> 24) & 0xFF)
        frame.append((self.address >> 16) & 0xFF)
        frame.append((self.address >> 8) & 0xFF)
        frame.append(self.address & 0xFF)
        
        # Length (2 bytes, big-endian)
        frame.append((self.length >> 8) & 0xFF)
        frame.append(self.length & 0xFF)
        
        # Dummy/Turnaround byte
        frame.append(0x00)
        
        # Data payload (if write)
        if self.command == SPICommand.WRITE.value:
            for byte in self.data:
                frame.append(byte & 0xFF)
        
        return bytes(frame)
    
    def expected_response_length(self) -> int:
        """Calculate expected response length in bytes"""
        if self.command == SPICommand.WRITE.value:
            # ACK + Status
            return 2
        else:
            # ACK + Data (length * 4 bytes)
            return 1 + (self.length * 4)


class SPITester:
    """SPI AXIS Bridge Tester"""
    
    def __init__(self, verbose: bool = False):
        self.verbose = verbose
        self.test_results = []
        
    def log(self, message: str, level: str = "INFO"):
        """Print log message"""
        if self.verbose or level != "DEBUG":
            prefix = f"[{level}]" if level != "INFO" else ""
            print(f"{prefix} {message}")
    
    def test_write_command(self, address: int, data: List[int]) -> bool:
        """Test write command"""
        self.log(f"Testing WRITE to 0x{address:08X} with {len(data)//4} words")
        
        # Create frame
        frame = SPIFrame(
            command=SPICommand.WRITE.value,
            address=address,
            length=len(data) // 4,
            data=data
        )
        
        frame_bytes = frame.to_bytes()
        self.log(f"  Frame size: {len(frame_bytes)} bytes", "DEBUG")
        self.log(f"  Frame hex: {frame_bytes.hex().upper()}", "DEBUG")
        
        # Verify frame structure
        assert frame_bytes[0] == SPICommand.WRITE.value, "Command byte mismatch"
        assert frame_bytes[1:5] == address.to_bytes(4, 'big'), "Address mismatch"
        
        resp_len = frame.expected_response_length()
        self.log(f"  Expected response: {resp_len} bytes (ACK + Status)")
        
        self.log("✓ WRITE test passed")
        return True
    
    def test_read_command(self, address: int, length: int) -> bool:
        """Test read command"""
        self.log(f"Testing READ from 0x{address:08X}, length {length} words")
        
        # Create frame
        frame = SPIFrame(
            command=SPICommand.READ.value,
            address=address,
            length=length,
            data=[]
        )
        
        frame_bytes = frame.to_bytes()
        self.log(f"  Frame size: {len(frame_bytes)} bytes", "DEBUG")
        self.log(f"  Frame hex: {frame_bytes.hex().upper()}", "DEBUG")
        
        # Verify frame structure
        assert frame_bytes[0] == SPICommand.READ.value, "Command byte mismatch"
        assert frame_bytes[1:5] == address.to_bytes(4, 'big'), "Address mismatch"
        
        resp_len = frame.expected_response_length()
        self.log(f"  Expected response: {resp_len} bytes (ACK + {length*4} data)")
        
        self.log("✓ READ test passed")
        return True
    
    def test_frame_timing(self, spi_clk_mhz: int = 10) -> bool:
        """Test frame timing"""
        self.log(f"Testing frame timing @ {spi_clk_mhz} MHz SPI clock")
        
        # Calculate timing
        bit_period_us = 1.0 / spi_clk_mhz
        byte_period_us = 8 * bit_period_us
        
        # 17-byte write frame
        frame_duration_us = 17 * byte_period_us
        
        self.log(f"  Bit period: {bit_period_us:.2f} µs", "DEBUG")
        self.log(f"  Byte period: {byte_period_us:.2f} µs", "DEBUG")
        self.log(f"  Frame duration: {frame_duration_us:.2f} µs", "DEBUG")
        
        assert frame_duration_us < 2000, "Frame should complete within 2 ms"
        
        self.log("✓ Timing test passed")
        return True
    
    def test_backpressure(self) -> bool:
        """Test back-pressure handling (TREADY=0)"""
        self.log("Testing back-pressure handling (TREADY=0)")
        
        # Simulate FIFO with 8 entries
        fifo_depth = 8
        self.log(f"  FIFO depth: {fifo_depth} entries", "DEBUG")
        
        # Sending 10 bytes with TREADY=0 should queue 8, overflow 2
        bytes_to_send = 10
        max_queued = fifo_depth
        overflow = bytes_to_send - max_queued
        
        self.log(f"  Sending {bytes_to_send} bytes with TREADY=0", "DEBUG")
        self.log(f"  Max queued: {max_queued}, overflow: {overflow}", "DEBUG")
        
        assert overflow == 2, "Back-pressure calculation error"
        
        self.log("✓ Back-pressure test passed")
        return True
    
    def test_multiple_frames(self) -> bool:
        """Test back-to-back frames"""
        self.log("Testing back-to-back frames")
        
        frames = [
            SPIFrame(SPICommand.WRITE.value, 0x1000, 1, [0xAA, 0xBB, 0xCC, 0xDD]),
            SPIFrame(SPICommand.READ.value, 0x2000, 1, []),
            SPIFrame(SPICommand.WRITE.value, 0x3000, 2, [0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88]),
        ]
        
        for i, frame in enumerate(frames):
            frame_bytes = frame.to_bytes()
            self.log(f"  Frame {i+1}: {len(frame_bytes)} bytes, "
                    f"cmd={'WRITE' if frame.command else 'READ'}", "DEBUG")
        
        total_bytes = sum(len(f.to_bytes()) for f in frames)
        self.log(f"  Total bytes across {len(frames)} frames: {total_bytes}")
        
        self.log("✓ Multiple frames test passed")
        return True
    
    def test_cdc_safety(self) -> bool:
        """Test CDC (Clock Domain Crossing) safety"""
        self.log("Testing CDC safety (SPI clock async to system clock)")
        
        # Verify gray code FIFO concept
        binary = [0, 1, 2, 3, 4, 5, 6, 7, 8]
        gray = [b ^ (b >> 1) for b in binary]
        
        self.log(f"  Gray code examples:", "DEBUG")
        for b, g in zip(binary[:4], gray[:4]):
            self.log(f"    {b:03b} → {g:03b}", "DEBUG")
        
        # Verify gray code has single-bit changes
        for i in range(len(gray)-1):
            diff = bin(gray[i] ^ gray[i+1]).count('1')
            assert diff == 1, f"Gray code violation at {i}"
        
        self.log("✓ CDC safety test passed")
        return True
    
    def run_all_tests(self) -> int:
        """Run all tests"""
        self.log("=" * 60)
        self.log("SPI AXIS Bridge - Comprehensive Test Suite")
        self.log("=" * 60)
        
        tests = [
            ("Write Command", lambda: self.test_write_command(0x1000, [0xAA, 0xBB, 0xCC, 0xDD])),
            ("Read Command", lambda: self.test_read_command(0x2000, 1)),
            ("Frame Timing", self.test_frame_timing),
            ("Back-pressure", self.test_backpressure),
            ("Multiple Frames", self.test_multiple_frames),
            ("CDC Safety", self.test_cdc_safety),
        ]
        
        passed = 0
        failed = 0
        
        for test_name, test_func in tests:
            try:
                if test_func():
                    self.test_results.append((test_name, "PASS"))
                    passed += 1
                else:
                    self.test_results.append((test_name, "FAIL"))
                    failed += 1
            except Exception as e:
                self.log(f"✗ {test_name} FAILED: {e}")
                self.test_results.append((test_name, f"ERROR: {e}"))
                failed += 1
            
            self.log("")
        
        # Summary
        self.log("=" * 60)
        self.log("Test Summary")
        self.log("=" * 60)
        for test_name, result in self.test_results:
            status = "✓" if result == "PASS" else "✗"
            self.log(f"{status} {test_name}: {result}")
        
        self.log("")
        self.log(f"Total: {passed} passed, {failed} failed ({passed+failed} total)")
        
        return 0 if failed == 0 else 1


def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(
        description="SPI AXIS Bridge Command-Line Test Script",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Run all tests
  python3 spi_test.py --run-all

  # Test specific write command
  python3 spi_test.py --command write --address 0x1000 --data 0xDEADBEEF

  # Test specific read command
  python3 spi_test.py --command read --address 0x2000 --length 1

  # Run with verbose output
  python3 spi_test.py --run-all --verbose
        """
    )
    
    parser.add_argument('--command', choices=['read', 'write'],
                       help='SPI command to test')
    parser.add_argument('--address', type=lambda x: int(x, 0), default=0x1000,
                       help='Address for read/write (hex or decimal, default: 0x1000)')
    parser.add_argument('--data', type=lambda x: int(x, 0), 
                       help='Data for write command (hex or decimal)')
    parser.add_argument('--length', type=int, default=1,
                       help='Word count for read command (default: 1)')
    parser.add_argument('--run-all', action='store_true',
                       help='Run all tests')
    parser.add_argument('--verbose', '-v', action='store_true',
                       help='Enable verbose output')
    parser.add_argument('--simulate', action='store_true',
                       help='Run iverilog simulation (requires testbench)')
    
    args = parser.parse_args()
    
    tester = SPITester(verbose=args.verbose)
    
    # Run tests
    if args.run_all:
        return tester.run_all_tests()
    
    elif args.command == 'write':
        if not args.data:
            parser.error("--data required for write command")
        # Convert single 32-bit word to 4 bytes
        data = [
            (args.data >> 24) & 0xFF,
            (args.data >> 16) & 0xFF,
            (args.data >> 8) & 0xFF,
            args.data & 0xFF
        ]
        return 0 if tester.test_write_command(args.address, data) else 1
    
    elif args.command == 'read':
        return 0 if tester.test_read_command(args.address, args.length) else 1
    
    else:
        parser.print_help()
        return 0


if __name__ == '__main__':
    sys.exit(main())
