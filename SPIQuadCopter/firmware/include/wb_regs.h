/*
 * Wishbone Peripheral Register Definitions
 * Target: VexRiscv (RV32IMC)
 * 
 * Memory Map:
 *   0x80000000 - 0x8000FFFF : RAM (boot/run)
 *   0x40000000 - 0x400FFFFF : Wishbone Peripherals
 *   0xFFFF0000 - 0xFFFF000F : Machine Timer (mtime/mtimecmp)
 */

#ifndef WB_REGS_H
#define WB_REGS_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// ============================================================================
// System Configuration
// ============================================================================
#ifndef CPU_CLOCK_HZ
#define CPU_CLOCK_HZ 80000000UL  // 80 MHz
#endif

// ============================================================================
// Wishbone Peripheral Base Addresses
// ============================================================================
#define WB_BASE                 0x40000000UL

#define WB_DEBUG_GPIO_BASE      (WB_BASE + 0x100)
#define WB_TIMER_BASE           (WB_BASE + 0x200)
#define WB_DSHOT_BASE           (WB_BASE + 0x300)
#define WB_MUX_BASE             (WB_BASE + 0x400)
#define WB_LED_BASE             (WB_BASE + 0x500)
#define WB_PWM_DECODER_BASE     (WB_BASE + 0x600)
#define WB_NEOPIXEL_BASE        (WB_BASE + 0x700)
#define WB_USB_UART_BASE        (WB_BASE + 0x800)
#define WB_ESC_UART_BASE        (WB_BASE + 0x900)
#define WB_VERSION_BASE         (WB_BASE + 0xA00)

// ============================================================================
// Debug GPIO (32-bit, directly toggle pins for logic analyzer)
// ============================================================================
#define WB_DEBUG_GPIO_OUT   (*(volatile uint32_t *)(WB_DEBUG_GPIO_BASE + 0x00))
#define WB_DEBUG_GPIO_SET   (*(volatile uint32_t *)(WB_DEBUG_GPIO_BASE + 0x04))
#define WB_DEBUG_GPIO_CLR   (*(volatile uint32_t *)(WB_DEBUG_GPIO_BASE + 0x08))
#define WB_DEBUG_GPIO_TGL   (*(volatile uint32_t *)(WB_DEBUG_GPIO_BASE + 0x0C))

// ============================================================================
// Hardware Timer (64-bit free-running counter at CPU_CLOCK_HZ)
// ============================================================================
#define WB_TIMER_COUNT_LO   (*(volatile uint32_t *)(WB_TIMER_BASE + 0x00))
#define WB_TIMER_COUNT_HI   (*(volatile uint32_t *)(WB_TIMER_BASE + 0x04))
#define WB_TIMER_CONTROL    (*(volatile uint32_t *)(WB_TIMER_BASE + 0x08))

// Timer helpers
static inline uint64_t timer_get_count(void) {
    uint32_t hi1, lo, hi2;
    do {
        hi1 = WB_TIMER_COUNT_HI;
        lo  = WB_TIMER_COUNT_LO;
        hi2 = WB_TIMER_COUNT_HI;
    } while (hi1 != hi2);  // Handle rollover
    return ((uint64_t)hi2 << 32) | lo;
}

static inline void timer_reset(void) {
    WB_TIMER_CONTROL = 1;
}

// Timing constants at 80 MHz
#define TIMER_TICKS_PER_US      80UL
#define TIMER_TICKS_PER_MS      80000UL
#define TIMER_TICKS_125US       10000UL    // 125µs = 8kHz DSHOT period
#define TIMER_TICKS_1SEC        80000000UL

// ============================================================================
// DSHOT Motor Control (4 channels)
// ============================================================================
#define WB_DSHOT_MOTOR1     (*(volatile uint32_t *)(WB_DSHOT_BASE + 0x00))
#define WB_DSHOT_MOTOR2     (*(volatile uint32_t *)(WB_DSHOT_BASE + 0x04))
#define WB_DSHOT_MOTOR3     (*(volatile uint32_t *)(WB_DSHOT_BASE + 0x08))
#define WB_DSHOT_MOTOR4     (*(volatile uint32_t *)(WB_DSHOT_BASE + 0x0C))
#define WB_DSHOT_STATUS     (*(volatile uint32_t *)(WB_DSHOT_BASE + 0x10))
#define WB_DSHOT_CONFIG     (*(volatile uint32_t *)(WB_DSHOT_BASE + 0x14))

// DSHOT status bits
#define WB_DSHOT_MOTOR1_READY   0x01
#define WB_DSHOT_MOTOR2_READY   0x02
#define WB_DSHOT_MOTOR3_READY   0x04
#define WB_DSHOT_MOTOR4_READY   0x08
#define WB_DSHOT_ALL_READY      0x0F

// DSHOT modes
#define DSHOT_MODE_150          150
#define DSHOT_MODE_300          300
#define DSHOT_MODE_600          600

// DSHOT throttle range
#define DSHOT_THROTTLE_MIN      48
#define DSHOT_THROTTLE_MAX      2047
#define DSHOT_CMD_DISARM        0

