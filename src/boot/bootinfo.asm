%include "src/boot/definitions/bootinfo.asm"

; ===== Boot Information passed to the kernel =====
boot_info:
  .magic: dq 0xDEADBEEF69696969

  ; Maximum input values for CPUID leafs
  .cpu_basic_max: dd 0
  .cpu_extf_max: dd 0

  ; CPU Vendor ID
  .cpu_vendor_id:
    dd 0
    dd 0
    dd 0

  ; Extended Processor Signature and Feature Bits
  .cpu_extf_sig: dd 0

  ; --------------------------------------------------
  ; CPU Extended Functions Bits:
  ;   [0] LAHF/SAHF available in 64-bit mode.
  ;   [1] LZCNT available.
  ;   [2] PREFETCHW available.
  ;   [3] SYSCALL/SYSRET available.
  ;   [4] Execute Disable Bit available.
  ;   [5] 1-GByte pages are available.
  ;   [6] RDTSCP and IA32_TSC_AUX are available.
  ;   [7] Intel 64 Architecture available.
  .cpu_extf: db 0