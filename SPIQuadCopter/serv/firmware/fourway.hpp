// 4-Way Interface Protocol implementation for BLHeli ESC configuration
#ifndef FOURWAY_HPP
#define FOURWAY_HPP

#include <stdint.h>

// 4-Way protocol sync bytes
#define FOURWAY_PC_SYNC     0x2F  // PC → FC request
#define FOURWAY_FC_SYNC     0x2E  // FC → PC response

// 4-Way commands
enum FourWayCmd {
    CMD_INTERFACE_TEST_ALIVE  = 0x30,
    CMD_PROTOCOL_GET_VERSION  = 0x31,
    CMD_INTERFACE_GET_NAME    = 0x32,
    CMD_INTERFACE_GET_VERSION = 0x33,
    CMD_INTERFACE_EXIT        = 0x34,
    CMD_DEVICE_RESET          = 0x35,
    CMD_DEVICE_INIT_FLASH     = 0x37,
    CMD_DEVICE_ERASE_ALL      = 0x38,
    CMD_DEVICE_PAGE_ERASE     = 0x39,
    CMD_DEVICE_READ           = 0x3A,
    CMD_DEVICE_WRITE          = 0x3B,
    CMD_DEVICE_C2CK_LOW       = 0x3C,
    CMD_DEVICE_READ_EEPROM    = 0x3D,
    CMD_DEVICE_WRITE_EEPROM   = 0x3E,
    CMD_INTERFACE_SET_MODE    = 0x3F,
};

// 4-Way ACK codes
enum FourWayAck {
    ACK_OK                 = 0x00,
    ACK_I_UNKNOWN_ERROR    = 0x01,
    ACK_I_INVALID_CMD      = 0x02,
    ACK_I_INVALID_CRC      = 0x03,
    ACK_I_VERIFY_ERROR     = 0x04,
    ACK_D_INVALID_COMMAND  = 0x05,
    ACK_D_COMMAND_FAILED   = 0x06,
    ACK_D_UNKNOWN_ERROR    = 0x07,
    ACK_I_INVALID_CHANNEL  = 0x08,
    ACK_I_INVALID_PARAM    = 0x09,
    ACK_D_GENERAL_ERROR    = 0x0F,
};

// 4-Way interface modes (ESC protocols)
enum FourWayMode {
    MODE_SiLC2  = 0,
    MODE_SiLBLB = 1,
    MODE_AtmBLB = 2,
    MODE_AtmSK  = 3,
    MODE_ARMBLB = 4,
};

// Maximum parameter size (256 indicated by 0)
#define FOURWAY_MAX_PARAMS 256

// 4-Way message structure
typedef struct {
    uint8_t  sync;
    uint8_t  cmd;
    uint16_t address;
    uint8_t  param_count;  // 0 means 256
    uint8_t  params[FOURWAY_MAX_PARAMS];
    uint8_t  ack;
    uint16_t crc;
} fourway_msg_t;

// Enter 4-way passthrough mode
// Returns when cmd_InterfaceExit is received or timeout
void fourway_loop();

// CRC16 X-Modem calculation
uint16_t crc16_xmodem(const uint8_t* data, uint16_t len);

#endif // FOURWAY_HPP
