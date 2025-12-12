import asyncio
import threading
import time
import sys
import os
from typing import Optional

import numpy as np
from imgui_bundle import imgui, hello_imgui
from imguTestApp.thread_bridge import ThreadBridge, DataPacket, Cmd

# Minimal device shim to reuse tang9k when available
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '../test'))
try:
    from tang9k import Tang9K, COLORS_RAINBOW
    from blheli_passthrough import BLHeliPassthrough
    from dshot_encoder import DshotEncoder
except Exception:
    # Fallback stubs
    class Tang9K:
        def __init__(self, *a, **kw):
            pass
        def dshot_set_mode(self, m):
            pass
        def dshot_get_status(self):
            return {f'motor{i}_ready': False for i in range(1,5)}
        def serial_read_available(self, max_bytes=256):
            return b''
        def serial_write_string(self, s, add_newline=True):
            print(f"[MOCK TX] {s}")
        def set_leds(self, v):
            pass
        def neopixel_set_color(self, i, color):
            pass
        def neopixel_update(self):
            pass
        def read_pwm_values(self, num_channels=6):
            return [0]*num_channels
        def dshot_set_motor(self, motor, frame):
            pass
        def close(self):
            pass

    COLORS_RAINBOW = [(255,0,0),(0,255,0),(0,0,255),(255,255,0),(255,0,255),(0,255,255)]
    class BLHeliPassthrough:
        def __init__(self, *a, **kw):
            pass
        def enable_passthrough(self):
            pass
        def disable_passthrough(self):
            pass
        def close(self):
            pass
    class DshotEncoder:
        def create_frame(self, throttle, telemetry=False):
            return int(throttle) & 0x7FF
        def motor_stop(self):
            return 0


