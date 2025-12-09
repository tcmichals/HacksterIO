#!/usr/bin/env python3
"""
DSHOT Frame Encoder and Wishbone Controller

Helper functions for creating properly formatted DSHOT protocol frames
with correct CRC calculation and controlling DSHOT via Wishbone interface.

Usage:
    from dshot_encoder import DshotEncoder, DshotWishbone
    
    # Create encoder
    dshot = DshotEncoder()
    
    # Create frames
    stop = dshot.motor_stop()
    min_throttle = dshot.throttle(48)
    half_throttle = dshot.throttle(1047)
    max_throttle = dshot.throttle(2047)
    with_telem = dshot.throttle(1000, telemetry=True)
    
    # Special commands
    reverse = dshot.spin_direction_reversed()
    info = dshot.esc_info()
    
    # Wishbone control (if using wb_dshot_controller.sv)
    wb = DshotWishbone(base_address=0x40000000)
    wb.set_mode(300)  # Switch to DSHOT300
    wb.set_motor(1, dshot.throttle(1000))  # Motor 1 throttle
    ready = wb.get_status()  # Check ready bits
"""

class DshotEncoder:
    """Encoder for DSHOT protocol frames"""
    
    # Special command values (throttle field values 0-47)
    CMD_MOTOR_STOP = 0
    CMD_ESC_INFO = 6
    CMD_SPIN_DIRECTION_1 = 7
    CMD_SPIN_DIRECTION_2 = 8
    CMD_3D_MODE_OFF = 9
    CMD_3D_MODE_ON = 10
    CMD_SETTINGS_REQUEST = 11
    CMD_SAVE_SETTINGS = 12
    CMD_SPIN_DIRECTION_NORMAL = 20
    CMD_SPIN_DIRECTION_REVERSED = 21
    
    # Throttle range
    MIN_THROTTLE = 48
    MAX_THROTTLE = 2047
    
    def __init__(self):
        pass
    
    def _calculate_crc(self, payload):
        """
        Calculate 4-bit CRC for DSHOT frame.
        
        Args:
            payload: 12-bit value (throttle[11:1] + telemetry[0])
        
        Returns:
            4-bit CRC value
        """
        crc = (payload ^ (payload >> 4) ^ (payload >> 8)) & 0x0F
        return crc
    
    def create_frame(self, throttle, telemetry=False):
        """
        Create a complete DSHOT frame with CRC.
        
        Args:
            throttle: 11-bit throttle value (0-2047)
            telemetry: Request telemetry data (default: False)
        
        Returns:
            16-bit DSHOT frame (throttle[15:5] + telem[4] + crc[3:0])
        
        Raises:
            ValueError: If throttle is out of range
        """
        if not (0 <= throttle <= 2047):
            raise ValueError(f"Throttle must be 0-2047, got {throttle}")
        
        # Build 12-bit payload: throttle (11 bits) + telemetry (1 bit)
        payload = (throttle << 1) | (1 if telemetry else 0)
        
        # Calculate CRC
        crc = self._calculate_crc(payload)
        
        # Combine into 16-bit frame
        frame = (payload << 4) | crc
        
        return frame
    
    def throttle(self, value, telemetry=False):
        """
        Create throttle command frame.
        
        Args:
            value: Throttle value (48-2047, or use constants for special commands)
            telemetry: Request telemetry data
        
        Returns:
            16-bit DSHOT frame
        """
        return self.create_frame(value, telemetry)
    
    def motor_stop(self, telemetry=False):
        """Create motor stop/disarm command"""
        return self.create_frame(self.CMD_MOTOR_STOP, telemetry)
    
    def esc_info(self, telemetry=True):
        """Request ESC information"""
        return self.create_frame(self.CMD_ESC_INFO, telemetry)
    
    def spin_direction_normal(self, telemetry=False):
        """Set normal spin direction"""
        return self.create_frame(self.CMD_SPIN_DIRECTION_NORMAL, telemetry)
    
    def spin_direction_reversed(self, telemetry=False):
        """Set reversed spin direction"""
        return self.create_frame(self.CMD_SPIN_DIRECTION_REVERSED, telemetry)
    
    def mode_3d_off(self, telemetry=False):
        """Disable 3D mode"""
        return self.create_frame(self.CMD_3D_MODE_OFF, telemetry)
    
    def mode_3d_on(self, telemetry=False):
        """Enable 3D mode (bidirectional)"""
        return self.create_frame(self.CMD_3D_MODE_ON, telemetry)
    
    def settings_request(self, telemetry=True):
        """Request current ESC settings"""
        return self.create_frame(self.CMD_SETTINGS_REQUEST, telemetry)
    
    def save_settings(self, telemetry=False):
        """Save current settings to EEPROM"""
        return self.create_frame(self.CMD_SAVE_SETTINGS, telemetry)
    
    def decode_frame(self, frame):
        """
        Decode a DSHOT frame.
        
        Args:
            frame: 16-bit DSHOT frame
        
        Returns:
            dict with 'throttle', 'telemetry', 'crc', 'crc_valid'
        """
        # Extract fields
        crc_received = frame & 0x0F
        payload = (frame >> 4) & 0xFFF
        telemetry = payload & 0x01
        throttle = (payload >> 1) & 0x7FF
        
        # Verify CRC
        crc_calculated = self._calculate_crc(payload)
        crc_valid = (crc_received == crc_calculated)
        
        return {
            'throttle': throttle,
            'telemetry': bool(telemetry),
            'crc': crc_received,
            'crc_valid': crc_valid,
            'payload': payload
        }
    
    def format_frame_hex(self, frame):
        """Format frame as hex string for display"""
        return f"0x{frame:04X}"
    
    def format_frame_binary(self, frame):
        """Format frame as binary string for display"""
        return f"0b{frame:016b}"


