/*
 * SERV Firmware - Minimal MSP Bridge
 *
 * Wishbone Peripherals (SERV bus):
 *   0x4000_0100 : Debug GPIO (3 bits) - fast digital outputs for debugging
 *   0x4000_0700 : Mux Register - mode control
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

#include "msp_bridge.hpp"
#include "wb_regs.h"
#include <stdint.h>
#include <stddef.h>

// Debug state values (output on debug GPIO pins)
#define DBG_RESET      0
#define DBG_RUNNING    1
#define DBG_LOOP       2
#define DBG_RX         3
#define DBG_MSP_START  4
#define DBG_MSP_DONE   5
#define DBG_TX_DONE    6
#define DBG_ERROR      7

// Set debug GPIO output (values 0-7)
inline void dbg_set(uint8_t val) {
    WB_DEBUG_GPIO_OUT = val & 0x07;
}

// Set debug GPIO output (values 0-7)
inline void dbgToggle(uint8_t val) {
    WB_DEBUG_GPIO_TGL = val & 0x07;
}

#define RX_READY 0x0100


uint16_t getMSPInChar() 
{
    uint32_t status = WB_USB_STATUS;
    if (status & WB_USB_RX_VALID) 
    {
        return WB_USB_RX_DATA & 0xFF | RX_READY;
    }

    return 0;
}
int main() {
    // Signal: processor is running
    dbg_set(DBG_RUNNING);
    
    // MSP RX state machine
    uint8_t msp_rx_buf[MSP_MAX_PAYLOAD + 16];
    uint8_t msp_tx_buf[MSP_MAX_PAYLOAD + 16];
    int msp_rx_idx = 0;
    int msp_expected_len = 0;
    int msp_state = 0;  // 0=wait '$', 1=wait 'M', 2=wait '<', 3=wait len, 4=collect
    
    // Signal: entering main loop
    dbg_set(DBG_LOOP);
    
    while (1) {
        dbgToggle(0x1);  // Toggle loop bit for activity indication
        // Check for USB UART RX data
        uint16_t mspChar = getMSPInChar();
        if (mspChar & RX_READY) 
        {
            uint8_t ch = mspChar & 0xFF;
            dbg_set(DBG_RX);
            
            // Simple MSP frame detection (MSPv1: $M<len cmd payload crc)
            switch (msp_state) 
            {
                case 0:  // Wait for '$'
                    if (ch == '$') {
                        msp_rx_buf[0] = ch;
                        msp_rx_idx = 1;
                        msp_state = 1;
                    }
                    break;
                case 1:  // Wait for 'M'
                    if (ch == 'M') {
                        msp_rx_buf[msp_rx_idx++] = ch;
                        msp_state = 2;
                    } else {
                        msp_state = 0;
                    }
                    break;
                case 2:  // Wait for '<' (request) or '>' (response)
                    if (ch == '<' || ch == '>') {
                        msp_rx_buf[msp_rx_idx++] = ch;
                        msp_state = 3;
                        dbg_set(DBG_MSP_START);
                    } else {
                        msp_state = 0;
                    }
                    break;
                case 3:  // Payload length
                    msp_rx_buf[msp_rx_idx++] = ch;
                    msp_expected_len = ch + 2;  // +cmd +crc
                    msp_state = 4;
                    break;
                case 4:  // Collect cmd + payload + crc
                    msp_rx_buf[msp_rx_idx++] = ch;
                    msp_expected_len--;
                    if (msp_expected_len == 0) {
                        dbg_set(DBG_MSP_DONE);
                        
                        // Full MSP frame received - process it
                        int tx_len = 0;
                        msp_bridge_loop(msp_rx_buf, msp_rx_idx, msp_tx_buf, &tx_len);
                        
                        // Send response
                        for (int i = 0; i < tx_len; i++) {
                            while (!(WB_USB_STATUS & WB_USB_TX_READY));
                            WB_USB_TX_DATA = msp_tx_buf[i];
                        }
                        
                        dbg_set(DBG_TX_DONE);
                        msp_state = 0;
                        msp_rx_idx = 0;
                    }
                    break;
                default:
                    msp_state = 0;
                    dbg_set(DBG_ERROR);
                    break;
            }
            
            // Return to loop state after processing
            dbg_set(DBG_LOOP);
        }
    }
    return 0;
}
