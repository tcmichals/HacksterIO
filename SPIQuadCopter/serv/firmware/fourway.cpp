// 4-Way Interface Protocol implementation for BLHeli ESC configuration
#include "fourway.hpp"
#include "wb_regs.h"

// Debug helpers - stubbed for test host
#ifdef TEST_HOST
static inline void dbg_toggle() { }
static inline void dbg_set(uint8_t val) { (void)val; }
#else
static inline void dbg_toggle() {
    WB_DEBUG_GPIO_TGL = 0x01;
}
// Output toggle pattern: N pulses for the debug value (visible on scope)
static inline void dbg_set(uint8_t val) {
    for (uint8_t i = 0; i < val; i++) {
        WB_DEBUG_GPIO_TGL = 0x01;  // Toggle bit 0
        WB_DEBUG_GPIO_TGL = 0x01;  // Toggle back (creates pulse)
    }
}
#endif

// Interface identification
static const char INTERFACE_NAME[] = "T9K-4WAY";
static const uint8_t PROTOCOL_VERSION = 107;  // Same as Betaflight
static const uint8_t INTERFACE_VERSION = 200;

// Current target ESC channel (0-3)
static uint8_t current_target = 0;

// CRC16 X-Modem lookup table
static const uint16_t crc16_xmodem_table[256] = {
    0x0000, 0x1021, 0x2042, 0x3063, 0x4084, 0x50A5, 0x60C6, 0x70E7,
    0x8108, 0x9129, 0xA14A, 0xB16B, 0xC18C, 0xD1AD, 0xE1CE, 0xF1EF,
    0x1231, 0x0210, 0x3273, 0x2252, 0x52B5, 0x4294, 0x72F7, 0x62D6,
    0x9339, 0x8318, 0xB37B, 0xA35A, 0xD3BD, 0xC39C, 0xF3FF, 0xE3DE,
    0x2462, 0x3443, 0x0420, 0x1401, 0x64E6, 0x74C7, 0x44A4, 0x5485,
    0xA56A, 0xB54B, 0x8528, 0x9509, 0xE5EE, 0xF5CF, 0xC5AC, 0xD58D,
    0x3653, 0x2672, 0x1611, 0x0630, 0x76D7, 0x66F6, 0x5695, 0x46B4,
    0xB75B, 0xA77A, 0x9719, 0x8738, 0xF7DF, 0xE7FE, 0xD79D, 0xC7BC,
    0x48C4, 0x58E5, 0x6886, 0x78A7, 0x0840, 0x1861, 0x2802, 0x3823,
    0xC9CC, 0xD9ED, 0xE98E, 0xF9AF, 0x8948, 0x9969, 0xA90A, 0xB92B,
    0x5AF5, 0x4AD4, 0x7AB7, 0x6A96, 0x1A71, 0x0A50, 0x3A33, 0x2A12,
    0xDBFD, 0xCBDC, 0xFBBF, 0xEB9E, 0x9B79, 0x8B58, 0xBB3B, 0xAB1A,
    0x6CA6, 0x7C87, 0x4CE4, 0x5CC5, 0x2C22, 0x3C03, 0x0C60, 0x1C41,
    0xEDAE, 0xFD8F, 0xCDEC, 0xDDCD, 0xAD2A, 0xBD0B, 0x8D68, 0x9D49,
    0x7E97, 0x6EB6, 0x5ED5, 0x4EF4, 0x3E13, 0x2E32, 0x1E51, 0x0E70,
    0xFF9F, 0xEFBE, 0xDFDD, 0xCFFC, 0xBF1B, 0xAF3A, 0x9F59, 0x8F78,
    0x9188, 0x81A9, 0xB1CA, 0xA1EB, 0xD10C, 0xC12D, 0xF14E, 0xE16F,
    0x1080, 0x00A1, 0x30C2, 0x20E3, 0x5004, 0x4025, 0x7046, 0x6067,
    0x83B9, 0x9398, 0xA3FB, 0xB3DA, 0xC33D, 0xD31C, 0xE37F, 0xF35E,
    0x02B1, 0x1290, 0x22F3, 0x32D2, 0x4235, 0x5214, 0x6277, 0x7256,
    0xB5EA, 0xA5CB, 0x95A8, 0x8589, 0xF56E, 0xE54F, 0xD52C, 0xC50D,
    0x34E2, 0x24C3, 0x14A0, 0x0481, 0x7466, 0x6447, 0x5424, 0x4405,
    0xA7DB, 0xB7FA, 0x8799, 0x97B8, 0xE75F, 0xF77E, 0xC71D, 0xD73C,
    0x26D3, 0x36F2, 0x0691, 0x16B0, 0x6657, 0x7676, 0x4615, 0x5634,
    0xD94C, 0xC96D, 0xF90E, 0xE92F, 0x99C8, 0x89E9, 0xB98A, 0xA9AB,
    0x5844, 0x4865, 0x7806, 0x6827, 0x18C0, 0x08E1, 0x3882, 0x28A3,
    0xCB7D, 0xDB5C, 0xEB3F, 0xFB1E, 0x8BF9, 0x9BD8, 0xABBB, 0xBB9A,
    0x4A75, 0x5A54, 0x6A37, 0x7A16, 0x0AF1, 0x1AD0, 0x2AB3, 0x3A92,
    0xFD2E, 0xED0F, 0xDD6C, 0xCD4D, 0xBDAA, 0xAD8B, 0x9DE8, 0x8DC9,
    0x7C26, 0x6C07, 0x5C64, 0x4C45, 0x3CA2, 0x2C83, 0x1CE0, 0x0CC1,
    0xEF1F, 0xFF3E, 0xCF5D, 0xDF7C, 0xAF9B, 0xBFBA, 0x8FD9, 0x9FF8,
    0x6E17, 0x7E36, 0x4E55, 0x5E74, 0x2E93, 0x3EB2, 0x0ED1, 0x1EF0
};

// Calculate CRC16 X-Modem (for 4-Way protocol - PC to FC)
uint16_t crc16_xmodem(const uint8_t* data, uint16_t len) {
    uint16_t crc = 0;
    for (uint16_t i = 0; i < len; i++) {
        crc = (crc << 8) ^ crc16_xmodem_table[((crc >> 8) ^ data[i]) & 0xFF];
    }
    return crc;
}

// Calculate CRC16-IBM (for BLHeli bootloader - FC to ESC)
// Polynomial 0xA001 (bit-reversed 0x8005), LSB first
static uint16_t crc16_ibm(const uint8_t* data, uint16_t len) {
    uint16_t crc = 0;
    for (uint16_t i = 0; i < len; i++) {
        crc ^= data[i];
        for (int j = 0; j < 8; j++) {
            if (crc & 1)
                crc = (crc >> 1) ^ 0xA001;
            else
                crc >>= 1;
        }
    }
    return crc;  // Send LSB first
}

// BLHeli bootloader identifier frame (BootInit)
// From Betaflight serial_4way_avrootloader.c:
// uint8_t BootInit[] = {0,0,0,0,0,0,0,0,0x0D,'B','L','H','e','l','i',0xF4,0x7D};
// 8 zeros + 0x0D + "BLHeli" + pre-calculated CRC16 = 17 bytes
static const uint8_t BLHELI_BOOTINIT[] = {
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // 8 zero bytes
    0x0D,                                             // Carriage return
    'B', 'L', 'H', 'e', 'l', 'i',                     // "BLHeli"
    0xF4, 0x7D                                        // Pre-calculated CRC16 (LSB first)
};

// Read a byte from USB UART with timeout (returns -1 on timeout)
static int usb_getchar_timeout(uint32_t timeout_loops) {
    while (timeout_loops > 0) {
        uint32_t status = WB_USB_STATUS;
        if (status & WB_USB_RX_VALID) {
            dbg_set(2);  // Got data - 2 pulses
            return WB_USB_RX_DATA & 0xFF;
        }
        timeout_loops--;
    }
    return -1;
}

// Write a byte to USB UART
static void usb_putchar(uint8_t ch) {
    while (!(WB_USB_STATUS & WB_USB_TX_READY)) ;
    WB_USB_TX_DATA = ch;
}

// Write buffer to USB UART
static void usb_write(const uint8_t* buf, uint16_t len) {
    for (uint16_t i = 0; i < len; i++) {
        usb_putchar(buf[i]);
    }
}

// Set mux to UART mode for specified channel
static void mux_set_uart(uint8_t channel) {
    // bit[0] = 0 for serial mode, bits[2:1] = channel
    WB_MUX_REG = (channel & 0x03) << 1;
}

// Set mux to UART mode with force LOW (break signal for bootloader entry)
static void mux_set_uart_break(uint8_t channel) {
    // bit[0] = 0 for serial mode, bits[2:1] = channel, bit[4] = force LOW
    WB_MUX_REG = ((channel & 0x03) << 1) | WB_MUX_FORCE_LOW;
}

// Set mux to DSHOT mode
static void mux_set_dshot() {
    // bit[0] = 1 for DSHOT mode
    WB_MUX_REG = WB_MUX_DSHOT_MODE;
}

// Read byte from ESC UART with timeout
static int esc_getchar_timeout(uint32_t timeout_loops) {
    while (timeout_loops > 0) {
        if (WB_ESC_STATUS & WB_ESC_RX_VALID) {
            return WB_ESC_RX_DATA & 0xFF;
        }
        timeout_loops--;
    }
    return -1;
}

// Write byte to ESC UART
static void esc_putchar(uint8_t ch) {
    while (!(WB_ESC_STATUS & WB_ESC_TX_READY)) ;
    WB_ESC_TX_DATA = ch;
}

// Send 4-way response frame
static void send_response(uint8_t cmd, uint16_t addr, const uint8_t* params, 
                          uint8_t param_count, uint8_t ack) {
    // Calculate actual param count for buffer
    uint16_t actual_count = (param_count == 0) ? 256 : param_count;
    
    // Build response (max 265 bytes: 5 header + 256 params + 1 ack + 2 crc)
    uint8_t resp[265];
    uint16_t idx = 0;
    
    resp[idx++] = FOURWAY_FC_SYNC;
    resp[idx++] = cmd;
    resp[idx++] = (addr >> 8) & 0xFF;
    resp[idx++] = addr & 0xFF;
    resp[idx++] = param_count;  // 0 means 256
    
    for (uint16_t i = 0; i < actual_count; i++) {
        resp[idx++] = params[i];
    }
    
    resp[idx++] = ack;
    
    // Calculate CRC over everything except CRC bytes
    uint16_t crc = crc16_xmodem(resp, idx);
    resp[idx++] = (crc >> 8) & 0xFF;
    resp[idx++] = crc & 0xFF;
    
    usb_write(resp, idx);
}

// Simple response with no params
static void send_simple_response(uint8_t cmd, uint8_t ack) {
    uint8_t zero = 0;
    send_response(cmd, 0, &zero, 1, ack);
}

