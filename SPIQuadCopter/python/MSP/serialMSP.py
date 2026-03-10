#!/usr/bin/env python3
"""
serialMSP.py

Send MSP (MultiWii Serial Protocol) commands and arbitrary raw bytes (e.g. BLHeli_S frames)
over a serial port to exercise/test hardware (FPGA, ESCs, etc.).

Usage examples:
  python3 serialMSP.py --port /dev/ttyUSB0 --baud 115200 msp --cmd 105 --payload 01ff
  python3 serialMSP.py --port /dev/ttyUSB0 raw --data 0A0B0C
  python3 serialMSP.py --port /dev/ttyUSB0 listen

Note: BLHeli/BLHeli_S ESCs commonly use inverted UART levels and 1-wire half-duplex interfaces;
this script writes normal TTL-level bytes. Hardware adapter or FPGA wiring must handle inversion
and direction switching.

Requires: pyserial (pip install pyserial)
"""

import argparse
import serial
import sys
import time
import datetime

MSP_HEADER_OUT = b"$M<"
MSP_HEADER_IN = b"$M>"

# 4-Way protocol constants
FOURWAY_PC_SYNC = 0x2F
FOURWAY_FC_SYNC = 0x2E

# 4-Way commands
FOURWAY_CMDS = {
    'test_alive': 0x30,
    'get_version': 0x31,
    'get_name': 0x32,
    'get_if_version': 0x33,
    'exit': 0x34,
    'reset': 0x35,
    'init_flash': 0x37,
    'erase_all': 0x38,
    'page_erase': 0x39,
    'read': 0x3A,
    'write': 0x3B,
    'read_eeprom': 0x3D,
    'write_eeprom': 0x3E,
    'set_mode': 0x3F,
}

FOURWAY_ACK = {
    0x00: 'OK',
    0x01: 'UNKNOWN_ERROR',
    0x02: 'INVALID_CMD',
    0x03: 'INVALID_CRC',
    0x04: 'VERIFY_ERROR',
    0x05: 'D_INVALID_CMD',
    0x06: 'D_CMD_FAILED',
    0x07: 'D_UNKNOWN_ERROR',
    0x08: 'INVALID_CHANNEL',
    0x09: 'INVALID_PARAM',
    0x0F: 'GENERAL_ERROR',
}


def crc16_xmodem(data: bytes) -> int:
    """CRC16 X-Modem calculation"""
    crc = 0
    for byte in data:
        crc ^= byte << 8
        for _ in range(8):
            if crc & 0x8000:
                crc = (crc << 1) ^ 0x1021
            else:
                crc <<= 1
        crc &= 0xFFFF
    return crc


def calc_checksum(buf: bytes) -> int:
    cs = 0
    for b in buf:
        cs ^= b
    return cs


def hexdump(data: bytes) -> str:
    return ' '.join(f"{b:02X}" for b in data)


class MSP:
    def __init__(self, ser: serial.Serial):
        self.ser = ser
    def send_msp(self, cmd: int, payload: bytes = b"", expect_response: bool = True, timeout: float = 1.0, dump: bool = False):
        size = len(payload)
        header = MSP_HEADER_OUT
        frame = header + bytes([size, cmd]) + payload
        cs = calc_checksum(frame[3:])
        frame += bytes([cs])
        self.ser.write(frame)
        self.ser.flush()
        print(f"Sent MSP cmd={cmd} size={size} cs=0x{cs:02x}")
        if dump:
            print("TX:", hexdump(frame))
        if expect_response:
            return self._read_response(timeout)
        return None

    def _read_response(self, timeout: float = 1.0):
        t0 = time.time()
        # read until we find MSP_HEADER_IN
        buf = b""
        while time.time() - t0 < timeout:
            b = self.ser.read(1)
            if not b:
                continue
            buf += b
            if buf.endswith(MSP_HEADER_IN):
                break
            # keep buffer length reasonable
            if len(buf) > 64:
                buf = buf[-64:]
        else:
            print("No MSP response header seen (timeout)")
            return None
        # read size and cmd
        size_b = self.ser.read(1)
        if not size_b:
            print("Truncated response (size missing)")
            return None
        size = size_b[0]
        cmd_b = self.ser.read(1)
        if not cmd_b:
            print("Truncated response (cmd missing)")
            return None
        cmd = cmd_b[0]
        payload = self.ser.read(size)
        if len(payload) != size:
            print(f"Truncated payload (got {len(payload)} expected {size})")
            # try to continue anyway
        cs_b = self.ser.read(1)
        if not cs_b:
            print("Truncated response (checksum missing)")
            return None
        cs = cs_b[0]
        # verify checksum
        chk = calc_checksum(bytes([size, cmd]) + payload)
        ok = chk == cs
        print(f"Recv MSP cmd={cmd} size={size} cs=0x{cs:02x} calc=0x{chk:02x} ok={ok}")
        print("RX:", hexdump(bytes([0x24, 0x4D, 0x3E]) + bytes([size, cmd]) + payload + bytes([cs])))
        return {"cmd": cmd, "size": size, "payload": payload, "cs": cs, "valid": ok}


