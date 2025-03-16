#include "console/console.h"

typedef struct {
  unsigned long magic;
  unsigned int cpuBasicMax;
  unsigned int cpuExtMax;
  unsigned char cpuVendorId[16];
  unsigned int cpuVersionInfo;
  unsigned char cpuBrandIndex;
  unsigned char cpuCflushSize;
  unsigned char cpuLegacyMaxApicId;
  unsigned long cpuBasicFeatures;
  unsigned int cpuExtSignature;
  unsigned char cpuExtFeatures;
  unsigned char cpuLpShift;
  unsigned char cpuCoreShift;
  unsigned char cpuApicId;
  unsigned char cpuLpCount;
}__attribute__((packed)) BootInfo;

/**
 * Kernel entry point.
 */
__attribute__((section(".text.kmain")))
void kmain(BootInfo* bootInfo) {
  console_init();
  console_println("Kernel Booted!");
  console_print("Boot Magic: ");
  console_print_hex(bootInfo->magic, 16);
  console_print("\nCPUID: Max Basic: ");
  console_print_hex(bootInfo->cpuBasicMax, 8);
  console_print(", Max Ext: ");
  console_print_hex(bootInfo->cpuExtMax, 8);
  console_print("\nCPU: ");
  console_print(bootInfo->cpuVendorId);
  console_print(", ");
  console_print_hex(bootInfo->cpuVersionInfo, 8);
  console_print("\nLP-Shift: ");
  console_print_hex(bootInfo->cpuLpShift, 2);
  console_print(", Core-Shift: ");
  console_print_hex(bootInfo->cpuCoreShift, 2);
  console_print("\nLeaf 1: APIC-ID: ");
  console_print_dec(bootInfo->cpuApicId);
  console_print(", LP#: ");
  console_print_dec(bootInfo->cpuLpCount);
  for (;;);
}