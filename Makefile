arch ?= x86_64
target ?= $(arch)-unknown-linux-gnu
machine ?= pc
ld ?= $(arch)-ld
as ?= $(arch)-as

all: run

clean:
	cargo clean
	rm -rf dest

run: build_iso
	qemu-system-$(arch) -machine $(machine) \
		-cdrom dest/os_$(arch).iso

debug: build_iso
	qemu-system-$(arch) -machine $(machine) \
		-cdrom dest/os_$(arch).iso \
		-monitor stdio

inspect: build
	$(arch)-nm -n dest/kernel_$(arch).bin

build_iso: build
	mkdir -p dest/isofiles/boot/grub
	cp dest/kernel_$(arch).bin dest/isofiles/boot/kernel.bin
	cp src/arch/$(arch)/grub.cfg dest/isofiles/boot/grub
	grub-mkrescue -o dest/os_$(arch).iso dest/isofiles 2> /dev/null

build: build_init build_asm build_cargo build_linker

build_init:
	mkdir -p dest

build_cargo:
	cargo rustc --target $(target) -- -Z no-landing-pads

build_linker:
	$(ld) -n --gc-sections \
		-o dest/kernel_$(arch).bin \
		dest/multiboot_header.o dest/long_mode_init.o dest/boot.o \
		target/$(target)/debug/libkernel_bootstrap.a \
		-T src/arch/$(arch)/linker.ld

build_asm:
	$(as) src/arch/$(arch)/multiboot_header.s -o dest/multiboot_header.o
	$(as) src/arch/$(arch)/long_mode_init.s -o dest/long_mode_init.o
	$(as) src/arch/$(arch)/boot.s -o dest/boot.o
