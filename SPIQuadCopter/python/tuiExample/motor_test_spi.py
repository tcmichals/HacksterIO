#!/usr/bin/env python3
"""
Motor test via SPI - sends DSHOT commands directly to FPGA.
Uses wb_driver for SPI Wishbone communication.

Controls:
  1-4    : Select motor (or 'a' for all)
  UP/w   : Increase throttle
  DOWN/s : Decrease throttle
  SPACE  : Stop all motors (emergency stop)
  ESC    : Stop and exit
  q      : Quit

SAFETY: Max throttle capped at 500 for testing.
"""

import sys
import os
import time
import termios
import tty

# Add parent directory to path for wb_driver import
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from wb_driver import WishboneDriver

# SAFETY: Maximum throttle for testing (2047 is full throttle)
MAX_THROTTLE = 500
THROTTLE_STEP = 50

def get_key_blocking():
    """Get a single keypress, blocking until key is pressed."""
    fd = sys.stdin.fileno()
    old_settings = termios.tcgetattr(fd)
    try:
        tty.setraw(fd)
        ch = sys.stdin.read(1)
        # Handle escape sequences (arrow keys)
        if ch == '\x1b':
            ch2 = sys.stdin.read(1)
            if ch2 == '[':
                ch3 = sys.stdin.read(1)
                if ch3 == 'A':
                    return 'UP'
                elif ch3 == 'B':
                    return 'DOWN'
                elif ch3 == 'C':
                    return 'RIGHT'
                elif ch3 == 'D':
                    return 'LEFT'
            return 'ESC'
        return ch
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)


def print_status(motors, selected):
    """Print current motor status."""
    os.system('clear' if os.name == 'posix' else 'cls')
    print("=" * 50)
    print("       SPI DSHOT Motor Test")
    print("=" * 50)
    print()
    print("Controls: 1-4=select motor, a=all, UP/w=+, DOWN/s=-")
    print("          SPACE/ESC=stop, q=quit")
    print()
    print(f"Selected: {'ALL' if selected == 0 else f'Motor {selected}'}")
    print()
    for i in range(4):
        marker = ">>>" if (selected == i + 1 or selected == 0) else "   "
        bar_len = int(motors[i] / MAX_THROTTLE * 20)
        bar = "#" * bar_len + "-" * (20 - bar_len)
        print(f"  {marker} Motor {i+1}: [{bar}] {motors[i]:4d}")
    print()
    print(f"Max throttle: {MAX_THROTTLE}")


def main():
    print("Initializing SPI connection...")
    
    try:
        wb = WishboneDriver(bus=0, device=0, speed_hz=6000000)
    except Exception as e:
        print(f"Failed to open SPI: {e}")
        print("Make sure SPI is enabled and you have permissions.")
        return 1
    
    # Verify connection
    version = wb.get_version()
    print(f"FPGA Version: {version.hex()}")
    
    # Motor values
    motors = [0, 0, 0, 0]
    selected = 0  # 0 = all, 1-4 = individual motor
    running = True
    
    # Initialize motors to 0
    wb.stop_motors()
    
    print_status(motors, selected)
    
    try:
        while running:
            key = get_key_blocking()
            
            if key in (' ', 'ESC'):
                # Emergency stop
                motors = [0, 0, 0, 0]
                wb.stop_motors()
                if key == 'ESC':
                    running = False
                    
            elif key == 'q':
                motors = [0, 0, 0, 0]
                wb.stop_motors()
                running = False
                
            elif key in ('1', '2', '3', '4'):
                selected = int(key)
                
            elif key == 'a':
                selected = 0  # All motors
                
            elif key in ('UP', 'w'):
                # Increase throttle
                if selected == 0:
                    for i in range(4):
                        motors[i] = min(MAX_THROTTLE, motors[i] + THROTTLE_STEP)
                else:
                    motors[selected - 1] = min(MAX_THROTTLE, motors[selected - 1] + THROTTLE_STEP)
                wb.set_motors(*motors)
                
            elif key in ('DOWN', 's'):
                # Decrease throttle
                if selected == 0:
                    for i in range(4):
                        motors[i] = max(0, motors[i] - THROTTLE_STEP)
                else:
                    motors[selected - 1] = max(0, motors[selected - 1] - THROTTLE_STEP)
                wb.set_motors(*motors)
            
            print_status(motors, selected)
            
    except KeyboardInterrupt:
        pass
    finally:
        # Always stop motors on exit
        print("\nStopping motors...")
        wb.stop_motors()
        wb.close()
        print("Done.")
    
    return 0


if __name__ == "__main__":
    sys.exit(main())
