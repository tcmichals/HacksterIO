/*
 * VexRiscv Startup Code (crt0.S)
 * Target: RV32IMC
 * 
 * - Initializes stack pointer
 * - Clears BSS
 * - Calls C++ global constructors
 * - Jumps to main()
 * - Interrupt/exception vector table
 */

    .section .text.init, "ax", @progbits
    .global _start
    .type _start, @function
    .option push
    .option norelax

_start:
    /* Disable interrupts */
    csrci   mstatus, 8          /* Clear MIE (bit 3) */

    /* Initialize global pointer (for small data access) */
    la      gp, __global_pointer$

    /* Initialize stack pointer */
    la      sp, __stack_top

    /* Clear BSS section */
    la      a0, __bss_start
    la      a1, __bss_end
    bgeu    a0, a1, 2f
1:
    sw      zero, 0(a0)
    addi    a0, a0, 4
    bltu    a0, a1, 1b
2:

    /* Call C++ global constructors */
    la      a0, __init_array_start
    la      a1, __init_array_end
    bgeu    a0, a1, 4f
3:
    lw      a2, 0(a0)
    jalr    a2
    addi    a0, a0, 4
    bltu    a0, a1, 3b
4:

    /* Set up machine trap vector (direct mode) */
    la      t0, _trap_handler
    csrw    mtvec, t0

    /* Enable interrupts (optional - FreeRTOS will manage this) */
    /* csrsi   mstatus, 8 */

    /* Call main() */
    li      a0, 0               /* argc = 0 */
    li      a1, 0               /* argv = NULL */
    call    main

    /* If main returns, fall through to halt */
    .global _exit
_exit:
    /* Call C++ global destructors (optional) */
    la      a0, __fini_array_start
    la      a1, __fini_array_end
    bgeu    a0, a1, 6f
5:
    lw      a2, 0(a0)
    jalr    a2
    addi    a0, a0, 4
    bltu    a0, a1, 5b
6:

    /* Halt: infinite loop with WFI */
    .global _halt
_halt:
    wfi
    j       _halt

    .option pop
    .size _start, . - _start


/*
 * Trap Handler (exceptions and interrupts)
 * VexRiscv with CsrPlugin uses MTVEC for trap entry
 */
    .section .text, "ax", @progbits
    .global _trap_handler
    .type _trap_handler, @function
    .weak _trap_handler
    .align 4

_trap_handler:
    /* Save caller-saved registers */
    addi    sp, sp, -64
    sw      ra, 0(sp)
    sw      t0, 4(sp)
    sw      t1, 8(sp)
    sw      t2, 12(sp)
    sw      a0, 16(sp)
    sw      a1, 20(sp)
    sw      a2, 24(sp)
    sw      a3, 28(sp)
    sw      a4, 32(sp)
    sw      a5, 36(sp)
    sw      a6, 40(sp)
    sw      a7, 44(sp)
    sw      t3, 48(sp)
    sw      t4, 52(sp)
    sw      t5, 56(sp)
    sw      t6, 60(sp)

    /* Read cause and handle */
    csrr    a0, mcause
    csrr    a1, mepc
    
    /* Check if interrupt (MSB set) or exception */
    bgez    a0, _handle_exception
    
_handle_interrupt:
    /* Call C interrupt handler if defined */
    .weak   isr_handler
    la      t0, isr_handler
    beqz    t0, _trap_return
    jalr    t0
    j       _trap_return

_handle_exception:
    /* Call C exception handler if defined */
    .weak   exception_handler
    la      t0, exception_handler
    beqz    t0, _trap_return
    jalr    t0

_trap_return:
    /* Restore registers */
    lw      ra, 0(sp)
    lw      t0, 4(sp)
    lw      t1, 8(sp)
    lw      t2, 12(sp)
    lw      a0, 16(sp)
    lw      a1, 20(sp)
    lw      a2, 24(sp)
    lw      a3, 28(sp)
    lw      a4, 32(sp)
    lw      a5, 36(sp)
    lw      a6, 40(sp)
    lw      a7, 44(sp)
    lw      t3, 48(sp)
    lw      t4, 52(sp)
    lw      t5, 56(sp)
    lw      t6, 60(sp)
    addi    sp, sp, 64
    
    mret

    .size _trap_handler, . - _trap_handler


/*
 * Interrupt Vector Table (for vectored mode, optional)
 * Place at fixed address if using MTVEC vectored mode
 */
    .section .vectors, "ax", @progbits
    .global _vectors
    .type _vectors, @function
    .align 8

_vectors:
    j       _trap_handler       /* 0: Exception */
    j       _trap_handler       /* 1: Supervisor software interrupt */
    j       _trap_handler       /* 2: Reserved */
    j       _trap_handler       /* 3: Machine software interrupt */
    j       _trap_handler       /* 4: Reserved */
    j       _trap_handler       /* 5: Supervisor timer interrupt */
    j       _trap_handler       /* 6: Reserved */
    j       _timer_handler      /* 7: Machine timer interrupt */
    j       _trap_handler       /* 8: Reserved */
    j       _trap_handler       /* 9: Supervisor external interrupt */
    j       _trap_handler       /* 10: Reserved */
    j       _trap_handler       /* 11: Machine external interrupt */

    .size _vectors, . - _vectors


/*
 * Machine Timer Interrupt Handler
 * For FreeRTOS tick or bare-metal timer
 */
    .global _timer_handler
    .type _timer_handler, @function
    .weak _timer_handler

_timer_handler:
    /* Default: just return (override this for FreeRTOS) */
    mret

    .size _timer_handler, . - _timer_handler
