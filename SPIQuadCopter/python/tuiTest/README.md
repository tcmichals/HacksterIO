# Tang9K SPI Master TUI

## Installation

Install dependencies:
```bash
pip install textual spidev
```

Note: `spidev` requires SPI to be enabled on your system (e.g., Raspberry Pi).

## Usage

Run the TUI application:
```bash
python tang9k_tui.py
```

## Features

- **Serial Console**: Send and receive serial data via SPI/Wishbone (half-duplex)
- **LED Counter**: Increment counter displayed on Tang9K LEDs
- **NeoPixel Waterfall**: Animated color waterfall on NeoPixel string
- **PWM Monitor**: Read and display PWM decoder values
- **BLHeli Passthrough**: Configure ESCs using BLHeliSuite or BLHeliConfigurator

## BLHeli ESC Configuration

The app creates a virtual serial port (PTY) that BLHeli tools can connect to:

1. Click "Enable Passthrough" button (or press `p`)
2. Note the PTY device path (e.g., `/tmp/blheli_passthrough`)
3. Open BLHeliSuite or BLHeliConfigurator
4. Select the PTY device as the serial port
5. Configure your ESCs as normal
6. Click "Disable Passthrough" when done

**Important**: Passthrough mode switches the mux from DSHOT to serial. Motors will not respond to DSHOT commands while passthrough is enabled.

## Keyboard Shortcuts

- `q`: Quit application
- `c`: Clear serial log
- `w`: Toggle NeoPixel waterfall
- `p`: Toggle BLHeli passthrough mode

## SPI Configuration

Default configuration:
- Bus: 0
- Device: 0
- Speed: 1 MHz
- Mode: 0

Modify in `SPIMaster.__init__()` if needed.

## Wishbone Address Map

- 0x0000: LED Controller
- 0x0100: Serial (UART)
- 0x0200: PWM Decoder
- 0x0300: DSHOT Controller
- 0x0400: Serial/DSHOT Mux
- 0x0500: NeoPixel Controller

See `SYSTEM_OVERVIEW.md` for full details.
