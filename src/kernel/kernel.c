#define VGA_BUFFER 0xB8000
#define VGA_OFFSET_START (VGA_BUFFER + 240) // Start at 3rd line not to override protected mode code

void print(const char* str) {
    volatile unsigned char* vga = (unsigned char*)VGA_OFFSET_START;
    for (; *str; str++) {
        *vga++ = *str;
        *vga++ = 0x70;
    }
}

__attribute__((section(".text.kmain")))
void kmain(void) {
    print("C Kernel Loaded!");
    for (;;);
}

unsigned char padding[400] = {0};