/**
 * sim_firmware.c - Minimal Firmware for Simulation Testing
 *
 * This simple firmware is used for quick simulation validation.
 * It writes to debug GPIO and LEDs to verify CPU operation.
 */

#include <stdint.h>

// Wishbone peripheral base addresses (from wb_regs.h)
#define WB_BASE         0x40000000
#define WB_DEBUG_GPIO   (WB_BASE + 0x0100)
#define WB_DSHOT_MBOX   (WB_BASE + 0x0300)
#define WB_MUX_REG      (WB_BASE + 0x0700)
#define WB_USB_UART     (WB_BASE + 0x0800)

// Register access macros
#define REG32(addr) (*(volatile uint32_t*)(addr))

// Debug GPIO registers
#define DEBUG_OUT   REG32(WB_DEBUG_GPIO + 0x00)
#define DEBUG_SET   REG32(WB_DEBUG_GPIO + 0x04)
#define DEBUG_CLR   REG32(WB_DEBUG_GPIO + 0x08)

// UART registers
#define UART_DATA   REG32(WB_USB_UART + 0x00)
#define UART_STATUS REG32(WB_USB_UART + 0x04)

void delay(volatile int count) {
    while (count--) {
        __asm__ volatile ("nop");
    }
}

void uart_putc(char c) {
    // Wait for TX ready
    while (UART_STATUS & 0x01);
    UART_DATA = c;
}

void uart_puts(const char* s) {
    while (*s) {
        uart_putc(*s++);
    }
}

int main(void) {
    // Signal boot via debug GPIO
    DEBUG_OUT = 0x00000001;
    
    // Set DSHOT mode
    REG32(WB_MUX_REG) = 0x00000001;
    
    // Send boot message
    uart_puts("SIM\r\n");
    
    // Debug pattern
    DEBUG_OUT = 0x00000002;
    
    // Main loop - toggle debug GPIO
    uint32_t count = 0;
    while (1) {
        DEBUG_OUT = count & 0xFF;
        count++;
        delay(1000);
        
        // Write motor values periodically
        if ((count & 0xFF) == 0) {
            REG32(WB_DSHOT_MBOX + 0x00) = 100;  // Motor 0
            REG32(WB_DSHOT_MBOX + 0x04) = 200;  // Motor 1
            REG32(WB_DSHOT_MBOX + 0x08) = 300;  // Motor 2
            REG32(WB_DSHOT_MBOX + 0x0C) = 400;  // Motor 3
        }
    }
    
    return 0;
}

// Startup code (minimal)
void _start(void) __attribute__((naked, section(".text.start")));
void _start(void) {
    __asm__ volatile (
        "la sp, _stack_top\n"   // Set stack pointer
        "call main\n"           // Call main
        "1: j 1b\n"             // Infinite loop if main returns
    );
}
