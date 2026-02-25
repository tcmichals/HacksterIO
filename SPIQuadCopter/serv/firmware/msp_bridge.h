// MSP protocol definitions for SERV firmware
#ifndef MSP_BRIDGE_H
#define MSP_BRIDGE_H

#include <stdint.h>

// MSP framing constants
#define MSP_HEADER1 '$'
#define MSP_HEADER2 'M'
#define MSP_HEADER3 '<'   // Host-to-device
#define MSP_HEADER3_RESP '>' // Device-to-host

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
    uint8_t header[3];   // '$','M','<' or '>'
    uint8_t payload_size;
    uint8_t cmd;
    uint8_t payload[MSP_MAX_PAYLOAD];
    uint8_t crc;
} msp_packet_t;

// Response table entry
typedef struct {
    uint8_t cmd;
    uint8_t payload_size;
    void (*handler)(const msp_packet_t* req, msp_packet_t* resp);
} msp_response_entry_t;

#endif // MSP_BRIDGE_H
