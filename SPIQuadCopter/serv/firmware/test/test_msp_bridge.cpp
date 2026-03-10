// Test harness for MSP bridge - compile and run on Linux
// Build: g++ -std=c++17 -I.. -o test_msp test_msp_bridge.cpp ../msp_bridge.cpp ../msp_loop.cpp -DTEST_HOST
// Run: ./test_msp

#include <iostream>
#include <iomanip>
#include <cstring>
#include <cstdint>
#include <cassert>
#include <vector>

// Mock hardware registers (defined before including headers)
uint32_t mock_dshot_motor1 = 0;
uint32_t mock_dshot_motor2 = 0;
uint32_t mock_dshot_motor3 = 0;
uint32_t mock_dshot_motor4 = 0;

#include "msp_bridge.hpp"
#include "msp_loop.hpp"

// ============================================================================
// MSP Frame Builder
// ============================================================================

std::vector<uint8_t> build_msp_frame(uint8_t cmd, const std::vector<uint8_t>& payload = {}) {
    std::vector<uint8_t> frame;
    frame.push_back('$');
    frame.push_back('M');
    frame.push_back('<');  // Request direction
    frame.push_back(static_cast<uint8_t>(payload.size()));
    frame.push_back(cmd);
    
    uint8_t crc = payload.size() ^ cmd;
    for (uint8_t b : payload) {
        frame.push_back(b);
        crc ^= b;
    }
    frame.push_back(crc);
    
    return frame;
}

// Parse MSP response and validate
struct MSPResponse {
    bool valid;
    uint8_t cmd;
    uint8_t size;
    std::vector<uint8_t> payload;
    uint8_t crc;
    bool crc_ok;
};

MSPResponse parse_msp_response(const uint8_t* data, int len) {
    MSPResponse resp{};
    if (len < 6) {
        resp.valid = false;
        return resp;
    }
    
    if (data[0] != '$' || data[1] != 'M' || data[2] != '>') {
        resp.valid = false;
        return resp;
    }
    
    resp.size = data[3];
    resp.cmd = data[4];
    
    if (len < 6 + resp.size) {
        resp.valid = false;
        return resp;
    }
    
    uint8_t calc_crc = resp.size ^ resp.cmd;
    for (int i = 0; i < resp.size; i++) {
        resp.payload.push_back(data[5 + i]);
        calc_crc ^= data[5 + i];
    }
    
    resp.crc = data[5 + resp.size];
    resp.crc_ok = (resp.crc == calc_crc);
    resp.valid = true;
    
    return resp;
}

// ============================================================================
// Hex dump helper
// ============================================================================

void hexdump(const char* label, const uint8_t* data, int len) {
    std::cout << label << " [" << len << " bytes]: ";
    for (int i = 0; i < len; i++) {
        std::cout << std::hex << std::setw(2) << std::setfill('0') << (int)data[i] << " ";
    }
    std::cout << std::dec << std::endl;
}

void hexdump(const char* label, const std::vector<uint8_t>& data) {
    hexdump(label, data.data(), data.size());
}

// ============================================================================
// Test Cases
// ============================================================================

int tests_passed = 0;
int tests_failed = 0;

#define TEST(name) void test_##name()
#define RUN_TEST(name) do { \
    std::cout << "Running " << #name << "... "; \
    try { test_##name(); tests_passed++; std::cout << "PASS\n"; } \
    catch (const std::exception& e) { tests_failed++; std::cout << "FAIL: " << e.what() << "\n"; } \
} while(0)

#define ASSERT(cond) do { if (!(cond)) throw std::runtime_error(#cond); } while(0)

TEST(msp_ident) {
    // Build MSP_IDENT request (cmd=100, no payload)
    auto frame = build_msp_frame(MSP_IDENT);
    hexdump("TX", frame);
    
    uint8_t tx_buf[128];
    int tx_len = 0;
    
    msp_bridge_loop(frame.data(), frame.size(), tx_buf, &tx_len);
    
    hexdump("RX", tx_buf, tx_len);
    
    ASSERT(tx_len > 0);
    
    auto resp = parse_msp_response(tx_buf, tx_len);
    ASSERT(resp.valid);
    ASSERT(resp.crc_ok);
    ASSERT(resp.cmd == MSP_IDENT);
    ASSERT(resp.size == 7);
    
    std::cout << "\n  Response: cmd=" << (int)resp.cmd << " size=" << (int)resp.size 
              << " crc_ok=" << resp.crc_ok << " ";
}