// Process a 4-way command
static bool process_fourway_cmd(const fourway_msg_t* msg) {
    uint8_t response_params[256];
    uint8_t response_len = 0;
    uint8_t ack = ACK_OK;
    
    switch (msg->cmd) {
        case CMD_INTERFACE_TEST_ALIVE:
            // Keep-alive - just respond OK
            send_simple_response(msg->cmd, ACK_OK);
            return true;
            
        case CMD_PROTOCOL_GET_VERSION:
            response_params[0] = PROTOCOL_VERSION;
            send_response(msg->cmd, 0, response_params, 1, ACK_OK);
            return true;
            
        case CMD_INTERFACE_GET_NAME:
            // Return interface name
            for (int i = 0; INTERFACE_NAME[i]; i++) {
                response_params[i] = INTERFACE_NAME[i];
                response_len++;
            }
            send_response(msg->cmd, 0, response_params, response_len, ACK_OK);
            return true;
            
        case CMD_INTERFACE_GET_VERSION:
            response_params[0] = INTERFACE_VERSION;
            send_response(msg->cmd, 0, response_params, 1, ACK_OK);
            return true;
            
        case CMD_INTERFACE_EXIT:
            // Exit 4-way mode - restore DSHOT
            mux_set_dshot();
            send_simple_response(msg->cmd, ACK_OK);
            return false;  // Signal to exit fourway_loop
            
        case CMD_DEVICE_INIT_FLASH: {
            // Initialize flash for target ESC
            current_target = msg->params[0] & 0x03;  // ESC 0-3
            
            // Step 1: Set UART mode (line goes HIGH - idle state)
            // ESC needs to see stable HIGH before the break to recognize bootloader entry
            mux_set_uart(current_target);
            uint32_t mux_before = WB_MUX_REG;  // Debug: read back
            
            // Wait ~200ms for ESC to see UART idle (HIGH) and exit DSHOT mode
            for (volatile int d = 0; d < 28000; d++) ;
            
            // Step 2: Send break signal (force pin LOW) for ~500ms
            // ESC main firmware needs extended LOW to detect bootloader request
            // This is passthrough mode - ESC is already running, not power-up boot
            mux_set_uart_break(current_target);
            uint32_t mux_break = WB_MUX_REG;  // Debug: read back - should have bit4 set
            
            // Delay ~500ms (measured: 14000 iterations = 100ms, so 70000 = 500ms)
            for (volatile int d = 0; d < 70000; d++) ;
            
            // Step 3: Release break, back to normal UART mode (HIGH)
            mux_set_uart(current_target);
            uint32_t mux_after = WB_MUX_REG;  // Debug: read back;
            
            // No delay - send BootInit immediately after break release
            // The bootloader is waiting for LOW edges (UART start bits)
            
            // Clear any pending RX data
            uint8_t rx_cleared = 0;
            while (WB_ESC_STATUS & WB_ESC_RX_VALID) {
                (void)WB_ESC_RX_DATA;
                rx_cleared++;
            }
            
            // Send BLHeli BootInit frame (17 bytes)
            // From Betaflight: 8 zeros + 0x0D + "BLHeli" + CRC16
            uint8_t bytes_sent = 0;
            for (int i = 0; i < 17; i++) {
                esc_putchar(BLHELI_BOOTINIT[i]);
                bytes_sent++;
            }
            
            // Wait for TX to fully complete (last byte + guard time)
            // At 19200 baud: 1 byte ≈ 0.52ms, need ~1ms margin
            for (volatile int d = 0; d < 500; d++) ;
            
            // Capture status before RX polling (bit2=TX active should be 0)
            uint8_t status_before_rx = WB_ESC_STATUS & 0xFF;
            
            // Wait for bootloader response: 8 bytes
            // BootInfo[0-3] = BOOT_MSG "471c" or "471d"
            // BootInfo[4]   = SIGNATURE_001 (sig high)
            // BootInfo[5]   = SIGNATURE_002 (sig low)
            // BootInfo[6]   = BOOT_VERSION (always 6)
            // BootInfo[7]   = BOOT_PAGES
            uint8_t boot_info[8];
            int boot_len = 0;
            
            for (int j = 0; j < 8; j++) {
                int b = esc_getchar_timeout(100000);  // ~350ms timeout
                if (b < 0) break;
                boot_info[boot_len++] = b;
            }
            
            if (boot_len >= 6) {
                // Got enough response - format 4-byte DeviceInfo for 4-way
                // From Betaflight:
                // bytes[0] = BootInfo[5] (SIGNATURE_002, sig low)
                // bytes[1] = BootInfo[4] (SIGNATURE_001, sig high)
                // bytes[2] = BootInfo[3] (BOOT_MSG last char, e.g. 'c')
                // bytes[3] = 1 (interfaceMode = imSIL_BLB = SiLabs bootloader)
                uint8_t final_params[4];
                final_params[0] = boot_info[5];  // SIGNATURE_002 (sig low)
                final_params[1] = boot_info[4];  // SIGNATURE_001 (sig high)
                final_params[2] = boot_info[3];  // BOOT_MSG last char
                final_params[3] = 1;             // interfaceMode = SiLabs
                send_response(msg->cmd, msg->address, final_params, 4, ACK_OK);
                return true;
            }
            
            // No response or truncated - ESC not in bootloader mode
            // Return debug info: mux values before/during/after break
            ack = ACK_D_GENERAL_ERROR;
            response_params[0] = mux_before & 0xFF;  // mux before break
            response_params[1] = mux_break & 0xFF;   // mux during break (should have bit4=0x10)
            response_params[2] = mux_after & 0xFF;   // mux after release
            response_params[3] = current_target;     // which channel
            response_params[4] = boot_len;           // how many bytes we got
            response_len = 5;
            send_response(msg->cmd, msg->address, response_params, response_len, ack);
            return true;
        }
            
        case CMD_DEVICE_READ:
            // Read from ESC flash/EEPROM
            {
                uint8_t count = (msg->param_count == 0) ? 256 : msg->params[0];
                
                // Send read command to ESC
                // BLHeli bootloader read: [0x03][ADDR_H][ADDR_L][COUNT]
                esc_putchar(0x03);  // Read command
                esc_putchar((msg->address >> 8) & 0xFF);
                esc_putchar(msg->address & 0xFF);
                esc_putchar(count);
                
                // Read response bytes
                response_len = 0;
                for (uint8_t i = 0; i < count; i++) {
                    int b = esc_getchar_timeout(50000);
                    if (b < 0) {
                        ack = ACK_D_GENERAL_ERROR;
                        break;
                    }
                    response_params[response_len++] = b;
                }
            }
            send_response(msg->cmd, msg->address, response_params, response_len, ack);
            return true;
            
        case CMD_DEVICE_WRITE:
            // Write to ESC flash
            {
                uint8_t count = (msg->param_count == 0) ? 256 : msg->param_count;
                
                // Send write command to ESC
                // BLHeli bootloader write: [0x02][ADDR_H][ADDR_L][COUNT][DATA...]
                esc_putchar(0x02);  // Write command
                esc_putchar((msg->address >> 8) & 0xFF);
                esc_putchar(msg->address & 0xFF);
                esc_putchar(count);
                
                for (uint8_t i = 0; i < count; i++) {
                    esc_putchar(msg->params[i]);
                }
                
                // Wait for ACK from ESC
                int b = esc_getchar_timeout(100000);
                ack = (b == 0x00) ? ACK_OK : ACK_D_GENERAL_ERROR;
            }
            send_simple_response(msg->cmd, ack);
            return true;
            
        case CMD_DEVICE_READ_EEPROM:
            // Read EEPROM (same as flash read for most ESCs)
            {
                uint8_t count = (msg->param_count == 0) ? 256 : msg->params[0];
                
                // Send EEPROM read command
                esc_putchar(0x04);  // EEPROM read
                esc_putchar((msg->address >> 8) & 0xFF);
                esc_putchar(msg->address & 0xFF);
                esc_putchar(count);
                
                response_len = 0;
                for (uint8_t i = 0; i < count; i++) {
                    int b = esc_getchar_timeout(50000);
                    if (b < 0) {
                        ack = ACK_D_GENERAL_ERROR;
                        break;
                    }
                    response_params[response_len++] = b;
                }
            }
            send_response(msg->cmd, msg->address, response_params, response_len, ack);
            return true;
            
        case CMD_DEVICE_WRITE_EEPROM:
            // Write EEPROM
            {
                uint8_t count = (msg->param_count == 0) ? 256 : msg->param_count;
                
                esc_putchar(0x05);  // EEPROM write
                esc_putchar((msg->address >> 8) & 0xFF);
                esc_putchar(msg->address & 0xFF);
                esc_putchar(count);
                
                for (uint8_t i = 0; i < count; i++) {
                    esc_putchar(msg->params[i]);
                }
                
                int b = esc_getchar_timeout(100000);
                ack = (b == 0x00) ? ACK_OK : ACK_D_GENERAL_ERROR;
            }
            send_simple_response(msg->cmd, ack);
            return true;
            
        case CMD_DEVICE_RESET:
            // Reset ESC
            esc_putchar(0x00);  // Reset command
            mux_set_dshot();
            send_simple_response(msg->cmd, ACK_OK);
            return true;
            
        case CMD_DEVICE_PAGE_ERASE: {
            // Erase flash page
            esc_putchar(0x01);  // Erase command
            esc_putchar((msg->address >> 8) & 0xFF);
            esc_putchar(msg->address & 0xFF);
            
            // Wait for erase complete
            int b = esc_getchar_timeout(500000);  // Erase takes longer
            ack = (b == 0x00) ? ACK_OK : ACK_D_GENERAL_ERROR;
            send_simple_response(msg->cmd, ack);
            return true;
        }
            
        case CMD_INTERFACE_SET_MODE:
            // Set interface mode (SiLC2, SiLBLB, AtmBLB, AtmSK, ARMBLB)
            // We'll accept any mode for now
            send_simple_response(msg->cmd, ACK_OK);
            return true;
            
        default:
            // Unknown command
            send_simple_response(msg->cmd, ACK_I_INVALID_CMD);
            return true;
    }
}

