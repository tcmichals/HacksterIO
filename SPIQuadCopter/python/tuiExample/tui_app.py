import curses
import time
from wb_driver import WishboneDriver

class App:
    def __init__(self, stdscr):
        self.stdscr = stdscr
        self.driver = WishboneDriver(bus=1, device=0) 
        # Note: User example used /dev/spidev1.0, so bus=1, device=0.
        
        # State
        self.mode = 'MENU' # MENU, PWM, DSHOT, NEO
        self.dshot_values = [0, 0, 0, 0]
        self.neo_values = [(0,0,0,0)] * 8
        self.neo_cursor_idx = 0
        self.neo_cursor_comp = 0 # 0=R, 1=G, 2=B, 3=W

        # Setup curses
        curses.curs_set(0)
        self.stdscr.nodelay(True)
        self.stdscr.timeout(100) # 100ms refresh

        self.last_pwm_read = 0
        self.pwm_inputs = [0]*6
        
        self.led_state = 0
        
        # --- Boot Check ---
        self.boot_error = None
        try:
            # Try to read version to verify connection
            v = self.driver.get_version()
            if len(v) != 4:
                self.boot_error = "SPI Comm Error: Invalid Version Length"
            else:
                 val = int.from_bytes(v, 'little') # Data is LE (User confirmed)
                 # FPGA returns DEADBEEF as placeholder version
                 if val != 0xDEADBEEF:
                      # It's an error if we expected specific version, but for now just warn?
                      # Or maybe it's fine. Users said "version is right ... returns deadbeef" implying that's expected.
                      pass 
        except Exception as e:
            self.boot_error = f"Boot Error: {str(e)}"
            
        if self.boot_error:
             self.mode = 'ERROR'

    # ... (skipping unchanged parts)

    def update_pixel(self, i):
        r,g,b,w = self.neo_values[i]
        self.driver.set_neopixel(i, r, g, b, w)
        self.stdscr.addstr(start_y, 2, "NEOPIXEL CONTROL (RGBW)", curses.A_UNDERLINE)

        for i in range(8):
            r, g, b, w = self.neo_values[i]
            cursor = "*" if i == self.neo_cursor_idx else " "
            
            # Highlight component
            r_s = f"[{r:3d}]" if self.neo_cursor_comp == 0 and i == self.neo_cursor_idx else f" {r:3d} "
            g_s = f"[{g:3d}]" if self.neo_cursor_comp == 1 and i == self.neo_cursor_idx else f" {g:3d} "
            b_s = f"[{b:3d}]" if self.neo_cursor_comp == 2 and i == self.neo_cursor_idx else f" {b:3d} "
            w_s = f"[{w:3d}]" if self.neo_cursor_comp == 3 and i == self.neo_cursor_idx else f" {w:3d} "
            
            self.stdscr.addstr(start_y+2+i, 2, f"{cursor} LED {i}: R{r_s} G{g_s} B{b_s} W{w_s}")

    def handle_input(self):
        c = self.stdscr.getch()
        if c == -1: return

        if self.mode == 'MENU':
            if c == ord('1'): self.mode = 'PWM'
            elif c == ord('2'): self.mode = 'DSHOT'
            elif c == ord('3'): self.mode = 'NEO'
            elif c == ord('4'): self.mode = 'LED'
            elif c == ord('q'): exit(0)
            
        elif self.mode == 'ERROR':
            if c == ord('q'): exit(1)
            elif c == ord('c'): self.mode = 'MENU'; self.boot_error = None
            
        elif self.mode == 'PWM':
            if c == ord('b'): self.mode = 'MENU'
            
        elif self.mode == 'LED':
             if c == ord('b'): self.mode = 'MENU'
             elif c == ord('1'): self.driver.toggle_leds(1)
             elif c == ord('2'): self.driver.toggle_leds(2)
             elif c == ord('3'): self.driver.toggle_leds(4)
             elif c == ord('4'): self.driver.toggle_leds(8)
            
        elif self.mode == 'DSHOT':
            if c == ord('b'): self.mode = 'MENU'
            elif c == ord('!'): 
                self.dshot_values = [0,0,0,0]
                for i in range(4): self.driver.set_dshot(i+1, 0)
            
            # Motor controls: q/a, w/s, e/d, r/f
            inc = 47
            idx = -1
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

        elif self.mode == 'NEO':
            if c == ord('b'): self.mode = 'MENU'
            elif c == curses.KEY_UP:
                self.neo_cursor_idx = max(0, self.neo_cursor_idx - 1)
            elif c == curses.KEY_DOWN:
                self.neo_cursor_idx = min(7, self.neo_cursor_idx + 1)
            elif c == curses.KEY_LEFT:
                self.neo_cursor_comp = max(0, self.neo_cursor_comp - 1)
            elif c == curses.KEY_RIGHT:
                self.neo_cursor_comp = min(3, self.neo_cursor_comp + 1) # Max 3 (W)
            elif c == curses.KEY_PPAGE: # PgUp
                idx = self.neo_cursor_idx
                vals = list(self.neo_values[idx])
                vals[self.neo_cursor_comp] = min(255, vals[self.neo_cursor_comp] + 10)
                self.neo_values[idx] = tuple(vals)
                self.update_pixel(idx)
            elif c == curses.KEY_NPAGE: # PgDn
                idx = self.neo_cursor_idx
                vals = list(self.neo_values[idx])
                vals[self.neo_cursor_comp] = max(0, vals[self.neo_cursor_comp] - 10)
                self.neo_values[idx] = tuple(vals)
                self.update_pixel(idx)
            elif c == ord(' '):
                self.driver.trigger_neopixel_update()

    def update_pixel(self, i):
        r,g,b,w = self.neo_values[i]
        self.driver.set_neopixel(i, r, g, b, w)
        
        # Setup curses
        curses.curs_set(0)
        self.stdscr.nodelay(True)
        self.stdscr.timeout(100) # 100ms refresh

        self.last_pwm_read = 0
        self.pwm_inputs = [0]*6
        
        self.led_state = 0
        
        # --- Boot Check ---
        self.boot_error = None
        try:
            # Try to read version to verify connection
            v = self.driver.get_version()
            if len(v) != 4:
                self.boot_error = "SPI Comm Error: Invalid Version Length"
            else:
                 val = int.from_bytes(v, 'little') # Data is LE (User confirmed)
                 # FPGA returns DEADBEEF as placeholder version
                 if val != 0xDEADBEEF:
                      # It's an error if we expected specific version, but for now just warn?
                      # Or maybe it's fine. Users said "version is right ... returns deadbeef" implying that's expected.
                      pass 
        except Exception as e:
            self.boot_error = f"Boot Error: {str(e)}"
            
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
        # Poll PWM every 100ms if on PWM or MENU screen
        now = time.time()
        if now - self.last_pwm_read > 0.1:
            try:
                self.pwm_inputs = self.driver.read_pwm_inputs()
            except Exception:
                pass # Ignore SPI errors during poll
            self.last_pwm_read = now

    def draw(self):
        self.stdscr.erase()
        h, w = self.stdscr.getmaxyx()
        
        # Define layout boundaries
        footer_h = 4
        main_h = h - footer_h
        
        # --- Main Content Area ---
        # Title
        title = "Tang9K FPGA Controller"
        self.stdscr.addstr(0, (w-len(title))//2, title, curses.A_BOLD)

        # Draw content offset by 2 lines for title
        if self.mode == 'MENU':
            self.draw_menu(2)
        elif self.mode == 'PWM':
            self.draw_pwm(2)
        elif self.mode == 'DSHOT':
            self.draw_dshot(2)
        elif self.mode == 'NEO':
            self.draw_neo(2)
        elif self.mode == 'LED':
             self.draw_led(2)

        # --- Footer Area ---
        # Separator Line
        self.stdscr.hline(main_h, 0, curses.ACS_HLINE, w)
        self.draw_footer(main_h + 1)

        self.stdscr.refresh()

    def draw_footer(self, y):
        h, w = self.stdscr.getmaxyx()
        
        # Status Line
        try:
            ver_bytes = self.driver.get_version()
            ver_int = int.from_bytes(ver_bytes, 'little')
            ver_str = f"0x{ver_int:08X} [{' '.join(f'{b:02X}' for b in ver_bytes)}]"
        except:
            ver_str = "vErr"
        
        status = f"Status: Connected | FPGA: {ver_str} | Mode: {self.mode}"
        self.stdscr.addstr(y, 2, status, curses.A_REVERSE)
        
        # Commands Line
        if self.mode == 'MENU':
             cmds = "Global: [q] Quit | Select Option [1-4]"
        else:
             cmds = "Global: [q] Quit [b] Back"
        self.stdscr.addstr(y+1, 2, cmds)
        
        # Context specific help
        help_msg = ""
        if self.mode == 'DSHOT':
            help_msg = "Controls: [q/a] M1 [w/s] M2 [e/d] M3 [r/f] M4 | [!] Stop All"
        elif self.mode == 'NEO':
            help_msg = "Controls: Arrows: Nav | PgUp/Dn: Value +/- | Space: Update"
        elif self.mode == 'PWM':
            help_msg = "Monitor Only: Values update automatically every 100ms"
        elif self.mode == 'LED':
            help_msg = "Controls: Press [1-4] to toggle LEDs"
            
        if help_msg:
             self.stdscr.addstr(y+2, 2, help_msg, curses.A_BOLD)

    def draw_menu(self, start_y):
        options = [
            "Select an option:",
            "",
            "  [1] PWM Input Monitor",
            "  [2] DSHOT Motor Control",
            "  [3] NeoPixel Control",
            "  [4] On-board LED Control",
            "  [q] Quit"
        ]
        for i, opt in enumerate(options):
            self.stdscr.addstr(start_y+1+i, 4, opt)

    def draw_error_window(self):
        h, w = self.stdscr.getmaxyx()
        h_center = h // 2
        w_center = w // 2
        
        # Draw Box
        box_h = 8
        box_w = 60
        start_y = h_center - (box_h//2)
        start_x = w_center - (box_w//2)
        
        # Clear background
        for i in range(box_h):
            self.stdscr.addstr(start_y+i, start_x, " " * box_w, curses.A_REVERSE)
            
        self.stdscr.addstr(start_y+1, start_x+2, "SYSTEM BOOT ERROR", curses.A_REVERSE | curses.A_BOLD)
        self.stdscr.addstr(start_y+3, start_x+2, f"Msg: {self.boot_error}", curses.A_REVERSE)
        self.stdscr.addstr(start_y+6, start_x+2, "Press [q] to Quit or [c] to Continue anyway", curses.A_REVERSE)

    def draw_led(self, start_y):
        self.stdscr.addstr(start_y, 2, "ON-BOARD LED CONTROL", curses.A_UNDERLINE)
        self.stdscr.addstr(start_y+2, 2, "Use [1-4] to toggle LEDs")
        
        # Read state (cached or live? live is better but slow, let's use cached for TUI feel)
        # self.led_state = self.driver.get_leds() 
        # Actually, let's live read for truth
        try:
             self.led_state = self.driver.get_leds()
        except:
             pass
             
        for i in range(4):
            is_on = (self.led_state >> i) & 1
            state_str = "[ON] " if is_on else "[OFF]"
            attr = curses.A_BOLD if is_on else curses.A_DIM
            self.stdscr.addstr(start_y+4+i, 4, f"LED {i}: {state_str}", attr)
        self.stdscr.addstr(start_y+10, 2, "[b] Back")
    def draw_pwm(self, start_y):
        self.stdscr.addstr(start_y, 2, "PWM INPUTS (Microseconds)", curses.A_UNDERLINE)
        for i, val in enumerate(self.pwm_inputs):
            # Check flags based on pwmdecoder_wb.v
            # 0xC000 = Guard time error (no signal)
            # 0x8000 = Guard time error (pulse too long)
            
            if (val & 0xC000) == 0xC000:
                self.stdscr.addstr(start_y+2+i, 2, f"CH{i}: [GUARD_ERROR_LOW] ", curses.A_DIM)
            elif (val & 0x8000) == 0x8000:
                 self.stdscr.addstr(start_y+2+i, 2, f"CH{i}: [GUARD_ERROR_HIGH]", curses.A_BLINK)
            else:
                bar_len = int((val / 2000) * 40)
                bar_len = max(0, min(40, bar_len))
                bar = "#" * bar_len
                self.stdscr.addstr(start_y+2+i, 2, f"CH{i}: {val:4d} us [{bar:<40}]")

    def draw_dshot(self, start_y):
        self.stdscr.addstr(start_y, 2, "DSHOT OUTPUT CONTROL (0-2047)", curses.A_UNDERLINE)
        
        for i in range(4):
            val = self.dshot_values[i]
            bar_len = int((val / 2048) * 40)
            bar = "=" * bar_len
            self.stdscr.addstr(start_y+2+i, 2, f"M{i+1}: {val:4d} [{bar:<40}]")

    def draw_neo(self, start_y):
        self.stdscr.addstr(start_y, 2, "NEOPIXEL CONTROL (RGBW)", curses.A_UNDERLINE)

        for i in range(8):
            r, g, b, w = self.neo_values[i]
            cursor = "*" if i == self.neo_cursor_idx else " "
            
            # Highlight component
            r_s = f"[{r:3d}]" if self.neo_cursor_comp == 0 and i == self.neo_cursor_idx else f" {r:3d} "
            g_s = f"[{g:3d}]" if self.neo_cursor_comp == 1 and i == self.neo_cursor_idx else f" {g:3d} "
            b_s = f"[{b:3d}]" if self.neo_cursor_comp == 2 and i == self.neo_cursor_idx else f" {b:3d} "
            w_s = f"[{w:3d}]" if self.neo_cursor_comp == 3 and i == self.neo_cursor_idx else f" {w:3d} "
            
            self.stdscr.addstr(start_y+2+i, 2, f"{cursor} LED {i}: R{r_s} G{g_s} B{b_s} W{w_s}")

    def handle_input(self):
        c = self.stdscr.getch()
        if c == -1: return

        if self.mode == 'MENU':
            if c == ord('1'): self.mode = 'PWM'
            elif c == ord('2'): self.mode = 'DSHOT'
            elif c == ord('3'): self.mode = 'NEO'
            elif c == ord('4'): self.mode = 'LED'
            elif c == ord('q'): exit(0)
            
        elif self.mode == 'ERROR':
            if c == ord('q'): exit(1)
            elif c == ord('c'): self.mode = 'MENU'; self.boot_error = None
            
        elif self.mode == 'PWM':
            if c == ord('b'): self.mode = 'MENU'
            
        elif self.mode == 'LED':
             if c == ord('b'): self.mode = 'MENU'
             elif c == ord('1'): self.driver.toggle_leds(1)
             elif c == ord('2'): self.driver.toggle_leds(2)
             elif c == ord('3'): self.driver.toggle_leds(4)
             elif c == ord('4'): self.driver.toggle_leds(8)
            
        elif self.mode == 'DSHOT':
            if c == ord('b'): self.mode = 'MENU'
            elif c == ord('!'): 
                self.dshot_values = [0,0,0,0]
                for i in range(4): self.driver.set_dshot(i+1, 0)
            
            # Simple controls: 1/2/3/4 increments, shift+1/2/3/4 decrements? Or global?
            # Let's make it simpler: Press 1-4 to bump that motor +50, Shift+1-4 to bump -50
            # That's hard to capture.
            # Let's just use Up/Down for *all* motors for test, or specific keys?
            # Let's use q/a for M1, w/s for M2, e/d for M3, r/f for M4
            
            inc = 47
            idx = -1
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

        elif self.mode == 'NEO':
            if c == ord('b'): self.mode = 'MENU'
            elif c == curses.KEY_UP:
                self.neo_cursor_idx = max(0, self.neo_cursor_idx - 1)
            elif c == curses.KEY_DOWN:
                self.neo_cursor_idx = min(7, self.neo_cursor_idx + 1)
            elif c == curses.KEY_LEFT:
                self.neo_cursor_comp = max(0, self.neo_cursor_comp - 1)
            elif c == curses.KEY_RIGHT:
                self.neo_cursor_comp = min(3, self.neo_cursor_comp + 1)
            elif c == curses.KEY_PPAGE: # PgUp
                idx = self.neo_cursor_idx
                vals = list(self.neo_values[idx])
                vals[self.neo_cursor_comp] = min(255, vals[self.neo_cursor_comp] + 10)
                self.neo_values[idx] = tuple(vals)
                self.update_pixel(idx)
            elif c == curses.KEY_NPAGE: # PgDn
                idx = self.neo_cursor_idx
                vals = list(self.neo_values[idx])
                vals[self.neo_cursor_comp] = max(0, vals[self.neo_cursor_comp] - 10)
                self.neo_values[idx] = tuple(vals)
                self.update_pixel(idx)
            elif c == ord(' '):
                self.driver.trigger_neopixel_update()

    def update_pixel(self, i):
        r,g,b,w = self.neo_values[i]
        self.driver.set_neopixel(i, r, g, b, w)

def main(stdscr):
    app = App(stdscr)
    app.run()

if __name__ == '__main__':
    curses.wrapper(main)
