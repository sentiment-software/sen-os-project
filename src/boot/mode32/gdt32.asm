; Minimal GDT for protected mode
gdt32_start:
  dq 0x0000000000000000          ; Null descriptor
  dq 0x00CF9A000000FFFF          ; 32-bit Code (0x8)
  dq 0x00CF92000000FFFF          ; 32-bit Data (0x10)
gdt32_end:

gdt32_descriptor:
  dw gdt32_end - gdt32_start - 1  ; Limit
  dd gdt32_start                  ; Base