
import time
import serial
import sys

ADDRESS_INDEX = 4
COLOR_OFFSET = 7

def updateColorLED(serialPort,  index = 0, color = 0):
    #A2 write #a1 read
    msg = [0xA2,
       # high to low 
       0,0,1,(index * 4) & 0xff,
       0, 4 ,
       # White  BLUE RED GREEN
       color & 0xFF, 
       (color >> 8) & 0xff,
       (color >> 16) & 0xff,
       (color >> 24) & 0xff,
    ]

    serialPort.write(msg)
    while serialPort.in_waiting < 7:
        pass

def updateLED(serialPort):
    #A2 write #a1 read
    msg = [0xA2,
       # high to low 
       0,0,1,0x20,
       0, 4 ,
       # White  BLUE RED GREEN
       0,0,0,0,
    ]
    serialPort.write(msg)
    serialPort.write(msg)
    while serialPort.in_waiting < 7:
        pass
    inmsg = serialPort.read(serialPort.in_waiting )

def rawUpdate(serialPort):
    #A2 write #a1 read
    msg = [0xA2,
       # high to low 
       0,0,1,0,
       0, 4 *8,
       # White  BLUE RED GREEN
       3,0,0,0,
       0,3,0,0,
       0,0,3,0,
       0,0,0,3,
       0,0,3,0,
       0,3,0,0,
       3,0,0,0,
       0,0,0,3,
    ]
    
    serialPort.write(msg)
    while serialPort.in_waiting < 7:
        pass
    inmsg = serialPort.read(serialPort.in_waiting )

        #A2 write #a1 read
    msg = [0xA2,
       # high to low 
       0,0,1,0x20,
       0, 4 ,
       # White  BLUE RED GREEN
       0,0xff,0,0,
    ]
    serialPort.write(msg)
    while serialPort.in_waiting < 7:
        pass
    inmsg = serialPort.read(serialPort.in_waiting )

def getColor( red=0, green=0, blue=0, white=0):
    return (white & 0xff) + ((blue & 0xff) << 8) + ((red & 0xff) << 16) + ((green & 0xff) << 24)



colorLEDs = [getColor(green=0xf), 
             getColor(red=0xf),
            getColor(white=0xf),
                getColor(blue=0xf), 
                getColor(),
                getColor(),
                getColor(),
                getColor()]


def updateLEDs(ser):
    try:
        ledArray = 0x01
        index = 0
        for ledColor in colorLEDs:
            updateColorLED(ser,index, ledColor)
            index+=1   
        
        val = colorLEDs[0]
        colorLEDs.pop(0)
        colorLEDs.append(val)
        updateLED(ser)

    except Exception:
        pass


    




    
    

