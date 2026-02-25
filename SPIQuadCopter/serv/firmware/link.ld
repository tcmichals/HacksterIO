ENTRY(_start)

MEMORY
{
  RAM (rwx) : ORIGIN = 0x00000000, LENGTH = 8K
}

SECTIONS
{
  .text : { *(.text*) } > RAM
  .rodata : { *(.rodata*) } > RAM
  .data : { *(.data*) } > RAM
  
  .bss : {
    _bss_start = .;
    *(.bss*)
    *(COMMON)
    _bss_end = .;
  } > RAM
  
  . = ALIGN(4);
  _stack_top = ORIGIN(RAM) + LENGTH(RAM);
  
  /DISCARD/ : { *(.eh_frame) }
}