TEST(msp_status) {
    auto frame = build_msp_frame(MSP_STATUS);
    hexdump("TX", frame);
    
    uint8_t tx_buf[128];
    int tx_len = 0;
    
    msp_bridge_loop(frame.data(), frame.size(), tx_buf, &tx_len);
    
    hexdump("RX", tx_buf, tx_len);
    
    ASSERT(tx_len > 0);
    
    auto resp = parse_msp_response(tx_buf, tx_len);
    ASSERT(resp.valid);
    ASSERT(resp.crc_ok);
    ASSERT(resp.cmd == MSP_STATUS);
    ASSERT(resp.size == 10);
    
    std::cout << "\n  Response: cmd=" << (int)resp.cmd << " size=" << (int)resp.size 
              << " crc_ok=" << resp.crc_ok << " ";
}

TEST(msp_debug) {
    auto frame = build_msp_frame(MSP_DEBUG);
    hexdump("TX", frame);
    
    uint8_t tx_buf[128];
    int tx_len = 0;
    
    msp_bridge_loop(frame.data(), frame.size(), tx_buf, &tx_len);
    
    hexdump("RX", tx_buf, tx_len);
    
    ASSERT(tx_len > 0);
    
    auto resp = parse_msp_response(tx_buf, tx_len);
    ASSERT(resp.valid);
    ASSERT(resp.crc_ok);
    ASSERT(resp.cmd == MSP_DEBUG);
    ASSERT(resp.size == 4);
    ASSERT(resp.payload[0] == 0xDE);
    ASSERT(resp.payload[1] == 0xAD);
    ASSERT(resp.payload[2] == 0xBE);
    ASSERT(resp.payload[3] == 0xEF);
    
    std::cout << "\n  Response: DEADBEEF verified ";
}

TEST(msp_set_motor) {
    // Motor values: 1000, 1100, 1200, 1300 (little-endian)
    std::vector<uint8_t> payload = {
        0xE8, 0x03,  // 1000
        0x4C, 0x04,  // 1100
        0xB0, 0x04,  // 1200
        0x14, 0x05   // 1300
    };
    
    auto frame = build_msp_frame(MSP_SET_MOTOR, payload);
    hexdump("TX", frame);
    
    uint8_t tx_buf[128];
    int tx_len = 0;
    
    msp_bridge_loop(frame.data(), frame.size(), tx_buf, &tx_len);
    
    hexdump("RX", tx_buf, tx_len);
    
    ASSERT(tx_len > 0);
    
    auto resp = parse_msp_response(tx_buf, tx_len);
    ASSERT(resp.valid);
    ASSERT(resp.crc_ok);
    ASSERT(resp.cmd == MSP_SET_MOTOR);
    ASSERT(resp.size == 0);  // No payload in response
    
    // Verify motor values were written via set_motors() -> mock registers
    std::cout << "\n  Motors set: " << mock_dshot_motor1 << ", " << mock_dshot_motor2 
              << ", " << mock_dshot_motor3 << ", " << mock_dshot_motor4 << " ";
    
    ASSERT(mock_dshot_motor1 == 1000);
    ASSERT(mock_dshot_motor2 == 1100);
    ASSERT(mock_dshot_motor3 == 1200);
    ASSERT(mock_dshot_motor4 == 1300);
}

TEST(msp_unknown_cmd) {
    // Send unknown command - should get no response
    auto frame = build_msp_frame(0xFF);  // Unknown command
    hexdump("TX", frame);
    
    uint8_t tx_buf[128];
    int tx_len = 0;
    
    msp_bridge_loop(frame.data(), frame.size(), tx_buf, &tx_len);
    
    // Unknown commands should produce no response
    std::cout << "\n  tx_len=" << tx_len << " (expected 0 for unknown cmd) ";
    ASSERT(tx_len == 0);
}

TEST(msp_bad_crc) {
    // Build frame with bad CRC
    auto frame = build_msp_frame(MSP_IDENT);
    frame[frame.size() - 1] ^= 0xFF;  // Corrupt CRC
    hexdump("TX (bad CRC)", frame);
    
    uint8_t tx_buf[128];
    int tx_len = 0;
    
    msp_bridge_loop(frame.data(), frame.size(), tx_buf, &tx_len);
    
    // Bad CRC should produce no response
    std::cout << "\n  tx_len=" << tx_len << " (expected 0 for bad CRC) ";
    ASSERT(tx_len == 0);
}

// ============================================================================
// MspStateMachine Tests (byte-by-byte processing)
// ============================================================================

TEST(state_machine_ident) {
    MspStateMachine sm;
    uint8_t tx_buf[128];
    
    auto frame = build_msp_frame(MSP_IDENT);
    hexdump("TX", frame);
    
    int tx_len = 0;
    for (size_t i = 0; i < frame.size(); i++) {
        tx_len = sm.process_char(frame[i], tx_buf);
        // Only last byte should produce output
        if (i < frame.size() - 1) {
            ASSERT(tx_len == 0);
        }
    }
    
    hexdump("RX", tx_buf, tx_len);
    ASSERT(tx_len > 0);
    
    auto resp = parse_msp_response(tx_buf, tx_len);
    ASSERT(resp.valid);
    ASSERT(resp.crc_ok);
    ASSERT(resp.cmd == MSP_IDENT);
    std::cout << "\n  State machine processed frame correctly ";
}

