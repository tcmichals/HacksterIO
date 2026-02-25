// MSP protocol definitions for SERV firmware (C++)
#ifndef MSP_BRIDGE_HPP
#define MSP_BRIDGE_HPP

// Use C headers for bare-metal toolchain compatibility
#include <stdint.h>

// MSP framing constants
#define MSP_HEADER1 '$'
#define MSP_HEADER2 'M'
#define MSP_HEADER3 '<'
#define MSP_HEADER3_RESP '>'
#define MSP_MAX_PAYLOAD 64

// MSP command codes (example subset)
enum {
    MSP_IDENT      = 100,
    MSP_STATUS     = 101,
    MSP_RAW_IMU    = 102,
    MSP_SERVO      = 103,
    MSP_MOTOR      = 104,
    MSP_RC         = 105,
    MSP_SET_RAW_RC = 200,
    MSP_SET_MOTOR  = 214,
    MSP_SET_SERVO  = 212,
    MSP_DEBUG      = 254,
};

// MSP packet structure
typedef struct {
    uint8_t header[3];
    uint8_t payload_size;
    uint8_t cmd;
    uint8_t payload[MSP_MAX_PAYLOAD];
    uint8_t crc;
} msp_packet_t;

typedef struct {
    uint8_t cmd;
    uint8_t payload_size;
    void (*handler)(const msp_packet_t* req, msp_packet_t* resp);
} msp_response_entry_t;

// MSP bridge main processing function
// Parses rx_buffer, processes MSP commands, fills tx_buffer with response
void msp_bridge_loop(uint8_t* rx_buffer, int rx_len, uint8_t* tx_buffer, int* tx_len);

#endif // MSP_BRIDGE_HPP
