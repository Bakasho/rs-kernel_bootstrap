#![feature(lang_items)]
#![no_std]


#[macro_use]
extern crate vga;

extern crate rlibc;
extern crate multiboot2;
extern crate kernel;
extern crate paging;
extern crate memory;


pub mod lang_items;


use multiboot2::Multiboot2;
use kernel::Kernel;
use paging::arch;


#[no_mangle]
pub extern "C" fn __os_main(multiboot_information_address: usize) -> ! {
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

    unsafe {
        paging::init(0x1000000);
        memory::init(arch::get_page_end());
    }

    vga_println!(
        "Kernel start: {:?} end: {:?}, boot_start: {:?} boot_end: {:?}",
        kernel.get_kernel_start_address(), kernel.get_kernel_end_address(),
        kernel.get_boot_start_address(), kernel.get_kernel_end_address()
    );

    vga_println!("Hello, world!");

    loop {}
}
