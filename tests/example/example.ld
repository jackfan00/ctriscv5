ENTRY(_Reset)
SECTIONS
{
 . = 0x80000000;
 .text : {
  *(.text)
  *(.rodata)
 }
 . = ALIGN(8);
 . = . + 0x1000; /* 4kB of stack memory */
 _stack_top = .;
 . = 0x90000000; 
 .data : {
  *(.data)
  *(.bss)
  *(COMMON)
 }
}
