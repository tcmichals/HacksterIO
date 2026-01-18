# Tang9K Project TUI Application

This Python application provides a Terminal User Interface (TUI) for interacting with the Tang9K Quadcopter FPGA design over SPI. It allows you to monitor PWM inputs, control DSHOT motors, configure NeoPixels, toggle on-board LEDs, and enable Serial Passthrough for BLHeli ESC configuration.

## Prerequisites

- **Python 3.7+**
- **SpiDev**: Python bindings for Linux SPI device (`/dev/spidevX.Y`)
- **Curses**: Standard terminal handling library (usually pre-installed on Linux)

## Installation

1. **Install Dependencies**:
   ```bash
   pip install spidev
   ```
   *Note: On some systems, you may need to install `python3-spidev` via your package manager.*

2. **Permissions**:
   Ensure your user has permission to access the SPI device. Usually, this means being in the `spi` or `gpio` group:
   ```bash
   sudo usermod -a -G spi $USER
   # Logout and log back in for changes to take effect
   ```

## Hardware Setup

The application is configured to use **SPI Bus 1, Device 0** by default (per the `App` class initialization in `tui_app.py`).

Ensure your host (e.g., Raspberry Pi or another Linux-based controller) is connected to the Tang Nano 9K according to the [Hardware Pins](../../docs/HARDWARE_PINS.md) documentation.

## Running the Application

Navigate to this directory and run:

```bash
python tui_app.py
```

## Key Mapping & Usage

- **Global Keys**:
  - `0`: Return to Main Menu from any screen.
  - `q`: Exit application (from Main Menu).
  - `Shift + Q`: Force quit from anywhere.

### Mode-Specific Commands

| Mode | Command | Action |
|------|---------|--------|
| **DSHOT** | `q/a`, `w/s`, `e/d`, `r/f` | Increment/Decrement Throttle for Motors 1-4 |
| | `!` | Emergency Stop (All motors to 0) |
| **NeoPixel** | `Arrows` | Navigate Pixels and R, G, B, W components |
| | `Page Up/Down`| Adjust Selected Color Value (+/- 10) |
| | `c` / `C` | Clear All Pixels |
| | `Space` | Refresh Hardware (Send buffer to LEDs) |
| **LED** | `1` - `5` | Toggle On-board LEDs |
| **Serial Bypass** | `m` | Toggle between PASSTHROUGH and DSHOT mode |
| | `1` - `4` | Select target Motor channel for passthrough |

## Features

- **Live Hardware Sync**: When entering the NeoPixel menu, the TUI automatically reads back the current colors from the FPGA to stay in sync.
- **ASCII-Safe UI**: Optimized for all terminal environments, including restricted locales and SSH sessions.
- **Key Debugger**: Real-time display of key codes in the footer to help with terminal debugging.
