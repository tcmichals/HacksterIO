#!/usr/bin/env python3
"""
Version Register Stress Test
Reads version register many times and reports statistics.
Helps identify intermittent SPI/bridge issues.
"""

import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from wb_driver import WishboneDriver
import argparse
import time

VERSION_ADDR = 0x0000  # Version register address
EXPECTED_VALUE = 0xDEADBEEF  # Expected version value

def run_version_test(bus=1, device=0, speed_hz=5000000, iterations=100, delay_ms=1):
    """Read version register repeatedly and track errors."""
    
    print(f"Version Register Stress Test")
    print(f"  Bus: {bus}, Device: {device}")
    print(f"  Speed: {speed_hz/1e6:.1f} MHz")
    print(f"  Iterations: {iterations}")
    print(f"  Expected: 0x{EXPECTED_VALUE:08X}")
    print()
    
    # Create driver with specified speed
    wb = WishboneDriver(bus=bus, device=device, speed_hz=speed_hz)
    
    pass_count = 0
    fail_count = 0
    error_values = {}
    
    start_time = time.time()
    
    for i in range(iterations):
        try:
            raw = wb.get_version()
            # Convert bytes to int (little-endian)
            value = int.from_bytes(raw, byteorder='little')
            
            if value == EXPECTED_VALUE:
                pass_count += 1
            else:
                fail_count += 1
                key = f"0x{value:08X}"
                error_values[key] = error_values.get(key, 0) + 1
                
                if fail_count <= 10:
                    print(f"  [{i+1}] FAIL: Got 0x{value:08X}")
                elif fail_count == 11:
                    print("  ... (suppressing further error details)")
        
        except Exception as e:
            fail_count += 1
            key = f"Exception: {type(e).__name__}"
            error_values[key] = error_values.get(key, 0) + 1
            
            if fail_count <= 5:
                print(f"  [{i+1}] Exception: {e}")
        
        if delay_ms > 0:
            time.sleep(delay_ms / 1000.0)
    
    elapsed = time.time() - start_time
    
    wb.close()
    
    print()
    print("=== Results ===")
    print(f"  PASS: {pass_count}/{iterations} ({100*pass_count/iterations:.1f}%)")
    print(f"  FAIL: {fail_count}/{iterations} ({100*fail_count/iterations:.1f}%)")
    print(f"  Time: {elapsed:.2f}s ({iterations/elapsed:.1f} reads/sec)")
    
    if error_values:
        print()
        print("=== Error Patterns ===")
        sorted_errors = sorted(error_values.items(), key=lambda x: -x[1])
        for value, count in sorted_errors[:10]:
            print(f"  {value}: {count} occurrences")
    
    print()
    if fail_count == 0:
        print("*** ALL READS CORRECT ***")
        return True
    elif fail_count < iterations * 0.01:
        print(f"*** RARE ERRORS ({100*fail_count/iterations:.2f}%) - Likely metastability ***")
        return False
    elif fail_count < iterations * 0.5:
        print(f"*** FREQUENT ERRORS ({100*fail_count/iterations:.1f}%) - Timing issue ***")
        return False
    else:
        print(f"*** MOSTLY FAILING ({100*fail_count/iterations:.1f}%) - Fundamental problem ***")
        return False

def run_speed_sweep(bus=1, device=0, iterations=50):
    """Test at multiple speeds to find threshold."""
    
    print("=== Speed Sweep Test ===")
    print()
    
    speeds = [500000, 1000000, 2000000, 3000000, 4000000, 5000000, 6000000, 8000000, 10000000]
    
    results = []
    
    for speed in speeds:
        print(f"Testing {speed/1e6:.1f} MHz...")
        
        try:
            wb = WishboneDriver(bus=bus, device=device, speed_hz=speed)
            
            pass_count = 0
            for i in range(iterations):
                try:
                    raw = wb.get_version()
                    value = int.from_bytes(raw, byteorder='little')
                    if value == EXPECTED_VALUE:
                        pass_count += 1
                except:
                    pass
                time.sleep(0.001)
            
            wb.close()
            
            pct = 100 * pass_count / iterations
            results.append((speed, pct))
            status = "OK" if pct == 100 else "FAIL" if pct < 90 else "MARGINAL"
            print(f"  {speed/1e6:.1f} MHz: {pct:.0f}% pass [{status}]")
            
        except Exception as e:
            print(f"  {speed/1e6:.1f} MHz: ERROR - {e}")
            results.append((speed, 0))
        
        time.sleep(0.1)
    
    print()
    print("=== Speed Sweep Summary ===")
    for speed, pct in results:
        bar = "#" * int(pct / 5) + "." * (20 - int(pct / 5))
        print(f"  {speed/1e6:5.1f} MHz: [{bar}] {pct:5.1f}%")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Version Register Stress Test")
    parser.add_argument("--bus", type=int, default=1, help="SPI bus (default: 1)")
    parser.add_argument("--device", type=int, default=0, help="SPI device (default: 0)")
    parser.add_argument("--speed", type=int, default=5000000, help="SPI speed in Hz (default: 5MHz)")
    parser.add_argument("--iterations", type=int, default=100, help="Test iterations (default: 100)")
    parser.add_argument("--delay", type=int, default=1, help="Delay between reads in ms (default: 1)")
    parser.add_argument("--sweep", action="store_true", help="Run speed sweep test")
    
    args = parser.parse_args()
    
    if args.sweep:
        run_speed_sweep(args.bus, args.device, args.iterations)
    else:
        run_version_test(args.bus, args.device, args.speed, args.iterations, args.delay)
