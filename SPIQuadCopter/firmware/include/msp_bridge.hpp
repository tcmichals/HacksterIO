// MSP protocol definitions for VexRiscv firmware (C++)
#ifndef MSP_BRIDGE_HPP
#define MSP_BRIDGE_HPP

#include <stdint.h>

// MSP framing constants
constexpr uint8_t MSP_HEADER1     = '$';
constexpr uint8_t MSP_HEADER2     = 'M';
constexpr uint8_t MSP_HEADER3     = '<';
constexpr uint8_t MSP_HEADER3_RESP = '>';
constexpr int MSP_MAX_PAYLOAD     = 64;

// MSP command codes - ESC Configurator connection sequence
enum MspCommand : uint8_t {
    // Discovery commands (sent first by ESC Configurator)
    MSP_API_VERSION    = 1,
    MSP_FC_VARIANT     = 2,
    MSP_FC_VERSION     = 3,
    MSP_BOARD_INFO     = 4,
    MSP_BUILD_INFO     = 5,
    MSP_FEATURE_CONFIG = 36,
    
    // Standard Multiwii commands
    MSP_IDENT          = 100,
    MSP_STATUS         = 101,
    MSP_RAW_IMU        = 102,
    MSP_SERVO          = 103,
    MSP_MOTOR          = 104,
    MSP_RC             = 105,
    MSP_UID            = 160,
    MSP_SET_RAW_RC     = 200,
    MSP_SET_MOTOR      = 214,
    MSP_SET_SERVO      = 212,
    
    // Battery/status
    MSP_BATTERY_STATE  = 130,
    
    // BLHeli passthrough
    MSP_SET_PASSTHROUGH = 245,
    
    MSP_DEBUG          = 254,
};

// MSP packet structure
struct msp_packet_t {
    uint8_t header[3];
    uint8_t payload_size;
    uint8_t cmd;
    uint8_t payload[MSP_MAX_PAYLOAD];
    uint8_t crc;
};

// MSP response handler type
using msp_handler_t = void (*)(const msp_packet_t* req, msp_packet_t* resp);

struct msp_response_entry_t {
    uint8_t cmd;
    uint8_t payload_size;
    msp_handler_t handler;
};

// MSP bridge main processing function
// Parses rx_buffer, processes MSP commands, fills tx_buffer with response
void msp_bridge_loop(uint8_t* rx_buffer, int rx_len, uint8_t* tx_buffer, int* tx_len);

// Motor control functions
void set_motors(uint16_t m1, uint16_t m2, uint16_t m3, uint16_t m4);
void get_motors(uint16_t* m1, uint16_t* m2, uint16_t* m3, uint16_t* m4);

// Update cached motor values (called from msp_bridge on MSP_SET_MOTOR)
void update_cached_motors(uint16_t m1, uint16_t m2, uint16_t m3, uint16_t m4);

#endif // MSP_BRIDGE_HPP
