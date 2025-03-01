; ===== Constants =====
; Boolean
FALSE equ (0)
TRUE  equ (1)

; Disk
SECTOR_LIMIT equ 127

; CPUID flags
CPUID_ID     equ (1 << 21)
CPUID_MODE64 equ (1 << 29)

; Paging
PAGE_PRESENT equ (1 << 0)
PAGE_WRITE   equ (1 << 1)
PAGE_2MB     equ (1 << 7)

; Control registers
CR0_PE_BIT   equ (1 << 0)
CR0_PG_BIT   equ (1 << 31)
CR4_PAE_BIT  equ (1 << 5)
CR4_PGE_BIT  equ (1 << 7)
EFER_MSR     equ 0xC0000080
EFER_LME_BIT equ (1 << 8)

