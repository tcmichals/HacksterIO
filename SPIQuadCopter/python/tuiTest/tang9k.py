"""
Tang9K Hardware Wrapper

Provides a high-level Python interface to the Tang9K FPGA peripherals
via SPI/Wishbone communication.

Features:
- LED Control
- Serial UART (16650-style, half-duplex)
- PWM Decoder
- DSHOT ESC Control
- NeoPixel Controller
- Serial/DSHOT Mux Control
"""

import time
from typing import Optional, List, Callable

try:
    import spidev
except ImportError:
    print("Warning: spidev not available. Install with: pip install spidev")
    spidev = None


# Wishbone Address Map
ADDR_LED_CTRL = 0x0000
ADDR_SERIAL = 0x0100
ADDR_PWM = 0x0200
ADDR_DSHOT = 0x0300
ADDR_MUX = 0x0400
ADDR_NEOPX = 0x0500

# DSHOT Register Offsets (relative to ADDR_DSHOT)
DSHOT_MOTOR1 = 0x00
DSHOT_MOTOR2 = 0x04
DSHOT_MOTOR3 = 0x08
DSHOT_MOTOR4 = 0x0C
DSHOT_STATUS = 0x10  # Ready bits for each motor
DSHOT_CONFIG = 0x14  # DSHOT mode (150, 300, or 600)

# Serial Register Offsets
SERIAL_DATA = 0x00
SERIAL_IER = 0x04
SERIAL_IIR = 0x08
SERIAL_LSR = 0x0C
SERIAL_CTRL = 0x10


