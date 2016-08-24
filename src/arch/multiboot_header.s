.section .multiboot_header
.code32

multiboot_header_start:
  .long 0xE85250D6             /* magic number (multiboot 2) */
  .long 0                      /* architecture 0 (protected mode i386) */
  .long multiboot_header_end - multiboot_header_start
  /* checksum */
  .long 0x100000000 - (0xE85250D6 + 0 + (multiboot_header_end - multiboot_header_start))

  /* insert optional multiboot tags here */

  /* required end tag */
  .word 0 /* type */
  .word 0 /* flags */
  .long 8 /* size */
multiboot_header_end:
