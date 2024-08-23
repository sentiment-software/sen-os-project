[bits 64]

;------------------------------
; Interrupt Descriptor Table (IDT)
;
; 256 entries, 16 bytes long
;------------------------------
idt64:
idt64_end:

idt64_desc:
  dw idt64_end - idt64 - 1
  dq idt64

;------------------------------
; Interrupt Descriptor Table Entry
;------------------------------
idt64_entry:
  dw 0x0000           ; Offset bits 0-15 to ISR entry point
  dw 0x0000           ; Code segment selector in GDT
  db 0x0000           ; IST/TSS offset 3 bits, other bits are reserved (0)
  db 10001111b        ; Present (1), DPL (00), 0, Gate type (0xF)
  dw 0x0000           ; Offset bits 16-31 to ISR entry point
  dd 0x00000000       ; Offset bits 32-63 to ISR entry point
  dd 0x00000000       ; Reserved (0)