#include "console/console.h"

#define VGA_BUFFER 0xB8000
#define VGA_OFFSET_START (VGA_BUFFER + 320)

typedef struct {
  unsigned long magic;
  unsigned int cpuBasicMax;
  unsigned int cpuExtMax;
  unsigned int cpuVendorId1;
  unsigned int cpuVendorId2;
  unsigned int cpuVendorId3;
  unsigned int cpuExtSignature;
  unsigned int cpuExtFeatures;
} BootInfo;

/**
 * Kernel entry point.
 */
__attribute__((section(".text.kmain")))
void kmain(BootInfo* bootInfo) {
  println("C Kernel Loaded!");
  println("-- Boot Info --");
  print("Magic: ");
  printHex(bootInfo->magic);
  newline();
  print("CPU: ");
  printAscii(bootInfo->cpuVendorId1);
  printAscii(bootInfo->cpuVendorId2);
  printAscii(bootInfo->cpuVendorId3);
  newline();
  for (;;);
}