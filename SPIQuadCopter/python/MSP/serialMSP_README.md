serialMSP — quick README

This script helps send MSP (MultiWii Serial Protocol) frames and arbitrary raw bytes (e.g. BLHeli_S command frames)
over a serial port for testing FPGA or ESC interfaces.

Usage examples:

- Send MSP command id 105 with payload 0x01 0xff:
  python3 serialMSP.py --port /dev/ttyUSB0 --baud 115200 msp --cmd 105 --payload 01ff

- Send raw BLHeli frame (hex):
  python3 serialMSP.py --port /dev/ttyUSB0 raw --data 0A0B0C

- Listen and print serial bytes as hex:
  python3 serialMSP.py --port /dev/ttyUSB0 --baud 115200 listen --hex

Notes / caveats:
- Install pyserial: pip install pyserial
- BLHeli/BLHeli_S ESCs commonly require inverted UART levels and sometimes a single-wire half-duplex connection.
  Ensure your FPGA or adapter provides correct inversion and direction control. This script writes TTL-level bytes
  as-is and does not perform inversion or GPIO direction switching.
- The script implements basic MSP framing: header "$M<", size, cmd, payload, checksum (xor of size/cmd/payload)
  and will attempt to parse responses with header "$M>".

If you want specific BLHeli commands implemented (read/write config, set motor params), provide the packet definitions
and I can add convenience functions that build those packets directly.

set_mux example
----------------
Set the serial/DSHOT mux using MSP id 245 (convenience `set_mux` subcommand):

- Select passthrough, channel 3 (which maps to physical `o_motor1` in the design), MSP mode off:
  python3 serialMSP.py --port /dev/ttyUSB0 set_mux --mux-sel 0 --mux-ch 3 --msp-mode 0 --dump

- Clear any MSP override (send zero-length payload):
  python3 serialMSP.py --port /dev/ttyUSB0 set_mux --clear --dump

The payload layout (1 byte) is: bit0=mux_sel, bits[2:1]=mux_ch, bit3=msp_mode. A length==0 packet clears the override.