TEST(state_machine_noise_recovery) {
    MspStateMachine sm;
    uint8_t tx_buf[128];
    
    // Send some garbage first
    sm.process_char(0xFF, tx_buf);
    sm.process_char(0x00, tx_buf);
    sm.process_char('X', tx_buf);
    sm.process_char('Y', tx_buf);
    
    // Now send valid frame
    auto frame = build_msp_frame(MSP_DEBUG);
    
    int tx_len = 0;
    for (uint8_t b : frame) {
        tx_len = sm.process_char(b, tx_buf);
    }
    
    ASSERT(tx_len > 0);
    
    auto resp = parse_msp_response(tx_buf, tx_len);
    ASSERT(resp.valid);
    ASSERT(resp.crc_ok);
    ASSERT(resp.cmd == MSP_DEBUG);
    std::cout << "\n  Recovered from noise and parsed correctly ";
}

TEST(state_machine_partial_abort) {
    MspStateMachine sm;
    uint8_t tx_buf[128];
    
    // Start a frame but abort mid-way
    sm.process_char('$', tx_buf);
    sm.process_char('M', tx_buf);
    sm.process_char('X', tx_buf);  // Invalid - should reset
    
    // State should be reset; send valid frame
    auto frame = build_msp_frame(MSP_STATUS);
    
    int tx_len = 0;
    for (uint8_t b : frame) {
        tx_len = sm.process_char(b, tx_buf);
    }
    
    ASSERT(tx_len > 0);
    
    auto resp = parse_msp_response(tx_buf, tx_len);
    ASSERT(resp.valid);
    ASSERT(resp.cmd == MSP_STATUS);
    std::cout << "\n  Recovered from partial frame abort ";
}

TEST(state_machine_back_to_back) {
    MspStateMachine sm;
    uint8_t tx_buf[128];
    
    // Send two frames back-to-back
    auto frame1 = build_msp_frame(MSP_IDENT);
    auto frame2 = build_msp_frame(MSP_DEBUG);
    
    // Process first frame
    int tx_len = 0;
    for (uint8_t b : frame1) {
        tx_len = sm.process_char(b, tx_buf);
    }
    ASSERT(tx_len > 0);
    auto resp1 = parse_msp_response(tx_buf, tx_len);
    ASSERT(resp1.cmd == MSP_IDENT);
    
    // Process second frame
    tx_len = 0;
    for (uint8_t b : frame2) {
        tx_len = sm.process_char(b, tx_buf);
    }
    ASSERT(tx_len > 0);
    auto resp2 = parse_msp_response(tx_buf, tx_len);
    ASSERT(resp2.cmd == MSP_DEBUG);
    
    std::cout << "\n  Back-to-back frames processed correctly ";
}

TEST(state_machine_state_transitions) {
    MspStateMachine sm;
    uint8_t tx_buf[128];
    
    // Verify initial state
    ASSERT(sm.get_state() == MspState::WAIT_DOLLAR);
    std::cout << "\n  Initial state: WAIT_DOLLAR ";
    
    // Process '$' -> should transition to WAIT_M
    sm.process_char('$', tx_buf);
    ASSERT(sm.get_state() == MspState::WAIT_M);
    std::cout << "-> WAIT_M ";
    
    // Process 'M' -> should transition to WAIT_DIRECTION
    sm.process_char('M', tx_buf);
    ASSERT(sm.get_state() == MspState::WAIT_DIRECTION);
    std::cout << "-> WAIT_DIRECTION ";
    
    // Process '<' -> should transition to READ_LENGTH
    sm.process_char('<', tx_buf);
    ASSERT(sm.get_state() == MspState::READ_LENGTH);
    std::cout << "-> READ_LENGTH ";
    
    // Process length byte (0 = no payload) -> should transition to READ_COMMAND
    sm.process_char(0, tx_buf);
    ASSERT(sm.get_state() == MspState::READ_COMMAND);
    std::cout << "-> READ_COMMAND ";
    
    // Process command byte (MSP_IDENT=100) -> should transition to READ_CRC (no payload)
    sm.process_char(MSP_IDENT, tx_buf);
    ASSERT(sm.get_state() == MspState::READ_CRC);
    std::cout << "-> READ_CRC ";
    
    // Process CRC (for len=0, cmd=100: crc = 0 ^ 100 = 100) -> should complete and return to WAIT_DOLLAR
    int tx_len = sm.process_char(0 ^ MSP_IDENT, tx_buf);
    ASSERT(sm.get_state() == MspState::WAIT_DOLLAR);
    ASSERT(tx_len > 0);
    std::cout << "-> WAIT_DOLLAR (complete) ";
}