// DSHOT CRC encoder
static inline uint16_t dshot_encode(uint16_t throttle, uint8_t telemetry) {
    uint16_t packet = (throttle << 5) | ((telemetry & 1) << 4);
    uint16_t crc = (packet ^ (packet >> 4) ^ (packet >> 8)) & 0x0F;
    return packet | crc;
}

// ============================================================================
// Mux Register (Motor pin routing)
// ============================================================================
#define WB_MUX_REG          (*(volatile uint32_t *)(WB_MUX_BASE + 0x00))

// Mux modes
#define WB_MUX_DSHOT_MODE   0x01    // bit[0] = 1 for DSHOT
#define WB_MUX_SERIAL_MODE  0x00    // bit[0] = 0 for serial/UART
#define WB_MUX_FORCE_LOW    0x10    // bit[4] = force pin LOW (bootloader break)
#define WB_MUX_CH_MASK      0x06    // bits[2:1] = channel select (0-3)
#define WB_MUX_CH_SHIFT     1

static inline void mux_set_dshot(void) {
    WB_MUX_REG = WB_MUX_DSHOT_MODE;
}

static inline void mux_set_serial(uint8_t channel) {
    WB_MUX_REG = ((channel & 0x03) << WB_MUX_CH_SHIFT);
}

static inline void mux_set_serial_break(uint8_t channel) {
    WB_MUX_REG = ((channel & 0x03) << WB_MUX_CH_SHIFT) | WB_MUX_FORCE_LOW;
}

// ============================================================================
// USB UART (MSP communication, 115200 baud)
// ============================================================================
#define WB_USB_TX_DATA      (*(volatile uint32_t *)(WB_USB_UART_BASE + 0x00))
#define WB_USB_STATUS       (*(volatile uint32_t *)(WB_USB_UART_BASE + 0x04))
#define WB_USB_RX_DATA      (*(volatile uint32_t *)(WB_USB_UART_BASE + 0x08))

#define WB_USB_TX_READY     0x01
#define WB_USB_RX_VALID     0x02

static inline void usb_putchar(uint8_t ch) {
    while (!(WB_USB_STATUS & WB_USB_TX_READY)) ;
    WB_USB_TX_DATA = ch;
}

static inline int usb_getchar_nonblocking(void) {
    if (WB_USB_STATUS & WB_USB_RX_VALID) {
        return WB_USB_RX_DATA & 0xFF;
    }
    return -1;
}

// ============================================================================
// ESC UART (BLHeli configuration, 19200 baud half-duplex)
// ============================================================================
#define WB_ESC_TX_DATA      (*(volatile uint32_t *)(WB_ESC_UART_BASE + 0x00))
#define WB_ESC_STATUS       (*(volatile uint32_t *)(WB_ESC_UART_BASE + 0x04))
#define WB_ESC_RX_DATA      (*(volatile uint32_t *)(WB_ESC_UART_BASE + 0x08))

#define WB_ESC_TX_READY     0x01
#define WB_ESC_RX_VALID     0x02

// ============================================================================
// LED Controller
// ============================================================================
#define WB_LED_OUT          (*(volatile uint32_t *)(WB_LED_BASE + 0x00))

// ============================================================================
// PWM Decoder (6 channels)
// ============================================================================
#define WB_PWM_CH0          (*(volatile uint32_t *)(WB_PWM_DECODER_BASE + 0x00))
#define WB_PWM_CH1          (*(volatile uint32_t *)(WB_PWM_DECODER_BASE + 0x04))
#define WB_PWM_CH2          (*(volatile uint32_t *)(WB_PWM_DECODER_BASE + 0x08))
#define WB_PWM_CH3          (*(volatile uint32_t *)(WB_PWM_DECODER_BASE + 0x0C))
#define WB_PWM_CH4          (*(volatile uint32_t *)(WB_PWM_DECODER_BASE + 0x10))
#define WB_PWM_CH5          (*(volatile uint32_t *)(WB_PWM_DECODER_BASE + 0x14))

// ============================================================================
// Version Register (read-only)
// ============================================================================
#define WB_VERSION          (*(volatile uint32_t *)(WB_VERSION_BASE + 0x00))

// ============================================================================
// Machine Timer (RISC-V standard CLINT)
// ============================================================================
#define CLINT_BASE          0xFFFF0000UL
#define MTIME_LO            (*(volatile uint32_t *)(CLINT_BASE + 0x00))
#define MTIME_HI            (*(volatile uint32_t *)(CLINT_BASE + 0x04))
#define MTIMECMP_LO         (*(volatile uint32_t *)(CLINT_BASE + 0x08))
#define MTIMECMP_HI         (*(volatile uint32_t *)(CLINT_BASE + 0x0C))

static inline uint64_t mtime_get(void) {
    uint32_t hi1, lo, hi2;
    do {
        hi1 = MTIME_HI;
        lo  = MTIME_LO;
        hi2 = MTIME_HI;
    } while (hi1 != hi2);
    return ((uint64_t)hi2 << 32) | lo;
}

static inline void mtimecmp_set(uint64_t value) {
    MTIMECMP_LO = 0xFFFFFFFF;  // Prevent spurious interrupt
    MTIMECMP_HI = (uint32_t)(value >> 32);
    MTIMECMP_LO = (uint32_t)value;
}

#ifdef __cplusplus
}
#endif

#endif // WB_REGS_H
