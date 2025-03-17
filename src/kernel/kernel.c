#include "console/console.h"

extern struct {
  unsigned int cpuidMaxLeafBasic;
  unsigned int cpuidMaxLeafExtf;
  unsigned char vendorString[16];
  unsigned int versionInfo;
  unsigned char brandIndex;
  unsigned char cflushSize;
  unsigned long featureBasic;
  unsigned int sigExtf;
  unsigned char featureExt;
  unsigned char shiftLp;
  unsigned char shiftCore;
  unsigned char legacyApicId;
  unsigned char legacyCountLp;
} CpuInfo __attribute__((packed));

extern void kernel_entry(void); // ASM kernel entry for the linker

/**
 * Kernel entry point.
 */
//__attribute__((section(".text.kmain")))
void kmain() {
  console_init();
  console_println("Kernel loaded!");
  console_print("CPUID Max Leaf: Basic [");
  console_print_hex(CpuInfo.cpuidMaxLeafBasic, 8);
  console_print("], Ext [");
  console_print_hex(CpuInfo.cpuidMaxLeafExtf, 8);
  console_print("]\nCPU: ");
  console_print(CpuInfo.vendorString);
  console_print(" [");
  console_print_hex(CpuInfo.versionInfo, 8);
  console_print("]\nShift: LP [");
  console_print_hex(CpuInfo.shiftLp, 2);
  console_print("], Core [");
  console_print_hex(CpuInfo.shiftCore, 2);
  console_print("]\nLegacy: APIC ID [");
  console_print_dec(CpuInfo.legacyApicId);
  console_print("], LP# [");
  console_print_dec(CpuInfo.legacyCountLp);
  console_print("]");
  for (;;);
}