; ===== Register Flags =====
CR0_PE_BIT   equ (1 << 0)
CR0_PG_BIT   equ (1 << 31)
CR4_PAE_BIT  equ (1 << 5)
CR4_PGE_BIT  equ (1 << 7)
EFER_MSR     equ 0xC0000080
EFER_LME_BIT equ (1 << 8)