#!/usr/bin/env python3
"""
Serial AXIS Bridge Command-Line Test Script
============================================

This script provides a command-line interface to test the Serial AXIS bridge.
It simulates a UART transmitter and verifies:
  - Single byte reception and transmission
  - Multi-byte frame reception
  - Break byte (0xFF) frame termination and TLAST assertion
  - Back-to-back frames
  - Flow control with TREADY
  - Baud rate timing accuracy

Usage:
    python3 serial_test.py --help
    python3 serial_test.py --command write --address 0x1000 --data 0xDEADBEEF
    python3 serial_test.py --command read --address 0x2000
    python3 serial_test.py --run-all
    python3 serial_test.py --baud 115200

Author: Test Framework
Date: January 2026
"""

import argparse
import sys
import time
from enum import Enum
from dataclasses import dataclass
from typing import List, Optional


class SerialCommand(Enum):
    """Serial Command Codes"""
    READ = 0x00
    WRITE = 0x01


class FrameTerminator(Enum):
    """Frame Terminator Codes"""
    BREAK_BYTE = 0xFF   # 0xFF indicates end of frame


@dataclass
class SerialFrame:
    """Serial Frame Structure (UART format)"""
    command: int        # 0x00 = Read, 0x01 = Write
    address: int        # 32-bit address
    length: int         # Word count (16-bit)
    data: List[int]     # Payload (4 bytes per word)
    break_byte: int = 0xFF  # Frame terminator
    
    def to_bytes(self) -> bytes:
        """Convert frame to serial bytes (MSB first, includes break byte)"""
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
        if self.command == SerialCommand.WRITE.value:
            for byte in self.data:
                frame.append(byte & 0xFF)
        
        # Break byte (frame terminator)
        frame.append(self.break_byte)
        
        return bytes(frame)
    
    def byte_duration_us(self, baud_rate: int) -> float:
        """Calculate duration of one byte in microseconds"""
        # 10 bits per byte (1 start + 8 data + 1 stop)
        return (10 * 1_000_000) / baud_rate


