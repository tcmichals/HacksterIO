# Tang9K Python Library

High-level Python interface for controlling the Tang9K FPGA quadcopter hardware via SPI/Wishbone.

## Features

The `tang9k.py` module provides a clean, object-oriented interface to all Tang9K peripherals:

- **LED Control**: Simple 4-bit counter display
- **Serial UART**: 16650-style UART with half-duplex support for BLHeli ESC configuration
- **PWM Decoder**: Read RC receiver PWM signals (6 channels)
- **DSHOT Controller**: Send DSHOT commands to ESCs (4 motors)
- **NeoPixel Controller**: Control WS2812 LED strips (8 pixels)
- **Serial/DSHOT Mux**: Switch shared output between serial and DSHOT modes

## Installation

```bash
# Install dependencies
pip install spidev

# Or use the setup script
cd python/test
./setup.sh
```

## Quick Start

### Basic Usage

```python
from tang9k import Tang9K

# Connect to Tang9K via SPI
tang9k = Tang9K(bus=0, device=0, max_speed_hz=1000000)

# Control LEDs
tang9k.set_leds(0x0F)  # Turn on all 4 LEDs

# Send serial data
tang9k.serial_write_string("Hello, ESC!")

# Read PWM from RC receiver
pwm_values = tang9k.read_pwm_values(num_channels=4)
print(f"PWM: {pwm_values}")

# Control NeoPixels
tang9k.neopixel_set_color(0, 0xFF0000)  # First pixel red
tang9k.neopixel_update()

# Clean up
tang9k.close()
```

### Serial Communication (Half-Duplex)

```python
# Enable half-duplex mode for ESC communication
tang9k.serial_set_half_duplex(True)

# Switch mux to serial mode (vs DSHOT)
tang9k.set_serial_mode()

# Send data
tang9k.serial_write_string("AT+CONFIG", add_newline=False)

# Read response
while True:
    byte = tang9k.serial_read_byte()
    if byte is not None:
        print(chr(byte), end='')
    else:
        break
```

### DSHOT Motor Control

```python
# Switch to DSHOT mode
tang9k.set_dshot_mode()

# Arm motors (throttle 0)
tang9k.dshot_arm_all()

# Set individual motor throttle
tang9k.dshot_set_throttle(motor=0, throttle=100)  # Motor 1, 100/2047
tang9k.dshot_set_throttle(motor=1, throttle=100)  # Motor 2, 100/2047
# ... etc

# Disarm
tang9k.dshot_disarm_all()

# Switch back to serial mode
tang9k.set_serial_mode()
```

### NeoPixel Effects

```python
from tang9k import Tang9K, COLORS_RAINBOW

tang9k = Tang9K()

# Static colors
tang9k.neopixel_set_all(0xFF0000)  # All red

# Individual pixels
for i in range(8):
    tang9k.neopixel_set_color(i, COLORS_RAINBOW[i])
tang9k.neopixel_update()

# Waterfall effect
running = True
def should_continue():
    return running

tang9k.neopixel_waterfall(COLORS_RAINBOW, delay=0.1, callback=should_continue)
```

## API Reference

### Tang9K Class

#### Constructor

```python
Tang9K(bus=0, device=0, max_speed_hz=1000000)
```

- `bus`: SPI bus number (typically 0)
- `device`: SPI device number (typically 0)
- `max_speed_hz`: SPI clock speed in Hz

#### Low-Level Wishbone Access

```python
write_wishbone(address: int, data: int) -> None
read_wishbone(address: int) -> Optional[int]
```

Direct Wishbone bus read/write. Use high-level methods instead when possible.

#### LED Control

```python
set_leds(value: int) -> None
```

Set 4-bit LED counter value (0-15).

#### Serial UART

```python
serial_write_byte(byte: int) -> None
serial_write(data: bytes) -> None
serial_write_string(text: str, add_newline: bool = True) -> None
serial_read_byte() -> Optional[int]
serial_set_half_duplex(enable: bool) -> None
```

- `serial_write_byte`: Send single byte
- `serial_write`: Send byte array
- `serial_write_string`: Send text string
- `serial_read_byte`: Read single byte (returns None if no data)
- `serial_set_half_duplex`: Enable/disable half-duplex mode

#### PWM Decoder

```python
read_pwm_values(num_channels: int = 6) -> List[int]
```

Read PWM pulse widths from RC receiver channels. Returns list of values in microseconds.

#### DSHOT Controller

```python
dshot_set_throttle(motor: int, throttle: int) -> None
dshot_arm_all() -> None
dshot_disarm_all() -> None
```

- `dshot_set_throttle`: Set motor throttle (motor 0-3, throttle 0-2047)
- `dshot_arm_all`: Arm all motors (send throttle 0)
- `dshot_disarm_all`: Disarm all motors

#### Serial/DSHOT Mux

```python
set_serial_mode() -> None
set_dshot_mode() -> None
```

Switch shared output pin between serial UART and DSHOT modes.

#### NeoPixel Controller

