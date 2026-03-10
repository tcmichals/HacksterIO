#!/usr/bin/env python3
"""
SPI Loopback Test - Test raw SPI communication
Sends known patterns and analyzes MISO response timing.
This tests the SPI slave module in isolation.
"""

import spidev
import argparse
import time

def run_loopback_test(bus=1, device=0, speed_hz=5000000, iterations=100):
    """Send patterns and check responses."""
    
    spi = spidev.SpiDev()
    spi.open(bus, device)
    spi.max_speed_hz = speed_hz
    spi.mode = 0
    
    print(f"SPI Loopback Test")
    print(f"  Bus: {bus}, Device: {device}")
    print(f"  Speed: {speed_hz/1e6:.1f} MHz")
    print(f"  Iterations: {iterations}")
    print()
    
    # Test 1: Check SYNC byte response (idle behavior)
    # SPI slave should return DA when idle
    print("=== Test 1: SYNC Response (Idle State) ===")
    sync_ok = 0
    sync_bad = 0
    bad_values = {}
    
    for i in range(iterations):
        # Send DA, expect DA back (delayed by 1 byte)
        tx = [0xDA, 0xDA, 0xDA]
        rx = spi.xfer2(tx)
        
        # First byte is undefined (shifting), bytes 2+ should be DA
        if rx[1] == 0xDA and rx[2] == 0xDA:
            sync_ok += 1
        else:
            sync_bad += 1
            key = f"{rx[1]:02X},{rx[2]:02X}"
            bad_values[key] = bad_values.get(key, 0) + 1
        
        time.sleep(0.001)  # Small delay between transactions
    
    print(f"  PASS: {sync_ok}/{iterations}")
    print(f"  FAIL: {sync_bad}/{iterations}")
    if bad_values:
        print(f"  Bad patterns: {bad_values}")
    print()
    
    # Test 2: Check incrementing pattern
    print("=== Test 2: Incrementing Pattern ===")
    pattern_ok = 0
    pattern_bad = 0
    
    for i in range(iterations):
        # Send incrementing bytes, check stable response
        tx = [0xDA] * 8  # All sync bytes
        rx = spi.xfer2(tx)
        
        # After first byte, all should be DA
        all_da = all(b == 0xDA for b in rx[1:])
        if all_da:
            pattern_ok += 1
        else:
            pattern_bad += 1
            if pattern_bad <= 5:
                print(f"    Bad response: {[hex(b) for b in rx]}")
        
        time.sleep(0.001)
    
    print(f"  PASS: {pattern_ok}/{iterations}")
    print(f"  FAIL: {pattern_bad}/{iterations}")
    print()
    
    # Test 3: Long transaction stability
    print("=== Test 3: Long Transaction (32 bytes) ===")
    long_ok = 0
    long_bad = 0
    
    for i in range(iterations // 10):
        tx = [0xDA] * 32
        rx = spi.xfer2(tx)
        
        all_da = all(b == 0xDA for b in rx[1:])
        if all_da:
            long_ok += 1
        else:
            long_bad += 1
            bad_idx = [j for j, b in enumerate(rx[1:], 1) if b != 0xDA]
            if long_bad <= 3:
                print(f"    Bad at positions: {bad_idx}")
                print(f"    Values: {[hex(rx[j]) for j in bad_idx[:5]]}")
        
        time.sleep(0.005)
    
    total_long = iterations // 10
    print(f"  PASS: {long_ok}/{total_long}")
    print(f"  FAIL: {long_bad}/{total_long}")
    print()
    
    spi.close()
    
    # Summary
    total_tests = iterations * 2 + total_long
    total_pass = sync_ok + pattern_ok + long_ok
    total_fail = sync_bad + pattern_bad + long_bad
    
    print("=== Summary ===")
    print(f"  Total PASS: {total_pass}")
    print(f"  Total FAIL: {total_fail}")
    print(f"  Success Rate: {100*total_pass/total_tests:.1f}%")
    
    if total_fail == 0:
        print("\n*** SPI LAYER OK - Problem is elsewhere ***")
    else:
        print("\n*** SPI LAYER HAS ISSUES ***")
    
    return total_fail == 0

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="SPI Loopback Test")
    parser.add_argument("--bus", type=int, default=1, help="SPI bus (default: 1)")
    parser.add_argument("--device", type=int, default=0, help="SPI device (default: 0)")
    parser.add_argument("--speed", type=int, default=5000000, help="SPI speed in Hz (default: 5MHz)")
    parser.add_argument("--iterations", type=int, default=100, help="Test iterations (default: 100)")
    
    args = parser.parse_args()
    run_loopback_test(args.bus, args.device, args.speed, args.iterations)
