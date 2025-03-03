.PHONY: clean

source := src
target := target

all: clean create-target build-all
build-all: build-bootloader
build-bootloader: compile-boot0 compile-boot1 merge-boot

clean:
	rmdir "${target}\\" /S /Q
create-target:
	if not exist "${target}\\" mkdir "${target}\\"
compile-boot0:
	nasm ${source}\boot\boot0.asm -f bin -o ${target}\boot0.bin
compile-boot1:
	nasm ${source}\boot\boot1.asm -f bin -o ${target}\boot1.bin
merge-boot:
	copy ${target}\boot0.bin /B + ${target}\boot1.bin /B ${target}\os.bin /B