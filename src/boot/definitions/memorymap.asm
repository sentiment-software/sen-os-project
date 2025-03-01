; ===== Memory Maps =====

; ----- Real Mode Address Space (< 1MiB, standardized) -----
IVT_BASE        equ 0x00000000 ; Real mode Interrupt Vector Table
IVT_END         equ 0x000003FF
BDA_BASE        equ 0x00000400 ; BIOS Data Area
BDA_END         equ 0x000004FF
FREE_MEM_1_BASE equ 0x00000500 ; Free memory below boot sector
FREE_MEM_1_END  equ 0x00007BFF
BOOTSECTOR_BASE equ 0x00007C00 ; Boot Sector
BOOTSECTOR_END  equ 0x00007DFF
FREE_MEM_2_BASE equ 0x00007E00 ; Free memory above boot sector
FREE_MEM_2_END  equ 0x0007FFFF
EDBA_BASE       equ 0x00080000 ; Extended BIOS Data Area
EDBA_END        equ 0x0009FFFF
VDM_BASE        equ 0x000A0000 ; Video Display Memory
VDM_END         equ 0x000BFFFF
BIOS_V_BASE     equ 0x000C0000 ; Video BIOS
BIOS_V_END      equ 0x000C7FFF
BIOS_E_BASE     equ 0x000C8000 ; BIOS Expansions
BIOS_E_END      equ 0x000EFFFF
BIOS_MB_BASE    equ 0x000F0000 ; Motherboard BIOS
BIOS_MB_END     equ 0x000FFFFF

; ----- Program Memory Map -----

; Boot stage 1
BOOT_1_BASE     equ 0x0700
BOOT_1_SIZE     equ 0x1000
BOOT_1_END      equ BOOT_1_BASE + BOOT_1_SIZE - 1 ; 0x16FF
; Page tables
PAGE_ALLOC_BASE equ 0x1700
PAGE_ALLOC_END  equ 0xA6FF
PML4_BASE       equ 0x1700
PDP_BASE        equ 0x2700
PD_BASE         equ 0x3700
PD_TABLES       equ 1
PD_SIZE         equ 0x1000
PD_END          equ PD_BASE + (PD_TABLES * PD_SIZE) - 1 ; 0x46FF
; IDT
IDT_BASE        equ 0xA700
IDT_SIZE        equ 0x1000
IDT_END         equ IDT_BASE + IDT_SIZE - 1 ; 0xB6FF
; GDT + TSS
GDT_BASE        equ 0xB700
GDT_SIZE        equ 0x0080
GDT_END         equ GDT_BASE + GDT_SIZE - 1 ; 0xB77F
TSS_BASE        equ GDT_END + 1 ; 0xB780
TSS_SIZE        equ 0x0080
TSS_END         equ TSS_BASE + TSS_SIZE - 1 ; 0xB7FF
; Kernel entry
KERN_ENTRY_BASE equ 0xC000
KERN_ENTRY_TOP  equ 0x7F000

; ----- Stack Pointers -----
; Boot stack pointer: initial value of SP
BOOT_STACK_BASE equ 0x0500
BOOT_STACK_TOP  equ 0x06FF
; Protected mode stack pointer: initial value of ESP
PM_STACK_BASE equ 0x7F000
PM_STACK_TOP  equ 0x7FFFF
; Kernel stack pointer: initial value of RSP
KERN_STACK_BASE equ 0x7F000
KERN_STACK_TOP  equ 0x7FFFF
