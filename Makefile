.PHONY: all clean run debug

# Directories
SRC_DIR = src
BOOT_DIR = $(SRC_DIR)\boot
KERNEL_DIR = $(SRC_DIR)\kernel
TARGET_DIR = target
BUILD_DIR = build
DEBUG_DIR = debug

# Tools
ASM = nasm
CC = x86_64-elf-gcc
LD = x86_64-elf-ld
QEMU = qemu-system-x86_64

# Flags
ASMFLAGS = -f bin
CFLAGS = -ffreestanding -mno-red-zone -Wall -Wextra -c
LINKER_SCRIPT = $(BUILD_DIR)\kernel.ld
LDFLAGS = -T $(LINKER_SCRIPT) -nostdlib

# Files
BOOT0_SRC = $(BOOT_DIR)\boot0.asm
BOOT1_SRC = $(BOOT_DIR)\boot1.asm
GLOB_SRC = $(BOOT_DIR)\glob.asm
NULL_SRC = $(BOOT_DIR)\null.asm
KERNEL_SRC = $(KERNEL_DIR)\kernel.c
CONSOLE_SRC = $(KERNEL_DIR)\console\console.c
CONSOLE_HDR = $(KERNEL_DIR)\console\console.h

BOOT0_BIN = $(TARGET_DIR)\boot0.bin
BOOT1_BIN = $(TARGET_DIR)\boot1.bin
GLOB_BIN = $(TARGET_DIR)\glob.bin
NULL_BIN = $(TARGET_DIR)\null.bin
KERNEL_OBJS = $(TARGET_DIR)\kernel.o $(TARGET_DIR)\console.o
KERNEL_BIN = $(TARGET_DIR)\kernel.bin
OS_BIN = $(TARGET_DIR)\os.bin

BOOT0_DIS = $(TARGET_DIR)\$(DEBUG_DIR)\boot0.dis
BOOT1_DIS = $(TARGET_DIR)\$(DEBUG_DIR)\boot1.dis
GLOB_DIS = $(TARGET_DIR)\$(DEBUG_DIR)\glob.dis
KERNEL_DIS = $(TARGET_DIR)\$(DEBUG_DIR)\kernel.dis
OS_DIS = $(TARGET_DIR)\$(DEBUG_DIR)\os.dis

all: $(OS_BIN) $(OS_DIS) debug-all

# Build os.bin from the binaries
$(OS_BIN): $(BOOT0_BIN) $(BOOT1_BIN) $(GLOB_BIN) $(KERNEL_BIN) $(NULL_BIN)
	copy $(BOOT0_BIN)/B + $(BOOT1_BIN)/B + $(GLOB_BIN)/B + $(KERNEL_BIN)/B + $(NULL_BIN)/B $(OS_BIN)/B

# Assemble boot0.asm
$(BOOT0_BIN): $(BOOT0_SRC) | $(TARGET_DIR)
	$(ASM) $(ASMFLAGS) -o $@ $<

# Assemble boot1.asm
$(BOOT1_BIN): $(BOOT1_SRC) | $(TARGET_DIR)
	$(ASM) $(ASMFLAGS) -o $@ $<

# Assemble glob.asm
$(GLOB_BIN): $(GLOB_SRC) | $(TARGET_DIR)
	$(ASM) $(ASMFLAGS) -o $@ $<

# Assemble null.asm (hack padding temporarily)
$(NULL_BIN): $(NULL_SRC) | $(TARGET_DIR)
	$(ASM) $(ASMFLAGS) -o $@ $<

# Link kernel objects into kernel.bin
$(KERNEL_BIN): $(KERNEL_OBJS) $(LINKER_SCRIPT)
	$(LD) $(LDFLAGS) -o $@ $(KERNEL_OBJS)

# Compile kernel.c
$(TARGET_DIR)\kernel.o: $(KERNEL_SRC) $(CONSOLE_HDR) | $(TARGET_DIR)
	$(CC) $(CFLAGS) -o $@ $<

# Compile console.c
$(TARGET_DIR)\console.o: $(CONSOLE_SRC) $(CONSOLE_HDR) | $(TARGET_DIR)
	$(CC) $(CFLAGS) -o $@ $<

# Create build directory
$(TARGET_DIR):
	if not exist $@ mkdir $@

# Create debug directory
$(DEBUG_DIR): $(TARGET_DIR)
	if not exist $<\$@ mkdir $<\$@

# Clean
clean:
	rmdir $(TARGET_DIR) /S /Q

# Run in QEMU
run: $(OS_BIN)
	$(QEMU) -drive format=raw,file=$<

# Generate all debug objects
debug-all: $(BOOT0_DIS) $(BOOT1_DIS) $(GLOB_DIS) $(KERNEL_DIS) $(OS_DIS)

# Disassemble boot0.bin
$(BOOT0_DIS): $(BOOT0_BIN) | $(DEBUG_DIR)
	ndisasm -b 16 -o 0x7C00 $< > $@

$(BOOT1_DIS): $(BOOT1_BIN) | $(DEBUG_DIR)
	ndisasm -o 0x1000 $< > $@

$(GLOB_DIS): $(GLOB_BIN) | $(DEBUG_DIR)
	ndisasm -o 0x2000 $< > $@

$(KERNEL_DIS): $(KERNEL_BIN) | $(DEBUG_DIR)
	ndisasm -b 64 -o 0xA000 $< > $@

$(OS_DIS): $(OS_BIN) | $(DEBUG_DIR)
	ndisasm -o 0x0 $< > $@