class DshotWishbone:
    """
    Wishbone interface controller for DSHOT module.
    
    Register Map (wb_dshot_controller.sv):
        0x00: MOTOR1_VALUE [15:0] - Motor 1 DSHOT frame
        0x04: MOTOR2_VALUE [15:0] - Motor 2 DSHOT frame
        0x08: MOTOR3_VALUE [15:0] - Motor 3 DSHOT frame
        0x0C: MOTOR4_VALUE [15:0] - Motor 4 DSHOT frame
        0x10: STATUS [3:0]        - Ready bits [motor4, motor3, motor2, motor1]
        0x14: CONFIG [15:0]       - DSHOT mode (150, 300, or 600)
    
    Usage:
        wb = DshotWishbone(base_address=0x40000000, write_func=my_write, read_func=my_read)
        
        # Set DSHOT speed
        wb.set_mode(300)  # DSHOT300
        
        # Control motors
        encoder = DshotEncoder()
        wb.set_motor(1, encoder.throttle(1000))
        wb.set_motor(2, encoder.throttle(1500))
        
        # Check status
        status = wb.get_status()
        if status['motor1_ready']:
            wb.set_motor(1, encoder.throttle(2000))
    """
    
    # Register offsets
    REG_MOTOR1 = 0x00
    REG_MOTOR2 = 0x04
    REG_MOTOR3 = 0x08
    REG_MOTOR4 = 0x0C
    REG_STATUS = 0x10
    REG_CONFIG = 0x14
    
    # DSHOT modes
    MODE_150 = 150
    MODE_300 = 300
    MODE_600 = 600
    
    def __init__(self, base_address=0x40000000, write_func=None, read_func=None):
        """
        Initialize Wishbone controller.
        
        Args:
            base_address: Base address of DSHOT controller in memory map
            write_func: Function(addr, value) to write 32-bit value to address
            read_func: Function(addr) -> value to read 32-bit value from address
        """
        self.base = base_address
        self.write = write_func or self._default_write
        self.read = read_func or self._default_read
    
    def _default_write(self, addr, value):
        """Default write stub - override with actual hardware access"""
        print(f"WRITE: addr=0x{addr:08X}, value=0x{value:08X}")
    
    def _default_read(self, addr):
        """Default read stub - override with actual hardware access"""
        print(f"READ: addr=0x{addr:08X}")
        return 0
    
    def set_motor(self, motor_num, dshot_frame):
        """
        Set DSHOT command for a motor.
        
        Args:
            motor_num: Motor number (1-4)
            dshot_frame: 16-bit DSHOT frame (from DshotEncoder)
        
        Raises:
            ValueError: If motor_num is out of range
        """
        if not (1 <= motor_num <= 4):
            raise ValueError(f"Motor number must be 1-4, got {motor_num}")
        
        reg_offset = [self.REG_MOTOR1, self.REG_MOTOR2, 
                      self.REG_MOTOR3, self.REG_MOTOR4][motor_num - 1]
        
        self.write(self.base + reg_offset, dshot_frame & 0xFFFF)
    
    def set_mode(self, mode):
        """
        Set DSHOT protocol speed.
        
        Args:
            mode: DSHOT mode (150, 300, or 600)
        
        Raises:
            ValueError: If mode is not supported
        """
        if mode not in [150, 300, 600]:
            raise ValueError(f"Mode must be 150, 300, or 600, got {mode}")
        
        self.write(self.base + self.REG_CONFIG, mode)
    
    def get_mode(self):
        """
        Read current DSHOT mode.
        
        Returns:
            Current mode (150, 300, or 600)
        """
        return self.read(self.base + self.REG_CONFIG) & 0xFFFF
    
    def get_status(self):
        """
        Read ready status for all motors.
        
        Returns:
            dict with 'motor1_ready', 'motor2_ready', 'motor3_ready', 'motor4_ready'
        """
        status = self.read(self.base + self.REG_STATUS)
        return {
            'motor1_ready': bool(status & 0x01),
            'motor2_ready': bool(status & 0x02),
            'motor3_ready': bool(status & 0x04),
            'motor4_ready': bool(status & 0x08),
        }
    
    def wait_ready(self, motor_num, timeout_ms=10):
        """
        Wait for motor to be ready.
        
        Args:
            motor_num: Motor number (1-4)
            timeout_ms: Timeout in milliseconds
        
        Returns:
            True if ready, False if timeout
        """
        import time
        start = time.time()
        ready_bit = 1 << (motor_num - 1)
        
        while (time.time() - start) < (timeout_ms / 1000.0):
            status = self.read(self.base + self.REG_STATUS)
            if status & ready_bit:
                return True
            time.sleep(0.0001)  # 100us
        
        return False
    
    def set_all_motors(self, motor1=None, motor2=None, motor3=None, motor4=None):
        """
        Set multiple motors at once.
        
        Args:
            motor1-4: DSHOT frames for each motor (None = skip)
        """
        if motor1 is not None:
            self.set_motor(1, motor1)
        if motor2 is not None:
            self.set_motor(2, motor2)
        if motor3 is not None:
            self.set_motor(3, motor3)
        if motor4 is not None:
            self.set_motor(4, motor4)


