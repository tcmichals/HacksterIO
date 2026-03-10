// MSP protocol and bridge implementation for SERV firmware (C++)
#include "msp_bridge.hpp"
#include "wb_regs.h"
#include <stddef.h>
#include <cstring>

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
    std::memset(resp->payload, 0, 10); // Example: fill with zeros
}

void msp_debug_handler(const msp_packet_t* req, msp_packet_t* resp) {
    resp->payload_size = 4;
    resp->payload[0] = 0xDE;
    resp->payload[1] = 0xAD;
    resp->payload[2] = 0xBE;
    resp->payload[3] = 0xEF;
}

// =========================================================================
// ESC Configurator Discovery Handlers
// =========================================================================

// MSP_API_VERSION (1) - First command sent by ESC Configurator
void msp_api_version_handler(const msp_packet_t* req, msp_packet_t* resp) {
    resp->payload_size = 3;
    resp->payload[0] = 0;    // MSP protocol version
    resp->payload[1] = 1;    // API major version  
    resp->payload[2] = 46;   // API minor version (1.46 is modern)
}

// MSP_FC_VARIANT (2) - Flight controller identifier
void msp_fc_variant_handler(const msp_packet_t* req, msp_packet_t* resp) {
    resp->payload_size = 4;
    resp->payload[0] = 'B';  // "BTFL" = Betaflight compatible
    resp->payload[1] = 'T';
    resp->payload[2] = 'F';
    resp->payload[3] = 'L';
}

// MSP_FC_VERSION (3) - Firmware version
void msp_fc_version_handler(const msp_packet_t* req, msp_packet_t* resp) {
    resp->payload_size = 3;
    resp->payload[0] = 4;    // Major (4.5.0)
    resp->payload[1] = 5;    // Minor
    resp->payload[2] = 0;    // Patch
}

// MSP_BOARD_INFO (4) - Board identifier
void msp_board_info_handler(const msp_packet_t* req, msp_packet_t* resp) {
    resp->payload_size = 6;
    resp->payload[0] = 'T';  // Board ID "T9K_"
    resp->payload[1] = '9';
    resp->payload[2] = 'K';
    resp->payload[3] = '_';
    resp->payload[4] = 0;    // Hardware revision
    resp->payload[5] = 0;
}

// MSP_BUILD_INFO (5) - Build date/time
void msp_build_info_handler(const msp_packet_t* req, msp_packet_t* resp) {
    resp->payload_size = 19;
    // Date: "Mar 07 2026" (11 chars)
    const char* date = "Mar 07 2026";
    const char* time = "12:00:00";  // 8 chars
    for (int i = 0; i < 11; i++) resp->payload[i] = date[i];
    for (int i = 0; i < 8; i++) resp->payload[11 + i] = time[i];
}

// MSP_FEATURE_CONFIG (36) - Feature flags
void msp_feature_config_handler(const msp_packet_t* req, msp_packet_t* resp) {
    resp->payload_size = 4;
    resp->payload[0] = 0;    // Features bitmap (no special features)
    resp->payload[1] = 0;
    resp->payload[2] = 0;
    resp->payload[3] = 0;
}

// MSP_MOTOR (104) - Get motor values
void msp_motor_handler(const msp_packet_t* req, msp_packet_t* resp) {
    uint16_t m1, m2, m3, m4;
    get_motors(&m1, &m2, &m3, &m4);
    
    resp->payload_size = 8;  // 4 motors × 2 bytes
    resp->payload[0] = m1 & 0xFF;
    resp->payload[1] = (m1 >> 8) & 0xFF;
    resp->payload[2] = m2 & 0xFF;
    resp->payload[3] = (m2 >> 8) & 0xFF;
    resp->payload[4] = m3 & 0xFF;
    resp->payload[5] = (m3 >> 8) & 0xFF;
    resp->payload[6] = m4 & 0xFF;
    resp->payload[7] = (m4 >> 8) & 0xFF;
}

// MSP_UID (160) - Unique device ID
void msp_uid_handler(const msp_packet_t* req, msp_packet_t* resp) {
    resp->payload_size = 12;
    // 3 x uint32 unique ID (fake values)
    resp->payload[0] = 0x54;  // "T9K1"
    resp->payload[1] = 0x39;
    resp->payload[2] = 0x4B;
    resp->payload[3] = 0x31;
    resp->payload[4] = 0x00;
    resp->payload[5] = 0x00;
    resp->payload[6] = 0x00;
    resp->payload[7] = 0x01;
    resp->payload[8] = 0x00;
    resp->payload[9] = 0x00;
    resp->payload[10] = 0x00;
    resp->payload[11] = 0x02;
}

