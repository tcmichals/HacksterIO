// MSP protocol and bridge implementation for SERV firmware (C++)
#include "msp_bridge.hpp"
#include "wb_regs.h"
#include <stddef.h>
// Minimal memset for bare-metal toolchains
static void *my_memset(void *s, int c, size_t n) {
    unsigned char *p = (unsigned char *)s;
    while (n--) *p++ = (unsigned char)c;
    return s;
}

// CRC calculation for MSP (XOR of payload_size, cmd, payload)
uint8_t msp_crc(const msp_packet_t* pkt) {
    uint8_t crc = pkt->payload_size ^ pkt->cmd;
    for (uint8_t i = 0; i < pkt->payload_size; i++)
        crc ^= pkt->payload[i];
    return crc;
}

// Example response handlers
void msp_ident_handler(const msp_packet_t* req, msp_packet_t* resp) {
    resp->payload_size = 7;
    resp->payload[0] = 0; // Version
    resp->payload[1] = 0; // Type
    resp->payload[2] = 0; // MultiType
    resp->payload[3] = 0; // MSP Version
    resp->payload[4] = 0; // Capability
    resp->payload[5] = 0; // Reserved
    resp->payload[6] = 0; // Reserved
}

void msp_status_handler(const msp_packet_t* req, msp_packet_t* resp) {
    resp->payload_size = 10;
    my_memset(resp->payload, 0, 10); // Example: fill with zeros
}

void msp_debug_handler(const msp_packet_t* req, msp_packet_t* resp) {
    resp->payload_size = 4;
    resp->payload[0] = 0xDE;
    resp->payload[1] = 0xAD;
    resp->payload[2] = 0xBE;
    resp->payload[3] = 0xEF;
}

// MSP_SET_MOTOR handler - write motor values to DSHOT controller
// DSHOT is shared between SERV and SPI buses via arbiter
void msp_set_motor_handler(const msp_packet_t* req, msp_packet_t* resp) {
    // MSP_SET_MOTOR payload: 16-bit throttle values for each motor (little-endian)
    // Payload size should be 8 bytes for 4 motors (2 bytes each)
    if (req->payload_size >= 8) {
        // Extract 16-bit motor values (little-endian)
        uint16_t m1 = req->payload[0] | (req->payload[1] << 8);
        uint16_t m2 = req->payload[2] | (req->payload[3] << 8);
        uint16_t m3 = req->payload[4] | (req->payload[5] << 8);
        uint16_t m4 = req->payload[6] | (req->payload[7] << 8);
        
        // Write to DSHOT controller (values 0-2047 for throttle)
        WB_DSHOT_MOTOR1 = m1;
        WB_DSHOT_MOTOR2 = m2;
        WB_DSHOT_MOTOR3 = m3;
        WB_DSHOT_MOTOR4 = m4;
    }
    resp->payload_size = 0;
}

// Response table
msp_response_entry_t msp_response_table[] = {
    {MSP_IDENT,      7,  msp_ident_handler},
    {MSP_STATUS,     10, msp_status_handler},
    {MSP_DEBUG,      4,  msp_debug_handler},
    {MSP_SET_MOTOR,  4,  msp_set_motor_handler},
    // Add more handlers as needed
};

constexpr int MSP_RESPONSE_TABLE_SIZE = sizeof(msp_response_table)/sizeof(msp_response_entry_t);

// MSP packet parser (state machine)
int msp_parse_byte(uint8_t byte, msp_packet_t* pkt, int* state, int* index) {
    switch (*state) {
        case 0: // Header1
            if (byte == MSP_HEADER1) { *state = 1; *index = 0; }
            break;
        case 1: // Header2
            if (byte == MSP_HEADER2) { *state = 2; }
            else *state = 0;
            break;
        case 2: // Header3
            if (byte == MSP_HEADER3) { *state = 3; }
            else *state = 0;
            break;
        case 3: // Payload size
            pkt->payload_size = byte;
            *state = 4;
            break;
        case 4: // Command
            pkt->cmd = byte;
            *index = 0;
            *state = (pkt->payload_size > 0) ? 5 : 6;
            break;
        case 5: // Payload
            pkt->payload[*index] = byte;
            (*index)++;
            if (*index >= pkt->payload_size) *state = 6;
            break;
        case 6: // CRC
            pkt->crc = byte;
            *state = 7;
            break;
        case 7: // Done
            *state = 0;
            return 1; // Packet complete
    }
    return 0;
}

// MSP bridge main loop (example)
void msp_bridge_loop(uint8_t* rx_buffer, int rx_len, uint8_t* tx_buffer, int* tx_len) {
    static msp_packet_t req, resp;
    static int state = 0, index = 0;
    for (int i = 0; i < rx_len; i++) {
        if (msp_parse_byte(rx_buffer[i], &req, &state, &index)) {
            // Validate CRC
            if (req.crc == msp_crc(&req)) {
                // Find handler
                for (int j = 0; j < MSP_RESPONSE_TABLE_SIZE; j++) {
                    if (msp_response_table[j].cmd == req.cmd) {
                        // Prepare response
                        resp.header[0] = MSP_HEADER1;
                        resp.header[1] = MSP_HEADER2;
                        resp.header[2] = MSP_HEADER3_RESP;
                        resp.cmd = req.cmd;
                        msp_response_table[j].handler(&req, &resp);
                        resp.crc = msp_crc(&resp);
                        // Serialize response
                        int k = 0;
                        tx_buffer[k++] = resp.header[0];
                        tx_buffer[k++] = resp.header[1];
                        tx_buffer[k++] = resp.header[2];
                        tx_buffer[k++] = resp.payload_size;
                        tx_buffer[k++] = resp.cmd;
                        for (int m = 0; m < resp.payload_size; m++)
                            tx_buffer[k++] = resp.payload[m];
                        tx_buffer[k++] = resp.crc;
                        *tx_len = k;
                        return;
                    }
                }
            }
        }
    }
}