def test_wishbone_controller():
    """Test the Wishbone controller interface"""
    print("\n=== DSHOT Wishbone Controller Test ===\n")
    
    encoder = DshotEncoder()
    wb = DshotWishbone(base_address=0x40000000)
    
    # Set mode
    print("Setting DSHOT300 mode:")
    wb.set_mode(300)
    
    print("\nReading current mode:")
    mode = wb.get_mode()
    print(f"Current mode: DSHOT{mode}")
    
    # Set motor values
    print("\nSetting motor throttles:")
    wb.set_motor(1, encoder.throttle(1000))
    wb.set_motor(2, encoder.throttle(1500))
    wb.set_motor(3, encoder.motor_stop())
    wb.set_motor(4, encoder.throttle(2047))
    
    # Check status
    print("\nReading motor status:")
    status = wb.get_status()
    for i in range(1, 5):
        ready = status[f'motor{i}_ready']
        print(f"  Motor {i}: {'Ready' if ready else 'Busy'}")
    
    # Switch mode
    print("\nSwitching to DSHOT600:")
    wb.set_mode(600)
    
    # Set all motors at once
    print("\nSetting all motors to half throttle:")
    half = encoder.throttle(1047)
    wb.set_all_motors(motor1=half, motor2=half, motor3=half, motor4=half)
    
    print("\nTest complete!")


