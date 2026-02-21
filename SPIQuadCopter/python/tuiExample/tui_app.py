import curses
import time
import struct
import sys
from wb_driver import WishboneDriver

# Force ASCII compliance for older terminals
# (Will help prevent crashes if accidental Unicode creeps in)

class App:
    def __init__(self, stdscr):
        self.stdscr = stdscr
        # Use bus=1, device=0 per user requirement
        self.driver = WishboneDriver(bus=1, device=0) 
        
        # State
        self.mode = 'MENU' # MENU, PWM, DSHOT, NEO, LED, SERIAL
        self.dshot_values = [0, 0, 0, 0]
        self.serial_bypass_mode = 1  # Default to 1 (DSHOT) for safety
        self.serial_bypass_channel = 0
        self.neo_values = [(0,0,0,0)] * 8
        self.neo_cursor_idx = 0
        self.neo_cursor_comp = 0 # 0=R, 1=G, 2=B, 3=W
        
        self.last_key = None
        self.last_pwm_read = 0
        self.pwm_inputs = [0]*6
        self.led_state = 0
        self.msp_log = ["MSP Log Ready"]
        
        # Setup curses
        curses.curs_set(0) # Hide cursor
        self.stdscr.nodelay(True)
        self.stdscr.timeout(100) # 100ms refresh
        
        # --- Boot Check ---
        self.boot_error = None
        try:
            v = self.driver.get_version()
            if len(v) != 4:
                self.boot_error = "SPI Comm Error: Invalid Version Length"
            else:
                 val = int.from_bytes(v, 'little')
                 if val != 0xDEADBEEF:
                      pass 
        except Exception as e:
            self.boot_error = "Boot Error: " + str(e)
            
        if self.boot_error:
             self.mode = 'ERROR'

    def run(self):
        try:
            while True:
                self.draw()
                self.handle_input()
                self.background_tasks()
        except KeyboardInterrupt:
            pass
        finally:
            self.driver.close()

    def background_tasks(self):
        now = time.time()
        if now - self.last_pwm_read > 0.1:
            try:
                self.pwm_inputs = self.driver.read_pwm_inputs()
            except Exception:
                pass
            self.last_pwm_read = now

    # --- Input Handling (Key Router) ---

    def handle_input(self):
        c = self.stdscr.getch()
        if c == -1: return
        
        self.last_key = c # For debug display
        
        # 1. Global priority keys
        if c == ord('0'): 
            if self.mode != 'MENU':
                self.mode = 'MENU'
            return
            
        if c == ord('Q'): # Shift+Q to force quit from anywhere
            exit(0)

        # 2. Route to Mode Handlers
        handlers = {
            'MENU':   self._handle_menu_input,
            'PWM':    self._handle_pwm_input,
            'DSHOT':  self._handle_dshot_input,
            'NEO':    self._handle_neo_input,
            'LED':    self._handle_led_input,
            'SERIAL': self._handle_serial_input,
            'MSP':    self._handle_msp_input,
            'ERROR':  self._handle_error_input
        }
        
        handler = handlers.get(self.mode)
        if handler:
            handler(c)

    def _handle_menu_input(self, c):
        if c == ord('1'): self.mode = 'PWM'
        elif c == ord('2'): self.mode = 'DSHOT'
        elif c == ord('3'): 
            self.mode = 'NEO'
            try:
                self.neo_values = self.driver.get_neopixels()
            except:
                pass
        elif c == ord('4'): self.mode = 'LED'
        elif c == ord('5'): self.mode = 'SERIAL'
        elif c == ord('6'): self.mode = 'MSP'
        elif c == ord('q'): exit(0)

    def _handle_msp_input(self, c):
        if c == ord('b') or c == ord('q'): self.mode = 'MENU'
        elif c == ord('1'): self.send_msp_command(100)
        elif c == ord('2'): self.send_msp_command(245, [0, 0])

    def send_msp_command(self, cmd_id, payload=None):
        if payload is None: payload = []
        size = len(payload)
        checksum = 0
        # Header $M<
        packet = bytearray([ord('$'), ord('M'), ord('<')])
        packet.append(size); checksum ^= size
        packet.append(cmd_id); checksum ^= cmd_id
        for b in payload:
            packet.append(b); checksum ^= b
        packet.append(checksum)
        
        # Write
        try:
            # Check TX ready
            for b in packet:
                # Wait for TX ready (bit 5 of LSR 0x10C)
                # Timeout safety in loop
                for _ in range(100):
                    lsr = self.driver.read(0x10C, 1)[0]
                    if (lsr & 0x20): break
                    time.sleep(0.001)
                self.driver.write(0x100, bytes([b]))
                
            self.msp_log.append(f"TX: CMD {cmd_id} ({packet.hex()})")
            if(len(self.msp_log) > 10): self.msp_log.pop(0)
            
            self.check_msp_response()
        except Exception as e:
            self.msp_log.append(f"Err: {str(e)}")

    def check_msp_response(self):
        # Poll for response
        rx_bytes = bytearray()
        start = time.time()
        while (time.time() - start) < 0.2: # 200ms timeout
            try:
                lsr = self.driver.read(0x10C, 1)[0]
                if (lsr & 0x01): # RX Ready
                    val = self.driver.read(0x100, 1)[0]
                    rx_bytes.append(val)
                else:
                    if len(rx_bytes) > 0:
                        # If we have started receiving, and line is idle, assumes done?
                        # MSP packets are contiguous. 
                        # Continue polling briefly to ensure full packet.
                        time.sleep(0.005) 
                        continue
                    time.sleep(0.01)
            except:
                break
        
        if rx_bytes:
            self.msp_log.append(f"RX: {rx_bytes.hex()}")
            if(len(self.msp_log) > 10): self.msp_log.pop(0)

    def _handle_pwm_input(self, c):
        if c == ord('b'): self.mode = 'MENU'

    def _handle_led_input(self, c):
        if c == ord('b') or c == ord('q'): self.mode = 'MENU'
        elif c == ord('1'): self.driver.toggle_leds(1 << 0)
        elif c == ord('2'): self.driver.toggle_leds(1 << 1)
        elif c == ord('3'): self.driver.toggle_leds(1 << 2)
        elif c == ord('4'): self.driver.toggle_leds(1 << 3)
        elif c == ord('5'): self.driver.toggle_leds(1 << 4)

    def _handle_dshot_input(self, c):
        if c == ord('b'): self.mode = 'MENU'
        elif c == ord('!'): 
            self.dshot_values = [0,0,0,0]
            for i in range(4): self.driver.set_dshot(i+1, 0)
        
        inc = 47
        idx = -1
        # Throttle controls: q/a, w/s, e/d, r/f
        if c == ord('q'): idx=0; delta=inc
        elif c == ord('a'): idx=0; delta=-inc
        elif c == ord('w'): idx=1; delta=inc
        elif c == ord('s'): idx=1; delta=-inc
        elif c == ord('e'): idx=2; delta=inc
        elif c == ord('d'): idx=2; delta=-inc
        elif c == ord('r'): idx=3; delta=inc
        elif c == ord('f'): idx=3; delta=-inc
        
        if idx >= 0:
            self.dshot_values[idx] = max(0, min(2047, self.dshot_values[idx] + delta))
            self.driver.set_dshot(idx+1, self.dshot_values[idx])

    def _handle_neo_input(self, c):
        if c == ord('b') or c == ord('q'): self.mode = 'MENU'
        elif c == curses.KEY_UP:
            self.neo_cursor_idx = max(0, self.neo_cursor_idx - 1)
        elif c == curses.KEY_DOWN:
            self.neo_cursor_idx = min(7, self.neo_cursor_idx + 1)
        elif c == curses.KEY_LEFT:
            self.neo_cursor_comp = max(0, self.neo_cursor_comp - 1)
        elif c == curses.KEY_RIGHT:
            self.neo_cursor_comp = min(3, self.neo_cursor_comp + 1)
        elif c == curses.KEY_PPAGE:
            idx = self.neo_cursor_idx
            vals = list(self.neo_values[idx])
            vals[self.neo_cursor_comp] = min(255, vals[self.neo_cursor_comp] + 10)
            self.neo_values[idx] = tuple(vals)
            self.update_pixel(idx)
        elif c == curses.KEY_NPAGE:
            idx = self.neo_cursor_idx
            vals = list(self.neo_values[idx])
            vals[self.neo_cursor_comp] = max(0, vals[self.neo_cursor_comp] - 10)
            self.neo_values[idx] = tuple(vals)
            self.update_pixel(idx)
        elif c == ord('c') or c == ord('C'):
            self.neo_values = [(0,0,0,0)] * 8
            for i in range(8):
                self.update_pixel(i)
            self.driver.trigger_neopixel_update()
        elif c == ord(' '):
            self.driver.trigger_neopixel_update()

    def _handle_serial_input(self, c):
        if c == ord('b') or c == ord('q'): self.mode = 'MENU'
        elif c == ord('m'):
            self.serial_bypass_mode = 1 - self.serial_bypass_mode
            self._update_serial_mux()
        elif c == ord('1'): self.serial_bypass_channel = 0; self._update_serial_mux()
        elif c == ord('2'): self.serial_bypass_channel = 1; self._update_serial_mux()
        elif c == ord('3'): self.serial_bypass_channel = 2; self._update_serial_mux()
        elif c == ord('4'): self.serial_bypass_channel = 3; self._update_serial_mux()

    def _handle_error_input(self, c):
        if c == ord('c'): self.mode = 'MENU'; self.boot_error = None
        elif c == ord('q'): exit(1)

    def _update_serial_mux(self):
        mux_val = (self.serial_bypass_channel << 1) | self.serial_bypass_mode
        try:
            self.driver.write(0x0400, struct.pack('<I', mux_val))
        except:
            pass

    def update_pixel(self, i):
        r,g,b,w = self.neo_values[i]
        self.driver.set_neopixel(i, r, g, b, w)

    # --- Drawing ---

    def draw(self):
        self.stdscr.erase()
        h, w = self.stdscr.getmaxyx()
        footer_h = 4
        main_h = h - footer_h
        
        title = "Tang9K FPGA Controller"
        self.stdscr.addstr(0, (w-len(title))//2, title, curses.A_BOLD)

        if self.mode == 'MENU': self.draw_menu(2)
        elif self.mode == 'PWM': self.draw_pwm(2)
        elif self.mode == 'DSHOT': self.draw_dshot(2)
        elif self.mode == 'NEO': self.draw_neo(2)
        elif self.mode == 'LED': self.draw_led(2)
        elif self.mode == 'SERIAL': self.draw_serial(2)
        elif self.mode == 'MSP': self.draw_msp(2)

        # ASCII horizontal line instead of curses.ACS_HLINE
        self.stdscr.addstr(main_h, 0, "-" * (w-1))
        self.draw_footer(main_h + 1)
        self.stdscr.refresh()

    def draw_footer(self, y):
        try:
            v_int = int.from_bytes(self.driver.get_version(), 'little')
            ver_str = "0x" + format(v_int, '08X')
        except: ver_str = "vErr"
        
        key_debug = (" | Key: " + str(self.last_key)) if self.last_key else ""
        
        status = "Status: Connected | FPGA: " + ver_str + " | Mode: " + self.mode + key_debug
        # Final safety: replace any accidental non-ascii with '?'
        status_safe = "".join([c if ord(c) < 128 else "?" for c in status])
        
        self.stdscr.addstr(y, 2, status_safe, curses.A_REVERSE)
        
        if self.mode == 'MENU': cmds = "Global: [q] Quit | Select Option [1-6]"
        else: cmds = "Global: [0/b/q] Back to Menu"
        self.stdscr.addstr(y+1, 2, cmds)
        
        help_msg = ""
        if self.mode == 'DSHOT': help_msg = "[q/a] M1 [w/s] M2 [e/d] M3 [r/f] M4 | [!] Stop All"
        elif self.mode == 'NEO': help_msg = "Arrows: Nav | PgUp/Dn: Val +/- | [c] Clear All | Space: Update"
        elif self.mode == 'LED': help_msg = "Press [1-5] to toggle LEDs"
        elif self.mode == 'SERIAL': help_msg = "[m] Mode Toggle | [1-4] Select Motor"
        elif self.mode == 'MSP': help_msg = "[1] Ident [2] Passthrough"
            
        if help_msg: self.stdscr.addstr(y+2, 2, help_msg, curses.A_BOLD)

    def draw_menu(self, start_y):
        opts = ["Select an option:", "", "[1] PWM Monitor", "[2] DSHOT Control", "[3] NeoPixel Control", "[4] LED Control", "[5] Serial Bypass", "[6] MSP Test", "[q] Quit"]
        for i, opt in enumerate(opts): self.stdscr.addstr(start_y+1+i, 4, opt)

    def draw_msp(self, start_y):
        self.stdscr.addstr(start_y, 2, "MSP PROTOCOL TESTER", curses.A_UNDERLINE)
        self.stdscr.addstr(start_y+2, 2, "Options: [1] Send Ident  [2] Trigger Passthrough")
        self.stdscr.addstr(start_y+4, 2, "Log:")
        for i, msg in enumerate(self.msp_log):
             self.stdscr.addstr(start_y+5+i, 4, msg)

    def draw_led(self, start_y):
        self.stdscr.addstr(start_y, 2, "ON-BOARD LED CONTROL", curses.A_UNDERLINE)
        self.stdscr.addstr(start_y+2, 2, "Press [1-5] to toggle, [0] back")
        try: self.led_state = self.driver.get_leds()
        except: pass
        for i in range(5):
            is_on = (self.led_state >> i) & 1
            attr = curses.A_BOLD if is_on else curses.A_DIM
            state = "[ON]" if is_on else "[OFF]"
            self.stdscr.addstr(start_y+4+i, 4, "LED " + str(i+1) + ": " + state, attr)

    def draw_pwm(self, start_y):
        self.stdscr.addstr(start_y, 2, "PWM INPUTS (us)", curses.A_UNDERLINE)
        for i, val in enumerate(self.pwm_inputs):
            self.stdscr.addstr(start_y+2+i, 2, "CH" + str(i) + ": " + str(val) + " us")

    def draw_dshot(self, start_y):
        self.stdscr.addstr(start_y, 2, "DSHOT CONTROL", curses.A_UNDERLINE)
        for i, val in enumerate(self.dshot_values):
            self.stdscr.addstr(start_y+2+i, 2, "M" + str(i+1) + ": " + str(val))

    def draw_neo(self, start_y):
        self.stdscr.addstr(start_y, 2, "NEOPIXEL RGBW", curses.A_UNDERLINE)
        for i in range(8):
            r,g,b,w = self.neo_values[i]
            is_row = (i == self.neo_cursor_idx)
            cur = "*" if is_row else " "
            
            self.stdscr.addstr(start_y+2+i, 2, cur + " Pixel " + str(i+1) + ": ")
            
            # Draw each component, highlighting the one under the cursor
            comps = [('R', r), ('G', g), ('B', b), ('W', w)]
            for j, (label, val) in enumerate(comps):
                attr = curses.A_REVERSE if (is_row and j == self.neo_cursor_comp) else curses.A_NORMAL
                self.stdscr.addstr(label + format(val, '3d') + " ", attr)

    def draw_serial(self, start_y):
        self.stdscr.addstr(start_y, 2, "SERIAL BYPASS", curses.A_UNDERLINE)
        mode = "PASSTHROUGH" if self.serial_bypass_mode == 0 else "DSHOT"
        self.stdscr.addstr(start_y+2, 2, "Mode: " + mode)
        self.stdscr.addstr(start_y+3, 2, "Channel: Motor " + str(self.serial_bypass_channel+1))

def main(stdscr):
    App(stdscr).run()

if __name__ == '__main__':
    curses.wrapper(main)
