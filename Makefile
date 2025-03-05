.PHONY: clean

source := src
target := target

all: clean create-target compile-boot

clean:
	if exist "${target}\\" rmdir "${target}\\" /S /Q
create-target:
	if not exist "${target}\\" mkdir "${target}\\"
compile-boot:
	nasm ${source}\boot\glob.asm -f bin -o ${target}\glob.bin
	nasm ${source}\boot\boot0.asm -f bin -o ${target}\boot0.bin
	nasm ${source}\boot\boot1.asm -f bin -o ${target}\boot1.bin
	copy ${target}\boot0.bin /B + ${target}\boot1.bin /B + ${target}\glob.bin /B ${target}\os.bin /B
