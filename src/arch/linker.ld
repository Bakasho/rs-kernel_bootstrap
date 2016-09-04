ENTRY(__os_start)

SECTIONS {
  . = 0x100000;

  .rodata : ALIGN(4K) {
    KEEP(*(.multiboot_header))
    *(.rodata .rodata.*)
    . = ALIGN(4K);
  }

  .text : ALIGN(4K) {
    *(.text .text.*)
    . = ALIGN(4K);
  }

  .data : ALIGN(4K) {
    *(.data .data.*)
    . = ALIGN(4K);
  }

  .bss : ALIGN(4K) {
    *(.bss .bss.*)
    . = ALIGN(4K);
  }

  .data.rel.ro : ALIGN(4K) {
    *(.data.rel.ro.local*) *(.data.rel.ro .data.rel.ro.*)
    . = ALIGN(4K);
  }

  .gcc_except_table : ALIGN(4K) {
    *(.gcc_except_table)
    . = ALIGN(4K);
  }
}
