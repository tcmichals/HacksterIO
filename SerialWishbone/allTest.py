import time
import serial
import sys
import neo
import blinkt

NUM_ON_BOARD_LEDS=6
def addLed( offset, value):
    return (value & ( 1 << offset )) << offset
	

def writeLEDTang9K(ser, led_0_5):

    led_val = led_0_5 & 0xFF

    msg = [0xA2,
           0,0,0,0,
           0, 4 ,
           led_val,0,0,0 ]
    reply = ser.write(msg)
    
    while (ser.in_waiting == 0):
        pass
  
    if (ser.in_waiting):
        inmsg = ser.read(ser.in_waiting )

def toggleOffLEDTang9K(ser, led_0_5 ):

    led_val = led_0_5 & 0xFF

    msg = [0xA2,
           0,0,0,8,
           0,4,
           led_val,0 ,0,0 ]
    reply = ser.write(msg)
    while (ser.in_waiting == 0):
        pass
  
    if (ser.in_waiting):
        inmsg = ser.read(ser.in_waiting )    
 
def toggleOnLEDTang9K(ser, led_0_5 ):

    led_val = led_0_5 & 0xFF

    msg = [0xA2,
           0,0,0,4,
           0,4,
           led_val,0 ,0,0 ]
    reply = ser.write(msg)
    while (ser.in_waiting == 0):
        pass
  
    if (ser.in_waiting):
        inmsg = ser.read(ser.in_waiting )    

def loop(ser, count = 1000):
    
    try:

        loopcnt = range(count)
        ledArray = 0x01
        for x in loopcnt:
            # Report the channel 0 and channel 1 voltages to the terminal
 
            for n in range(0,NUM_ON_BOARD_LEDS):
                writeLEDTang9K(ser, 1 << n)
                neo.updateLEDs(ser)
                blinkt.updateLEDs(ser)
                time.sleep(0.05)




    finally:
        ser.close()
       
def openSerialPort():
    ser = serial.Serial(port='/dev/ttyUSB1', bytesize= serial.EIGHTBITS, parity=serial.PARITY_NONE, stopbits=serial.STOPBITS_ONE)  # open serial port
    ser.baudrate = 1000000
    return ser

def main():
    ser = openSerialPort()
    time.sleep(.1)
    ser.close()
    ser=openSerialPort()
    time.sleep(.1)
    loop(ser,5000)

    ser.close()


if __name__ == "__main__":
    # execute only if run as a script
    main()