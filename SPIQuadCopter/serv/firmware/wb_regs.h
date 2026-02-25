#ifndef WB_REGS_H
#define WB_REGS_H

#include <stdint.h>

// =========================================================================
// Wishbone Peripheral Address Map (SERV ext bus at 0x4000_0000+)
// =========================================================================
// SERV has a dedicated Wishbone bus with:
//   - Debug GPIO (digital outputs for logic analyzer/scope)
//   - DSHOT Controller (shared with SPI bus via arbiter)
//   - Mux Register (mode control)
//   - USB UART (MSP communication)
//
// Other peripherals (LED, PWM, NeoPixel, Version) are on the 
// separate SPI Wishbone bus only.
// =========================================================================

// Debug GPIO (3 digital outputs: o_debug_0, o_debug_1, o_debug_2)
// Directly toggle pins for fast debugging with logic analyzer/scope
#define WB_DEBUG_GPIO_BASE  0x40000100UL
#define WB_DEBUG_GPIO_OUT   (*(volatile uint32_t *)(WB_DEBUG_GPIO_BASE + 0x00))  // bits[2:0] = outputs
#define WB_DEBUG_GPIO_SET   (*(volatile uint32_t *)(WB_DEBUG_GPIO_BASE + 0x04))  // write 1s to set bits
#define WB_DEBUG_GPIO_CLR   (*(volatile uint32_t *)(WB_DEBUG_GPIO_BASE + 0x08))  // write 1s to clear bits
#define WB_DEBUG_GPIO_TGL   (*(volatile uint32_t *)(WB_DEBUG_GPIO_BASE + 0x0C))  // write 1s to toggle bits

// DSHOT Controller (4 motors) - shared with SPI bus via arbiter
#define WB_DSHOT_BASE     0x40000400UL
#define WB_DSHOT_MOTOR1   (*(volatile uint32_t *)(WB_DSHOT_BASE + 0x00))
#define WB_DSHOT_MOTOR2   (*(volatile uint32_t *)(WB_DSHOT_BASE + 0x04))
#define WB_DSHOT_MOTOR3   (*(volatile uint32_t *)(WB_DSHOT_BASE + 0x08))
#define WB_DSHOT_MOTOR4   (*(volatile uint32_t *)(WB_DSHOT_BASE + 0x0C))
#define WB_DSHOT_STATUS   (*(volatile uint32_t *)(WB_DSHOT_BASE + 0x10))
#define WB_DSHOT_CONFIG   (*(volatile uint32_t *)(WB_DSHOT_BASE + 0x14))

// Serial/DSHOT Mux Register
// bit[0]: 0=Serial/Passthrough, 1=DSHOT mode
// bit[2:1]: Channel select (0-3)
// bit[3]: MSP mode
#define WB_MUX_REG        (*(volatile uint32_t *)(0x40000700UL))

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

#endif // WB_REGS_H
