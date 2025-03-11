#include "console/console.h"

#define VGA_BUFFER 0xB8000
#define VGA_OFFSET_START (VGA_BUFFER + 320)

typedef struct {
  unsigned long magic;
} BootInfo;

/**
 * Kernel entry point.
 */
__attribute__((section(".text.kmain")))
void kmain(BootInfo* bootInfo) {
  println("C Kernel Loaded!");
  if (bootInfo->magic == 0xDEADBEEF) {
    println("Boot magic arrived: 0xDEADBEEF");
  }
  print("Print very long line: 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789");
  for (;;);
}