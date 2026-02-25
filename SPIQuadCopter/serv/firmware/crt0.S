/* Minimal RISC-V startup code for SERV */

.section .text
.global _start
.type _start, @function

_start:
    /* Set up stack pointer (end of RAM) */
    la sp, _stack_top

    /* Clear BSS section */
    la a0, _bss_start
    la a1, _bss_end
clear_bss:
    bgeu a0, a1, done_bss
    sw zero, 0(a0)
    addi a0, a0, 4
    j clear_bss
done_bss:

    /* Call main */
    jal ra, main

    /* Infinite loop if main returns */
halt:
    j halt

.size _start, . - _start