class FourWay:
    """4-Way interface protocol handler"""
    def __init__(self, ser: serial.Serial):
        self.ser = ser

    def send(self, cmd: int, address: int = 0, params: bytes = b"", timeout: float = 2.0):
        """Send a 4way command and wait for response"""
        if len(params) == 0:
            params = bytes([0])  # Protocol requires at least 1 param byte
        
        param_len = len(params) if len(params) < 256 else 0  # 0 means 256
        
        # Build message: [sync][cmd][addr_h][addr_l][len][params...]
        msg = bytes([FOURWAY_PC_SYNC, cmd, (address >> 8) & 0xFF, address & 0xFF, param_len]) + params
        
        # Calculate CRC16 over message (excluding CRC itself)
        crc = crc16_xmodem(msg)
        frame = msg + bytes([(crc >> 8) & 0xFF, crc & 0xFF])
        
        self.ser.write(frame)
        self.ser.flush()
        print(f"4way TX: cmd=0x{cmd:02X} addr=0x{address:04X} params={params.hex()}")
        print(f"  Frame: {hexdump(frame)}")
        
        return self._read_response(timeout)

    def _read_response(self, timeout: float):
        """Read 4way response"""
        t0 = time.time()
        
        # Wait for sync byte
        while time.time() - t0 < timeout:
            b = self.ser.read(1)
            if not b:
                continue
            if b[0] == FOURWAY_FC_SYNC:
                break
        else:
            print("4way: No response (timeout waiting for sync)")
            return None
        
        # Read cmd, addr_h, addr_l, len
        header = self.ser.read(4)
        if len(header) < 4:
            print(f"4way: Truncated header (got {len(header)} bytes)")
            return None
        
        cmd = header[0]
        address = (header[1] << 8) | header[2]
        param_len = header[3] if header[3] != 0 else 256
        
        # Read params
        params = self.ser.read(param_len)
        if len(params) < param_len:
            print(f"4way: Truncated params (got {len(params)}, expected {param_len})")
        
        # Read ACK byte
        ack_b = self.ser.read(1)
        ack = ack_b[0] if ack_b else 0xFF
        
        # Read CRC (2 bytes)
        crc_bytes = self.ser.read(2)
        if len(crc_bytes) < 2:
            print("4way: Truncated CRC")
            recv_crc = 0
        else:
            recv_crc = (crc_bytes[0] << 8) | crc_bytes[1]
        
        # Verify CRC
        msg = bytes([FOURWAY_FC_SYNC, cmd, (address >> 8) & 0xFF, address & 0xFF, 
                     header[3]]) + params + bytes([ack])
        calc_crc = crc16_xmodem(msg)
        crc_ok = recv_crc == calc_crc
        
        ack_str = FOURWAY_ACK.get(ack, f'UNKNOWN(0x{ack:02X})')
        print(f"4way RX: cmd=0x{cmd:02X} addr=0x{address:04X} ack={ack_str} params={params.hex()}")
        print(f"  CRC: recv=0x{recv_crc:04X} calc=0x{calc_crc:04X} ok={crc_ok}")
        
        return {
            'cmd': cmd,
            'address': address,
            'params': params,
            'ack': ack,
            'ack_str': ack_str,
            'crc_ok': crc_ok
        }

    def test_alive(self):
        """Send keep-alive ping"""
        return self.send(FOURWAY_CMDS['test_alive'])

    def get_version(self):
        """Get protocol version"""
        return self.send(FOURWAY_CMDS['get_version'])

    def get_name(self):
        """Get interface name"""
        return self.send(FOURWAY_CMDS['get_name'])

    def exit_4way(self):
        """Exit 4way mode, return to MSP"""
        return self.send(FOURWAY_CMDS['exit'])

    def init_flash(self, esc_num: int = 0):
        """Initialize ESC for flashing (triggers bootloader)"""
        return self.send(FOURWAY_CMDS['init_flash'], address=0, params=bytes([esc_num & 0x03]), timeout=10.0)

    def read_flash(self, address: int, length: int):
        """Read from ESC flash"""
        return self.send(FOURWAY_CMDS['read'], address=address, params=bytes([length & 0xFF]))


