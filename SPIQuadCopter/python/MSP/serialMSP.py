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