// MSP_BATTERY_STATE (130) - Battery status (polled by ESC Configurator)
void msp_battery_state_handler(const msp_packet_t* req, msp_packet_t* resp) {
    resp->payload_size = 9;  // Match Betaflight format
    resp->payload[0] = 0;    // cells
    resp->payload[1] = 0;    // capacity LSB
    resp->payload[2] = 0;    // capacity MSB
    resp->payload[3] = 0;    // voltage (0.1V units)
    resp->payload[4] = 0;    // mAh drawn LSB
    resp->payload[5] = 0;    // mAh drawn MSB
    resp->payload[6] = 0;    // Amps LSB
    resp->payload[7] = 0;    // Amps MSB
    resp->payload[8] = 0;    // battery state (0=OK)
}

// Flag to enter passthrough mode (checked by msp_loop after sending response)
extern volatile bool enter_passthrough_mode;

// MSP_SET_PASSTHROUGH (245) - Enter ESC passthrough mode
void msp_set_passthrough_handler(const msp_packet_t* req, msp_packet_t* resp) {
    // Report 4 ESCs connected, then flag for passthrough entry
    resp->payload_size = 1;
    resp->payload[0] = 4;    // Number of connected ESCs
    enter_passthrough_mode = true;  // msp_loop will call fourway_loop after sending response
}

// Motor values - stored for access/observation
static uint16_t motor_values[4] = {0, 0, 0, 0};

// Get motor values (for testing/debug)
void get_motors(uint16_t* m1, uint16_t* m2, uint16_t* m3, uint16_t* m4) {
    *m1 = motor_values[0];
    *m2 = motor_values[1];
    *m3 = motor_values[2];
    *m4 = motor_values[3];
}

// Motor control function - can be mocked for testing
#ifdef TEST_HOST
extern uint32_t mock_dshot_motor1;
extern uint32_t mock_dshot_motor2;
extern uint32_t mock_dshot_motor3;
extern uint32_t mock_dshot_motor4;

void set_motors(uint16_t m1, uint16_t m2, uint16_t m3, uint16_t m4) {
    motor_values[0] = m1;
    motor_values[1] = m2;
    motor_values[2] = m3;
    motor_values[3] = m4;
    mock_dshot_motor1 = m1;
    mock_dshot_motor2 = m2;
    mock_dshot_motor3 = m3;
    mock_dshot_motor4 = m4;
}
#else
// Extern declaration for cached motor update (defined in msp_loop.cpp)
extern void update_cached_motors(uint16_t m1, uint16_t m2, uint16_t m3, uint16_t m4);

void set_motors(uint16_t m1, uint16_t m2, uint16_t m3, uint16_t m4) {
    motor_values[0] = m1;
    motor_values[1] = m2;
    motor_values[2] = m3;
    motor_values[3] = m4;
    
    // Update cached values for auto-repeat (msp_loop handles 8kHz output)
    update_cached_motors(m1, m2, m3, m4);
}
#endif

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
        
        set_motors(m1, m2, m3, m4);
    }
    resp->payload_size = 0;
}

// Response table - must include all commands ESC Configurator needs
msp_response_entry_t msp_response_table[] = {
    // Discovery commands (ESC Configurator connection sequence)
    {MSP_API_VERSION,     3,  msp_api_version_handler},
    {MSP_FC_VARIANT,      4,  msp_fc_variant_handler},
    {MSP_FC_VERSION,      3,  msp_fc_version_handler},
    {MSP_BOARD_INFO,      6,  msp_board_info_handler},
    {MSP_BUILD_INFO,      19, msp_build_info_handler},
    {MSP_FEATURE_CONFIG,  4,  msp_feature_config_handler},
    {MSP_UID,             12, msp_uid_handler},
    {MSP_MOTOR,           8,  msp_motor_handler},
    {MSP_SET_PASSTHROUGH, 1,  msp_set_passthrough_handler},
    {MSP_BATTERY_STATE,   9,  msp_battery_state_handler},
    
    // Standard Multiwii commands
    {MSP_IDENT,           7,  msp_ident_handler},
    {MSP_STATUS,          10, msp_status_handler},
    {MSP_SET_MOTOR,       0,  msp_set_motor_handler},
    {MSP_DEBUG,           4,  msp_debug_handler},
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
            *state = 0;  // Reset for next packet
            return 1;    // Packet complete!
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