def parse_hex_bytes(s: str) -> bytes:
    s2 = s.replace("0x", "").replace(" ", "").replace(",", "")
    if len(s2) % 2 == 1:
        s2 = "0" + s2
    return bytes.fromhex(s2)


def open_serial(port: str, baud: int, timeout: float = 0.1) -> serial.Serial:
    try:
        ser = serial.Serial(port, baud, timeout=timeout)
        # small sleep to let device reset/settle
        time.sleep(0.05)
        return ser
    except Exception as e:
        print(f"Failed to open serial port {port}: {e}")
        sys.exit(2)


def main():
    p = argparse.ArgumentParser(description="Send MSP and raw serial frames")
    p.add_argument("--port", required=True, help="Serial device, e.g. /dev/ttyUSB0")
    p.add_argument("--baud", type=int, default=115200)
    p.add_argument("--dump", action="store_true", help="Hex dump TX/RX frames")
    sub = p.add_subparsers(dest="mode")

    msp = sub.add_parser("msp", help="Send an MSP command")
    msp.add_argument("--cmd", type=int, required=True, help="MSP command id (decimal)")
    msp.add_argument("--payload", default="", help="Payload bytes as hex (e.g. 0102ff)")
    msp.add_argument("--no-response", action="store_true", help="Don't wait for an MSP response")

    raw = sub.add_parser("raw", help="Send raw bytes (useful for BLHeli frames)")
    raw.add_argument("--data", required=True, help="Hex bytes to send, e.g. 0A0B0C")
    raw.add_argument("--repeat", type=int, default=1, help="Repeat count")
    raw.add_argument("--read-after", type=float, default=0.05, help="Time (s) to wait and read response after write")

    blheli = sub.add_parser("blheli", help="Send BLHeli-style raw bytes (convenience wrapper)")
    blheli.add_argument("--data", required=True, help="Hex bytes for BLHeli frame, e.g. 0A0B0C")
    blheli.add_argument("--repeat", type=int, default=1, help="Repeat count")
    blheli.add_argument("--read-after", type=float, default=0.02, help="Wait time after write to read response")

    set_mux = sub.add_parser("set_mux", help="Set UART mux selection via MSP id 245")
    set_mux.add_argument("--mux-sel", type=int, choices=[0,1], default=0, help="Mux select (0 or 1)")
    set_mux.add_argument("--mux-ch", type=int, choices=[0,1,2,3], default=0, help="Mux channel (0..3)")
    set_mux.add_argument("--msp-mode", type=int, choices=[0,1], default=0, help="MSP mode (0 or 1)")
    set_mux.add_argument("--clear", action="store_true", help="Send clear (zero-length) payload for MSP 245")

    listen = sub.add_parser("listen", help="Listen and print bytes/lines from serial")
    listen.add_argument("--hex", action="store_true", help="Print bytes as hex")

    fourway = sub.add_parser("fourway", help="Send 4-way interface commands (after MSP passthrough)")
    fourway.add_argument("--cmd", choices=list(FOURWAY_CMDS.keys()),
                         help="Single 4way command to send")
    fourway.add_argument("--cmds", nargs='+', choices=list(FOURWAY_CMDS.keys()),
                         help="Multiple 4way commands to send in sequence")
    fourway.add_argument("--esc", type=int, default=0, choices=[0,1,2,3],
                         help="ESC number (for init_flash)")
    fourway.add_argument("--address", type=lambda x: int(x, 0), default=0,
                         help="Address (for read/write commands)")
    fourway.add_argument("--length", type=int, default=128,
                         help="Length (for read commands)")
    fourway.add_argument("--passthrough", action="store_true",
                         help="Send MSP_SET_PASSTHROUGH (245) first to enter 4way mode")
    fourway.add_argument("--delay", type=float, default=0.1,
                         help="Delay in seconds between commands (default: 0.1)")

    args = p.parse_args()
    if args.mode is None:
        p.print_help()
        sys.exit(1)

    ser = open_serial(args.port, args.baud)

    if args.mode == "msp":
        payload = parse_hex_bytes(args.payload) if args.payload else b""
        m = MSP(ser)
        resp = m.send_msp(args.cmd, payload, expect_response=not args.no_response, dump=args.dump)
        if resp:
            print("Payload:", resp["payload"].hex())
    elif args.mode == "raw":
        data = parse_hex_bytes(args.data)
        for i in range(args.repeat):
            ser.write(data)
            ser.flush()
            print(f"Wrote {len(data)} bytes: {data.hex()}")
            if args.dump:
                print("TX:", hexdump(data))
            # optional read-after to capture response
            if getattr(args, 'read_after', 0) and args.read_after > 0:
                time.sleep(args.read_after)
                rx = ser.read(256)
                if rx:
                    print(datetime.datetime.now().isoformat(), "RX:", hexdump(rx))
            time.sleep(0.01)
    elif args.mode == "blheli":
        data = parse_hex_bytes(args.data)
        for i in range(args.repeat):
            ser.write(data)
            ser.flush()
            print(f"Wrote BLHeli {len(data)} bytes: {data.hex()}")
            if args.dump:
                print("TX:", hexdump(data))
            time.sleep(args.read_after)
            rx = ser.read(256)
            if rx:
                print(datetime.datetime.now().isoformat(), "RX:", hexdump(rx))
    elif args.mode == "set_mux":
        # Build and send MSP id 245 to control UART muxing
        m = MSP(ser)
        if args.clear:
            payload = b""
            print("Sending MSP 245 clear (zero-length payload)")
        else:
            val = (args.msp_mode << 3) | (args.mux_ch << 1) | (args.mux_sel)
            payload = bytes([val & 0xFF])
            print(f"Sending MSP 245 set_mux mux_sel={args.mux_sel} mux_ch={args.mux_ch} msp_mode={args.msp_mode} val=0x{val:02x}")
        resp = m.send_msp(245, payload, expect_response=True, dump=args.dump)
        if args.dump:
            print("Payload TX:", hexdump(payload))
        if resp:
            print("Response payload:", resp.get("payload", b"").hex())
    elif args.mode == "fourway":
        # Enter 4way mode first if requested
        if args.passthrough:
            print("Entering 4way mode via MSP_SET_PASSTHROUGH...")
            m = MSP(ser)
            resp = m.send_msp(245, b"", expect_response=True)
            if resp and resp.get('valid'):
                print(f"4way mode active, {resp['payload'][0] if resp['payload'] else 0} ESCs reported")
            else:
                print("Failed to enter 4way mode")
                ser.close()
                sys.exit(1)
        
        fw = FourWay(ser)
        
        # Build command list from --cmd or --cmds
        if args.cmds:
            cmd_list = args.cmds
        elif args.cmd:
            cmd_list = [args.cmd]
        else:
            print("Error: must specify --cmd or --cmds")
            ser.close()
            sys.exit(1)
        
        for idx, cmd in enumerate(cmd_list):
            if idx > 0:
                time.sleep(args.delay)
            print(f"\n--- Command {idx+1}/{len(cmd_list)}: {cmd} ---")
            
            if cmd == 'test_alive':
                fw.test_alive()
            elif cmd == 'get_version':
                fw.get_version()
            elif cmd == 'get_name':
                resp = fw.get_name()
                if resp and resp['params']:
                    name = resp['params'].decode('ascii', errors='replace').rstrip('\x00')
                    print(f"Interface name: {name}")
            elif cmd == 'get_if_version':
                fw.send(FOURWAY_CMDS['get_if_version'])
            elif cmd == 'exit':
                fw.exit_4way()
                print("Exited 4way mode")
            elif cmd == 'init_flash':
                print(f"Initializing ESC {args.esc} for flashing...")
                resp = fw.init_flash(args.esc)
                if resp and resp['ack'] == 0:
                    print(f"ESC {args.esc} bootloader active, signature: {resp['params'].hex()}")
                else:
                    print(f"ESC {args.esc} init failed")
            elif cmd == 'read':
                fw.read_flash(args.address, args.length)
            elif cmd == 'reset':
                fw.send(FOURWAY_CMDS['reset'], params=bytes([args.esc & 0x03]))
            else:
                # Generic send
                fw.send(FOURWAY_CMDS[cmd])
    elif args.mode == "listen":
        print(f"Listening on {args.port} @ {args.baud} baud. Ctrl-C to exit.")
        try:
            while True:
                b = ser.read(1)
                if not b:
                    continue
                if args.hex:
                    print(datetime.datetime.now().isoformat(), "RX:", b.hex(), end=" ", flush=True)
                else:
                    # try to print human text, fall back to hex for non-printables
                    if 32 <= b[0] <= 126 or b in b"\n\r\t":
                        sys.stdout.buffer.write(b)
                        sys.stdout.flush()
                    else:
                        print(datetime.datetime.now().isoformat(), "RX:", b.hex(), end=" ", flush=True)
        except KeyboardInterrupt:
            print("\nStopped listening")
    ser.close()


if __name__ == "__main__":
    main()
