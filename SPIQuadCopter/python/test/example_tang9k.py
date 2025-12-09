#!/usr/bin/env python3
"""
Example script demonstrating Tang9K hardware interface

This script shows how to use the Tang9K Python wrapper to:
- Control LEDs
- Send/receive serial data
- Read PWM values
- Control NeoPixels
- Switch between serial and DSHOT modes
"""

import time
import argparse
from tang9k import Tang9K, COLORS_RAINBOW, COLORS_CHRISTMAS


def example_leds(tang9k):
    """Example: LED control"""
    print("\n=== LED Control Example ===")
    print("Counting 0-15 on LEDs...")
    
    for i in range(16):
        tang9k.set_leds(i)
        print(f"LED value: {i} (0x{i:X})")
        time.sleep(0.5)
    
    tang9k.set_leds(0)
    print("LEDs reset to 0")


def example_serial(tang9k):
    """Example: Serial communication"""
    print("\n=== Serial Communication Example ===")
    
    # Enable half-duplex mode for ESC communication
    print("Enabling half-duplex mode...")
    tang9k.serial_set_half_duplex(True)
    
    # Send a test message
    print("Sending test message...")
    tang9k.serial_write_string("Hello from Tang9K!")
    
    # Try to read back
    print("Checking for received data...")
    for _ in range(10):
        byte = tang9k.serial_read_byte()
        if byte is not None:
            print(f"Received: {chr(byte)}", end='')
        time.sleep(0.1)
    print()


def example_pwm(tang9k):
    """Example: PWM reading"""
    print("\n=== PWM Decoder Example ===")
    print("Reading PWM values (connect RC receiver to PWM inputs)...")
    
    for _ in range(10):
        values = tang9k.read_pwm_values(num_channels=4)
        print(f"PWM: {values}")
        time.sleep(0.5)


def example_neopixel(tang9k):
    """Example: NeoPixel control"""
    print("\n=== NeoPixel Example ===")
    
    # Test individual colors
    print("Setting individual colors...")
    colors = [0xFF0000, 0x00FF00, 0x0000FF, 0xFFFF00, 
              0xFF00FF, 0x00FFFF, 0xFFFFFF, 0x000000]
    
    for i, color in enumerate(colors):
        tang9k.neopixel_set_color(i, color)
    tang9k.neopixel_update()
    time.sleep(2)
    
    # Rainbow waterfall
    print("Running rainbow waterfall for 10 seconds...")
    start_time = time.time()
    
    def stop_after_10_sec():
        return (time.time() - start_time) < 10
    
    tang9k.neopixel_waterfall(COLORS_RAINBOW, delay=0.1, callback=stop_after_10_sec)
    
    # Clear
    print("Clearing NeoPixels...")
    tang9k.neopixel_clear()


def example_mux(tang9k):
    """Example: Serial/DSHOT mux control"""
    print("\n=== Serial/DSHOT Mux Example ===")
    
    # Switch to serial mode
    print("Switching to serial mode...")
    tang9k.set_serial_mode()
    time.sleep(1)
    
    # Switch to DSHOT mode
    print("Switching to DSHOT mode...")
    tang9k.set_dshot_mode()
    time.sleep(1)
    
    # Back to serial
    print("Switching back to serial mode...")
    tang9k.set_serial_mode()


def example_dshot(tang9k):
    """Example: DSHOT motor control"""
    print("\n=== DSHOT Motor Control Example ===")
    print("WARNING: Ensure ESCs are disconnected or props are removed!")
    
    response = input("Continue? (y/n): ")
    if response.lower() != 'y':
        print("Skipping DSHOT example")
        return
    
    # Switch to DSHOT mode
    tang9k.set_dshot_mode()
    
    # Arm motors (send 0 throttle)
    print("Arming motors (throttle 0)...")
    tang9k.dshot_arm_all()
    time.sleep(2)
    
    # Ramp up throttle slowly
    print("Ramping throttle 0 -> 200...")
    for throttle in range(0, 200, 10):
        for motor in range(4):
            tang9k.dshot_set_throttle(motor, throttle)
        print(f"Throttle: {throttle}")
        time.sleep(0.1)
    
    # Ramp down
    print("Ramping throttle 200 -> 0...")
    for throttle in range(200, -1, -10):
        for motor in range(4):
            tang9k.dshot_set_throttle(motor, throttle)
        print(f"Throttle: {throttle}")
        time.sleep(0.1)
    
    # Disarm
    print("Disarming motors...")
    tang9k.dshot_disarm_all()
    
    # Back to serial mode
    tang9k.set_serial_mode()


def main():
    parser = argparse.ArgumentParser(description="Tang9K Hardware Example")
    parser.add_argument('--device', default='/dev/spidev0.0', 
                       help='SPI device path (default: /dev/spidev0.0)')
    parser.add_argument('--speed', type=int, default=1000000,
                       help='SPI speed in Hz (default: 1000000)')
    parser.add_argument('--example', choices=['leds', 'serial', 'pwm', 'neopixel', 'mux', 'dshot', 'all'],
                       default='all', help='Which example to run')
    
    args = parser.parse_args()
    
    # Parse device path (e.g., /dev/spidev0.0 -> bus=0, device=0)
    if 'spidev' in args.device:
        parts = args.device.split('spidev')[1].split('.')
        bus = int(parts[0])
        device = int(parts[1])
    else:
        bus = 0
        device = 0
    
    print(f"Opening Tang9K on SPI bus {bus}, device {device}, speed {args.speed} Hz")
    tang9k = Tang9K(bus=bus, device=device, max_speed_hz=args.speed)
    
    try:
        examples = {
            'leds': example_leds,
            'serial': example_serial,
            'pwm': example_pwm,
            'neopixel': example_neopixel,
            'mux': example_mux,
            'dshot': example_dshot,
        }
        
        if args.example == 'all':
            for name, func in examples.items():
                if name != 'dshot':  # Skip DSHOT in 'all' mode for safety
                    func(tang9k)
        else:
            examples[args.example](tang9k)
        
        print("\n=== Example Complete ===")
    
    except KeyboardInterrupt:
        print("\n\nInterrupted by user")
    
    finally:
        print("Cleaning up...")
        tang9k.neopixel_clear()
        tang9k.set_leds(0)
        tang9k.close()
        print("Done!")


if __name__ == '__main__':
    main()
