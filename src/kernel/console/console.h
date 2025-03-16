#ifndef CONSOLE_H
#define CONSOLE_H

#define VGA_BUFFER ((unsigned char*)0xB8000)
#define VGA_WIDTH 80
#define VGA_HEIGHT 25
#define VGA_SIZE (VGA_WIDTH * VGA_HEIGHT * 2)

#define VGA_COLOR(fg, bg) (((bg) << 4) | (fg))
#define VGA_COLOR_BLACK        0x0
#define VGA_COLOR_BLUE         0x1
#define VGA_COLOR_GREEN        0x2
#define VGA_COLOR_CYAN         0x3
#define VGA_COLOR_RED          0x4
#define VGA_COLOR_PURPLE       0x5
#define VGA_COLOR_BROWN        0x6
#define VGA_COLOR_GRAY         0x7
#define VGA_COLOR_DARK_GRAY    0x8
#define VGA_COLOR_LIGHT_BLUE   0x9
#define VGA_COLOR_LIGHT_GREEN  0xA
#define VGA_COLOR_LIGHT_CYAN   0xB
#define VGA_COLOR_LIGHT_RED    0xC
#define VGA_COLOR_LIGHT_PURPLE 0xD
#define VGA_COLOR_YELLOW       0xE
#define VGA_COLOR_WHITE        0xF
#define VGA_DEFAULT_COLOR VGA_COLOR(VGA_COLOR_BLACK, VGA_COLOR_GRAY)

typedef struct {
  unsigned char* vga;
  unsigned char col;
  unsigned char line;
} Console;

void console_init(void);
void console_clear(void);
void console_print_char(char c);
void console_print(const char* str);
void console_println(const char* str);
void console_print_hex(unsigned long var, int digits);
void console_print_dec(unsigned long var);

#endif // CONSOLE_H