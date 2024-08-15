.PHONY: clean

source := src\main
target := target

all: bootloader

bootloader:
	if not exist "${target}\\" mkdir "${target}\\"
	nasm ${source}\boot\bootloader.asm -f bin -o ${target}\bootloader.bin

clean:
	rmdir "${target}\\" /S /Q