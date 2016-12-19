use core;


#[allow(non_snake_case)]
#[no_mangle]
pub extern "C" fn _Unwind_Resume(_ex_obj: *mut ()) { }

#[lang = "eh_personality"]
extern "C" fn eh_personality() {}

#[lang = "panic_fmt"]
#[no_mangle]
extern fn panic_fmt(fmt: core::fmt::Arguments, file: &str, line: u32) -> ! {
    vga_println!("\n\nPANIC in {} at line {}:", file, line);
    vga_println!("\t\t{}", fmt);
    loop{}
}


/// 64 bit remainder on 32 bit arch
#[cfg(target_pointer_width = "32")]
#[no_mangle]
pub extern "C" fn __umoddi3(mut a: u64, mut b: u64) -> u64 {
    let mut hig = a >> 32; // The first 32 bits of a
    let mut d = 1;

    if hig >= b {
        hig /= b;
        a -= (hig * b) << 32;
    }

    while b > 0 && b < a {
        b *= 2;
        d *= 2;
    }

    loop {
        if a >= b {
            a -= b;
        }
        b >>= 1;
        d >>= 1;

        if d == 0 {
            break;
        }
    }

    a
}

/// 64 bit division on 32 bit arch
#[cfg(target_pointer_width = "32")]
#[no_mangle]
pub extern "C" fn __udivdi3(mut a: u64, mut b: u64) -> u64 {
    let mut res = 0;
    let mut hig = a >> 32; // The first 32 bits of a
    let mut d = 1;

    if hig >= b {
        hig /= b;
        res = hig << 32;
        a -= (hig * b) << 32;
    }

    while b > 0 && b < a {
        b *= 2;
        d *= 2;
    }

    loop {
        if a >= b {
            a -= b;
            res += d;
        }
        b >>= 1;
        d >>= 1;

        if d == 0 {
            break;
        }
    }

    res
}

/// 64 bit division and rem on 32 bit arch
#[cfg(target_pointer_width = "32")]
#[no_mangle]
pub extern "C" fn __udivremi3(mut a: u64, mut b: u64) -> (u64, u64) {
    let mut res = 0;
    let mut hig = a >> 32; // The first 32 bits of a
    let mut d = 1;

    if hig >= b {
        hig /= b;
        res = hig << 32;
        a -= (hig * b) << 32;
    }

    while b > 0 && b < a {
        b *= 2;
        d *= 2;
    }

    loop {
        if a >= b {
            a -= b;
            res += d;
        }
        b >>= 1;
        d >>= 1;

        if d == 0 {
            break;
        }
    }

    (res, a)
}
