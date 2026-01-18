            elif c == ord(' '):
                self.driver.trigger_neopixel_update()
        
        elif self.mode == 'SERIAL':
            if c == ord('b'): self.mode = 'MENU'
            elif c == ord('m'):  # Toggle mode
                self.serial_bypass_mode = 1 - self.serial_bypass_mode
                self._update_serial_mux()
            elif c == ord('1'):  # Motor 1
                self.serial_bypass_channel = 0
                self._update_serial_mux()
            elif c == ord('2'):  # Motor 2
                self.serial_bypass_channel = 1
                self._update_serial_mux()
            elif c == ord('3'):  # Motor 3
                self.serial_bypass_channel = 2
                self._update_serial_mux()
            elif c == ord('4'):  # Motor 4
                self.serial_bypass_channel = 3
                self._update_serial_mux()
    
    def _update_serial_mux(self):
        """Update the serial/DSHOT mux register (0x0400)"""
        # Bit 0: mux_sel (0=Passthrough, 1=DSHOT)
        # Bit 2:1: mux_ch (0-3 for Motor 1-4)
        mux_val = (self.serial_bypass_channel << 1) | self.serial_bypass_mode
        try:
            self.driver.wb.write(0x0400, mux_val)
        except Exception as e:
            pass  # Ignore errors for now

    def update_pixel(self, i):
        r,g,b,w = self.neo_values[i]
        self.driver.set_neopixel(i, r, g, b, w)
    
    def draw_serial(self, start_y):
        self.stdscr.addstr(start_y, 2, "SERIAL BYPASS CONTROL", curses.A_UNDERLINE)
        self.stdscr.addstr(start_y+2, 2, "Switch between DSHOT motor control and BLHeli passthrough mode")
        
        # Current mode
        mode_str = "PASSTHROUGH (BLHeli Config)" if self.serial_bypass_mode == 0 else "DSHOT (Motor Control)"
        mode_attr = curses.A_BOLD if self.serial_bypass_mode == 0 else curses.A_NORMAL
        self.stdscr.addstr(start_y+4, 2, f"Current Mode: {mode_str}", mode_attr)
        
        # Selected channel (only relevant in passthrough mode)
        if self.serial_bypass_mode == 0:
            ch_str = f"Motor {self.serial_bypass_channel + 1} (Pin {32 + self.serial_bypass_channel})"
            self.stdscr.addstr(start_y+5, 2, f"Passthrough Channel: {ch_str}", curses.A_BOLD)
        
        # Mux register value
        mux_val = (self.serial_bypass_channel << 1) | self.serial_bypass_mode
        self.stdscr.addstr(start_y+7, 2, f"Mux Register (0x0400): 0x{mux_val:02X}")
        
        # Instructions
        self.stdscr.addstr(start_y+9, 2, "Controls:")
        self.stdscr.addstr(start_y+10, 4, "[m] Toggle Mode (DSHOT ↔ Passthrough)")
        self.stdscr.addstr(start_y+11, 4, "[1-4] Select Motor Channel for Passthrough")
        self.stdscr.addstr(start_y+12, 4, "[b] Back to Menu")
        
        # Warning
        if self.serial_bypass_mode == 0:
            self.stdscr.addstr(start_y+14, 2, "⚠ WARNING: Motors disabled in Passthrough mode!", curses.A_BLINK | curses.A_BOLD)

def main(stdscr):
    app = App(stdscr)
    app.run()

if __name__ == '__main__':
    curses.wrapper(main)
