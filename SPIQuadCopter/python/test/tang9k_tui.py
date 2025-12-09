"""
Tang9K SPI Master TUI Application

Features:
- RX/TX serial half-duplex via SPI/Wishbone
- NeoPixel color waterfall control
- PWM decoder monitoring
- LED counter display
- BLHeli ESC passthrough mode
- DSHOT ESC control with runtime speed selection (150/300/600)

Dependencies:
- spidev (for SPI communication)
- textual (for TUI)
"""

import sys
import os
import struct
import time
from typing import Optional
from textual.app import App, ComposeResult
from textual.containers import Container, Horizontal, Vertical
from textual.widgets import Header, Footer, Static, Input, Button, Log, Label, Select
from textual.reactive import reactive
from rich.text import Text

# Add dshot directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '../../dshot'))

# Import Tang9K wrapper, BLHeli passthrough, and DSHOT encoder
from tang9k import Tang9K, COLORS_RAINBOW
from blheli_passthrough import BLHeliPassthrough
from dshot_encoder import DshotEncoder


class DummyTang9K:
    """A minimal no-hardware fallback for running the TUI without SPI device."""
    def __init__(self):
        pass

    def dshot_set_mode(self, mode: int):
        return

    def dshot_get_status(self):
        return {f'motor{i}_ready': False for i in range(1, 5)}

    def serial_read_available(self, max_bytes: int = 256) -> bytes:
        return b""

    def serial_write_string(self, s: str, add_newline: bool = True):
        # Print to stdout so the developer can see TX when running without hardware
        end = "\n" if add_newline else ""
        print(f"[MOCK SERIAL TX] {s}{end}", end="")

    def close(self):
        return


# Wishbone address map (for backward compatibility)
ADDR_LED_CTRL = 0x0000
ADDR_SERIAL = 0x0100
ADDR_PWM = 0x0200
ADDR_DSHOT = 0x0300
ADDR_MUX = 0x0400
ADDR_NEOPX = 0x0500

# Serial register offsets
SERIAL_DATA = 0x00
SERIAL_IER = 0x04
SERIAL_IIR = 0x08
SERIAL_LSR = 0x0C