def test_dshot_encoder():
    """Test the DSHOT encoder with various values"""
    encoder = DshotEncoder()
    
    print("=== DSHOT Encoder Test ===\n")
    
    # Test motor stop
    stop = encoder.motor_stop()
    decoded = encoder.decode_frame(stop)
    print(f"Motor Stop: {encoder.format_frame_hex(stop)}")
    print(f"  Decoded: throttle={decoded['throttle']}, telem={decoded['telemetry']}, CRC valid={decoded['crc_valid']}\n")
    
    # Test minimum throttle
    min_thr = encoder.throttle(48)
    decoded = encoder.decode_frame(min_thr)
    print(f"Min Throttle (48): {encoder.format_frame_hex(min_thr)}")
    print(f"  Binary: {encoder.format_frame_binary(min_thr)}")
    print(f"  Decoded: throttle={decoded['throttle']}, telem={decoded['telemetry']}, CRC valid={decoded['crc_valid']}\n")
    
    # Test mid throttle
    mid_thr = encoder.throttle(1047)
    decoded = encoder.decode_frame(mid_thr)
    print(f"Mid Throttle (1047): {encoder.format_frame_hex(mid_thr)}")
    print(f"  Decoded: throttle={decoded['throttle']}, telem={decoded['telemetry']}, CRC valid={decoded['crc_valid']}\n")
    
    # Test max throttle
    max_thr = encoder.throttle(2047)
    decoded = encoder.decode_frame(max_thr)
    print(f"Max Throttle (2047): {encoder.format_frame_hex(max_thr)}")
    print(f"  Decoded: throttle={decoded['throttle']}, telem={decoded['telemetry']}, CRC valid={decoded['crc_valid']}\n")
    
    # Test with telemetry
    telem_frame = encoder.throttle(1000, telemetry=True)
    decoded = encoder.decode_frame(telem_frame)
    print(f"Throttle 1000 + Telemetry: {encoder.format_frame_hex(telem_frame)}")
    print(f"  Decoded: throttle={decoded['throttle']}, telem={decoded['telemetry']}, CRC valid={decoded['crc_valid']}\n")
    
    # Test special commands
    print("=== Special Commands ===")
    reverse = encoder.spin_direction_reversed()
    decoded = encoder.decode_frame(reverse)
    print(f"Spin Direction Reversed: {encoder.format_frame_hex(reverse)}")
    print(f"  Decoded: throttle={decoded['throttle']}, CRC valid={decoded['crc_valid']}\n")
    
    # Test CRC validation with corrupted frame
    print("=== CRC Validation ===")
    good_frame = encoder.throttle(1000)
    bad_frame = good_frame ^ 0x0001  # Flip LSB to corrupt CRC
    decoded_good = encoder.decode_frame(good_frame)
    decoded_bad = encoder.decode_frame(bad_frame)
    print(f"Good frame: {encoder.format_frame_hex(good_frame)}, CRC valid={decoded_good['crc_valid']}")
    print(f"Bad frame:  {encoder.format_frame_hex(bad_frame)}, CRC valid={decoded_bad['crc_valid']}")


if __name__ == "__main__":
    test_dshot_encoder()
    test_wishbone_controller()
