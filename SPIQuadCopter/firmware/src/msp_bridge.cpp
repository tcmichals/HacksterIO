// MSP protocol and bridge implementation for VexRiscv firmware
#include "msp_bridge.hpp"
#include "wb_regs.h"
#include <cstring>

// External flag for passthrough mode
extern volatile bool enter_passthrough_mode;

// Motor values storage
static uint16_t motor_values[4] = {0, 0, 0, 0};

// CRC calculation for MSP (XOR of payload_size, cmd, payload)
static uint8_t msp_crc(const msp_packet_t* pkt) {
    uint8_t crc = pkt->payload_size ^ pkt->cmd;
    for (uint8_t i = 0; i < pkt->payload_size; i++)
        crc ^= pkt->payload[i];
    return crc;
}

// ============================================================================
// MSP Response Handlers
// ============================================================================

static void msp_api_version_handler(const msp_packet_t* req, msp_packet_t* resp) {
    (void)req;
    resp->payload_size = 3;
    resp->payload[0] = 0;    // MSP protocol version
    resp->payload[1] = 1;    // API major version
    resp->payload[2] = 46;   // API minor version
}

static void msp_fc_variant_handler(const msp_packet_t* req, msp_packet_t* resp) {
    (void)req;
    resp->payload_size = 4;
    resp->payload[0] = 'B';
    resp->payload[1] = 'T';
    resp->payload[2] = 'F';
    resp->payload[3] = 'L';
}

static void msp_fc_version_handler(const msp_packet_t* req, msp_packet_t* resp) {
    (void)req;
    resp->payload_size = 3;
    resp->payload[0] = 4;    // Major
    resp->payload[1] = 5;    // Minor
    resp->payload[2] = 0;    // Patch
}

static void msp_board_info_handler(const msp_packet_t* req, msp_packet_t* resp) {
    (void)req;
    resp->payload_size = 6;
    resp->payload[0] = 'V';  // "VEX_"
    resp->payload[1] = 'E';
    resp->payload[2] = 'X';
    resp->payload[3] = '_';
    resp->payload[4] = 0;
    resp->payload[5] = 0;
}

static void msp_build_info_handler(const msp_packet_t* req, msp_packet_t* resp) {
    (void)req;
    resp->payload_size = 19;
    const char* date = "Mar 10 2026";
    const char* time = "12:00:00";
    for (int i = 0; i < 11; i++) resp->payload[i] = date[i];
    for (int i = 0; i < 8; i++) resp->payload[11 + i] = time[i];
}

static void msp_feature_config_handler(const msp_packet_t* req, msp_packet_t* resp) {
    (void)req;
    resp->payload_size = 4;
    std::memset(resp->payload, 0, 4);
}

static void msp_ident_handler(const msp_packet_t* req, msp_packet_t* resp) {
    (void)req;
    resp->payload_size = 7;
    std::memset(resp->payload, 0, 7);
}

static void msp_status_handler(const msp_packet_t* req, msp_packet_t* resp) {
    (void)req;
    resp->payload_size = 10;
    std::memset(resp->payload, 0, 10);
}

static void msp_motor_handler(const msp_packet_t* req, msp_packet_t* resp) {
    (void)req;
    uint16_t m1, m2, m3, m4;
    get_motors(&m1, &m2, &m3, &m4);
    
    resp->payload_size = 8;
    resp->payload[0] = m1 & 0xFF;
    resp->payload[1] = (m1 >> 8) & 0xFF;
    resp->payload[2] = m2 & 0xFF;
    resp->payload[3] = (m2 >> 8) & 0xFF;
    resp->payload[4] = m3 & 0xFF;
    resp->payload[5] = (m3 >> 8) & 0xFF;
    resp->payload[6] = m4 & 0xFF;
    resp->payload[7] = (m4 >> 8) & 0xFF;
}

static void msp_uid_handler(const msp_packet_t* req, msp_packet_t* resp) {
    (void)req;
    resp->payload_size = 12;
    resp->payload[0] = 'V';
    resp->payload[1] = 'E';
    resp->payload[2] = 'X';
    resp->payload[3] = '1';
    std::memset(&resp->payload[4], 0, 8);
}

static void msp_battery_state_handler(const msp_packet_t* req, msp_packet_t* resp) {
    (void)req;
    resp->payload_size = 9;
    std::memset(resp->payload, 0, 9);
}

