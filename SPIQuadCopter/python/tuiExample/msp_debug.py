#!/usr/bin/env python3
import serial
import time
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

def list_serial_ports():
    return glob.glob('/dev/ttyUSB*')

def main():
    print("=== Tang9K MSP Debug Tool (No Curses) ===")
    
    ports = list_serial_ports()
    if not ports:
        print("No /dev/ttyUSB* ports found!")
        port_name = input("Enter port manually (e.g. /dev/ttyACM0): ").strip()
    else:
        print(f"Found ports: {ports}")
        # Default to the second one if available (often getting mapped to 1), or just first
        port_name = ports[0] 
        print(f"Selecting default: {port_name}")

    baud_rate = 115200
    
    try:
        ser = serial.Serial(port_name, baud_rate, timeout=0.1)
        print(f"Successfully opened {port_name} @ {baud_rate}")
    except Exception as e:
        print(f"Error opening serial port: {e}")
        return

    print("\nCommands:")
    print("  [1] Send MSP_IDENT (100)")
    print("  [2] Send MSP_SET_PASSTHROUGH (245)")
    print("  [3] Send MSP_FC_VARIANT (2)")
    print("  [q] Quit")

    while True:
        # Non-blocking check for received data
        while ser.in_waiting > 0:
            data = ser.read(ser.in_waiting)
            print(f"RX: {data.hex()} (ASCII: {data})")

        # Non-blocking input is hard in pure python without curses/external libs
        # So we will use blocking input() but this pauses RX display.
        # For a debug tool, this is acceptable.
        
        try:
            cmd = input("\nEnter command [1/2/3/q]: ").strip()
        except EOFError:
            break
            
        if cmd == 'q':
            break
        elif cmd == '1':
            send_msp(ser, MSP_IDENT)
            # Wait briefly for response
            time.sleep(0.1)
            if ser.in_waiting:
                data = ser.read(ser.in_waiting)
                print(f"RX (Immediate): {data.hex()}")
                
        elif cmd == '2':
            send_msp(ser, MSP_SET_PASSTHROUGH, [0])
        elif cmd == '3':
            send_msp(ser, MSP_FC_VARIANT)
        else:
            print("Unknown command")

def send_msp(ser, cmd_id, payload=[]):
    size = len(payload)
    checksum = 0
    packet = bytearray([ord('$'), ord('M'), ord('<')])
    packet.append(size); checksum ^= size
    packet.append(cmd_id); checksum ^= cmd_id
    for b in payload:
        packet.append(b); checksum ^= b
    packet.append(checksum)
    
    print(f"TX: CMD {cmd_id} Payload len {size} -> {packet.hex()}")
    ser.write(packet)

if __name__ == "__main__":
    main()
