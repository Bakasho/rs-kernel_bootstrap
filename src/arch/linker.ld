ENTRY(_kernel_start)

SECTIONS {
    . = 0x100000;

    .text : {
		*(.multiboot_header);
		*(.text);
	}
}