static void msp_set_passthrough_handler(const msp_packet_t* req, msp_packet_t* resp) {
    (void)req;
    resp->payload_size = 1;
    resp->payload[0] = 4;  // 4 ESCs connected
    enter_passthrough_mode = true;
}

static void msp_debug_handler(const msp_packet_t* req, msp_packet_t* resp) {
    (void)req;
    resp->payload_size = 4;
    resp->payload[0] = 0xDE;
    resp->payload[1] = 0xAD;
    resp->payload[2] = 0xBE;
    resp->payload[3] = 0xEF;
}

// ============================================================================
// Motor Control
// ============================================================================

void get_motors(uint16_t* m1, uint16_t* m2, uint16_t* m3, uint16_t* m4) {
    *m1 = motor_values[0];
    *m2 = motor_values[1];
    *m3 = motor_values[2];
    *m4 = motor_values[3];
}

void set_motors(uint16_t m1, uint16_t m2, uint16_t m3, uint16_t m4) {
    motor_values[0] = m1;
    motor_values[1] = m2;
    motor_values[2] = m3;
    motor_values[3] = m4;
    update_cached_motors(m1, m2, m3, m4);
}

// ============================================================================
// MSP Command Dispatch
// ============================================================================

// Handler table
static const msp_response_entry_t msp_handlers[] = {
    { MSP_API_VERSION,    3,  msp_api_version_handler },
    { MSP_FC_VARIANT,     4,  msp_fc_variant_handler },
    { MSP_FC_VERSION,     3,  msp_fc_version_handler },
    { MSP_BOARD_INFO,     6,  msp_board_info_handler },
    { MSP_BUILD_INFO,     19, msp_build_info_handler },
    { MSP_FEATURE_CONFIG, 4,  msp_feature_config_handler },
    { MSP_IDENT,          7,  msp_ident_handler },
    { MSP_STATUS,         10, msp_status_handler },
    { MSP_MOTOR,          8,  msp_motor_handler },
    { MSP_UID,            12, msp_uid_handler },
    { MSP_BATTERY_STATE,  9,  msp_battery_state_handler },
    { MSP_SET_PASSTHROUGH, 1, msp_set_passthrough_handler },
    { MSP_DEBUG,          4,  msp_debug_handler },
};

static constexpr int NUM_HANDLERS = sizeof(msp_handlers) / sizeof(msp_handlers[0]);

void msp_bridge_loop(uint8_t* rx_buffer, int rx_len, uint8_t* tx_buffer, int* tx_len) {
    *tx_len = 0;
    
    if (rx_len < 6) return;  // Minimum: $M< + len + cmd + crc
    
    // Parse incoming packet
    msp_packet_t req;
    req.header[0] = rx_buffer[0];
    req.header[1] = rx_buffer[1];
    req.header[2] = rx_buffer[2];
    req.payload_size = rx_buffer[3];
    req.cmd = rx_buffer[4];
    
    for (int i = 0; i < req.payload_size && i < MSP_MAX_PAYLOAD; i++) {
        req.payload[i] = rx_buffer[5 + i];
    }
    req.crc = rx_buffer[5 + req.payload_size];
    
    // Verify CRC
    uint8_t expected_crc = msp_crc(&req);
    if (expected_crc != req.crc) {
        return;  // Bad CRC
    }
    
    // Find handler
    msp_packet_t resp;
    resp.cmd = req.cmd;
    resp.payload_size = 0;
    
    bool handled = false;
    for (int i = 0; i < NUM_HANDLERS; i++) {
        if (msp_handlers[i].cmd == req.cmd) {
            msp_handlers[i].handler(&req, &resp);
            handled = true;
            break;
        }
    }
    
    if (!handled) {
        return;  // Unknown command
    }
    
    // Build response: $M> + len + cmd + payload + crc
    tx_buffer[0] = '$';
    tx_buffer[1] = 'M';
    tx_buffer[2] = '>';
    tx_buffer[3] = resp.payload_size;
    tx_buffer[4] = resp.cmd;
    
    for (int i = 0; i < resp.payload_size; i++) {
        tx_buffer[5 + i] = resp.payload[i];
    }
    
    // Calculate response CRC
    uint8_t resp_crc = resp.payload_size ^ resp.cmd;
    for (int i = 0; i < resp.payload_size; i++) {
        resp_crc ^= resp.payload[i];
    }
    tx_buffer[5 + resp.payload_size] = resp_crc;
    
    *tx_len = 6 + resp.payload_size;
}
