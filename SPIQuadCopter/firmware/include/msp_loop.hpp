// MSP Loop - UART RX state machine and framing
#ifndef MSP_LOOP_HPP
#define MSP_LOOP_HPP

#include <stdint.h>
#include "msp_bridge.hpp"

// Debug state values - toggle count patterns for GPIO
// Each value = number of toggle pulses to output (visible on scope)
constexpr uint8_t DBG_RESET     = 1;
constexpr uint8_t DBG_RUNNING   = 2;
constexpr uint8_t DBG_LOOP      = 3;
constexpr uint8_t DBG_RX        = 4;
constexpr uint8_t DBG_MSP_START = 5;
constexpr uint8_t DBG_MSP_DONE  = 6;
constexpr uint8_t DBG_TX_DONE   = 7;
constexpr uint8_t DBG_ERROR     = 8;

// MSP parsing state machine states
enum class MspState {
    WAIT_DOLLAR,      // Waiting for '$' start character
    WAIT_M,           // Waiting for 'M'
    WAIT_DIRECTION,   // Waiting for '<' or '>'
    READ_LENGTH,      // Reading payload length byte
    READ_COMMAND,     // Reading command byte
    READ_PAYLOAD,     // Collecting payload bytes (if any)
    READ_CRC          // Reading CRC byte and validating frame
};

// MSP RX state machine - processes one character at a time
// Returns: number of bytes in tx_buf when frame complete, 0 otherwise
class MspStateMachine {
public:
    MspStateMachine() 
        : state_(MspState::WAIT_DOLLAR)
        , rx_idx_(0)
        , payload_len_(0)
        , payload_remaining_(0) 
    {}
    
    // Process one received character
    // Returns tx_len > 0 when a complete frame has been processed and response is ready
    int process_char(uint8_t ch, uint8_t* tx_buf);
    
    // Get current state for debug
    MspState get_state() const { return state_; }
    
    // Reset state machine
    void reset() { 
        state_ = MspState::WAIT_DOLLAR; 
        rx_idx_ = 0; 
        payload_len_ = 0; 
        payload_remaining_ = 0; 
    }
    
private:
    uint8_t rx_buf_[MSP_MAX_PAYLOAD + 16];
    MspState state_;
    int rx_idx_;
    int payload_len_;
    int payload_remaining_;
};

// Blocking MSP loop (for embedded use) - never returns
void msp_loop();

#endif // MSP_LOOP_HPP
