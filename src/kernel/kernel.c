/**
 * 64-bit kernel entry point
 */

#define VGA_BUFFER 0xB8000
#define VGA_OFFSET_START (VGA_BUFFER + 240) // Start at 3rd line not to override protected mode code

// Structure to receive boot info from bootloader
typedef struct {
    unsigned long magic;
} BootInfo;

// VGA text output (simple, for demo)
void putchar(char c) {
    static unsigned short* vga = (unsigned short*)VGA_OFFSET_START;
    static int pos = 0;
    vga[pos++] = (0x70 << 8) | c; // Black on gray
}

// Print a string
void print(const char* str) {
    while (*str) {
        putchar(*str++);
    }
}

// Kernel entry point
void kmain(BootInfo* boot_info) {
    // Clear screen (fill with spaces)
    for (int i = 0; i < 80 * 25; i++) {
        putchar(' ');
    }

    // Reset position
    print("Kernel loaded!\n");
    print("Boot magic: ");
    if (boot_info->magic == 0xDEADBEEF) {
        print("0xDEADBEEF\n");
    } else {
        print("Invalid\n");
    }

//    // Test syscall ISR
//    print("Triggering syscall (int 0x80)...\n");
//    asm volatile ("int $0x80");
//
//    // Check if syscall worked
//    extern unsigned long syscall_flag;
//    if (syscall_flag) {
//        print("Syscall executed!\n");
//    }

    // Infinite loop
    for (;;);
}