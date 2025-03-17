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

# Build Flags
ASM_BIN_FLAGS = -f bin -o $@ $<
ASM_ELF_FLAGS = -f elf64 -o $@ $<
CFLAGS = -ffreestanding -mno-red-zone -Wall -Wextra -c -O0
LINKER_SCRIPT = $(BUILD_DIR)\kernel.ld
LDFLAGS = -T $(LINKER_SCRIPT) -nostdlib

# Run Flags
EMU_DRIVE = -drive format=raw,file=$<
EMU_CPU = -cpu Skylake-Client-v4
EMU_SMP = -smp 16,sockets=1,cores=8,threads=2

# Files
BOOT0_SRC = $(BOOT_DIR)\boot0.asm
BOOT1_SRC = $(BOOT_DIR)\boot1.asm
NULL_SRC = $(BOOT_DIR)\null.asm
KERNEL_ASM_SRC = $(KERNEL_DIR)\kernel.asm
KERNEL_C_SRC = $(KERNEL_DIR)\kernel.c
CONSOLE_SRC = $(KERNEL_DIR)\console\console.c
CONSOLE_HDR = $(KERNEL_DIR)\console\console.h
CPUINFO_ASM_SRC = $(KERNEL_DIR)\cpu\CpuInfo.asm

BOOT0_BIN = $(TARGET_DIR)\boot0.bin
BOOT1_BIN = $(TARGET_DIR)\boot1.bin
NULL_BIN = $(TARGET_DIR)\null.bin
KERNEL_OBJS = $(TARGET_DIR)\CpuInfo_asm.o $(TARGET_DIR)\kernel_asm.o $(TARGET_DIR)\kernel.o $(TARGET_DIR)\console.o
KERNEL_BIN = $(TARGET_DIR)\kernel.bin
OS_BIN = $(TARGET_DIR)\os.bin

BOOT0_DIS = $(TARGET_DIR)\$(DEBUG_DIR)\boot0.dis
BOOT1_DIS = $(TARGET_DIR)\$(DEBUG_DIR)\boot1.dis
KERNEL_DIS = $(TARGET_DIR)\$(DEBUG_DIR)\kernel.dis
OS_DIS = $(TARGET_DIR)\$(DEBUG_DIR)\os.dis

# ====================================================================================================
# PHONY TARGETS
# ====================================================================================================

.PHONY: all
all: clean $(OS_BIN) $(OS_DIS) debug-all

.PHONY: clean
clean:
	if exist $(TARGET_DIR) rmdir $(TARGET_DIR) /S /Q

.PHONY: run
run: $(OS_BIN)
	$(QEMU) $(EMU_DRIVE) $(EMU_CPU) $(EMU_SMP)

.PHONY: debug-all
debug-all: $(BOOT0_DIS) $(BOOT1_DIS) $(KERNEL_DIS) $(OS_DIS)

# ====================================================================================================
# DIRECTORY TARGETS
# ====================================================================================================

# Create build directory
$(TARGET_DIR):
	if not exist $@ mkdir $@

# Create debug directory
$(DEBUG_DIR): $(TARGET_DIR)
	if not exist $<\$@ mkdir $<\$@

# ====================================================================================================
# BOOT TARGETS
# ====================================================================================================

# Assemble boot0.asm
$(BOOT0_BIN): $(BOOT0_SRC) | $(TARGET_DIR)
	$(ASM) $(ASM_BIN_FLAGS)

# Assemble boot1.asm
$(BOOT1_BIN): $(BOOT1_SRC) | $(TARGET_DIR)
	$(ASM) $(ASM_BIN_FLAGS)

# Assemble null.asm (hack padding temporarily)
$(NULL_BIN): $(NULL_SRC) | $(TARGET_DIR)
	$(ASM) $(ASM_BIN_FLAGS)

# ====================================================================================================
# KERNEL TARGETS
# ====================================================================================================

# Link kernel objects into kernel.bin
$(KERNEL_BIN): $(KERNEL_OBJS) $(LINKER_SCRIPT)
	$(LD) $(LDFLAGS) -o $@ $(KERNEL_OBJS)

# Assemble kernel.asm
$(TARGET_DIR)\kernel_asm.o: $(KERNEL_ASM_SRC) | $(TARGET_DIR)
	$(ASM) $(ASM_ELF_FLAGS)

# Assemble CpuInfo.asm
$(TARGET_DIR)\CpuInfo_asm.o: $(CPUINFO_ASM_SRC) | $(TARGET_DIR)
	$(ASM) $(ASM_ELF_FLAGS)

# Compile kernel.c
$(TARGET_DIR)\kernel.o: $(KERNEL_C_SRC) $(CONSOLE_HDR) | $(TARGET_DIR)
	$(CC) $(CFLAGS) -o $@ $<

# Compile console.c
$(TARGET_DIR)\console.o: $(CONSOLE_SRC) $(CONSOLE_HDR) | $(TARGET_DIR)
	$(CC) $(CFLAGS) -o $@ $<

# ====================================================================================================
# OS IMAGE TARGETS
# ====================================================================================================

# Build OS image flat binary
$(OS_BIN): $(BOOT0_BIN) $(BOOT1_BIN) $(KERNEL_BIN) $(NULL_BIN)
	copy $(BOOT0_BIN)/B + $(BOOT1_BIN)/B + $(KERNEL_BIN)/B + $(NULL_BIN)/B $(OS_BIN)/B

# ====================================================================================================
# DEBUG TARGETS
# ====================================================================================================

# Disassemble boot0.bin
$(BOOT0_DIS): $(BOOT0_BIN) | $(DEBUG_DIR)
	ndisasm -b 16 -o 0x7C00 $< > $@

# Disassemble boot1.bin
$(BOOT1_DIS): $(BOOT1_BIN) | $(DEBUG_DIR)
	ndisasm -o 0x1000 $< > $@

# Disassemble kernel.bin
$(KERNEL_DIS): $(KERNEL_BIN) | $(DEBUG_DIR)
	ndisasm -b 64 -o 0xA000 $< > $@

# Disassemble os.bin
$(OS_DIS): $(OS_BIN) | $(DEBUG_DIR)
	ndisasm -o 0x0 $< > $@