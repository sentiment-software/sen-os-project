;------------------------------
; Global Descriptor Table
; Read/Write, Non-Conforming, Expand-Down
;------------------------------
gdt:
gdt_null:
  dq 0x0000000000000000  ; Null segment
gdt_code:
  dw 0xffff              ; Limit bits 0-15 (ignored in mode 64)
  dw 0x0000              ; Base bits 0-15 (ignored in mode 64)
  db 0x00                ; Base bits 16-23 (ignored in mode 64)
  db 10011010b           ; Access byte
  db 10100000b           ; Flags and limit bits 16-19
  db 0x00                ; Base bits 24-31 (ignored in mode 64)
gdt_data:
  dw 0xffff              ; Limit bits 0-15 (in expand-down mode, limit is the lower bound)
  dw 0x0000              ; Base bits 0-15
  db 0x00                ; Base bits 16-23
  db 10010010b           ; Access byte
  db 11000000b           ; Flags and limit bits 16-19
  db 0x00                ; Base bits 24-31
gdt_end:

gdt_desc:
  dw gdt_end - gdt - 1
  dd gdt