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

  call enable_a20                ; Enable the A20 line
  call init_paging               ; Init paging
  call remap_pic                 ; Remap PIC
  call init_mode64               ; Enter long mode

  jmp CODE_SEG:kernel_main       ; Jump to kernel code

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
%include "src/main/boot/mode16/gdt64.asm"
%include "src/main/boot/mode16/init64.asm"

; ===== Messages
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