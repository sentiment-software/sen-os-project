; ===== Memory Maps =====

; ===== Real Mode Address Space (< 1MiB, standardized) =====
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
EBDA_BASE       equ 0x00080000 ; Extended BIOS Data Area
EBDA_END        equ 0x0009FFFF
VDM_BASE        equ 0x000A0000 ; Video Display Memory
VDM_END         equ 0x000BFFFF
BIOS_V_BASE     equ 0x000C0000 ; Video BIOS
BIOS_V_END      equ 0x000C7FFF
BIOS_E_BASE     equ 0x000C8000 ; BIOS Expansions
BIOS_E_END      equ 0x000EFFFF
BIOS_MB_BASE    equ 0x000F0000 ; Motherboard BIOS
BIOS_MB_END     equ 0x000FFFFF

; ===== Program Memory Map =====
; ----- Boot Stage 1 -----
BOOT_1_BASE     equ 0x1000
BOOT_1_SIZE     equ 0x1000
BOOT_1_END      equ BOOT_1_BASE + BOOT_1_SIZE - 1 ; 0x1FFF
BOOT_1_SECTOR   equ 1
; ----- Global Structures -----
; -- Allocation for Global Structures
GLOB_BASE       equ 0x2000
GLOB_SIZE       equ 0x1000
GLOB_END        equ GLOB_BASE + GLOB_SIZE - 1 ; 0x2FFF
; -- GDT-32
GDT32_BASE      equ 0x2000
GDT32_SIZE      equ 0x80
GDT32_END       equ GDT32_BASE + GDT32_SIZE - 1 ; 0x207F
; -- TSS-64
TSS64_BASE      equ 0x2080
TSS64_SIZE      equ 0x80
TSS64_END       equ TSS64_BASE + TSS64_SIZE - 1 ; 0x20FF
; -- GDT-64
GDT64_BASE      equ 0x2100
GDT64_SIZE      equ 0x200
GDT64_END       equ GDT64_BASE + GDT64_SIZE - 1 ; 0x22FF
; -- GDT-32 Descriptor
GDT32_DESC_BASE equ 0x2300
GDT32_DESC_SIZE equ 0x10
GDT32_DESC_END  equ GDT32_DESC_BASE + GDT32_DESC_SIZE - 1 ; 0x230F
; -- GDT-64 Descriptor
GDT64_DESC_BASE equ 0x2310
GDT64_DESC_SIZE equ 0x10
GDT64_DESC_END  equ GDT64_DESC_BASE + GDT64_DESC_SIZE - 1 ; 0x231F
; > IDT-64 Descriptor
IDT64_DESC_BASE equ 0x2320
IDT64_DESC_SIZE equ 0x10
IDT64_DESC_END  equ IDT64_DESC_BASE + IDT64_DESC_SIZE - 1 ; 0x232F
; ----- IDT (64-bit) -----
IDT_BASE        equ 0x3000
IDT_SIZE        equ 0x1000
IDT_END         equ IDT_BASE + IDT_SIZE - 1 ; 0x3FFF
; ----- Paging Structure -----
PAGE_ALLOC_BASE equ 0x4000
PAGE_ALLOC_SIZE equ 0x6000
PAGE_ALLOC_END  equ PAGE_ALLOC_BASE + PAGE_ALLOC_SIZE - 1 ; 0x9FFF
PML4_BASE       equ PAGE_ALLOC_BASE
PDP_BASE        equ PAGE_ALLOC_BASE + 0x1000
PD_BASE         equ PAGE_ALLOC_BASE + 0x2000
; ----- Kernel -----
KERN_BASE       equ 0x10000
KERN_SIZE       equ 0x6E000
KERN_END        equ KERN_BASE + KERN_SIZE - 1
KERN_SECTOR     equ BOOT_1_SECTOR + ((BOOT_1_SIZE + GLOB_SIZE) / 512) + 1

; ===== Stack Pointers =====
; ----- Boot Stack Pointer (SP) -----
BOOT_STACK_BASE equ 0x0800
BOOT_STACK_TOP  equ 0x0FFF
; ----- Protected Mode Stack Pointer (ESP) -----
PM_STACK_BASE equ 0x45700
PM_STACK_TOP  equ 0x476FF
; ----- Kernel Stack Pointer (RSP) -----
KERN_STACK_BASE equ 0x46000
KERN_STACK_TOP  equ 0x47FFF
