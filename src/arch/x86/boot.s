.section .rodata
.align 4096


gdt_contents:
  .byte 0, 0, 0, 0, 0, 0, 0, 0		      	/* Offset: 0  - Null selector - required */
  .byte 255, 255, 0, 0, 0, 0x9A, 0xCF, 0	/* Offset: 8  - KM Code selector - covers the entire 4GiB address range */
  .byte 255, 255, 0, 0, 0, 0x92, 0xCF, 0	/* Offset: 16 - KM Data selector - covers the entire 4GiB address range */
  .byte 255, 255, 0, 0, 0, 0xFA, 0xCF, 0	/* Offset: 24 - UM Code selector - covers the entire 4GiB address range */
  .byte 255, 255, 0, 0, 0, 0xF2, 0xCF, 0	/* Offset: 32 - UM Data selector - covers the entire 4GiB address range */

/* GDT - Global Descriptor Table */
/* Size - Change iff adding/removing rows from GDT contents */
/* Size = Total bytes in GDT - 1 */
gdt_ptr:
  .byte 39, 0, 0, 0, 0, 0


.section .text
.align 4096
.code32
.extern __os_main
.global __os_start


__os_start:
  cli

  /* Move Multiboot info pointer to edi to pass it to the kernel. We must not */
  /* modify the `edi` register until the kernel is called. */
  movl %ebx, %edi

  call check_multiboot
  call check_cpuid

  /* Switch to protected mode */
  movl %cr0, %eax
  orl $1, %eax
  movl %eax, %cr0

  /* BEGIN - Set stack pointer */
  movl $kernel_stack_top, %esp

  /* Tell CPU about GDT */
  movl $gdt_contents, (gdt_ptr + 2)
  movl $gdt_ptr, %eax
  lgdt (%eax)

  /* Set data segments */
  movw $0x10, %ax
  movw %ax, %ds
  movw %ax, %es
  movw %ax, %fs
  movw %ax, %gs
  movw %ax, %ss

  ljmp $0x8, $flush_cs_gdt


flush_cs_gdt:

  pushl %edi
  call __os_main

  movb $'r', %al
  call error


/* Throw error 0 if eax doesn't contain the Multiboot 2 magic value (0x36d76289). */
check_multiboot:
  cmpl $0x36D76289, %eax
  jne no_multiboot
  ret
no_multiboot:
  movb $'0', %al
  jmp error


/* Throw error 1 if the CPU doesn't support the CPUID command. */
check_cpuid:
  pushf                /* Store the FLAGS-register. */
  pop %eax             /* Restore the A-register. */
  mov %eax, %ecx       /* Set the C-register to the A-register. */
  xor $1 << 21, %eax   /* Flip the ID-bit, which is bit 21. */
  push %eax            /* Store the A-register. */
  popf                 /* Restore the FLAGS-register. */
  pushf                /* Store the FLAGS-register. */
  pop %eax             /* Restore the A-register. */
  push %ecx            /* Store the C-register. */
  popf                 /* Restore the FLAGS-register. */
  xor %ecx, %eax       /* Do a XOR-operation on the A-register and the C-register. */
  jz no_cpuid          /* The zero flag is set, no CPUID. */
  ret                  /* CPUID is available for use. */
no_cpuid:
  mov $'1', %al
  jmp error


/* Prints `ERR: ` and the given error code to screen and hangs. */
/* parameter: error code (in ascii) in al */
error:
  movl $0x4f524f45, (0xb8000)
  movl $0x4f3a4f52, (0xb8004)
  movl $0x4f204f20, (0xb8008)
  movb %al, (0xb800a)
  hlt


  .section .data
  .align 4096
  .global __os_page_directory, __os_page_tables


.section .bss
.align 4096


kernel_stack_bottom:
  .skip 65535
kernel_stack_top:
