[bits 16]

boot1_main:
  mov si, msg_boot1_start
  call mode16_print

  call has_cpuid                 ; Test CPUID
  cmp eax, FALSE
  je .cpuid_not_supported
  mov si, msg_cpuid_supported
  call mode16_print

  call has_cpuid_mode64          ; Test CPUID.Mode64
  cmp eax, FALSE
  je .mode64_not_supported
  mov si, msg_mode64_supported
  call mode16_print

  call enable_a20
  call init_paging
  call remap_pic
  call init_mode64

  .mode64_not_supported:
    mov si, msg_mode64_unsupported
    call mode16_print
    call halt
  .cpuid_not_supported:
    mov si, msg_cpuid_unsupported
    call mode16_print
    call halt

; ===== Includes
%include "src/main/boot/mode16/a20.asm"
%include "src/main/boot/mode16/paging.asm"
%include "src/main/boot/mode16/pic.asm"
%include "src/main/boot/mode16/cpuid.asm"

init_mode64:
  mov edi, PAGING_DATA      ; Move paging data to EDI
  mov eax, 10100000b        ; Set PAE and PGE bits in CR4
  mov cr4, eax
  mov edx, edi              ; Set CR3 to the PML4
  mov cr3, edx
  mov ecx, 0xc0000080       ; Read from EFER MSR
  rdmsr
  or eax, 0x00000100        ; Set the Long Mode Enable bit
  wrmsr
  mov ebx, cr0
  or ebx, 0x80000001
  mov cr0, ebx              ; Long mode, paging and protected mode enabled

  lgdt[gdt_desc]            ; Load the GDT into GDTR

  jmp CODE_SEG:kernel_main  ; Jump to kernel code

; Global Descriptor Table
; Read/Write, Non-Conforming, Expand-Down
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

; Messages
msg_boot1_start dw 15
db 'Boot 1: Start', 13, 10
msg_cpuid_supported dw 25
db 'Boot 1: CPUID supported', 13, 10
msg_cpuid_unsupported dw 29
db 'Boot 1: CPUID not supported', 13, 10
msg_mode64_supported dw 29
db 'Boot 1: Long mode supported', 13, 10
msg_mode64_unsupported dw 33
db 'Boot 1: Long mode not supported', 13, 10
