/*
 * Minimal syscall stubs for newlib-nano
 * Routes printf/putchar to USB UART
 */

#include <sys/stat.h>
#include <errno.h>
#include "wb_regs.h"

// _write: send characters to USB UART (stdout/stderr)
int _write(int fd, const char *buf, int len) {
    (void)fd;  // ignore file descriptor, always use USB UART
    
    for (int i = 0; i < len; i++) {
        // Wait for TX ready
        while (!(WB_USB_STATUS & WB_USB_TX_READY))
            ;
        WB_USB_TX_DATA = buf[i];
    }
    return len;
}

// _read: not implemented (return 0 = EOF)
int _read(int fd, char *buf, int len) {
    (void)fd; (void)buf; (void)len;
    return 0;
}

// Minimal stubs required by newlib
void *_sbrk(int incr) {
    extern char _bss_end;  // from linker script
    static char *heap_end = 0;
    char *prev_heap_end;
    
    if (heap_end == 0) {
        heap_end = &_bss_end;
    }
    prev_heap_end = heap_end;
    heap_end += incr;
    return prev_heap_end;
}

int _close(int fd) { (void)fd; return -1; }
int _fstat(int fd, struct stat *st) { (void)fd; st->st_mode = S_IFCHR; return 0; }
int _isatty(int fd) { (void)fd; return 1; }
int _lseek(int fd, int ptr, int dir) { (void)fd; (void)ptr; (void)dir; return 0; }
void _exit(int status) { (void)status; while(1); }
int _kill(int pid, int sig) { (void)pid; (void)sig; errno = EINVAL; return -1; }
int _getpid(void) { return 1; }
