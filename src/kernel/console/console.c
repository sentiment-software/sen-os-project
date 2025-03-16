#include "console.h"

// Global console instance
Console console = { VGA_BUFFER, 0, 0 };

void console_init(void) {
    console_clear();
}

void console_clear(void) {
    unsigned char* vga = VGA_BUFFER;
    for (int i = 0; i < VGA_WIDTH * VGA_HEIGHT; i++) {
        *vga++ = ' ';
        *vga++ = VGA_DEFAULT_COLOR;
    }
    console.vga = VGA_BUFFER;
    console.col = 0;
    console.line = 0;
}

void console_print_char(char c) {
    if (c == '\n') {
        console.line++;
        console.col = 0;
    } else {
        *console.vga++ = c;
        *console.vga++ = VGA_DEFAULT_COLOR;
        if (++console.col >= VGA_WIDTH) {
            console.line++;
            console.col = 0;
        }
    }

    if (console.line >= VGA_HEIGHT) {
        // Scroll up
        for (int i = 0; i < VGA_HEIGHT - 1; i++) {
            for (int j = 0; j < VGA_WIDTH; j++) {
                int src = (i + 1) * VGA_WIDTH * 2 + j * 2;
                int dst = i * VGA_WIDTH * 2 + j * 2;
                VGA_BUFFER[dst] = VGA_BUFFER[src];
                VGA_BUFFER[dst + 1] = VGA_BUFFER[src + 1];
            }
        }
        // Clear last line
        for (int j = 0; j < VGA_WIDTH; j++) {
            int pos = (VGA_HEIGHT - 1) * VGA_WIDTH * 2 + j * 2;
            VGA_BUFFER[pos] = ' ';
            VGA_BUFFER[pos + 1] = VGA_DEFAULT_COLOR;
        }
        console.line = VGA_HEIGHT - 1;
    }
    console.vga = VGA_BUFFER + (console.line * VGA_WIDTH * 2) + (console.col * 2);
}

void console_print(const char* str) {
    for (; *str; str++) {
        console_print_char(*str);
    }
}

void console_println(const char* str) {
    console_print(str);
    console_print_char('\n');
}

void console_print_hex(unsigned long var, int digits) {
    const char hexDigits[] = "0123456789ABCDEF";
    if (digits < 1 || digits > 16) digits = 16;  // Max 64-bit
    console_print("0x");
    for (int i = digits - 1; i >= 0; i--) {
        unsigned char nibble = (var >> (i * 4)) & 0xF;
        console_print_char(hexDigits[nibble]);
    }
}

void console_print_dec(unsigned long var) {
    if (var == 0) {
        console_print_char('0');
        return;
    }
    char digits[20];  // Max 64-bit unsigned = 20 digits
    int i = 0;
    while (var > 0) {
        digits[i++] = (var % 10) + '0';
        var /= 10;
    }
    for (int j = i - 1; j >= 0; j--) {
        console_print_char(digits[j]);
    }
}