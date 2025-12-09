#!/usr/bin/env python3
"""
DSHOT Speed Switching Example

Demonstrates how to dynamically switch between DSHOT150, DSHOT300, and DSHOT600
speeds at runtime using the Wishbone interface.

This example shows:
1. Starting with DSHOT150 (most reliable)
2. Switching to DSHOT300 for normal operation
3. Switching to DSHOT600 for high-performance mode
4. Proper use of ready signals when changing speeds
"""

from dshot_encoder import DshotEncoder, DshotWishbone
import time


def demo_speed_switching():
    """
    Demonstrate dynamic DSHOT speed switching.
    
    Note: Replace write_func and read_func with actual hardware access functions.
    """
    
    # Initialize encoder and Wishbone controller
    encoder = DshotEncoder()
    
    # For real hardware, provide actual memory access functions:
    # wb = DshotWishbone(
    #     base_address=0x40000000,
    #     write_func=your_write_function,
    #     read_func=your_read_function
    # )
    wb = DshotWishbone(base_address=0x40000000)
    
    print("=== DSHOT Speed Switching Demo ===\n")
    
    # ========================================
    # Phase 1: Start with DSHOT150 (safest)
    # ========================================
    print("Phase 1: DSHOT150 - Initial startup and ESC detection")
    print("-" * 60)
    wb.set_mode(DshotWishbone.MODE_150)
    print(f"Mode set to: DSHOT{wb.get_mode()}")
    
    # Send motor stop commands to all ESCs
    print("Sending motor stop to all ESCs...")
    stop_frame = encoder.motor_stop()
    wb.set_all_motors(motor1=stop_frame, motor2=stop_frame, 
                      motor3=stop_frame, motor4=stop_frame)
    
    # In DSHOT150, guard time is 250µs
    time.sleep(0.001)  # Wait 1ms to be safe
    
    # Request ESC info
    print("Requesting ESC information...")
    info_frame = encoder.esc_info()
    wb.set_motor(1, info_frame)
    time.sleep(0.001)
    
    print("DSHOT150: Good for initial ESC detection and configuration\n")
    
    # ========================================
    # Phase 2: Switch to DSHOT300 (standard)
    # ========================================
    print("Phase 2: DSHOT300 - Normal flight operations")
    print("-" * 60)
    wb.set_mode(DshotWishbone.MODE_300)
    print(f"Mode set to: DSHOT{wb.get_mode()}")
    
    # Wait for ready before sending commands at new speed
    print("Waiting for motors to be ready...")
    for motor in range(1, 5):
        if wb.wait_ready(motor, timeout_ms=10):
            print(f"  Motor {motor}: Ready")
        else:
            print(f"  Motor {motor}: Timeout!")
    
    # Send throttle commands
    print("\nSending throttle commands (low speed)...")
    throttle_low = encoder.throttle(100)  # Low throttle
    wb.set_all_motors(motor1=throttle_low, motor2=throttle_low,
                      motor3=throttle_low, motor4=throttle_low)
    
    # In DSHOT300, guard time is 125µs - can update faster
    time.sleep(0.0005)  # 500µs
    
    # Increase throttle
    print("Increasing throttle to 50%...")
    throttle_mid = encoder.throttle(1047)  # ~50% throttle
    wb.set_all_motors(motor1=throttle_mid, motor2=throttle_mid,
                      motor3=throttle_mid, motor4=throttle_mid)
    
    print("DSHOT300: 2x faster updates, good for normal flight\n")
    
    # ========================================
    # Phase 3: Switch to DSHOT600 (racing)
    # ========================================
    print("Phase 3: DSHOT600 - High-performance racing mode")
    print("-" * 60)
    wb.set_mode(DshotWishbone.MODE_600)
    print(f"Mode set to: DSHOT{wb.get_mode()}")
    
    # Again, wait for ready
    print("Waiting for motors to be ready...")
    status = wb.get_status()
    all_ready = all([status['motor1_ready'], status['motor2_ready'],
                     status['motor3_ready'], status['motor4_ready']])
    print(f"  All motors ready: {all_ready}")
    
    # High-speed throttle updates
    print("\nHigh-speed throttle sequence...")
    throttles = [500, 750, 1000, 1250, 1500]
    for thr in throttles:
        frame = encoder.throttle(thr)
        wb.set_all_motors(motor1=frame, motor2=frame,
                          motor3=frame, motor4=frame)
        # In DSHOT600, guard time is only 62.5µs - very fast updates
        time.sleep(0.0001)  # 100µs
        print(f"  Sent throttle: {thr}")
    
    print("DSHOT600: 4x faster updates, best for racing/acrobatics\n")
    
    # ========================================
    # Phase 4: Return to safe mode
    # ========================================
    print("Phase 4: Returning to DSHOT150 for landing")
    print("-" * 60)
    wb.set_mode(DshotWishbone.MODE_150)
    print(f"Mode set to: DSHOT{wb.get_mode()}")
    
    # Gradual throttle reduction
    print("Gradual throttle reduction...")
    for thr in [1000, 500, 200, 100, 48]:
        frame = encoder.throttle(thr)
        wb.set_all_motors(motor1=frame, motor2=frame,
                          motor3=frame, motor4=frame)
        time.sleep(0.001)  # 1ms between commands
        print(f"  Throttle: {thr}")
    
    # Final stop
    print("\nSending final motor stop...")
    stop_frame = encoder.motor_stop()
    wb.set_all_motors(motor1=stop_frame, motor2=stop_frame,
                      motor3=stop_frame, motor4=stop_frame)
    
    print("\n=== Demo Complete ===\n")


