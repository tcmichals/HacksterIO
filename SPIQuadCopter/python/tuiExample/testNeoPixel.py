#!/usr/bin/env python3
"""
Simple NeoPixel test script.
Toggles first LED red and last LED blue, with read verification.
"""
from wb_driver import WishboneDriver
import argparse
import time

def main():
    parser = argparse.ArgumentParser(description="Test NeoPixel LEDs via SPI")
    parser.add_argument("--bus", type=int, default=0, help="SPI bus number (default: 0)")
    parser.add_argument("--device", type=int, default=0, help="SPI device number (default: 0)")
    args = parser.parse_args()

    wb = WishboneDriver(bus=args.bus, device=args.device)
    try:
        print("=== NeoPixel Test ===\n")
        
        # Read initial state
        print("Initial state:")
        pixels = wb.get_neopixels()
        for i, (r, g, b, w) in enumerate(pixels):
            print(f"  Pixel {i}: R={r:3d} G={g:3d} B={b:3d} W={w:3d}")
        
        print("\nSetting pixel 0 to RED (255, 0, 0)...")
        wb.set_neopixel(0, r=255, g=0, b=0, w=0)
        
        print("Setting pixel 7 to BLUE (0, 0, 255)...")
        wb.set_neopixel(7, r=0, g=0, b=255, w=0)
        
        print("Triggering NeoPixel update...")
        wb.trigger_neopixel_update()
        
        time.sleep(0.1)
        
        # Read back
        print("\nAfter update:")
        pixels = wb.get_neopixels()
        for i, (r, g, b, w) in enumerate(pixels):
            marker = " <--" if i in [0, 7] else ""
            print(f"  Pixel {i}: R={r:3d} G={g:3d} B={b:3d} W={w:3d}{marker}")
        
        # Verify
        print("\n=== Verification ===")
        p0 = pixels[0]
        p7 = pixels[7]
        
        if p0 == (255, 0, 0, 0):
            print("Pixel 0: PASS (RED)")
        else:
            print(f"Pixel 0: FAIL - expected (255,0,0,0), got {p0}")
        
        if p7 == (0, 0, 255, 0):
            print("Pixel 7: PASS (BLUE)")
        else:
            print(f"Pixel 7: FAIL - expected (0,0,255,0), got {p7}")
        
        print("\nPress Enter to turn off LEDs and exit...")
        input()
        
        # Clear all pixels
        for i in range(8):
            wb.set_neopixel(i, 0, 0, 0, 0)
        wb.trigger_neopixel_update()
        print("LEDs turned off.")
        
    finally:
        wb.close()

if __name__ == "__main__":
    main()