```python
neopixel_set_color(pixel: int, rgb: int) -> None
neopixel_update() -> None
neopixel_set_all(rgb: int) -> None
neopixel_clear() -> None
neopixel_waterfall(colors: List[int], delay: float = 0.1,
                  callback: Optional[Callable[[], bool]] = None) -> None
```

- `neopixel_set_color`: Set pixel color (pixel 0-7, rgb 0xRRGGBB)
- `neopixel_update`: Send buffered colors to LEDs
- `neopixel_set_all`: Set all pixels to same color
- `neopixel_clear`: Turn off all pixels
- `neopixel_waterfall`: Run animated waterfall effect

#### Color Palettes

```python
COLORS_RAINBOW  # 7 colors
COLORS_CHRISTMAS  # Red, green, white
COLORS_POLICE  # Red, blue
```

Predefined color lists for effects.

## Examples

### Run Example Script

```bash
cd python/test

# Run all examples
python3 example_tang9k.py

# Run specific example
python3 example_tang9k.py --example leds
python3 example_tang9k.py --example neopixel
python3 example_tang9k.py --example serial

# Specify SPI device and speed
python3 example_tang9k.py --device /dev/spidev0.0 --speed 2000000
```

Available examples:
- `leds`: LED counter 0-15
- `serial`: Send/receive serial data
- `pwm`: Read PWM values from RC receiver
- `neopixel`: Rainbow waterfall effect
- `mux`: Switch between serial and DSHOT modes
- `dshot`: Motor control (requires confirmation)
- `all`: Run all examples except DSHOT

### TUI Application

The full-featured TUI application uses the Tang9K class:

```bash
python3 tang9k_tui.py --device /dev/spidev0.0
```

Features:
- Serial console with half-duplex TX/RX
- LED counter control
- NeoPixel waterfall effects
- PWM value monitoring
- BLHeli ESC passthrough mode

## Hardware Setup

### SPI Connection

Connect Raspberry Pi or Linux SBC to Tang9K:

| Signal | Tang9K Pin | RPi Pin |
|--------|------------|---------|
| SPI_CLK | pin 4 | GPIO 11 (SCLK) |
| SPI_CS | pin 5 | GPIO 8 (CE0) |
| SPI_MOSI | pin 6 | GPIO 10 (MOSI) |
| SPI_MISO | pin 7 | GPIO 9 (MISO) |
| GND | GND | GND |

### Pin Assignments

See `tang9k.cst` for complete pin mapping:

- **Serial (half-duplex)**: pin 25
- **PWM inputs**: pins 26-29 (4 channels)
- **DSHOT outputs**: pins 30-33 (4 motors)
- **NeoPixel output**: pin 34

### Enable SPI on Raspberry Pi

```bash
# Enable SPI interface
sudo raspi-config
# Navigate to: Interface Options -> SPI -> Enable

# Add user to spi group
sudo usermod -a -G spi $USER

# Reboot
sudo reboot
```

## Address Map

| Peripheral | Base Address | Size |
|------------|--------------|------|
| LED Controller | 0x0000 | 256 bytes |
| Serial UART | 0x0100 | 256 bytes |
| PWM Decoder | 0x0200 | 256 bytes |
| DSHOT Controller | 0x0300 | 256 bytes |
| Serial/DSHOT Mux | 0x0400 | 4 bytes |
| NeoPixel Controller | 0x0500 | 256 bytes |

### Serial UART Registers

| Offset | Name | Access | Description |
|--------|------|--------|-------------|
| 0x00 | DATA | R/W | Data register (TX/RX FIFO) |
| 0x04 | IER | R/W | Interrupt Enable |
| 0x08 | IIR | R | Interrupt ID |
| 0x0C | LSR | R | Line Status (bit 0 = data ready) |
| 0x10 | CTRL | R/W | Control (bit 0 = half-duplex enable) |

## Troubleshooting

### SPI Permission Denied

```bash
# Add user to spi and dialout groups
sudo usermod -a -G spi,dialout $USER

# Verify SPI device permissions
ls -l /dev/spidev*

# Should show: crw-rw---- 1 root spi ...
```

### Import spidev Error

```bash
# Install spidev
pip3 install spidev

# Or system-wide
sudo apt-get install python3-spidev
```

### No Data Received

- Check SPI wiring (CLK, MOSI, MISO, CS, GND)
- Verify Tang9K is programmed with correct bitstream
- Check SPI speed (try lowering to 500000 Hz)
- Use logic analyzer to verify SPI transactions

### Serial Not Working

- Ensure half-duplex mode is enabled: `tang9k.serial_set_half_duplex(True)`
- Switch mux to serial mode: `tang9k.set_serial_mode()`
- Check serial pin 25 is connected
- Verify baud rate matches (default 115200)

## See Also

- [BLHELI_PASSTHROUGH.md](../../docs/BLHELI_PASSTHROUGH.md) - BLHeli ESC configuration
- [SYSTEM_OVERVIEW.md](../../docs/SYSTEM_OVERVIEW.md) - Complete system architecture
- [USB_SERIAL_BRIDGE.md](USB_SERIAL_BRIDGE.md) - Hardware serial adapter setup
- [HALF_DUPLEX_SERIAL.md](HALF_DUPLEX_SERIAL.md) - Half-duplex implementation details