class Tang9K:
    """High-level interface to Tang9K FPGA peripherals"""
    
    def __init__(self, bus=0, device=0, max_speed_hz=1000000):
        """
        Initialize Tang9K connection
        
        Args:
            bus: SPI bus number (default 0)
            device: SPI device number (default 0)
            max_speed_hz: SPI clock speed in Hz (default 1 MHz)
        """
        self.spi = None
        if spidev:
            try:
                self.spi = spidev.SpiDev()
                self.spi.open(bus, device)
                self.spi.max_speed_hz = max_speed_hz
                self.spi.mode = 0
            except Exception as e:
                print(f"Failed to open SPI device: {e}")
                self.spi = None
    
    def write_wishbone(self, address: int, data: int) -> None:
        """
        Write to Wishbone address via SPI
        
        Args:
            address: 32-bit Wishbone address
            data: 32-bit data to write
        """
        if not self.spi:
            return
        
        # Format: WRITE_REQ (0xA2), addr[3:0], data[3:0]
        packet = [
            0xA2,  # Write request
            (address >> 24) & 0xFF,
            (address >> 16) & 0xFF,
            (address >> 8) & 0xFF,
            address & 0xFF,
            (data >> 24) & 0xFF,
            (data >> 16) & 0xFF,
            (data >> 8) & 0xFF,
            data & 0xFF
        ]
        
        try:
            self.spi.xfer2(packet)
            time.sleep(0.001)  # Small delay for transaction
        except Exception as e:
            print(f"SPI write error: {e}")
    
    def read_wishbone(self, address: int) -> Optional[int]:
        """
        Read from Wishbone address via SPI
        
        Args:
            address: 32-bit Wishbone address
            
        Returns:
            32-bit data value or None on error
        """
        if not self.spi:
            return None
        
        # Format: READ_REQ (0xA1), addr[3:0]
        packet = [
            0xA1,  # Read request
            (address >> 24) & 0xFF,
            (address >> 16) & 0xFF,
            (address >> 8) & 0xFF,
            address & 0xFF
        ]
        
        try:
            # Send read request
            self.spi.xfer2(packet)
            time.sleep(0.001)
            
            # Read response (READ_RESP 0xA3 + data[3:0])
            response = self.spi.readbytes(5)
            if response[0] == 0xA3:
                data = (response[1] << 24) | (response[2] << 16) | (response[3] << 8) | response[4]
                return data
        except Exception as e:
            print(f"SPI read error: {e}")
        
        return None
    
    def close(self):
        """Close SPI connection"""
        if self.spi:
            self.spi.close()
    
    # =============================
    # LED Control
    # =============================
    
    def set_leds(self, value: int) -> None:
        """
        Set LED counter value
        
        Args:
            value: 4-bit LED value (0-15)
        """
        self.write_wishbone(ADDR_LED_CTRL, value & 0x0F)
    
    # =============================
    # Serial UART
    # =============================
    
    def serial_write_byte(self, byte: int) -> None:
        """
        Write a single byte to serial port
        
        Args:
            byte: Byte value (0-255)
        """
        self.write_wishbone(ADDR_SERIAL + SERIAL_DATA, byte & 0xFF)
    
    def serial_write(self, data: bytes) -> None:
        """
        Write bytes to serial port
        
        Args:
            data: Bytes to write
        """
        for byte in data:
            self.serial_write_byte(byte)
            time.sleep(0.01)  # Delay between characters
    
    def serial_write_string(self, text: str, add_newline: bool = True) -> None:
        """
        Write string to serial port
        
        Args:
            text: String to write
            add_newline: Append newline character (default True)
        """
        for char in text:
            self.serial_write_byte(ord(char))
            time.sleep(0.01)
        
        if add_newline:
            self.serial_write_byte(ord('\n'))
    
    def serial_read_byte(self) -> Optional[int]:
        """
        Read a single byte from serial port
        
        Returns:
            Byte value (0-255) or None if no data available
        """
        # Check line status register for data ready
        lsr = self.read_wishbone(ADDR_SERIAL + SERIAL_LSR)
        if lsr and (lsr & 0x01):  # Data ready bit
            return self.read_wishbone(ADDR_SERIAL + SERIAL_DATA) & 0xFF
        return None
    
    def serial_read_available(self, max_bytes: int = 256) -> bytes:
        """
        Read all available bytes from serial port
        
        Args:
            max_bytes: Maximum number of bytes to read (default 256)
            
        Returns:
            Bytes object with all available data (empty if none)
        """
        data = bytearray()
        for _ in range(max_bytes):
            byte = self.serial_read_byte()
            if byte is None:
                break
            data.append(byte)
        return bytes(data)
    
    def serial_set_half_duplex(self, enable: bool) -> None:
        """
        Enable or disable half-duplex mode
        
        Args:
            enable: True for half-duplex, False for full-duplex
        """
        self.write_wishbone(ADDR_SERIAL + SERIAL_CTRL, 1 if enable else 0)
    
    # =============================
    # PWM Decoder
    # =============================
    
    def read_pwm_values(self, num_channels: int = 6) -> List[int]:
        """
        Read PWM decoder values
        
        Args:
            num_channels: Number of PWM channels to read (default 6)
            
        Returns:
            List of PWM pulse widths in microseconds
        """
        values = []
        for i in range(num_channels):
            addr = ADDR_PWM + (i * 4)
            value = self.read_wishbone(addr)
            if value is not None:
                values.append(value & 0xFFFF)
            else:
                values.append(0)
        return values
    
    # =============================
    # DSHOT Controller
    # =============================
    
    def dshot_set_motor(self, motor: int, dshot_frame: int) -> None:
        """
        Set DSHOT command for a motor
        
        Args:
            motor: Motor number (1-4)
            dshot_frame: 16-bit DSHOT frame (use DshotEncoder to create)
        """
        if motor < 1 or motor > 4:
            raise ValueError("Motor must be 1-4")
        
        offset = [DSHOT_MOTOR1, DSHOT_MOTOR2, DSHOT_MOTOR3, DSHOT_MOTOR4][motor - 1]
        addr = ADDR_DSHOT + offset
        self.write_wishbone(addr, dshot_frame & 0xFFFF)
    
    def dshot_set_throttle(self, motor: int, throttle: int) -> None:
        """
        Set DSHOT throttle for a motor (simplified - just sends raw value)
        
        WARNING: This does NOT calculate CRC! Use DshotEncoder for proper frames.
        This is kept for backward compatibility only.
        
        Args:
            motor: Motor number (1-4) 
            throttle: Throttle value (0-2047)
        """
        if motor < 1 or motor > 4:
            raise ValueError("Motor must be 1-4")
        
        # Simple approach - just send the value (no CRC)
        # For production, use DshotEncoder.create_frame() instead
        offset = [DSHOT_MOTOR1, DSHOT_MOTOR2, DSHOT_MOTOR3, DSHOT_MOTOR4][motor - 1]
        addr = ADDR_DSHOT + offset
        self.write_wishbone(addr, throttle & 0x7FF)
    
    def dshot_set_mode(self, mode: int) -> None:
        """
        Set DSHOT protocol speed
        
        Args:
            mode: DSHOT mode (150, 300, or 600)
        """
        if mode not in [150, 300, 600]:
            raise ValueError("Mode must be 150, 300, or 600")
        
        self.write_wishbone(ADDR_DSHOT + DSHOT_CONFIG, mode)
    
    def dshot_get_mode(self) -> int:
        """
        Get current DSHOT mode
        
        Returns:
            Current mode (150, 300, or 600)
        """
        return self.read_wishbone(ADDR_DSHOT + DSHOT_CONFIG) & 0xFFFF
    
    def dshot_get_status(self) -> dict:
        """
        Get DSHOT ready status for all motors
        
        Returns:
            dict with 'motor1_ready', 'motor2_ready', 'motor3_ready', 'motor4_ready'
        """
        status = self.read_wishbone(ADDR_DSHOT + DSHOT_STATUS)
        return {
            'motor1_ready': bool(status & 0x01),
            'motor2_ready': bool(status & 0x02),
            'motor3_ready': bool(status & 0x04),
            'motor4_ready': bool(status & 0x08),
        }
    
    def dshot_wait_ready(self, motor: int, timeout_ms: int = 10) -> bool:
        """
        Wait for motor to be ready
        
        Args:
            motor: Motor number (1-4)
            timeout_ms: Timeout in milliseconds
            
        Returns:
            True if ready, False if timeout
        """
        import time
        start = time.time()
        ready_bit = 1 << (motor - 1)
        
        while (time.time() - start) < (timeout_ms / 1000.0):
            status = self.read_wishbone(ADDR_DSHOT + DSHOT_STATUS)
            if status & ready_bit:
                return True
            time.sleep(0.0001)  # 100us
        
        return False
    
    def dshot_arm_all(self) -> None:
        """Arm all motors (send throttle 0)"""
        for motor in range(1, 5):
            self.dshot_set_throttle(motor, 0)
    
    def dshot_disarm_all(self) -> None:
        """Disarm all motors"""
        for motor in range(1, 5):
            self.dshot_set_throttle(motor, 0)
    
    # =============================
    # Serial/DSHOT Mux
    # =============================
    
    def set_serial_mode(self) -> None:
        """Switch output to serial (TTL UART) mode"""
        self.write_wishbone(ADDR_MUX, 0)
    
    def set_dshot_mode(self) -> None:
        """Switch output to DSHOT mode"""
        self.write_wishbone(ADDR_MUX, 1)
    
    # =============================
    # NeoPixel Controller
    # =============================
    
    def neopixel_set_color(self, pixel: int, rgb: int) -> None:
        """
        Set NeoPixel color
        
        Args:
            pixel: Pixel index (0-7)
            rgb: 24-bit RGB color (0xRRGGBB)
        """
        if pixel < 0 or pixel > 7:
            raise ValueError("Pixel must be 0-7")
        
        addr = ADDR_NEOPX + (pixel * 4)
        self.write_wishbone(addr, rgb & 0xFFFFFF)
    
    def neopixel_update(self) -> None:
        """Trigger NeoPixel update (send data to LEDs)"""
        self.write_wishbone(ADDR_NEOPX + 0x20, 1)
    
    def neopixel_set_all(self, rgb: int) -> None:
        """
        Set all NeoPixels to same color
        
        Args:
            rgb: 24-bit RGB color (0xRRGGBB)
        """
        for i in range(8):
            self.neopixel_set_color(i, rgb)
        self.neopixel_update()
    
    def neopixel_clear(self) -> None:
        """Turn off all NeoPixels"""
        self.neopixel_set_all(0x000000)
    
    def neopixel_waterfall(self, colors: List[int], delay: float = 0.1, 
                          callback: Optional[Callable[[], bool]] = None) -> None:
        """
        Run a color waterfall effect
        
        Args:
            colors: List of RGB colors
            delay: Delay between frames in seconds
            callback: Optional callback function, return False to stop
        """
        offset = 0
        while True:
            for i in range(8):
                color = colors[(i + offset) % len(colors)]
                self.neopixel_set_color(i, color)
            
            self.neopixel_update()
            
            offset = (offset + 1) % len(colors)
            time.sleep(delay)
            
            if callback and not callback():
                break


# Predefined color palettes
COLORS_RAINBOW = [
    0xFF0000,  # Red
    0xFF7F00,  # Orange
    0xFFFF00,  # Yellow
    0x00FF00,  # Green
    0x0000FF,  # Blue
    0x4B0082,  # Indigo
    0x9400D3,  # Violet
]

COLORS_CHRISTMAS = [
    0xFF0000,  # Red
    0x00FF00,  # Green
    0xFFFFFF,  # White
]

COLORS_POLICE = [
    0xFF0000,  # Red
    0x0000FF,  # Blue
]
