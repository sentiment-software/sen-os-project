%include "src/boot/definitions/memorymap.asm"

[org GLOB_BASE]

; ===== 32-bit Global Descriptor Table =====
gdt32:
  dq 0x0000000000000000          ; Null descriptor
  dq 0x00CF9A000000FFFF          ; 32-bit Code (0x8)
  dq 0x00CF92000000FFFF          ; 32-bit Data (0x10)
  times 0x80 - ($ - gdt32) db 0

; ===== 64-bit Task State Segment =====
tss64:
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
  times 0x80 - ($ - tss64) db 0

; ===== 64-bit Global Descriptor Table ===== 88, 0x58
gdt64:
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
  dw TSS64_SIZE - 1                 ; Limit[15:0]
  dw TSS64_BASE                     ; Base[15:0]
  db 0x00                           ; Base[23:16]
  db 0x89                           ; Present, DPL-0, TSS, Execute-Only, Accessed
  db 0x00                           ; Limit[19:16] = 0, flags
  db 0x00                           ; Base[31:24]
  dd 0x00000000                     ; Base[63:32]
  dd 0x00000000                     ; Reserved
  times 0x200 - ($ - gdt64) db 0

; ===== 32-bit GDTD =====
gdt32_descriptor:
  dw GDT32_SIZE - 1  ; Limit
  dd GDT32_BASE      ; Base
  times 0x10 - ($ - gdt32_descriptor) db 0

; ===== 64-bit GDTD =====
gdt64_descriptor:
  dw GDT64_SIZE - 1  ; Limit
  dd GDT64_BASE      ; Base
  times 0x10 - ($ - gdt64_descriptor) db 0

; ===== 64-bit IDTD =====
idt64_descriptor:
  dw IDT_SIZE - 1                 ; Limit
  dq IDT_BASE                     ; Base
  times 0x10 - ($ - idt64_descriptor) db 0

; ===== Align on a 4kB (0x1000) boundary
times 4096 - ($ - $$) db 0