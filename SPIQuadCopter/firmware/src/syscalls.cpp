// System calls and FreeRTOS hooks for VexRiscv
#include <stdint.h>
#include <sys/stat.h>
#include <errno.h>
#include "wb_regs.h"

#ifdef USE_FREERTOS
#include "FreeRTOS.h"
#include "task.h"
#endif

#ifdef __cplusplus
extern "C" {
#endif

// ============================================================================
// Minimal newlib stubs
// ============================================================================

__attribute__((weak)) void _exit(int status) {
    (void)status;
    while (1) {
        __asm__ volatile("wfi");
    }
}

int _close(int fd) {
    (void)fd;
    return -1;
}

int _fstat(int fd, struct stat* st) {
    (void)fd;
    st->st_mode = S_IFCHR;
    return 0;
}

int _isatty(int fd) {
    (void)fd;
    return 1;
}

off_t _lseek(int fd, off_t offset, int whence) {
    (void)fd;
    (void)offset;
    (void)whence;
    return 0;
}

ssize_t _read(int fd, void* buf, size_t count) {
    (void)fd;
    (void)buf;
    (void)count;
    return 0;
}

ssize_t _write(int fd, const void* buf, size_t count) {
    (void)fd;
    const char* p = (const char*)buf;
    for (size_t i = 0; i < count; i++) {
        usb_putchar(p[i]);
    }
    return count;
}

void* _sbrk(ptrdiff_t incr) {
    extern char __heap_start;
    extern char __heap_end;
    static char* heap_ptr = &__heap_start;
    
    char* prev = heap_ptr;
    if (heap_ptr + incr > &__heap_end) {
        errno = ENOMEM;
        return (void*)-1;
    }
    heap_ptr += incr;
    return prev;
}

int _getpid(void) {
    return 1;
}

int _kill(int pid, int sig) {
    (void)pid;
    (void)sig;
    errno = EINVAL;
    return -1;
}

// ============================================================================
// FreeRTOS Static Allocation Hooks
// ============================================================================

#ifdef USE_FREERTOS

// Idle task static allocation
static StaticTask_t xIdleTaskTCB;
static StackType_t uxIdleTaskStack[configMINIMAL_STACK_SIZE];

void vApplicationGetIdleTaskMemory(StaticTask_t** ppxIdleTaskTCBBuffer,
                                    StackType_t** ppxIdleTaskStackBuffer,
                                    uint32_t* pulIdleTaskStackSize) {
    *ppxIdleTaskTCBBuffer = &xIdleTaskTCB;
    *ppxIdleTaskStackBuffer = uxIdleTaskStack;
    *pulIdleTaskStackSize = configMINIMAL_STACK_SIZE;
}

// Timer task static allocation (if timers enabled)
#if configUSE_TIMERS
static StaticTask_t xTimerTaskTCB;
static StackType_t uxTimerTaskStack[configTIMER_TASK_STACK_DEPTH];

void vApplicationGetTimerTaskMemory(StaticTask_t** ppxTimerTaskTCBBuffer,
                                     StackType_t** ppxTimerTaskStackBuffer,
                                     uint32_t* pulTimerTaskStackSize) {
    *ppxTimerTaskTCBBuffer = &xTimerTaskTCB;
    *ppxTimerTaskStackBuffer = uxTimerTaskStack;
    *pulTimerTaskStackSize = configTIMER_TASK_STACK_DEPTH;
}
#endif

// Stack overflow hook
void vApplicationStackOverflowHook(TaskHandle_t xTask, char* pcTaskName) {
    (void)xTask;
    (void)pcTaskName;
    
    // Blink LED rapidly to indicate stack overflow
    while (1) {
        WB_DEBUG_GPIO_TGL = 0x01;
        for (volatile int i = 0; i < 100000; i++) ;
    }
}

#endif  // USE_FREERTOS

// ============================================================================
// Assert Handler
// ============================================================================

void vAssertCalled(const char* file, int line) {
    (void)file;
    (void)line;
    
    // Output debug pulses and halt
    for (int i = 0; i < 10; i++) {
        WB_DEBUG_GPIO_TGL = 0x01;
        for (volatile int j = 0; j < 50000; j++) ;
    }
    
    while (1) {
        __asm__ volatile("wfi");
    }
}

#ifdef __cplusplus
}
#endif