def speed_comparison():
    """Show the differences between DSHOT speeds"""
    print("\n=== DSHOT Speed Comparison ===\n")
    
    print("┌───────────┬─────────────┬──────────────┬────────────────┐")
    print("│   Mode    │ Bit Period  │  Guard Time  │  Update Rate   │")
    print("├───────────┼─────────────┼──────────────┼────────────────┤")
    print("│ DSHOT150  │   6.67 µs   │    250 µs    │  ~3.7 kHz      │")
    print("│ DSHOT300  │   3.33 µs   │    125 µs    │  ~7.4 kHz      │")
    print("│ DSHOT600  │   1.67 µs   │   62.5 µs    │ ~14.8 kHz      │")
    print("└───────────┴─────────────┴──────────────┴────────────────┘")
    
    print("\nWhen to use each speed:\n")
    
    print("DSHOT150:")
    print("  ✓ Most reliable, works with all ESCs")
    print("  ✓ Best for initial testing and calibration")
    print("  ✓ Good for noisy electrical environments")
    print("  ✗ Slower update rate (~3.7 kHz)")
    print()
    
    print("DSHOT300:")
    print("  ✓ Good balance of speed and reliability")
    print("  ✓ Standard choice for most applications")
    print("  ✓ Supported by nearly all modern ESCs")
    print("  ✓ 2x faster than DSHOT150 (~7.4 kHz)")
    print()
    
    print("DSHOT600:")
    print("  ✓ Highest update rate (~14.8 kHz)")
    print("  ✓ Best for racing and acrobatic flight")
    print("  ✓ 4x faster than DSHOT150")
    print("  ✗ Requires high-quality signal paths")
    print("  ✗ May not work with all ESCs")
    print()


def best_practices():
    """Print best practices for speed switching"""
    print("\n=== Best Practices for Speed Switching ===\n")
    
    practices = [
        "1. Start with DSHOT150 during initialization",
        "   - Most reliable for ESC detection and calibration",
        "   - All ESCs support this speed",
        "",
        "2. Always wait for o_ready signal before writing",
        "   - Each speed has different guard times",
        "   - Ready signal handles this automatically",
        "",
        "3. Check ESC specifications",
        "   - Not all ESCs support DSHOT600",
        "   - Some may have specific speed requirements",
        "",
        "4. Test speed changes on the bench first",
        "   - Verify signal quality with oscilloscope",
        "   - Ensure ESCs respond correctly at each speed",
        "",
        "5. Use slower speeds in noisy environments",
        "   - DSHOT150 more robust to electrical noise",
        "   - DSHOT600 requires clean signal paths",
        "",
        "6. Mode changes take effect on NEXT transmission",
        "   - Current frame completes at old speed",
        "   - Wait for ready before first frame at new speed",
        "",
        "7. Consider using DSHOT300 as default",
        "   - Best balance for most applications",
        "   - Good compatibility and performance",
    ]
    
    for practice in practices:
        print(practice)
    print()


if __name__ == "__main__":
    demo_speed_switching()
    speed_comparison()
    best_practices()
