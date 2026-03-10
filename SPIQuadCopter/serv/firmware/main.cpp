/*
 * SERV Firmware - Minimal MSP Bridge
 *
 * Wishbone Peripherals (SERV bus):
 *   0x4000_0100 : Debug GPIO (3 bits) - fast digital outputs for debugging
 *   0x4000_0300 : DSHOT Mailbox - motor control
 *   0x4000_0400 : Mux Register - mode control
 *   0x4000_0800 : USB UART - MSP communication
 *
 * Debug GPIO values (bits 2:0):
 *   0 = Reset/idle
 *   1 = Processor running (set at boot)
 *   2 = Main loop entered
 *   3 = USB RX received
 *   4 = MSP frame start ($M<)
 *   5 = MSP frame complete
 *   6 = MSP response sent
 *   7 = Error state
 */

#include "msp_loop.hpp"
#include "wb_regs.h"

int main()
{
    WB_DEBUG_GPIO_OUT = DBG_RUNNING;
    
    // msp_loop continuously sends DSHOT disarm frames
    // ESC will arm automatically after ~1-2 seconds of receiving them
    msp_loop();  // Never returns
    
    return 0;
}