TEST(state_machine_with_payload) {
    MspStateMachine sm;
    uint8_t tx_buf[128];
    
    // Test with payload - MSP_SET_MOTOR has 8-byte payload
    sm.process_char('$', tx_buf);
    sm.process_char('M', tx_buf);
    sm.process_char('<', tx_buf);
    
    // Length = 2 (small payload for test)
    sm.process_char(2, tx_buf);
    ASSERT(sm.get_state() == MspState::READ_COMMAND);
    std::cout << "\n  With payload: READ_COMMAND ";
    
    // Command byte
    sm.process_char(0xAB, tx_buf);
    ASSERT(sm.get_state() == MspState::READ_PAYLOAD);
    std::cout << "-> READ_PAYLOAD ";
    
    // First payload byte
    sm.process_char(0x11, tx_buf);
    ASSERT(sm.get_state() == MspState::READ_PAYLOAD);
    std::cout << "-> READ_PAYLOAD ";
    
    // Second (last) payload byte -> should transition to READ_CRC
    sm.process_char(0x22, tx_buf);
    ASSERT(sm.get_state() == MspState::READ_CRC);
    std::cout << "-> READ_CRC ";
}

TEST(state_machine_reset) {
    MspStateMachine sm;
    uint8_t tx_buf[128];
    
    // Put state machine in middle of parsing
    sm.process_char('$', tx_buf);
    sm.process_char('M', tx_buf);
    ASSERT(sm.get_state() == MspState::WAIT_DIRECTION);
    
    // Reset should return to initial state
    sm.reset();
    ASSERT(sm.get_state() == MspState::WAIT_DOLLAR);
    
    // Should be able to process new frame after reset
    auto frame = build_msp_frame(MSP_DEBUG);
    int tx_len = 0;
    for (uint8_t b : frame) {
        tx_len = sm.process_char(b, tx_buf);
    }
    ASSERT(tx_len > 0);
    
    auto resp = parse_msp_response(tx_buf, tx_len);
    ASSERT(resp.valid);
    ASSERT(resp.cmd == MSP_DEBUG);
    std::cout << "\n  Reset and recovery works correctly ";
}

TEST(state_machine_invalid_direction) {
    MspStateMachine sm;
    uint8_t tx_buf[128];
    
    // Start valid frame
    sm.process_char('$', tx_buf);
    sm.process_char('M', tx_buf);
    ASSERT(sm.get_state() == MspState::WAIT_DIRECTION);
    
    // Send invalid direction (not '<' or '>')
    sm.process_char('?', tx_buf);
    ASSERT(sm.get_state() == MspState::WAIT_DOLLAR);
    std::cout << "\n  Invalid direction resets to WAIT_DOLLAR ";
}

TEST(state_machine_response_direction) {
    MspStateMachine sm;
    uint8_t tx_buf[128];
    
    // Test that '>' direction also works (response direction)
    sm.process_char('$', tx_buf);
    sm.process_char('M', tx_buf);
    sm.process_char('>', tx_buf);  // Response direction
    ASSERT(sm.get_state() == MspState::READ_LENGTH);
    std::cout << "\n  Response direction '>' accepted ";
}

// ============================================================================
// Main
// ============================================================================

int main() {
    std::cout << "=== MSP Bridge Test Suite ===\n\n";
    
    std::cout << "--- msp_bridge_loop tests ---\n";
    RUN_TEST(msp_ident);
    RUN_TEST(msp_status);
    RUN_TEST(msp_debug);
    RUN_TEST(msp_set_motor);
    RUN_TEST(msp_unknown_cmd);
    RUN_TEST(msp_bad_crc);
    
    std::cout << "\n--- MspStateMachine tests ---\n";
    RUN_TEST(state_machine_ident);
    RUN_TEST(state_machine_noise_recovery);
    RUN_TEST(state_machine_partial_abort);
    RUN_TEST(state_machine_back_to_back);
    RUN_TEST(state_machine_state_transitions);
    RUN_TEST(state_machine_with_payload);
    RUN_TEST(state_machine_reset);
    RUN_TEST(state_machine_invalid_direction);
    RUN_TEST(state_machine_response_direction);
    
    std::cout << "\n=== Results ===\n";
    std::cout << "Passed: " << tests_passed << "\n";
    std::cout << "Failed: " << tests_failed << "\n";
    
    return tests_failed > 0 ? 1 : 0;
}
