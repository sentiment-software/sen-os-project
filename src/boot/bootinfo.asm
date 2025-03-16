%include "src/boot/definitions/bootinfo.asm"

; ===== Boot Information passed to the kernel =====
boot_info:
  .magic: dq 0xDEADBEEF69696969

  .cpuid_max_basic: dd 0               ; Maximum input value for CPUID Basic Information leaves
  .cpuid_max_extf: dd 0                ; Maximum input value for CPUID Extended Features leaves
  .cpu_vendor_id:                      ; CPU Vendor String (12 bytes + 1 byte termination + 3 bytes align)
    times 16 db 0
  .cpu_version_info: dd 0              ; CPU Type, Family, Model, Stepping ID
  .cpu_brand_index: db 0               ; Brand Index
  .cpu_clflush_size: db 0              ; CLFLUSH line size (Value * 8 = cache line size)
  .cpu_max_apic_id: db 0               ; Maximum number of addressable IDs for logical processors
  .cpu_features:                       ; Basic processor features
    dd 0
    dd 0
  .cpu_extf_sig: dd 0                  ; Extended Processor Signature and Feature Bits
  .cpu_extf: db 0                      ; Extended processor features
  .cpu_lp_shift: db 0                  ; The logical processor shift value
  .cpu_core_shift: db 0                ; The core shift value
  .cpu_leg_apic_id: db 0               ; Legacy APIC ID if present
  .cpu_leg_lp_count: db 0              ; Legacy LP count if present


