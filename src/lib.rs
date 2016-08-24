#![feature(lang_items)]
#![no_std]


#[macro_use]
extern crate vga;

extern crate rlibc;
extern crate multiboot2;
extern crate kernel;


pub mod lang_items;


use multiboot2::Multiboot2;
use kernel::Kernel;


#[no_mangle]
pub extern "C" fn __os_main(multiboot_information_address: usize) -> ! {
    /*
    let hello = b"Hello World!";
    let color_byte = 0x1f; // white foreground, blue background

    let mut hello_colored = [color_byte; 24];
    for (i, char_byte) in hello.into_iter().enumerate() {
        hello_colored[i*2] = *char_byte;
    }

    // write `Hello World!` to the center of the VGA text buffer
    let buffer_ptr = (0xb8000 + 1988) as *mut _;
    unsafe { *buffer_ptr = hello_colored };
    */

    let multiboot = unsafe {
        Multiboot2::new(multiboot_information_address)
    };

    let memory_map_tag = multiboot.get_memory_map_tag().expect("Memory map tag required");
    let elf_sections_tag = multiboot.get_elf_sections_tag().expect("Elf sections tag required");

    let kernel_start = elf_sections_tag
        .get_sections()
        .filter(|s| s.is_allocated())
        .map(|s| s.get_address())
        .min()
        .unwrap();

    let kernel_end = elf_sections_tag
        .get_sections()
        .filter(|s| s.is_allocated())
        .map(|s| s.get_address() + s.get_size())
        .max()
        .unwrap();

    let kernel = Kernel::new(
        kernel_start as usize,
        kernel_end as usize,
        multiboot.get_start_address() as usize,
        multiboot.get_end_address() as usize,
        memory_map_tag.get_memory_areas()
    );

    vga_println!("Hello, world!");

    loop {}
}
