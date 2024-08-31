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

  ; Init long mode in _main as this code is sensitive to segment changes (RET, JMP).
  .init_mode64:
    cli                          ; Clear interrupts. This won't be reset here.
    mov edi, PAGING_DATA         ; Move paging data to EDI
    mov eax, 10100000b           ; Set PAE and PGE bits in CR4
    mov cr4, eax
    mov edx, edi                 ; Set CR3 to the PML4
    mov cr3, edx
    mov ecx, 0xc0000080          ; Read from EFER MSR
    rdmsr
    or eax, 0x00000100           ; Set the Long Mode Enable bit
    wrmsr
    mov ebx, cr0
    or ebx, 0x80000001
    mov cr0, ebx                 ; Long mode, paging and protected mode enabled

    lgdt [gdt64_pointer]         ; Load the GDT into GDTR
    jmp CODE_SEG_DPL0:kernel_main  ; Jump to kernel code

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
%include "src/main/boot/mode64/gdt64.asm"

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