#include "console.h"

// Global Console
Console console = {
  (unsigned char*)VGA_OFFSET_START,
  2,
  0,
  0
};

void print(const char* str) {
  for (; *str; str++) {
    *console.vga++ = *str;
    *console.vga++ = VGA_BLACK_ON_GRAY;
    if (++console.col >= VGA_LINE_LENGTH) {
      newline();
    }
  }
}

void println(const char* str) {
  print(str);
  newline();
}

void updateOffset() {
  console.vga = VGA_BUFFER + (2 * VGA_LINE_LENGTH * console.line) + (2 * console.col);
}

void newline() {
  console.line++;
  console.col = 0;
  updateOffset();
}