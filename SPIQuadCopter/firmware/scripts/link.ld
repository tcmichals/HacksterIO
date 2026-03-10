/* VexRiscv Linker Script
 * Target: RV32IMC, 32KB RAM at 0x80000000
 * 
 * Memory Map:
 *   0x80000000 - 0x80007FFF : RAM (32KB)
 *   0x40000000 - 0x400FFFFF : Wishbone Peripherals
 *   0xFFFF0000 - 0xFFFF000F : Machine Timer (mtime/mtimecmp)
 */

ENTRY(_start)

/* RAM size can be overridden via -Wl,--defsym=__ram_size=... */
__ram_origin = DEFINED(__ram_origin) ? __ram_origin : 0x80000000;
__ram_size   = DEFINED(__ram_size)   ? __ram_size   : 32K;

/* Stack at top of RAM, reserve 2KB for stack */
__stack_size = DEFINED(__stack_size) ? __stack_size : 2K;

MEMORY
{
    RAM (rwx) : ORIGIN = __ram_origin, LENGTH = __ram_size
}

SECTIONS
{
    /* Code and read-only data */
    .text : ALIGN(4)
    {
        KEEP(*(.vectors))      /* Interrupt vector table */
        *(.text.init)          /* Startup code first */
        *(.text .text.*)
        *(.gnu.linkonce.t.*)
        
        /* C++ constructors/destructors */
        . = ALIGN(4);
        __init_array_start = .;
        KEEP(*(.init_array))
        KEEP(*(SORT(.init_array.*)))
        __init_array_end = .;
        
        . = ALIGN(4);
        __fini_array_start = .;
        KEEP(*(.fini_array))
        KEEP(*(SORT(.fini_array.*)))
        __fini_array_end = .;
    } > RAM

    /* Read-only data */
    .rodata : ALIGN(4)
    {
        *(.rodata .rodata.*)
        *(.gnu.linkonce.r.*)
        *(.srodata .srodata.*)
    } > RAM

    /* Initialized data */
    .data : ALIGN(4)
    {
        __data_start = .;
        *(.data .data.*)
        *(.gnu.linkonce.d.*)
        *(.sdata .sdata.*)
        *(.sdata2 .sdata2.*)
        . = ALIGN(4);
        __data_end = .;
    } > RAM

    /* Uninitialized data (BSS) */
    .bss (NOLOAD) : ALIGN(4)
    {
        __bss_start = .;
        *(.bss .bss.*)
        *(.gnu.linkonce.b.*)
        *(.sbss .sbss.*)
        *(COMMON)
        . = ALIGN(4);
        __bss_end = .;
    } > RAM

    /* Heap: from end of BSS to start of stack */
    .heap (NOLOAD) : ALIGN(8)
    {
        __heap_start = .;
        . = ORIGIN(RAM) + LENGTH(RAM) - __stack_size;
        __heap_end = .;
    } > RAM

    /* Stack: at top of RAM */
    .stack (NOLOAD) : ALIGN(16)
    {
        __stack_bottom = .;
        . = . + __stack_size;
        __stack_top = .;
    } > RAM

    /* Sanity check: ensure heap doesn't overlap BSS */
    ASSERT(__heap_start >= __bss_end, "Heap overlaps BSS!")
    ASSERT(__stack_top == ORIGIN(RAM) + LENGTH(RAM), "Stack not at top of RAM!")

    /* Symbols for FreeRTOS */
    _estack = __stack_top;
    _end = __bss_end;
    
    /* Debug info */
    /DISCARD/ :
    {
        *(.eh_frame)
        *(.comment)
        *(.note.*)
    }
}

/* Provide required symbols */
PROVIDE(__global_pointer$ = __data_start + 0x800);
PROVIDE(_gp = __global_pointer$);
