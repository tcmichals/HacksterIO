#ifndef WB_REGS_H
#define WB_REGS_H

#include <stdint.h>

// =========================================================================
// Wishbone Peripheral Address Map (SERV ext bus at 0x4000_0000+)
// =========================================================================
// SERV has a dedicated Wishbone bus with:
//   - 0x40000100: Debug GPIO (digital outputs for logic analyzer/scope)
//   - 0x40000300: DSHOT Mailbox (dual-port motor control, shared with SPI)
//   - 0x40000700: Mux Register (mode control: Serial vs DSHOT)
//   - 0x40000800: USB UART (MSP communication)
//   - 0x40000900: ESC UART (BLHeli passthrough)
//
// The DSHOT Mailbox provides direct motor control from the CPU. Writes are
// arbitrated with the SPI path (SPI has priority on simultaneous access).
// =========================================================================

// Debug GPIO (3 digital outputs: o_debug_0, o_debug_1, o_debug_2)
// Directly toggle pins for fast debugging with logic analyzer/scope
#define WB_DEBUG_GPIO_BASE  0x40000100UL
#define WB_DEBUG_GPIO_OUT   (*(volatile uint32_t *)(WB_DEBUG_GPIO_BASE + 0x00))  // bits[2:0] = outputs
#define WB_DEBUG_GPIO_SET   (*(volatile uint32_t *)(WB_DEBUG_GPIO_BASE + 0x04))  // write 1s to set bits
#define WB_DEBUG_GPIO_CLR   (*(volatile uint32_t *)(WB_DEBUG_GPIO_BASE + 0x08))  // write 1s to clear bits
#define WB_DEBUG_GPIO_TGL   (*(volatile uint32_t *)(WB_DEBUG_GPIO_BASE + 0x0C))  // write 1s to toggle bits

// =========================================================================
// DSHOT Mailbox (Dual-Port Motor Control)
// =========================================================================
// CPU and SPI can both write motor commands. SPI has priority on collision.
// Motor registers: Write 16-bit DSHOT value (throttle[10:0] + telemetry + CRC)
// Use dshot_encode() helper to compute the full 16-bit value.
#define WB_DSHOT_BASE       0x40000300UL
#define WB_DSHOT_MOTOR1     (*(volatile uint32_t *)(WB_DSHOT_BASE + 0x00))  // Motor 1 command
#define WB_DSHOT_MOTOR2     (*(volatile uint32_t *)(WB_DSHOT_BASE + 0x04))  // Motor 2 command
#define WB_DSHOT_MOTOR3     (*(volatile uint32_t *)(WB_DSHOT_BASE + 0x08))  // Motor 3 command
#define WB_DSHOT_MOTOR4     (*(volatile uint32_t *)(WB_DSHOT_BASE + 0x0C))  // Motor 4 command
#define WB_DSHOT_STATUS     (*(volatile uint32_t *)(WB_DSHOT_BASE + 0x10))  // bits[3:0] = motor ready
#define WB_DSHOT_CONFIG     (*(volatile uint32_t *)(WB_DSHOT_BASE + 0x14))  // DSHOT mode (150/300/600)

// DSHOT status bits
#define WB_DSHOT_MOTOR1_READY  0x01
#define WB_DSHOT_MOTOR2_READY  0x02
#define WB_DSHOT_MOTOR3_READY  0x04
#define WB_DSHOT_MOTOR4_READY  0x08
#define WB_DSHOT_ALL_READY     0x0F

// DSHOT mode values
#define DSHOT_MODE_150    150
#define DSHOT_MODE_300    300
#define DSHOT_MODE_600    600

// DSHOT throttle range: 48-2047 (0=disarm, 1-47=special commands)
#define DSHOT_THROTTLE_MIN  48
#define DSHOT_THROTTLE_MAX  2047
#define DSHOT_CMD_DISARM    0

// Helper: Encode DSHOT value with CRC
// throttle: 0-2047, telemetry: 0 or 1
static inline uint16_t dshot_encode(uint16_t throttle, uint8_t telemetry) {
    uint16_t packet = (throttle << 5) | ((telemetry & 1) << 4);
    // CRC: XOR of nibbles
    uint16_t crc = (packet ^ (packet >> 4) ^ (packet >> 8)) & 0x0F;
    return packet | crc;
}

// Serial/DSHOT Mux Register
// bit[0]: 0=Serial/Passthrough, 1=DSHOT mode
// Mux Register: Controls motor pin routing
// bit[0]: Mode select (0=Serial/UART, 1=DSHOT)
// bit[2:1]: Channel select (0-3) for ESC UART
// bit[3]: MSP mode (reserved)
// bit[4]: Force LOW (for ESC bootloader break signal)
#define WB_MUX_REG        (*(volatile uint32_t *)(0x40000400UL))
#define WB_MUX_DSHOT_MODE 0x01  // bit[0] = 1 for DSHOT
#define WB_MUX_FORCE_LOW  0x10  // bit[4] = 1 forces target pin LOW

// USB UART (MSP communication, 115200 baud)
#define WB_USB_UART_BASE  0x40000800UL
#define WB_USB_TX_DATA    (*(volatile uint32_t *)(WB_USB_UART_BASE + 0x00))  // Write: TX byte
#define WB_USB_STATUS     (*(volatile uint32_t *)(WB_USB_UART_BASE + 0x04))  // bit0=TX ready, bit1=RX valid
#define WB_USB_RX_DATA    (*(volatile uint32_t *)(WB_USB_UART_BASE + 0x08))  // Read: RX byte (clears valid)
#define WB_USB_TX_READY   0x01
#define WB_USB_RX_VALID   0x02

// ESC UART (BLHeli configuration, 19200 baud half-duplex via motor pins)
// Mux must be in UART mode (WB_MUX_REG bit0 = 0) and channel selected
#define WB_ESC_UART_BASE  0x40000900UL
#define WB_ESC_TX_DATA    (*(volatile uint32_t *)(WB_ESC_UART_BASE + 0x00))  // Write: TX byte
#define WB_ESC_STATUS     (*(volatile uint32_t *)(WB_ESC_UART_BASE + 0x04))  // bit0=TX ready, bit1=RX valid
#define WB_ESC_RX_DATA    (*(volatile uint32_t *)(WB_ESC_UART_BASE + 0x08))  // Read: RX byte (clears valid)
#define WB_ESC_TX_READY   0x01
#define WB_ESC_RX_VALID   0x02

// Legacy aliases for compatibility
#define WB_MODE           WB_MUX_REG

// =========================================================================
// Timer (Free-running 64-bit counter at 54MHz for DSHOT auto-repeat)
// =========================================================================
// 54MHz clock: 1 tick = 18.5ns
// Useful values: 6750 ticks = 125µs (8kHz), 54000 ticks = 1ms
#define WB_TIMER_BASE     0x40000200UL
#define WB_TIMER_COUNT_LO (*(volatile uint32_t *)(WB_TIMER_BASE + 0x00))  // Lower 32 bits
#define WB_TIMER_COUNT_HI (*(volatile uint32_t *)(WB_TIMER_BASE + 0x04))  // Upper 32 bits
#define WB_TIMER_CONTROL  (*(volatile uint32_t *)(WB_TIMER_BASE + 0x08))  // Write 1 to reset

// Timing constants at 54MHz
#define TIMER_TICKS_PER_US     54       // 54 ticks = 1µs
#define TIMER_TICKS_125US      6750     // 125µs = 8kHz period
#define TIMER_TICKS_1MS        54000    // 1ms
#define TIMER_TICKS_1SEC       54000000 // 1 second

#endif // WB_REGS_H
