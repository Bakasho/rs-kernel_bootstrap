use core;


#[allow(non_snake_case)]
#[no_mangle]
pub extern "C" fn _Unwind_Resume() -> ! { loop{} }

#[lang = "eh_personality"]
extern "C" fn eh_personality() {}

#[lang = "panic_fmt"]
extern fn panic_fmt(fmt: core::fmt::Arguments, file: &str, line: u32) -> ! {
    vga_println!("\n\nPANIC in {} at line {}:", file, line);
    vga_println!("\t\t{}", fmt);
    loop{}
}
