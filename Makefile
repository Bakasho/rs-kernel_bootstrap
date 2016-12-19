#
arch ?= x86
qemu_arch ?= i386
rust_arch ?= i586
gnu_arch ?= i586
bits ?= 32
gnu_machine ?= i586

#\
arch ?= x86_64\
qemu_arch ?= x86_64\
rust_arch ?= x86_64\
gnu_arch ?= x86_64\
bits ?= 64\
gnu_machine ?= core2\

machine ?= unknown
os ?= linux
other ?= gnu

gnu_target ?= $(gnu_arch)-$(machine)-$(os)-$(other)
rust_target ?= $(rust_arch)-$(machine)-$(os)-$(other)

ld ?= $(gnu_target)-ld
as ?= $(gnu_target)-as
nm ?= $(gnu_target)-nm

device ?= pc

asm_arch_src_files := $(wildcard src/arch/$(arch)/*.s)
asm_noarch_src_files := $(wildcard src/arch/*.s)

asm_src_files := $(asm_arch_src_files) $(asm_noarch_src_files)
asm_obj_files := \
	$(patsubst src/arch/$(arch)/%.s, build/arch/$(arch)/%.o, $(asm_arch_src_files)) \
	$(patsubst src/arch/%.s, build/arch/%.o, $(asm_noarch_src_files))

all: run

clean:
	cargo clean
	rm -rf build

run: build_iso
	qemu-system-$(qemu_arch) -machine $(device) \
		-cdrom build/$(arch)-os.iso

debug: build_iso
	qemu-system-$(qemu_arch) -machine $(device) \
		-cdrom build/$(arch)-os.iso \
		-monitor stdio

inspect: build
	$(nm) -n build/os_$(arch).bin

build_iso: build
	mkdir -p build/isofiles/boot/grub
	cp build/os_$(arch).bin build/isofiles/boot/os.bin
	cp src/arch/grub.cfg build/isofiles/boot/grub
	grub-mkrescue -o build/$(arch)-os.iso build/isofiles 2> /dev/null

build: build_init $(asm_obj_files) build_cargo build_linker

build_init:
	mkdir -p build/arch/$(arch)

build_cargo:
	cargo rustc --target $(rust_target) -- -Z no-landing-pads

build_linker:
	$(ld) -O -n --gc-sections \
		-o build/os_$(arch).bin \
		$(asm_obj_files) target/$(rust_target)/debug/libos.a \
		-T src/arch/linker.ld

build/arch/$(arch)/%.o: src/arch/$(arch)/%.s
	$(as) --$(bits) -march=$(gnu_machine) $< -o $@

build/arch/%.o: src/arch/%.s
	$(as) --$(bits) -march=$(gnu_machine)  $< -o $@
