;------------------------------
; Global Descriptor Table
; =====
; This struct defines a 64-bit GDT with the following entries:
; 1) Null Segment (64 bits)
; 2) Code Segment:
;      - Limit and base bits are ignored in long mode
;      - Access byte:
;          [1]  - Present
;          [00] - Descriptor Privilege Level 0 (kernel)
;          [1]  - Descriptor type: Non-system (code) segment
;          [1]  - Executable
;          [0]  - Non-conforming code segment (execute on DPL level) TODO: review this bit
;          [1]  - R/W: code segment readable, write disabled
;          [1]  - Accessed
;      - Flags:
;          [0]  - Granularity 4KiB blocks (ignored in long mode)
;          [0]  - Clear for 64-bit segments
;          [1]  - Long-mode code flag
; 3) Data Segment:
;      - Limit and base bits are ignored in long mode
;      - Flags are ignored for data segments in long mode
;      - Access byte:
;          [1]  - Present
;          [00] - DPL: 0 (kernel)
;          [1]  - DT: Non-system (data) segment
;          [0]  - Up-growing data segment
;          [0]  - R/W: data segment readable, write disabled
;          [1]  - Accessed
; 4) Task State Segment:
;      - In long mode, the TSS is used to store the Interrupt Stack Table (IST).
;------------------------------
gdt64:
  .null:
    dq 0x0000000000000000  ; Null segment
  .code:
    dd 0xffff0000          ; Limit & base bits 0-15 (ignored)
    db 0x00                ; Base bits 16-23 (ignored)
    db 0x9b                ; Access byte (10011011)
    db 0x20                ; Flags (0010) and limit bits 16-19 (limit ignored)
    db 0x00                ; Base bits 24-31 (ignored)
  .data:
    dd 0xffff0000          ; Limit & base bits 0-15 (ignored)
    db 0x00                ; Base bits 16-23 (ignored)
    db 0x93                ; Access byte (10010011)
    db 0x00                ; Flags (0000) and limit bits 16-19 (limit ignored)
    db 0x00                ; Base bits 24-31 (ignored)
gdt64_end:

gdt64_desc:
  dw gdt64_end - gdt64 - 1
  dd gdt64