class ImgApp:
    def __init__(self):
        self.tang9k = Tang9K()
        self.dshot = DshotEncoder()
        self.led_counter = 0
        self.passthrough = False
        self.dshot_mode = 150
        self.motor_throttles = [0,0,0,0]
        self.current_motor = 1
        self.pwm_values = [0]*6
        self.serial_log_lines = []

        # (camera preview removed for demo)

        # background reader
        self.loop = asyncio.new_event_loop()
        self._stop_bg = False
        self.bg_thread = threading.Thread(target=self._bg_loop, daemon=True)
        self.bg_thread.start()
        # Bridge for communication between bg tasks and GUI
        self.bridge = ThreadBridge(self.loop)
        # UI state
        self._serial_input = ""
        self._last_rx: bytes = b""
        self.neopixel_status = "Idle"
        self.dshot_status_str = "----"
        # Advanced controls
        self._dshot_throttle_input = "0"
        self._waterfall_running = False
        # TCP-SPI client settings
        self.tcp_host = "127.0.0.1"
        self.tcp_port = 9999
        self._tcp_hex_input = "AA BB CC"
        # Mode and safety
        self.mode = 'motor'  # 'motor' or 'passthrough'
        self.safety_enabled = False

    def _bg_loop(self):
        asyncio.set_event_loop(self.loop)
        self.loop.run_until_complete(self._bg_main())

    async def _bg_main(self):
        while not self._stop_bg:
            try:
                data = self.tang9k.serial_read_available()
                if data:
                    self._last_rx = data
                    # Send a log packet to GUI
                    try:
                        self.bridge.push_to_gui(Cmd.LOG_MESSAGE, f"RX {len(data)} bytes")
                    except Exception:
                        # fallback to local log
                        self._append_log(f"RX {len(data)} bytes")
                # sample status
                pwm = self.tang9k.read_pwm_values()
                self._update_dshot_status()
                # Send PWM update packet
                try:
                    self.bridge.push_to_gui(Cmd.PROCESS_DATA, {'pwm': pwm})
                except Exception:
                    self.pwm_values = pwm
            except Exception:
                pass
            await asyncio.sleep(0.5)

    def _append_log(self, s: str):
        ts = time.strftime('%H:%M:%S')
        line = f"[{ts}] {s}"
        self.serial_log_lines.append(line)
        if len(self.serial_log_lines) > 200:
            self.serial_log_lines.pop(0)

    def gui(self):
        imgui.begin("Tang9K - imgui port")

        # Drain bridge messages first (logs, pwm updates, etc.)
        while True:
            pkt = self.bridge.pop_from_gui()
            if pkt is None:
                break
            if pkt.command == Cmd.LOG_MESSAGE:
                self._append_log(str(pkt.payload))
            elif pkt.command == Cmd.PROCESS_DATA:
                d = pkt.payload
                if isinstance(d, dict) and 'pwm' in d:
                    self.pwm_values = d['pwm']


        # Left column: serial log and input
        imgui.begin_child("serial", imgui.ImVec2(600, 300))
        imgui.text("Serial Log")
        for line in self.serial_log_lines[-20:]:
            imgui.text_wrapped(line)
        if imgui.button("Clear Log"):
            self.serial_log_lines.clear()
        imgui.same_line()
        if imgui.button("Read PWM"):
            self.read_pwm_values()

        imgui.separator()
        # TCP-SPI client controls
        imgui.text("TCP-SPI Bridge")
        changed, self.tcp_host = imgui.input_text("Host", self.tcp_host, 64)
        changed, self.tcp_port = imgui.input_int("Port", self.tcp_port)
        changed, self._tcp_hex_input = imgui.input_text("Hex Bytes (space separated)", self._tcp_hex_input, 64)
        if imgui.button("Send SPI over TCP"):
            # schedule the send on background loop
            try:
                hexstr = ''.join(self._tcp_hex_input.split())
                payload = bytes.fromhex(hexstr)
            except Exception:
                self._append_log("Invalid hex input")
                payload = b''
            if payload:
                self.loop.call_soon_threadsafe(asyncio.create_task, self._tcp_send_spi(self.tcp_host, int(self.tcp_port), payload))

        # Serial send input
        changed, self._serial_input = imgui.input_text("Send Message", self._serial_input, 512)
        imgui.same_line()
        if imgui.button("Send"):
            if self._serial_input:
                try:
                    self.tang9k.serial_write_string(self._serial_input, add_newline=True)
                    self._append_log(f"TX: {self._serial_input}")
                except Exception:
                    self._append_log("TX error")
                self._serial_input = ""

        imgui.separator()
        # Show last RX as hex dump
        imgui.text("Last RX (hex)")
        if self._last_rx:
            for ln in self.format_hex_dump(self._last_rx):
                imgui.text_wrapped(ln)
        imgui.end_child()

        imgui.separator()

        # Controls
        if imgui.button("LED +1"):
            self.led_counter = (self.led_counter + 1) % 16
            try:
                self.tang9k.set_leds(self.led_counter)
            except Exception:
                pass
            self._append_log(f"LED {self.led_counter}")

        imgui.same_line()
        if imgui.button("Reset LEDs"):
            self.led_counter = 0
            try:
                self.tang9k.set_leds(0)
            except Exception:
                pass
            self._append_log("LED reset")

        imgui.same_line()
        if imgui.button("Waterfall"):
            # start simple waterfall effect locally
            self._start_waterfall()

        imgui.same_line()
        # Mode selector: Passthrough vs Motor Control
        if imgui.button("Passthrough Mode"):
            # switch to passthrough mode
            self.mode = 'passthrough'
            # enable BLHeli passthrough if possible
            if not self.passthrough:
                try:
                    self.blheli = BLHeliPassthrough(self.tang9k, on_data_callback=lambda m: self._append_log(m))
                    self.blheli.enable_passthrough()
                except Exception:
                    pass
                self.passthrough = True
                self._append_log("Passthrough enabled")

        imgui.same_line()
        if imgui.button("Motor Control Mode"):
            # switch to motor control mode
            self.mode = 'motor'
            # when switching back to motor control we do not auto-enable safety
            self._append_log("Switched to Motor Control mode")

        imgui.same_line()
        # Safety enable button: only relevant for motor control mode
        if self.mode == 'motor':
            if self.safety_enabled:
                if imgui.button("Safety: ENABLED (Click to Disable)"):
                    self.safety_enabled = False
                    self._append_log("Safety DISABLED")
            else:
                if imgui.button("Safety: DISABLED (Click to Enable)"):
                    self.safety_enabled = True
                    self._append_log("Safety ENABLED")
        else:
            imgui.text("Safety: N/A in Passthrough")

        imgui.separator()

        imgui.text(f"DSHOT Mode: {self.dshot_mode}")
        if imgui.button("DSHOT150"):
            self.set_dshot_mode(150)
        imgui.same_line()
        if imgui.button("DSHOT300"):
            self.set_dshot_mode(300)
        imgui.same_line()
        if imgui.button("DSHOT600"):
            self.set_dshot_mode(600)

        imgui.separator()
        # Motor throttle controls (sliders)
        # Disable motor controls when in passthrough mode or when safety is not enabled
        motor_controls_disabled = (self.mode != 'motor') or (not self.safety_enabled)
        try:
            imgui.begin_disabled(motor_controls_disabled)
            for i in range(4):
                # Slider returns (changed, value) — use step 1, range 0..2047
                changed, val = imgui.slider_int(f"Motor {i+1}", self.motor_throttles[i], 0, 2047)
                if changed:
                    self.motor_throttles[i] = int(val)
                imgui.same_line()
                if imgui.button(f"Send {i+1}"):
                    frame = self.dshot.create_frame(self.motor_throttles[i])
                    try:
                        self.tang9k.dshot_set_motor(i+1, frame)
                    except Exception:
                        pass
                    self._append_log(f"Sent motor {i+1} throttle {self.motor_throttles[i]}")
            imgui.end_disabled()
        except Exception:
            # Fallback: if begin_disabled isn't available, simply skip sending when disabled
            for i in range(4):
                changed, val = imgui.slider_int(f"Motor {i+1}", self.motor_throttles[i], 0, 2047)
                if changed:
                    self.motor_throttles[i] = int(val)
                imgui.same_line()
                if imgui.button(f"Send {i+1}"):
                    if not motor_controls_disabled:
                        frame = self.dshot.create_frame(self.motor_throttles[i])
                        try:
                            self.tang9k.dshot_set_motor(i+1, frame)
                        except Exception:
                            pass
                        self._append_log(f"Sent motor {i+1} throttle {self.motor_throttles[i]}")

        imgui.separator()
        # Send same throttle to all motors
        changed, self._dshot_throttle_input = imgui.input_text("Throttle (0-2047)", self._dshot_throttle_input, 8)
        imgui.same_line()
        if imgui.button("Send All"):
            try:
                t = int(self._dshot_throttle_input or 0)
                t = max(0, min(2047, t))
                frame = self.dshot.create_frame(t)
                for m in range(1,5):
                    try:
                        self.tang9k.dshot_set_motor(m, frame)
                    except Exception:
                        pass
                self._append_log(f"Sent ALL motors throttle {t}")
            except Exception:
                self._append_log("Invalid throttle")

        imgui.end()

        # Right: status panel
        imgui.begin("Status")
        imgui.text(f"LED Counter: {self.led_counter}")
        imgui.text(f"NeoPixel: {self.neopixel_status}")
        imgui.text(f"Passthrough: {'ENABLED' if self.passthrough else 'DISABLED'}")
        imgui.text(f"DSHOT Mode: {self.dshot_mode}")
        imgui.separator()
        imgui.text("PWM Channels:")
        for i, v in enumerate(self.pwm_values):
            imgui.text(f"CH{i}: {v}")
        imgui.separator()
        imgui.text("Motors:")
        for i, t in enumerate(self.motor_throttles, start=1):
            imgui.text(f"Motor {i}: {t}/2047")
        imgui.separator()
        # Log window inside status panel: show commands and hex dumps
        imgui.text("Logs:")
        imgui.begin_child("status-log", imgui.ImVec2(400, 200), border=True)
        # show recent log lines
        for line in self.serial_log_lines[-200:]:
            imgui.text_wrapped(line)
        imgui.separator()
        imgui.text("Last RX Hex:")
        if self._last_rx:
            for ln in self.format_hex_dump(self._last_rx):
                imgui.text_wrapped(ln)
        imgui.end_child()
        if imgui.button("Save Log"):
            # default path in current working dir
            self.save_log("imgui_serial_log.txt")
        imgui.end()

    def _update_dshot_status(self):
        try:
            status = self.tang9k.dshot_get_status()
            ready_str = ''.join('R' if status.get(f'motor{i}_ready') else '-' for i in range(1,5))
            self.dshot_status_str = ready_str
        except Exception:
            self.dshot_status_str = '----'

    def format_hex_dump(self, data: bytes):
        lines = []
        for offset in range(0, len(data), 16):
            chunk = data[offset:offset+16]
            hex_part = ' '.join(f'{b:02X}' for b in chunk)
            hex_part = hex_part.ljust(47)
            ascii_part = ''.join(chr(b) if 32 <= b < 127 else '.' for b in chunk)
            lines.append(f"{offset:04X}:  {hex_part}  |{ascii_part}|")
        return lines

    def _start_waterfall(self):
        # simple local animation update
        for i in range(8):
            color = COLORS_RAINBOW[i % len(COLORS_RAINBOW)]
            try:
                self.tang9k.neopixel_set_color(i, color)
            except Exception:
                pass
        try:
            self.tang9k.neopixel_update()
        except Exception:
            pass
        self._append_log("Waterfall step")

    async def _waterfall_worker(self):
        offset = 0
        while self._waterfall_running and not self._stop_bg:
            for i in range(8):
                color = COLORS_RAINBOW[(i + offset) % len(COLORS_RAINBOW)]
                try:
                    self.tang9k.neopixel_set_color(i, color)
                except Exception:
                    pass
            try:
                self.tang9k.neopixel_update()
            except Exception:
                pass
            offset = (offset + 1) % len(COLORS_RAINBOW)
            await asyncio.sleep(0.1)

    def toggle_waterfall(self):
        if not self._waterfall_running:
            self._waterfall_running = True
            try:
                # schedule waterfall on background loop
                self.loop.call_soon_threadsafe(asyncio.create_task, self._waterfall_worker())
            except Exception:
                pass
            self.neopixel_status = "Running"
            self._append_log("Waterfall started")
        else:
            self._waterfall_running = False
            self.neopixel_status = "Stopped"
            self._append_log("Waterfall stopped")

    def save_log(self, path: str):
        try:
            with open(path, 'w') as f:
                for ln in self.serial_log_lines:
                    f.write(ln + "\n")
            self._append_log(f"Saved log to {path}")
        except Exception as e:
            self._append_log(f"Save log error: {e}")

    async def _tcp_send_spi(self, host: str, port: int, payload: bytes):
        import struct
        try:
            reader, writer = await asyncio.open_connection(host, port)
            from comm_proto import Message, ContentType, Cmd, pack_message
            msg = Message(command=Cmd.SPI_TRANSFER, content_type=ContentType.RAW, payload=payload)
            data = pack_message(msg)
            writer.write(struct.pack('>I', len(data)) + data)
            await writer.drain()

            hdr = await reader.readexactly(4)
            (length,) = struct.unpack('>I', hdr)
            data = await reader.readexactly(length)
            # unpack inner message
            from comm_proto import unpack_message, decode_payload
            resp = unpack_message(data)
            if resp.content_type == ContentType.RAW:
                self._append_log(f"SPI RESP: {resp.payload.hex()}")
            else:
                self._append_log(f"SPI RESP: {decode_payload(resp)}")
            writer.close()
            await writer.wait_closed()
        except Exception as e:
            self._append_log(f"TCP send error: {e}")

    def set_dshot_mode(self, mode: int):
        try:
            self.tang9k.dshot_set_mode(mode)
            self.dshot_mode = mode
            self._append_log(f"DSHOT mode {mode}")
        except Exception as e:
            self._append_log(f"DSHOT error: {e}")

    def read_pwm_values(self):
        try:
            self.pwm_values = self.tang9k.read_pwm_values()
            self._append_log(f"PWM {self.pwm_values}")
        except Exception:
            self._append_log("PWM read error")

    def shutdown(self):
        self._stop_bg = True
        try:
            self.tang9k.close()
        except Exception:
            pass


def main():
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("--no-gui", action="store_true", help="Initialize app but do not start GUI")
    args = parser.parse_args()

    app = ImgApp()

    if args.no_gui:
        # perform a quick initialization check and exit
        print("Initialized ImgApp in headless mode")
        app.shutdown()
        return

    rp = hello_imgui.RunnerParams()
    rp.app_window_params.window_title = "Tang9K imgui"
    rp.callbacks.show_gui = app.gui
    try:
        hello_imgui.run(rp)
    finally:
        app.shutdown()


if __name__ == "__main__":
    main()
