[bits 32]   ; Being called from protected mode

; GDT and TSS for long mode
; Copies the GDT and TSS to the target memory addresses
;setup_gdt_tss:
;  ; GDT
;  mov edi, GDT_BASE
;  mov esi, gdt_start
;  mov ecx, (gdt_end - gdt_start) / 4 ; 98 bytes = 24.5 dwords
;  rep movsd
;
;  ; TSS
;  mov edi, TSS_BASE
;  mov esi, tss_start
;  mov ecx, (tss_end - tss_start) / 4 ; 104 bytes = 26 dwords
;  rep movsd
;
;  ; GDT descriptor
;  mov word [gdt64_descriptor], GDT_END
;  mov dword [gdt64_descriptor + 2], GDT_BASE
;  mov dword [gdt64_descriptor + 6], 0
;  ret

; ===== 64-bit mode Task State Segment =====
; In long mode a 64-bit task state segment must exist.
; The TSS holds information important to 64-bit mode not related to the task-switch mechanism.
; This information includes:
;   - RSPn: The full 64-bit canonical forms of the stack pointers (RSP) for privilege levels 0-2.
;   - ISTn: The full 64-bit canonical forms of the Interrupt Stack Table (IST) pointers.
;   - I/O Map Base - The 16-bit offset to the I/O permission bit map from the 64-bit TSS base.
; The OS must create at least one 64-bit TSS after activating IA-32e mode and load it into the
; TR register by executing the LTR instruction.
tss64_start:
  dd 0                    ; Reserved
  dq KERN_STACK_TOP       ; RSP0 (kernel stack)
  dq 0                    ; RSP1
  dq 0                    ; RSP2
  dq 0                    ; Reserved
  dq 0                    ; IST1
  dq 0                    ; IST2
  dq 0                    ; IST3
  dq 0                    ; IST4
  dq 0                    ; IST5
  dq 0                    ; IST6
  dq 0                    ; IST7
  dd 0                    ; Reserved
  dd 0                    ; Reserved
  dw 0                    ; Reserved
  dw 0                    ; I/O Map Base (none)
tss64_end:

; ===== 64-bit Global Descriptor Table =====
gdt64_start:
  dq 0x0000000000000000   ; Null descriptor
  dq 0x00AF9B000000FFFF   ; Ring 0 Code (0x08)
  dq 0x00AF93000000FFFF   ; Ring 0 Data (0x10)
  dq 0x00AFDB000000FFFF   ; Ring 1 Code (0x18)
  dq 0x00AFD3000000FFFF   ; Ring 1 Data (0x20)
  dq 0x00AFBB000000FFFF   ; Ring 2 Code (0x28)
  dq 0x00AFB3000000FFFF   ; Ring 2 Data (0x30)
  dq 0x00AFFB000000FFFF   ; Ring 3 Code (0x38)
  dq 0x00AFF3000000FFFF   ; Ring 3 Data (0x40)

  ; TSS Descriptor (0x48)
  dw tss64_end - tss64_start - 1    ; Limit[15:0]
  dw tss64_start                    ; Base[15:0]
  db 0x00                           ; Base[23:16]
  db 0x89                           ; Present, DPL-0, TSS, Execute-Only, Accessed
  db 0x00                           ; Limit[19:16] = 0, flags
  db 0x00                           ; Base[31:24]
  dd 0x00000000                     ; Base[63:32]
  dd 0x00000000                     ; Reserved

  align 8
    db 0
gdt64_end:

gdt64_descriptor:
  dw gdt64_end - gdt64_start - 1
  dd gdt64_start