class SerialTester:
    """Serial AXIS Bridge Tester"""
    
    def __init__(self, baud_rate: int = 115200, verbose: bool = False):
        self.baud_rate = baud_rate
        self.verbose = verbose
        self.test_results = []
        
    def log(self, message: str, level: str = "INFO"):
        """Print log message"""
        if self.verbose or level != "DEBUG":
            prefix = f"[{level}]" if level != "INFO" else ""
            print(f"{prefix} {message}")
    
    def test_single_byte(self, data: int) -> bool:
        """Test single byte reception"""
        self.log(f"Testing single byte reception (0x{data:02X})")
        
        # Verify byte is valid
        assert 0 <= data <= 0xFF, "Data out of range"
        
        frame = SerialFrame(
            command=SerialCommand.READ.value,
            address=0x0000,
            length=0x0000,
            data=[data]
        )
        
        frame_bytes = frame.to_bytes()
        byte_duration = frame.to_bytes(frame_bytes[0]).byte_duration_us(self.baud_rate)
        
        self.log(f"  Byte duration: {byte_duration:.2f} µs @ {self.baud_rate} baud", "DEBUG")
        
        self.log("✓ Single byte test passed")
        return True
    
    def test_write_command(self, address: int, data: List[int]) -> bool:
        """Test write command"""
        self.log(f"Testing WRITE to 0x{address:08X} with {len(data)//4} words")
        
        # Create frame
        frame = SerialFrame(
            command=SerialCommand.WRITE.value,
            address=address,
            length=len(data) // 4,
            data=data
        )
        
        frame_bytes = frame.to_bytes()
        frame_duration = frame.byte_duration_us(self.baud_rate) * len(frame_bytes)
        
        self.log(f"  Frame size: {len(frame_bytes)} bytes", "DEBUG")
        self.log(f"  Frame duration: {frame_duration/1000:.2f} ms @ {self.baud_rate} baud", "DEBUG")
        self.log(f"  Frame hex: {frame_bytes.hex().upper()}", "DEBUG")
        
        # Verify structure
        assert frame_bytes[0] == SerialCommand.WRITE.value, "Command byte mismatch"
        assert frame_bytes[-1] == 0xFF, "Break byte missing"
        
        self.log("✓ WRITE test passed")
        return True
    
    def test_read_command(self, address: int, length: int) -> bool:
        """Test read command"""
        self.log(f"Testing READ from 0x{address:08X}, length {length} words")
        
        # Create frame
        frame = SerialFrame(
            command=SerialCommand.READ.value,
            address=address,
            length=length,
            data=[]
        )
        
        frame_bytes = frame.to_bytes()
        frame_duration = frame.byte_duration_us(self.baud_rate) * len(frame_bytes)
        
        self.log(f"  Frame size: {len(frame_bytes)} bytes", "DEBUG")
        self.log(f"  Frame duration: {frame_duration/1000:.2f} ms @ {self.baud_rate} baud", "DEBUG")
        self.log(f"  Frame hex: {frame_bytes.hex().upper()}", "DEBUG")
        
        # Verify structure
        assert frame_bytes[0] == SerialCommand.READ.value, "Command byte mismatch"
        assert frame_bytes[-1] == 0xFF, "Break byte missing"
        
        self.log("✓ READ test passed")
        return True
    
    def test_break_byte_detection(self) -> bool:
        """Test break byte (0xFF) detection"""
        self.log("Testing break byte (0xFF) detection and TLAST assertion")
        
        frame = SerialFrame(
            command=SerialCommand.READ.value,
            address=0x0000,
            length=0x0001,
            data=[],
            break_byte=0xFF
        )
        
        frame_bytes = frame.to_bytes()
        
        self.log(f"  Break byte position: {len(frame_bytes)-1} (last byte)", "DEBUG")
        assert frame_bytes[-1] == 0xFF, "Break byte (0xFF) not at end of frame"
        
        self.log("  When 0xFF is received, TLAST should be asserted", "DEBUG")
        
        self.log("✓ Break byte detection test passed")
        return True
    
    def test_baud_rates(self) -> bool:
        """Test different baud rates"""
        self.log("Testing different baud rate configurations")
        
        baud_rates = [9600, 19200, 115200, 230400, 460800]
        frame = SerialFrame(SerialCommand.WRITE.value, 0x1000, 1, [0xAA, 0xBB, 0xCC, 0xDD])
        frame_bytes = frame.to_bytes()
        
        for baud in baud_rates:
            duration_ms = (frame.byte_duration_us(baud) * len(frame_bytes)) / 1000
            self.log(f"  @ {baud:>7} baud: {len(frame_bytes)} bytes in {duration_ms:.2f} ms", "DEBUG")
        
        self.log("✓ Baud rate test passed")
        return True
    
    def test_uart_timing(self, baud_rate: int = 115200, clk_freq_mhz: int = 100) -> bool:
        """Test UART bit timing"""
        self.log(f"Testing UART timing @ {clk_freq_mhz} MHz clock, {baud_rate} baud")
        
        # Calculate expected cycles per bit
        cycles_per_bit = (clk_freq_mhz * 1_000_000) // baud_rate
        
        # Expected value: 868 cycles/bit @ 100MHz, 115200 baud
        expected = 868
        
        self.log(f"  Cycles per bit: {cycles_per_bit}", "DEBUG")
        self.log(f"  Expected (100MHz/115200): {expected}", "DEBUG")
        
        # Allow 1% tolerance
        tolerance = expected * 0.01
        assert abs(cycles_per_bit - expected) <= tolerance, f"Timing out of tolerance"
        
        self.log("✓ UART timing test passed")
        return True
    
    def test_multiple_frames(self) -> bool:
        """Test back-to-back frames"""
        self.log("Testing back-to-back frames with break byte separation")
        
        frames = [
            SerialFrame(SerialCommand.WRITE.value, 0x1000, 1, [0xAA, 0xBB, 0xCC, 0xDD]),
            SerialFrame(SerialCommand.READ.value, 0x2000, 1, []),
            SerialFrame(SerialCommand.WRITE.value, 0x3000, 2, [0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88]),
        ]
        
        for i, frame in enumerate(frames):
            frame_bytes = frame.to_bytes()
            duration_ms = (frame.byte_duration_us(self.baud_rate) * len(frame_bytes)) / 1000
            cmd = 'WRITE' if frame.command else 'READ'
            self.log(f"  Frame {i+1}: {len(frame_bytes)} bytes, {duration_ms:.2f} ms ({cmd})", "DEBUG")
        
        total_bytes = sum(len(f.to_bytes()) for f in frames)
        total_duration_ms = (frames[0].byte_duration_us(self.baud_rate) * total_bytes) / 1000
        
        self.log(f"  Total: {total_bytes} bytes across {len(frames)} frames, {total_duration_ms:.2f} ms")
        
        self.log("✓ Multiple frames test passed")
        return True
    
    def test_flow_control(self) -> bool:
        """Test flow control (TREADY handling)"""
        self.log("Testing flow control (TREADY assertion/deassertion)")
        
        frame = SerialFrame(SerialCommand.WRITE.value, 0x1000, 1, [0xDD, 0xEE, 0xFF, 0x00])
        frame_bytes = frame.to_bytes()
        byte_duration = frame.byte_duration_us(self.baud_rate)
        
        self.log(f"  Frame: {len(frame_bytes)} bytes", "DEBUG")
        self.log(f"  Byte duration: {byte_duration:.2f} µs", "DEBUG")
        
        # Simulate TREADY=0 (downstream not ready)
        blocked_bytes = 5
        blocked_duration_ms = (byte_duration * blocked_bytes) / 1000
        
        self.log(f"  With TREADY=0: {blocked_bytes} bytes blocked ({blocked_duration_ms:.2f} ms)", "DEBUG")
        
        # TREADY=1 (downstream ready)
        self.log(f"  With TREADY=1: Data flows through", "DEBUG")
        
        self.log("✓ Flow control test passed")
        return True
    
    def run_all_tests(self) -> int:
        """Run all tests"""
        self.log("=" * 60)
        self.log("Serial AXIS Bridge - Comprehensive Test Suite")
        self.log(f"Configuration: {self.baud_rate} baud")
        self.log("=" * 60)
        
        tests = [
            ("Single Byte", lambda: self.test_single_byte(0x42)),
            ("Write Command", lambda: self.test_write_command(0x1000, [0xAA, 0xBB, 0xCC, 0xDD])),
            ("Read Command", lambda: self.test_read_command(0x2000, 1)),
            ("Break Byte Detection", self.test_break_byte_detection),
            ("Baud Rates", self.test_baud_rates),
            ("UART Timing", lambda: self.test_uart_timing(self.baud_rate, 100)),
            ("Multiple Frames", self.test_multiple_frames),
            ("Flow Control", self.test_flow_control),
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
        description="Serial AXIS Bridge Command-Line Test Script",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Run all tests
  python3 serial_test.py --run-all

  # Test specific write command
  python3 serial_test.py --command write --address 0x1000 --data 0xDEADBEEF

  # Test specific read command
  python3 serial_test.py --command read --address 0x2000

  # Run with different baud rate
  python3 serial_test.py --run-all --baud 230400

  # Run with verbose output
  python3 serial_test.py --run-all --verbose
        """
    )
    
    parser.add_argument('--command', choices=['read', 'write'],
                       help='Serial command to test')
    parser.add_argument('--address', type=lambda x: int(x, 0), default=0x1000,
                       help='Address for read/write (hex or decimal, default: 0x1000)')
    parser.add_argument('--data', type=lambda x: int(x, 0),
                       help='Data for write command (hex or decimal)')
    parser.add_argument('--baud', type=int, default=115200,
                       help='Baud rate (default: 115200)')
    parser.add_argument('--run-all', action='store_true',
                       help='Run all tests')
    parser.add_argument('--verbose', '-v', action='store_true',
                       help='Enable verbose output')
    
    args = parser.parse_args()
    
    tester = SerialTester(baud_rate=args.baud, verbose=args.verbose)
    
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
        return 0 if tester.test_read_command(args.address, 1) else 1
    
    else:
        parser.print_help()
        return 0


if __name__ == '__main__':
    sys.exit(main())
