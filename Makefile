.PHONY: clean

source := src
target := target
build := build

all: clean create-target build-boot build-kernel merge-bin debug-dis

clean:
	if exist "${target}\\" rmdir "${target}\\" /S /Q
create-target:
	if not exist "${target}\\" mkdir "${target}\\"
	if not exist "${target}\\debug\\" mkdir "${target}\\debug\\"
build-boot:
	nasm ${source}\boot\glob.asm -f bin -o ${target}\glob.bin
	nasm ${source}\boot\boot0.asm -f bin -o ${target}\boot0.bin
	nasm ${source}\boot\boot1.asm -f bin -o ${target}\boot1.bin
build-kernel:
	x86_64-elf-gcc -ffreestanding -mno-red-zone -c ${source}\kernel\kernel.c -o ${target}\kernel.o
	x86_64-elf-ld -T ${build}\kernel.ld -o ${target}\kernel.bin ${target}\kernel.o
merge-bin:
	copy ${target}\boot0.bin /B + ${target}\boot1.bin /B + ${target}\glob.bin /B + ${target}\kernel.bin ${target}\os.bin /B
debug-dis:
	ndisasm -b 64 -o 0xA000 ${target}\kernel.bin > ${target}\debug\kernel.dis
	ndisasm -o 0x0 ${target}\os.bin > ${target}\debug\os.dis