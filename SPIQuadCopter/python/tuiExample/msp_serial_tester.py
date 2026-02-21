#!/usr/bin/env python3
import curses
import serial
import time
import struct
import argparse
import sys
import glob

# Standard MSP Commands
MSP_API_VERSION     = 1
MSP_FC_VARIANT      = 2
MSP_FC_VERSION      = 3
MSP_BOARD_INFO      = 4
MSP_BUILD_INFO      = 5
MSP_NAME            = 10
MSP_IDENT           = 100
MSP_SET_PASSTHROUGH = 245

class MspSerialTester:
    def __init__(self, stdscr):
        self.stdscr = stdscr
        self.serial_port = None
        self.port_name = "/dev/ttyUSB1" # Default
        self.baud_rate = 115200
        self.log = []
        self.connected = False
        self.last_key = -1
        
        # Setup curses
        curses.curs_set(0)
        self.stdscr.nodelay(True)
        self.stdscr.timeout(50) # 50ms refresh

        # Initial connect attempt
        self.connect_serial()

    def connect_serial(self):
        if self.serial_port and self.serial_port.is_open:
            self.serial_port.close()
            
        try:
            self.serial_port = serial.Serial(self.port_name, self.baud_rate, timeout=0.1)
            self.connected = True
            self.log_msg(f"Connected to {self.port_name} @ {self.baud_rate}")
        except Exception as e:
            self.connected = False
            self.log_msg(f"Connection Failed: {e}")

    def log_msg(self, msg):
        self.log.append(msg)
        if len(self.log) > 15:
            self.log.pop(0)

    def send_msp(self, cmd_id, payload=[]):
        if not self.connected:
            self.log_msg("Error: Not Connected")
            return

        size = len(payload)
        checksum = 0
        
        # Header $M<
        packet = bytearray([ord('$'), ord('M'), ord('<')])
        packet.append(size); checksum ^= size
        packet.append(cmd_id); checksum ^= cmd_id
        for b in payload:
            packet.append(b); checksum ^= b
        packet.append(checksum)
        
        try:
            self.serial_port.write(packet)
            self.log_msg(f"TX: CMD {cmd_id} ({packet.hex()})")
            
            # Expect response?
            # self.read_response() 
            # We poll response in background
        except Exception as e:
            self.log_msg(f"TX Error: {e}")
            self.connected = False

    def read_response(self):
        if not self.serial_port or not self.serial_port.is_open:
            return

        try:
            if self.serial_port.in_waiting > 0:
                # Read header '$'
                c = self.serial_port.read(1)
                if c == b'$':
                    # Start of packet
                    header = self.serial_port.read(2) # M> or M!
                    if len(header) != 2: return
                    
                    direction = header[1] # '>' (0x3E) or '!' (0x21)
                    size_b = self.serial_port.read(1)
                    if not size_b: return
                    size = size_b[0]
                    
                    cmd_b = self.serial_port.read(1)
                    if not cmd_b: return
                    cmd = cmd_b[0]
                    
                    # Read payload + checksum
                    remainder = self.serial_port.read(size + 1)
                    if len(remainder) != size + 1: return
                    
                    payload = remainder[:-1]
                    chk = remainder[-1]
                    
                    self.log_msg(f"RX: CMD {cmd} Len {size} [{payload.hex()}]")
                else:
                    # Garbage or other data
                    pass
        except Exception as e:
            self.log_msg(f"RX Error: {e}")

    def run(self):
        while True:
            self.draw()
            self.handle_input()
            if self.connected:
                self.read_response()
            time.sleep(0.01)

    def handle_input(self):
        try:
            c = self.stdscr.getch()
        except: return
        
        if c == -1: return
        
        if c == ord('q') or c == ord('Q'):
            sys.exit(0)
        elif c == ord('1'):
            self.send_msp(MSP_IDENT)
        elif c == ord('2'):
             # Standard Passthrough Command: [245, 0 (channel), 0 (baud?), 0, 0] ?
             # Payload for MSP_SET_PASSTHROUGH is usually [ESCMSP, Index]
             # Let's send a simple payload for now
            self.send_msp(MSP_SET_PASSTHROUGH, [0]) 
        elif c == ord('3'):
            self.send_msp(MSP_FC_VARIANT)
        elif c == ord('4'): # Toggle Port
            self.toggle_port()
        elif c == ord('c'):
            self.log = []

    def toggle_port(self):
        if self.port_name == '/dev/ttyUSB1': self.port_name = '/dev/ttyUSB0'
        else: self.port_name = '/dev/ttyUSB1'
        self.connect_serial()

    def draw(self):
        self.stdscr.erase()
        h, w = self.stdscr.getmaxyx()
        
        # Header
        title = "Tang9K MSP Serial Tester"
        self.stdscr.addstr(0, (w-len(title))//2, title, curses.A_BOLD)
        
        # Status
        status = f"Port: {self.port_name} | Baud: {self.baud_rate} | Connected: {self.connected}"
        self.stdscr.addstr(2, 2, status, curses.A_REVERSE if self.connected else curses.A_DIM)
        
        # Menu
        self.stdscr.addstr(4, 2, "Controls:", curses.A_UNDERLINE)
        self.stdscr.addstr(5, 4, "[1] Send MSP_IDENT (100)")
        self.stdscr.addstr(6, 4, "[2] Send PASSTHROUGH (245)")
        self.stdscr.addstr(7, 4, "[3] Send FC_VARIANT (2)")
        self.stdscr.addstr(8, 4, "[4] Switch Port (/dev/ttyUSB0 <-> 1)")
        self.stdscr.addstr(9, 4, "[c] Clear Log")
        self.stdscr.addstr(10, 4, "[q] Quit")
        
        # Log
        self.stdscr.addstr(12, 2, "Protocol Log:", curses.A_UNDERLINE)
        for i, line in enumerate(self.log):
            if 13+i < h-1:
                self.stdscr.addstr(13+i, 4, line)
        
        self.stdscr.refresh()

def main(stdscr):
    app = MspSerialTester(stdscr)
    while True:
        app.draw()
        app.handle_input()
        if app.connected:
            app.read_response()
        time.sleep(0.05)
