; ===== Register Flags =====

; --------------------------------------------------
; Extended Flags Register (EFLAGS)
; --------------------------------------------------
BIT_EFLAGS_CF    equ 0 ; Carry flag
BIT_EFLAGS_PF    equ 2 ; Parity flag
BIT_EFLAGS_AF    equ 4 ; Auxiliary carry flag
BIT_EFLAGS_ZF    equ 6 ; Zero flag
BIT_EFLAGS_SF    equ 7 ; Sign flag
BIT_EFLAGS_TF    equ 8 ; Trap flag
BIT_EFLAGS_IF    equ 9 ; Interrupts enabled flag
BIT_EFLAGS_DF    equ 10 ; Direction flag
BIT_EFLAGS_OF    equ 11 ; Overflow flag
BIT_EFLAGS_RF    equ 16 ; Resume flag
BIT_EFLAGS_VM    equ 17 ; Virtual 8086 mode flag
BIT_EFLAGS_AC    equ 18 ; Alignment check, SMAP access check
BIT_EFLAGS_VIF   equ 19 ; Virtual interrupt flag
BIT_EFLAGS_VIP   equ 20 ; Virtual interrupt pending
BIT_EFLAGS_CPUID equ 21 ; CPUID instruction available
BIT_EFLAGS_AES   equ 30 ; AES key schedule loaded flag
BIT_EFLAGS_AI    equ 31 ; Alignment Instruction Set enabled


; --------------------------------------------------
; Control Register 0 (CR0)
; --------------------------------------------------
BIT_CR0_PE   equ 0
BIT_CR0_PG   equ 31

; --------------------------------------------------
; Control Register 4 (CR4)
; --------------------------------------------------
BIT_CR4_PAE  equ 5
BIT_CR4_PGE  equ 7

; --------------------------------------------------
; Extended Feature Enables Register (EFER MSR)
; --------------------------------------------------
MSR_EFER     equ 0xC0000080
BIT_EFER_LME equ 8

; --------------------------------------------------
; Enable Miscellaneous Feature Register (MISC_ENABLE MSR)
; --------------------------------------------------
MSR_MISC equ 0x1A0
BIT_MISC_22 equ 22 ; Reserved, but BIOS may set it incorrectly on newer CPUs
