/*
 * FreeRTOS Configuration for VexRiscv RV32IMC @ 80 MHz
 * 
 * Key settings:
 * - Static memory allocation ONLY (no heap_*.c needed)
 * - Tick rate: 1 kHz (1ms tick)
 * - Preemptive scheduler
 * - No software timers (use hardware timer instead)
 */

#ifndef FREERTOS_CONFIG_H
#define FREERTOS_CONFIG_H

#include <stdint.h>

// ============================================================================
// Application-specific definitions
// ============================================================================
#ifndef CPU_CLOCK_HZ
#define CPU_CLOCK_HZ            80000000UL
#endif

// ============================================================================
// Scheduler Configuration
// ============================================================================
#define configUSE_PREEMPTION                    1
#define configUSE_PORT_OPTIMISED_TASK_SELECTION 0
#define configUSE_TICKLESS_IDLE                 0
#define configCPU_CLOCK_HZ                      CPU_CLOCK_HZ
#define configTICK_RATE_HZ                      ((TickType_t)1000)  // 1 kHz tick
#define configMAX_PRIORITIES                    8
#define configMINIMAL_STACK_SIZE                ((uint16_t)256)     // 256 words = 1KB
#define configMAX_TASK_NAME_LEN                 16
#define configUSE_16_BIT_TICKS                  0                   // 32-bit tick counter
#define configIDLE_SHOULD_YIELD                 1
#define configUSE_TASK_NOTIFICATIONS            1
#define configTASK_NOTIFICATION_ARRAY_ENTRIES   1
#define configUSE_MUTEXES                       1
#define configUSE_RECURSIVE_MUTEXES             0
#define configUSE_COUNTING_SEMAPHORES           1
#define configQUEUE_REGISTRY_SIZE               8
#define configUSE_QUEUE_SETS                    0
#define configUSE_TIME_SLICING                  1
#define configUSE_NEWLIB_REENTRANT              0
#define configENABLE_BACKWARD_COMPATIBILITY     0
#define configNUM_THREAD_LOCAL_STORAGE_POINTERS 0

// ============================================================================
// Memory Allocation - Static API + Dynamic Heap
// ============================================================================
#define configSUPPORT_STATIC_ALLOCATION         1
#define configSUPPORT_DYNAMIC_ALLOCATION        1
#define configTOTAL_HEAP_SIZE                   ((size_t)(4 * 1024))  // 4KB heap
#define configAPPLICATION_ALLOCATED_HEAP        0

// Stack overflow detection
#define configCHECK_FOR_STACK_OVERFLOW          2   // Method 2: check for pattern corruption

// ============================================================================
// Hook Functions
// ============================================================================
#define configUSE_IDLE_HOOK                     0
#define configUSE_TICK_HOOK                     0
#define configUSE_MALLOC_FAILED_HOOK            0
#define configUSE_DAEMON_TASK_STARTUP_HOOK      0

// ============================================================================
// Software Timers (disabled - use hardware timer)
// ============================================================================
#define configUSE_TIMERS                        0
#define configTIMER_TASK_PRIORITY               (configMAX_PRIORITIES - 1)
#define configTIMER_QUEUE_LENGTH                10
#define configTIMER_TASK_STACK_DEPTH            configMINIMAL_STACK_SIZE

// ============================================================================
// Co-routines (disabled)
// ============================================================================
#define configUSE_CO_ROUTINES                   0
#define configMAX_CO_ROUTINE_PRIORITIES         1

// ============================================================================
// RISC-V Specific Configuration
// ============================================================================
// For VexRiscv with machine mode only (no PMP, no user mode)
#define configMTIME_BASE_ADDRESS                0xFFFF0000UL
#define configMTIMECMP_BASE_ADDRESS             0xFFFF0008UL

// ============================================================================
// Debug and Statistics
// ============================================================================
#define configUSE_TRACE_FACILITY                0
#define configUSE_STATS_FORMATTING_FUNCTIONS    0
#define configGENERATE_RUN_TIME_STATS           0

// ============================================================================
// Assert Configuration
// ============================================================================
#ifdef __cplusplus
extern "C" {
#endif

void vAssertCalled(const char* file, int line);

#ifdef __cplusplus
}
#endif

#define configASSERT(x) if((x) == 0) vAssertCalled(__FILE__, __LINE__)

// ============================================================================
// Include/Exclude API Functions (minimize code size)
// ============================================================================
#define INCLUDE_vTaskPrioritySet                0
#define INCLUDE_uxTaskPriorityGet               0
#define INCLUDE_vTaskDelete                     0
#define INCLUDE_vTaskSuspend                    1
#define INCLUDE_xResumeFromISR                  0
#define INCLUDE_vTaskDelayUntil                 1
#define INCLUDE_vTaskDelay                      1
#define INCLUDE_xTaskGetSchedulerState          1
#define INCLUDE_xTaskGetCurrentTaskHandle       1
#define INCLUDE_uxTaskGetStackHighWaterMark     1
#define INCLUDE_xTaskGetIdleTaskHandle          0
#define INCLUDE_eTaskGetState                   0
#define INCLUDE_xEventGroupSetBitFromISR        0
#define INCLUDE_xTimerPendFunctionCall          0
#define INCLUDE_xTaskAbortDelay                 0
#define INCLUDE_xTaskGetHandle                  0
#define INCLUDE_xTaskResumeFromISR              0

// ============================================================================
// Interrupt Priorities (RISC-V machine mode)
// ============================================================================
// VexRiscv uses flat interrupt priorities in machine mode
// These macros are typically used for ARM Cortex-M; adapt for RISC-V
#define configKERNEL_INTERRUPT_PRIORITY         0
#define configMAX_SYSCALL_INTERRUPT_PRIORITY    0

#endif /* FREERTOS_CONFIG_H */
