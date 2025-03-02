; ===== Paging Constants =====

; --- PML4 Entry Bits
PML4_PRESENT equ (1 << 0)
PML4_WRITE   equ (1 << 1)
PML4_SUPER   equ (1 << 2) ; User/Supervisor (0=super, 1=user)
PML4_PWT     equ (1 << 3) ; Page-level write-through
PML4_PCD     equ (1 << 4) ; Page-level cache disable
PML4_A       equ (1 << 5) ; Accessed
PML4_PADDR   equ (1 << 12) ; Physical address position

; --- PDPT Entry Bits (that references a PD)
PDPT_PRESENT equ (1 << 0)
PDPT_WRITE   equ (1 << 1)
PDPT_SUPER   equ (1 << 2) ; User/Supervisor (0=super, 1=user)
PDPT_PWT     equ (1 << 3) ; Page-level write-through
PDPT_PCD     equ (1 << 4) ; Page-level cache disable
PDPT_A       equ (1 << 5) ; Accessed
PDPT_PADDR   equ (1 << 12) ; Physical address position

; --- PD Entry Bits (that references a PT)


; ---
PAGE_PRESENT equ (1 << 0)
PAGE_WRITE   equ (1 << 1)
PAGE_2MB     equ (1 << 7)