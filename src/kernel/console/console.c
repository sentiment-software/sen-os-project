#include "console.h"

// Global Console
Console console = {
  (unsigned char*)VGA_OFFSET_START,
  2,
  0,
  0
};

void printChar(char c) {
  *console.vga++ = c;
  *console.vga++ = VGA_BLACK_ON_GRAY;
  if (++console.col >= VGA_LINE_LENGTH) {
    newline();
  }
}

void print(const char* str) {
  for (; *str; str++) {
    printChar(*str);
  }
}

void println(const char* str) {
  print(str);
  newline();
}

void printAscii(const unsigned int var) {
  printChar((var >> 0) & 0xFF);
  printChar((var >> 8) & 0xFF);
  printChar((var >> 16) & 0xFF);
  printChar((var >> 24) & 0xFF);
}

void printHex(unsigned long var) {
  const char hexDigits[] = "0123456789ABCDEF";
  for (int i = 15; i >= 0; i--) {
    unsigned char byte = (var >> (i * 4)) & 0xF;
    printChar(hexDigits[byte]);
  }
}

void updateOffset() {
  console.vga = VGA_BUFFER + (2 * VGA_LINE_LENGTH * console.line) + (2 * console.col);
}

void newline() {
  console.line++;
  console.col = 0;
  updateOffset();
}