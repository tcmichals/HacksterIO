// MSP Loop implementation for VexRiscv
#include "msp_loop.hpp"
#include "msp_bridge.hpp"
#include "fourway.hpp"
#include "wb_regs.h"

#ifdef USE_FREERTOS
#include "FreeRTOS.h"
#include "task.h"
#endif

// Flag set by MSP_SET_PASSTHROUGH handler
volatile bool enter_passthrough_mode = false;

// Debug helper: output N pulses on debug GPIO bit 0
static inline void dbg_set(uint8_t val) {
    for (uint8_t i = 0; i < val; i++) {
        WB_DEBUG_GPIO_TGL = 0x01;
        WB_DEBUG_GPIO_TGL = 0x01;
    }
}

// Cached motor values for MSP_MOTOR response
static uint16_t cached_motors[4] = {0, 0, 0, 0};

// Convert MSP motor value (1000-2000 PWM range) to DSHOT throttle (0-2047)
static inline uint16_t msp_to_dshot_throttle(uint16_t msp_val) {
    if (msp_val <= 1000) return 0;
    if (msp_val >= 2000) return 2047;
    return 48 + ((msp_val - 1001) * (2047 - 48)) / (1999 - 1001);
}

// Update cached motor values and send to DSHOT hardware
void update_cached_motors(uint16_t m1, uint16_t m2, uint16_t m3, uint16_t m4) {
    cached_motors[0] = m1;
    cached_motors[1] = m2;
    cached_motors[2] = m3;
    cached_motors[3] = m4;
    
    // Ensure mux is in DSHOT mode
    mux_set_dshot();
    
    // Encode and write DSHOT values to hardware
    WB_DSHOT_MOTOR1 = dshot_encode(msp_to_dshot_throttle(m1), 0);
    WB_DSHOT_MOTOR2 = dshot_encode(msp_to_dshot_throttle(m2), 0);
    WB_DSHOT_MOTOR3 = dshot_encode(msp_to_dshot_throttle(m3), 0);
    WB_DSHOT_MOTOR4 = dshot_encode(msp_to_dshot_throttle(m4), 0);
}

int MspStateMachine::process_char(uint8_t ch, uint8_t* tx_buf) {
    switch (state_) {
    case MspState::WAIT_DOLLAR:
        if (ch == '$') {
            rx_buf_[0] = ch;
            rx_idx_ = 1;
            state_ = MspState::WAIT_M;
            dbg_set(DBG_RESET);
        }
        break;
        
    case MspState::WAIT_M:
        if (ch == 'M') {
            rx_buf_[rx_idx_++] = ch;
            dbg_set(DBG_RUNNING);
            state_ = MspState::WAIT_DIRECTION;
        } else {
            state_ = MspState::WAIT_DOLLAR;
        }
        break;
        
    case MspState::WAIT_DIRECTION:
        if (ch == '<' || ch == '>') {
            rx_buf_[rx_idx_++] = ch;
            state_ = MspState::READ_LENGTH;
            dbg_set(DBG_MSP_START);
        } else {
            state_ = MspState::WAIT_DOLLAR;
        }
        break;
        
    case MspState::READ_LENGTH:
        rx_buf_[rx_idx_++] = ch;
        payload_len_ = ch;
        payload_remaining_ = ch;
        state_ = MspState::READ_COMMAND;
        break;
        
    case MspState::READ_COMMAND:
        rx_buf_[rx_idx_++] = ch;
        if (payload_remaining_ > 0) {
            state_ = MspState::READ_PAYLOAD;
        } else {
            state_ = MspState::READ_CRC;
        }
        break;
        
    case MspState::READ_PAYLOAD:
        rx_buf_[rx_idx_++] = ch;
        payload_remaining_--;
        if (payload_remaining_ == 0) {
            state_ = MspState::READ_CRC;
        }
        break;
        
    case MspState::READ_CRC: {
        rx_buf_[rx_idx_++] = ch;
        dbg_set(DBG_MSP_DONE);
        
        int tx_len = 0;
        msp_bridge_loop(rx_buf_, rx_idx_, tx_buf, &tx_len);
        
        state_ = MspState::WAIT_DOLLAR;
        rx_idx_ = 0;
        
        return tx_len;
    }
    
    default:
        state_ = MspState::WAIT_DOLLAR;
        dbg_set(DBG_ERROR);
        break;
    }
    return 0;
}

// Hardware UART helpers
static inline uint16_t getMSPInChar() {
    uint32_t status = WB_USB_STATUS;
    if (status & WB_USB_RX_VALID) {
        return (WB_USB_RX_DATA & 0xFF) | 0x0100;
    }
    return 0;
}

static inline void sendMSPOut(const uint8_t* buf, int len) {
    for (int i = 0; i < len; i++) {
        usb_putchar(buf[i]);
    }
}

// Blocking MSP loop - never returns
void msp_loop() {
    MspStateMachine sm;
    uint8_t tx_buf[MSP_MAX_PAYLOAD + 16];
    
    // Ensure mux is in DSHOT mode
    mux_set_dshot();
    
    while (1) {
        // Process MSP UART input
        uint16_t ch = getMSPInChar();
        if (ch & 0x0100) {
            dbg_set(DBG_RX);
            uint8_t rx_ch = ch & 0xFF;
    
            int tx_len = sm.process_char(rx_ch, tx_buf);
            if (tx_len > 0) {
                sendMSPOut(tx_buf, tx_len);
                dbg_set(DBG_TX_DONE);
                
                // Check if passthrough mode requested
                if (enter_passthrough_mode) {
                    enter_passthrough_mode = false;
                    fourway_loop();
                }
            }
        }
        
#ifdef USE_FREERTOS
        // Yield to other tasks in FreeRTOS mode
        taskYIELD();
#endif
    }
}