// Main 4-way interface loop
// Called after MSP_SET_PASSTHROUGH, returns when CMD_INTERFACE_EXIT received
void fourway_loop() {
    fourway_msg_t msg;
    uint8_t rx_buf[265];
    uint16_t rx_idx = 0;
    
    // Debug: signal we entered fourway_loop
    dbg_toggle();
    
    // Set mux to DSHOT initially (will switch per-command)
    mux_set_dshot();
    
    while (1) {
        bool frame_ok = true;
        
        // Wait for sync byte (100ms timeout)
        int ch = usb_getchar_timeout(100000);  // ~100ms timeout
        if (ch < 0) {
            // Timeout - toggle to show we're still looping
            dbg_toggle();
            continue;
        }
        
        dbg_set(2);  // Got a byte
        
        if (ch != FOURWAY_PC_SYNC) {
            // Not a 4-way frame, ignore
            dbg_set(3);  // Wrong sync byte
            continue;
        }
        
        // Got correct 0x2F sync - no extra toggle here
        
        // Read header: cmd, addr_h, addr_l, len
        rx_buf[0] = FOURWAY_PC_SYNC;
        rx_idx = 1;
        
        for (int i = 0; i < 4 && frame_ok; i++) {
            ch = usb_getchar_timeout(100000);
            if (ch < 0) {
                frame_ok = false;
                break;
            }
            rx_buf[rx_idx++] = ch;
        }
        
        if (!frame_ok) continue;
        
        msg.cmd = rx_buf[1];
        msg.address = (rx_buf[2] << 8) | rx_buf[3];
        msg.param_count = rx_buf[4];
        
        // Calculate actual param count (0 = 256)
        uint16_t actual_count = (msg.param_count == 0) ? 256 : msg.param_count;
        
        // Read params
        for (uint16_t i = 0; i < actual_count && frame_ok; i++) {
            ch = usb_getchar_timeout(100000);
            if (ch < 0) {
                frame_ok = false;
                break;
            }
            msg.params[i] = ch;
            rx_buf[rx_idx++] = ch;
        }
        
        if (!frame_ok) continue;
        
        // Read CRC (2 bytes)
        ch = usb_getchar_timeout(100000);
        if (ch < 0) continue;
        uint8_t crc_h = ch;
        
        ch = usb_getchar_timeout(100000);
        if (ch < 0) continue;
        uint8_t crc_l = ch;
        
        msg.crc = (crc_h << 8) | crc_l;
        
        // Verify CRC
        uint16_t calc_crc = crc16_xmodem(rx_buf, rx_idx);
        if (calc_crc != msg.crc) {
            send_simple_response(msg.cmd, ACK_I_INVALID_CRC);
            continue;
        }
        
        // Process command
        if (!process_fourway_cmd(&msg)) {
            // CMD_INTERFACE_EXIT received, return to MSP mode
            return;
        }
    }
}
