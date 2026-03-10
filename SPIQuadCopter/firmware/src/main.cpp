/*
 * VexRiscv Firmware - Main Entry Point
 * Target: RV32IMC @ 80 MHz
 *
 * Wishbone Peripherals:
 *   0x4000_0100 : Debug GPIO (32-bit) - fast digital outputs for debugging
 *   0x4000_0300 : DSHOT Mailbox - motor control
 *   0x4000_0400 : Mux Register - mode control (DSHOT/Serial)
 *   0x4000_0800 : USB UART - MSP communication
 *   0x4000_0900 : ESC UART - BLHeli passthrough
 *
 * Debug GPIO pulse patterns (visible on logic analyzer):
 *   1 pulse  = Reset/idle
 *   2 pulses = Processor running
 *   3 pulses = Main loop entered
 *   4 pulses = USB RX received
 *   5 pulses = MSP frame start
 *   6 pulses = MSP frame complete
 *   7 pulses = MSP response sent
 *   8 pulses = Error state
 */

#include "wb_regs.h"
#include "msp_loop.hpp"

#ifdef USE_FREERTOS
#include "FreeRTOS.h"
#include "task.h"
#endif

// Debug state values
constexpr uint8_t DBG_RESET   = 1;
constexpr uint8_t DBG_RUNNING = 2;
constexpr uint8_t DBG_LOOP    = 3;

// Debug helper: output N pulses
static inline void dbg_pulse(uint8_t count) {
    for (uint8_t i = 0; i < count; i++) {
        WB_DEBUG_GPIO_TGL = 0x01;
        WB_DEBUG_GPIO_TGL = 0x01;
    }
}

#ifdef USE_FREERTOS

// FreeRTOS task: MSP protocol handler
static void msp_task(void* pvParameters) {
    (void)pvParameters;
    
    dbg_pulse(DBG_LOOP);
    
    // msp_loop handles MSP protocol and DSHOT output
    msp_loop();  // Never returns
}

// FreeRTOS task: LED heartbeat (optional)
static void heartbeat_task(void* pvParameters) {
    (void)pvParameters;
    
    while (1) {
        WB_LED_OUT ^= 0x01;  // Toggle LED 0
        vTaskDelay(pdMS_TO_TICKS(500));
    }
}

int main() {
    // Signal startup
    dbg_pulse(DBG_RUNNING);
    
    // Set mux to DSHOT mode initially
    mux_set_dshot();
    
    // Create MSP handler task (high priority)
    xTaskCreate(msp_task, "MSP", 512, nullptr, configMAX_PRIORITIES - 1, nullptr);
    
    // Create heartbeat task (low priority)
    xTaskCreate(heartbeat_task, "LED", 128, nullptr, 1, nullptr);
    
    // Start scheduler - never returns
    vTaskStartScheduler();
    
    // Should never reach here
    while (1) {
        __asm__ volatile("wfi");
    }
    
    return 0;
}

#else  // No FreeRTOS - bare metal

int main() {
    // Signal startup
    dbg_pulse(DBG_RUNNING);
    
    // Set mux to DSHOT mode initially
    mux_set_dshot();
    
    dbg_pulse(DBG_LOOP);
    
    // msp_loop handles MSP protocol and DSHOT output
    // Continuously sends disarm frames; ESC arms after receiving them
    msp_loop();  // Never returns
    
    return 0;
}

#endif  // USE_FREERTOS