class Tang9KTUI(App):
    """Tang9K SPI Master TUI Application"""
    
    CSS = """
    Screen {
        background: $surface;
    }
    
    #main-container {
        layout: vertical;
        height: 100%;
    }

    /* Lower row holds controls and status side-by-side below the serial log */
    #lower-row {
        layout: horizontal;
        height: auto;
        margin: 0;
        min-height: 15;
    }

    /* Serial panel occupies most of the screen */
    #serial-panel {
        height: 1fr;
        min-height: 20;
    }

    #control-panel {
        width: 30%;
        min-width: 30;
    }

    #status-panel {
        width: 70%;
        min-width: 70;
        layout: horizontal;
        padding: 0 1;
    }
    
    #status-panel > Vertical {
        width: 1fr;
        min-width: 20;
        margin-right: 2;
    }
    
    #status-panel > Vertical:first-child {
        text-align: left;
    }
    
    .panel {
        border: solid green;
        margin: 1;
        padding: 1;
    }
    
    #serial-panel {
        column-span: 1;
        row-span: 2;
    }
    
    #control-panel {
        column-span: 1;
        row-span: 1;
    }
    
    #status-panel {
        column-span: 1;
        row-span: 1;
    }
    
    .status-row {
        layout: horizontal;
        height: auto;
        margin: 1 0;
    }
    
    .status-label {
        width: 20;
        color: yellow;
    }
    
    /* Make status values fixed-width so updates don't reflow the layout */
    .status-value {
        width: 24;
        min-width: 24;
        max-width: 24;
        color: cyan;
        box-sizing: border-box;
    }
    
    #serial-log {
        height: 1fr;
        border: solid blue;
        min-height: 15;
    }

    /* Ensure control panel size is stable and won't be pushed by child widgets */
    #control-panel {
        min-width: 30;
        max-width: 40;
    }
    
    .button-row {
        layout: horizontal;
        height: 1;
        margin: 1 0;
    }

    /* Simple, consistent button styling */
    Button {
        margin: 0 1;
        padding: 0 1;
        min-width: 10;
        height: 1;
        content-align: center middle;
        box-sizing: border-box;
    }

    /* Avoid changing text metrics on focus to prevent button reflow */
    Button:focus {
        border: round $primary;
        background: $surface-darken-1;
    }

    /* Static control buttons - non-focusable, stable */
    .control-btn {
        background: $surface;
        padding: 0 1;
        height: 1;
        content-align: center middle;
        border: none;
    }
    """
    
    BINDINGS = [
        ("q", "quit", "Quit"),
        ("c", "clear_serial", "Clear Serial"),
        ("w", "waterfall", "NeoPixel Waterfall"),
        ("p", "toggle_passthrough", "Toggle Passthrough"),
        ("1", "set_dshot_150", "DSHOT150"),
        ("2", "set_dshot_300", "DSHOT300"),
        ("3", "set_dshot_600", "DSHOT600"),
        ("l", "led_inc", "LED +1"),
        ("r", "reset_leds", "Reset LEDs"),
        ("v", "read_pwm", "Read PWM"),
        ("plus", "throttle_up", "Throttle +50"),
        ("minus", "throttle_down", "Throttle -50"),
        ("m", "cycle_motor", "Cycle Motor"),
        ("s", "send_throttle", "Send Throttle"),
    ]
    
    led_counter = reactive(0)
    pwm_values = reactive([0] * 6)
    passthrough_mode = reactive(False)
    dshot_mode = reactive(150)
    motor_throttles = reactive([0, 0, 0, 0])  # Throttle for motors 1-4
    current_motor = reactive(1)  # Currently selected motor (1-4)
    
    def __init__(self):
        super().__init__()
        # Attempt to initialize the hardware. If SPI device isn't present,
        # fall back to a dummy implementation so the TUI can run for testing.
        try:
            self.tang9k = Tang9K(bus=0, device=0, max_speed_hz=1000000)
            self._no_spi = False
        except Exception as e:
            # Avoid crashing the entire app when hardware is missing
            print(f"Warning: Failed to open SPI device: {e}")
            self.tang9k = DummyTang9K()
            self._no_spi = True
        self.dshot_encoder = DshotEncoder()
        self.waterfall_running = False
        self.blheli = None
    
    def compose(self) -> ComposeResult:
        """Create child widgets for the app."""
        yield Header()
        
        with Container(id="main-container"):
            # Serial panel (left, full height)
            with Vertical(id="serial-panel", classes="panel"):
                yield Label("═══ Serial Console (Half-Duplex) ═══")
                yield Log(id="serial-log", auto_scroll=True)
                with Horizontal():
                    yield Input(placeholder="Type message and press Enter or click Send...", id="serial-input")
                    yield Button("Send", id="send-button", variant="primary")
            
            # Lower row: controls (left) and status (right)
            with Horizontal(id="lower-row"):
                with Vertical(id="control-panel", classes="panel"):
                    yield Label("═══ Controls (keyboard-only) ═══")
                    # Replace clickable buttons with keyboard-driven controls to avoid layout shifts
                    yield Static(
                        "Keys:\n  l = LED +1\n  r = Reset LEDs\n  w = Toggle Waterfall\n  c = Clear Serial\n  v = Read PWM\n  p = Toggle Passthrough\n  1/2/3 = DSHOT modes\n  +/- = Motor Speed\n  m = Cycle Motor  s = Send",
                        id="controls-help",
                    )

                with Vertical(id="status-panel", classes="panel"):
                    yield Label("═══ Status ═══")
                    # Column 1: General status
                    with Vertical():
                        with Horizontal(classes="status-row"):
                            yield Label("LED Counter:", classes="status-label")
                            yield Static("0x0 (0)", id="led-counter-value", classes="status-value")
                        with Horizontal(classes="status-row"):
                            yield Label("NeoPixel:", classes="status-label")
                            yield Static("Idle", id="neopixel-status", classes="status-value")
                        with Horizontal(classes="status-row"):
                            yield Label("Passthrough:", classes="status-label")
                            yield Static("Disabled", id="passthrough-status", classes="status-value")
                        with Horizontal(classes="status-row"):
                            yield Label("DSHOT Mode:", classes="status-label")
                            yield Static("DSHOT150", id="dshot-mode-status", classes="status-value")
                        with Horizontal(classes="status-row"):
                            yield Label("Motors Ready:", classes="status-label")
                            yield Static("----", id="dshot-ready-status", classes="status-value")
                    
                    # Column 2: PWM channels
                    with Vertical():
                        with Horizontal(classes="status-row"):
                            yield Label("PWM CH0:", classes="status-label")
                            yield Static("0", id="pwm-ch0", classes="status-value")
                        with Horizontal(classes="status-row"):
                            yield Label("PWM CH1:", classes="status-label")
                            yield Static("0", id="pwm-ch1", classes="status-value")
                        with Horizontal(classes="status-row"):
                            yield Label("PWM CH2:", classes="status-label")
                            yield Static("0", id="pwm-ch2", classes="status-value")
                        with Horizontal(classes="status-row"):
                            yield Label("PWM CH3:", classes="status-label")
                            yield Static("0", id="pwm-ch3", classes="status-value")
                        with Horizontal(classes="status-row"):
                            yield Label("PWM CH4:", classes="status-label")
                            yield Static("0", id="pwm-ch4", classes="status-value")
                        with Horizontal(classes="status-row"):
                            yield Label("PWM CH5:", classes="status-label")
                            yield Static("0", id="pwm-ch5", classes="status-value")
                    
                    # Column 3: Motor throttles
                    with Vertical():
                        with Horizontal(classes="status-row"):
                            yield Label("Motor 1:", classes="status-label")
                            yield Static("0/2047", id="motor-1-value", classes="status-value")
                        with Horizontal(classes="status-row"):
                            yield Label("Motor 2:", classes="status-label")
                            yield Static("0/2047", id="motor-2-value", classes="status-value")
                        with Horizontal(classes="status-row"):
                            yield Label("Motor 3:", classes="status-label")
                            yield Static("0/2047", id="motor-3-value", classes="status-value")
                        with Horizontal(classes="status-row"):
                            yield Label("Motor 4:", classes="status-label")
                            yield Static("0/2047", id="motor-4-value", classes="status-value")
        
        yield Footer()
    
    def on_mount(self) -> None:
        """Initialize on mount"""
        # Set initial DSHOT mode
        self.tang9k.dshot_set_mode(150)
        self.dshot_mode = 150
        self.update_status()
        self.set_interval(1.0, self.auto_update)
        self.set_interval(0.1, self.check_serial_rx)  # Check for RX data every 100ms
    
    def auto_update(self) -> None:
        """Auto-update status periodically"""
        self.update_status()
        # Update DSHOT ready status
        try:
            status = self.tang9k.dshot_get_status()
            ready_str = ""
            for i in range(1, 5):
                ready_str += "R" if status[f'motor{i}_ready'] else "-"
            self.query_one("#dshot-ready-status", Static).update(ready_str)
        except:
            pass
    
    def check_serial_rx(self) -> None:
        """Check for incoming serial data"""
        try:
            # Read serial data if available
            data = self.tang9k.serial_read_available()
            if data:
                self.log_hex_dump("RX", data)
        except Exception as e:
            # Silently ignore errors (device might not be ready)
            pass
    
    def update_status(self) -> None:
        """Update status display"""
        # Update LED counter display
        self.query_one("#led-counter-value", Static).update(
            f"0x{self.led_counter:X} ({self.led_counter})"
        )
        
        # Update DSHOT mode display
        self.query_one("#dshot-mode-status", Static).update(f"DSHOT{self.dshot_mode}")
        
        # Update individual PWM channel displays
        for i in range(6):
            widget_id = f"#pwm-ch{i}"
            value = self.pwm_values[i] if i < len(self.pwm_values) else 0
            self.query_one(widget_id, Static).update(f"{value} (0x{value:04X})")
    
    def on_button_pressed(self, event: Button.Pressed) -> None:
        """Handle button presses"""
        button_id = event.button.id
        
        if button_id == "send-button":
            self.send_serial_message()
        elif button_id == "led-counter-button":
            self.increment_led_counter()
        elif button_id == "reset-leds-button":
            self.reset_leds()
        elif button_id == "waterfall-button":
            self.start_waterfall()
        elif button_id == "stop-waterfall-button":
            self.stop_waterfall()
        elif button_id == "read-pwm-button":
            self.read_pwm_values()
        elif button_id == "clear-serial-button":
            self.action_clear_serial()
        elif button_id == "enable-passthrough-button":
            self.enable_passthrough()
        elif button_id == "disable-passthrough-button":
            self.disable_passthrough()
        elif button_id == "dshot-150-button":
            self.set_dshot_mode(150)
        elif button_id == "dshot-300-button":
            self.set_dshot_mode(300)
        elif button_id == "dshot-600-button":
            self.set_dshot_mode(600)
        elif button_id == "dshot-send-m1-button":
            self.send_dshot_throttle(1)
        elif button_id == "dshot-send-all-button":
            self.send_dshot_throttle_all()
        elif button_id == "dshot-stop-button":
            self.dshot_stop_all()
    
    def send_serial_message(self) -> None:
        """Send serial message via SPI/Wishbone"""
        input_widget = self.query_one("#serial-input", Input)
        message = input_widget.value
        
        if not message:
            return
        
        log = self.query_one("#serial-log", Log)
        
        # Display as hex dump
        self.log_hex_dump("TX", message.encode('utf-8'))
        
        # Write string using Tang9K wrapper
        self.tang9k.serial_write_string(message, add_newline=True)
        
        # Clear input
        input_widget.value = ""

    # Mouse click handler removed - controls are keyboard-only to avoid layout reflow
    
    def log_text(self, text_obj: Text) -> None:
        """Helper to write Rich Text to log widget"""
        from rich.console import Console
        from io import StringIO
        
        buffer = StringIO()
        console = Console(file=buffer, force_terminal=True, width=120)
        console.print(text_obj)
        
        log = self.query_one("#serial-log", Log)
        log.write(buffer.getvalue())
    
    def log_hex_dump(self, label: str, data: bytes) -> None:
        """Display data as hex dump with ASCII representation"""
        log = self.query_one("#serial-log", Log)
        
        # Header
        from rich.console import Console
        from io import StringIO
        
        buffer = StringIO()
        console = Console(file=buffer, force_terminal=True, width=120)
        
        header = Text(f"──── {label} ({len(data)} bytes) ────", style="bold cyan")
        console.print(header)
        
        # Process in 16-byte chunks
        for offset in range(0, len(data), 16):
            chunk = data[offset:offset+16]
            
            # Hex representation
            hex_part = ' '.join(f'{b:02X}' for b in chunk)
            # Pad to 16 bytes worth of hex display (47 chars: "XX " * 16 - 1)
            hex_part = hex_part.ljust(47)
            
            # ASCII representation
            ascii_part = ''.join(chr(b) if 32 <= b < 127 else '.' for b in chunk)
            
            # Combined line with styled text
            line = Text()
            line.append(f"{offset:04X}:", style="yellow")
            line.append(f"  {hex_part}  ")
            line.append(f"|{ascii_part}|", style="green")
            console.print(line)
        
        console.print("")  # Empty line for spacing
        
        # Write to log
        log.write(buffer.getvalue())
    
    def increment_led_counter(self) -> None:
        """Increment LED counter"""
        self.led_counter = (self.led_counter + 1) % 16
        self.tang9k.set_leds(self.led_counter)
        self.update_status()
        
        self.log_text(Text(f"LED Counter: {self.led_counter}", style="cyan"))
    
    def reset_leds(self) -> None:
        """Reset LED counter to 0"""
        self.led_counter = 0
        self.tang9k.set_leds(self.led_counter)
        self.update_status()
        
        self.log_text(Text("LED Counter Reset", style="yellow"))
    
    def start_waterfall(self) -> None:
        """Start NeoPixel waterfall effect"""
        if not self.waterfall_running:
            self.waterfall_running = True
            self.query_one("#neopixel-status", Static).update("[green]Running[/green]")
            self.run_worker(self.run_waterfall_async, exclusive=True, name="waterfall")
            
            self.log_text(Text("NeoPixel Waterfall Started", style="green"))
    
    def stop_waterfall(self) -> None:
        """Stop NeoPixel waterfall effect"""
        self.waterfall_running = False
        self.query_one("#neopixel-status", Static).update("[red]Stopped[/red]")
        
        self.log_text(Text("NeoPixel Waterfall Stopped", style="red"))
    
    def toggle_waterfall(self) -> None:
        """Toggle NeoPixel waterfall effect"""
        if self.waterfall_running:
            self.stop_waterfall()
        else:
            self.start_waterfall()
    
    async def run_waterfall_async(self) -> None:
        """Run NeoPixel waterfall effect (async worker)"""
        import asyncio
        offset = 0
        while self.waterfall_running:
            for i in range(8):
                color = COLORS_RAINBOW[(i + offset) % len(COLORS_RAINBOW)]
                self.tang9k.neopixel_set_color(i, color)
            
            # Trigger update
            self.tang9k.neopixel_update()
            
            offset = (offset + 1) % len(COLORS_RAINBOW)
            await asyncio.sleep(0.1)
    
    def read_pwm_values(self) -> None:
        """Read PWM decoder values"""
        pwm_vals = self.tang9k.read_pwm_values(num_channels=6)
        self.pwm_values = pwm_vals
        self.update_status()
        
        self.log_text(Text(f"PWM Values: {pwm_vals}", style="magenta"))
    
    def action_quit(self) -> None:
        """Quit the app"""
        self.waterfall_running = False
        
        # Disable passthrough before quitting
        if self.blheli:
            self.blheli.disable_passthrough()
            self.blheli.close()
        
        self.tang9k.close()
        self.exit()
    
    def action_clear_serial(self) -> None:
        """Clear serial log"""
        log = self.query_one("#serial-log", Log)
        log.clear()

    def action_led_inc(self) -> None:
        """Key action: increment LED counter"""
        self.increment_led_counter()

    def action_reset_leds(self) -> None:
        """Key action: reset LEDs"""
        self.reset_leds()

    def action_read_pwm(self) -> None:
        """Key action: read PWM values"""
        self.read_pwm_values()
    
    def action_waterfall(self) -> None:
        """Toggle waterfall"""
        self.toggle_waterfall()
    
    def action_toggle_passthrough(self) -> None:
        """Toggle passthrough mode"""
        if self.passthrough_mode:
            self.disable_passthrough()
        else:
            self.enable_passthrough()
    
    # =============================
    # DSHOT Control Methods
    # =============================
    
    def set_dshot_mode(self, mode: int) -> None:
        """Set DSHOT protocol speed"""
        try:
            self.tang9k.dshot_set_mode(mode)
            self.dshot_mode = mode
            self.update_status()
            self.log_text(Text(f"DSHOT Mode: {mode}", style="green"))
            
            # Update button styles to show active mode
            for m in [150, 300, 600]:
                button_id = f"#dshot-{m}-button"
                button = self.query_one(button_id, Button)
                if m == mode:
                    button.variant = "success"
                else:
                    button.variant = "default"
        except Exception as e:
            self.log_text(Text(f"Error setting DSHOT mode: {e}", style="red"))
    
    def send_dshot_throttle(self, motor: int) -> None:
        """Send DSHOT throttle to a specific motor"""
        input_widget = self.query_one("#dshot-throttle-input", Input)
        
        try:
            throttle = int(input_widget.value) if input_widget.value else 0
            
            if throttle < 0 or throttle > 2047:
                self.log_text(Text("Throttle must be 0-2047", style="red"))
                return
            
            # Create properly encoded DSHOT frame with CRC
            frame = self.dshot_encoder.create_frame(throttle, telemetry=False)
            
            # Send to motor
            self.tang9k.dshot_set_motor(motor, frame)
            
            self.log_text(Text(f"Motor {motor}: Throttle={throttle} Frame=0x{frame:04X}", style="cyan"))
        except ValueError:
            self.log_text(Text("Invalid throttle value", style="red"))
        except Exception as e:
            self.log_text(Text(f"Error sending DSHOT: {e}", style="red"))
    
    def send_dshot_throttle_all(self) -> None:
        """Send DSHOT throttle to all motors"""
        input_widget = self.query_one("#dshot-throttle-input", Input)
        
        try:
            throttle = int(input_widget.value) if input_widget.value else 0
            
            if throttle < 0 or throttle > 2047:
                self.log_text(Text("Throttle must be 0-2047", style="red"))
                return
            
            # Create properly encoded DSHOT frame with CRC
            frame = self.dshot_encoder.create_frame(throttle, telemetry=False)
            
            # Send to all motors
            for motor in range(1, 5):
                self.tang9k.dshot_set_motor(motor, frame)
            
            self.log_text(Text(f"All Motors: Throttle={throttle} Frame=0x{frame:04X}", style="cyan"))
        except ValueError:
            self.log_text(Text("Invalid throttle value", style="red"))
        except Exception as e:
            self.log_text(Text(f"Error sending DSHOT: {e}", style="red"))
    
    def dshot_stop_all(self) -> None:
        """Stop all motors (send motor stop command)"""
        try:
            # Create motor stop frame
            stop_frame = self.dshot_encoder.motor_stop()
            
            # Send to all motors
            for motor in range(1, 5):
                self.tang9k.dshot_set_motor(motor, stop_frame)
            
            self.log_text(Text(f"All Motors: STOP (0x{stop_frame:04X})", style="yellow"))
        except Exception as e:
            self.log_text(Text(f"Error stopping motors: {e}", style="red"))
    
    def action_set_dshot_150(self) -> None:
        """Set DSHOT150 mode (keyboard shortcut)"""
        self.set_dshot_mode(150)
    
    def action_set_dshot_300(self) -> None:
        """Set DSHOT300 mode (keyboard shortcut)"""
        self.set_dshot_mode(300)
    
    def action_set_dshot_600(self) -> None:
        """Set DSHOT600 mode (keyboard shortcut)"""
        self.set_dshot_mode(600)
    
    # =============================
    # BLHeli Passthrough Methods
    # =============================
    
    def enable_passthrough(self) -> None:
        """Enable BLHeli passthrough mode"""
        if self.passthrough_mode:
            return
        
        # Create BLHeli passthrough instance
        def on_passthrough_data(msg):
            self.log_text(Text(msg, style="yellow"))
        
        self.blheli = BLHeliPassthrough(self.tang9k, on_data_callback=on_passthrough_data)
        
        # Enable passthrough mode
        self.blheli.enable_passthrough()
        
        self.passthrough_mode = True
        
        # Update status
        self.query_one("#passthrough-status", Static).update("[green]ENABLED[/green]")
        
        self.log_text(Text("═══ BLHeli Passthrough ENABLED ═══", style="bold green"))
        self.log_text(Text("Serial: 115200 baud, half-duplex", style="cyan"))
        self.log_text(Text("In BLHeliSuite/Configurator:", style="yellow"))
        self.log_text(Text("1. Select your serial port (e.g., /dev/ttyUSB0)", style="yellow"))
        self.log_text(Text("2. Set baud rate to 115200", style="yellow"))
        self.log_text(Text("3. Connect to ESC", style="yellow"))
    
    def disable_passthrough(self) -> None:
        """Disable BLHeli passthrough mode"""
        if not self.passthrough_mode:
            return
        
        if self.blheli:
            self.blheli.disable_passthrough()
            self.blheli.close()
            self.blheli = None
        
        self.passthrough_mode = False
        
        # Update status
        self.query_one("#passthrough-status", Static).update("[red]DISABLED[/red]")
        
        self.log_text(Text("BLHeli Passthrough DISABLED", style="red"))
    
    # =============================
    # Motor Throttle Control Methods
    # =============================
    
    def action_throttle_up(self) -> None:
        """Increase current motor throttle by 50"""
        motor_idx = self.current_motor - 1
        throttles = list(self.motor_throttles)  # Create a copy
        throttles[motor_idx] = min(2047, throttles[motor_idx] + 50)
        self.motor_throttles = throttles  # Reassign to trigger reactive
        self.update_throttle_displays()
    
    def action_throttle_down(self) -> None:
        """Decrease current motor throttle by 50"""
        motor_idx = self.current_motor - 1
        throttles = list(self.motor_throttles)  # Create a copy
        throttles[motor_idx] = max(0, throttles[motor_idx] - 50)
        self.motor_throttles = throttles  # Reassign to trigger reactive
        self.update_throttle_displays()
    
    def action_cycle_motor(self) -> None:
        """Cycle to the next motor (1-4)"""
        self.current_motor = (self.current_motor % 4) + 1
        self.log_text(Text(f"Selected Motor {self.current_motor}", style="bold yellow"))
        self.update_throttle_displays()
    
    def action_send_throttle(self) -> None:
        """Send current motor throttle via DSHOT"""
        motor_idx = self.current_motor - 1
        throttle = self.motor_throttles[motor_idx]
        
        try:
            frame = self.dshot_encoder.create_frame(throttle, telemetry=False)
            self.tang9k.dshot_set_motor(self.current_motor, frame)
            self.log_text(Text(f"Motor {self.current_motor}: Sent Throttle={throttle} Frame=0x{frame:04X}", style="green"))
        except Exception as e:
            self.log_text(Text(f"Error sending DSHOT: {e}", style="red"))
    
    def update_throttle_displays(self) -> None:
        """Update all motor throttle displays, highlight current motor"""
        for i in range(1, 5):
            widget_id = f"#motor-{i}-value"
            throttle = self.motor_throttles[i - 1]
            
            # Highlight the current motor
            if i == self.current_motor:
                display = f"[bold cyan]{throttle}/2047[/bold cyan]"
            else:
                display = f"{throttle}/2047"
            
            self.query_one(widget_id, Static).update(display)
        
        # Log the change
        throttle = self.motor_throttles[self.current_motor - 1]
        self.log_text(Text(f"Motor {self.current_motor}: {throttle}/2047", style="cyan"))


if __name__ == "__main__":
    app = Tang9KTUI()
    app.run()
