%include "src/boot/definitions/memorymap.asm"
%include "src/boot/definitions/registers.asm"
%include "src/boot/definitions/segments.asm"

[bits 16]
[org BOOT_1_BASE]

; ===== Real Mode =====
boot1_main:
  call hide_cursor16
  cli

  ; Enable A20
  call enable_a20
  test ax, ax
  jz .a20_disabled

  ; Load minimal 32-bit GDT
  lgdt [gdt32_descriptor]

  ; Enable Protected Mode
  mov eax, cr0
  or eax, (1 << BIT_CR0_PE)
  mov cr0, eax

  ; Jump to protected mode code
  jmp SEG_CODE_32:protected_mode_entry

  .a20_disabled:
    sti
    mov si, msg_a20_disabled
    call print16
    cli
    hlt

; ===== Includes (mode 16)
%include "src/boot/mode16/a20.asm"
%include "src/boot/mode16/print16.asm"
; ===== Messages (mode 16)
msg_a20_disabled: db 'A20 disabled', 0

; ===== Protected Mode =====
[bits 32]
protected_mode_entry:
  ; Reload segment registers and set Protected Mode Stack Pointer
  mov ax, SEG_DATA_32
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov ss, ax
  mov esp, PM_STACK_TOP

  call cpuid_supported
  test eax, eax
  jz .cpuid_not_supported

  call cpuid_test_all_mode64
  test eax, eax
  jz .mode64_not_supported

  call init_pages
  call remap_pic
  call setup_idt
  jmp enable_long_mode

  .cpuid_not_supported:
    mov ebx, msg_cpuid_unsupported
    call println32
    cli
    hlt
  .mode64_not_supported:
    mov ebx, msg_mode64_unsupported
    call println32
    cli
    hlt

enable_long_mode:
  ; Load 64-bit GDT
  lgdt [gdt64_descriptor]

  ; Enable PAE and PGE
  mov eax, cr4
  or eax, (1 << BIT_CR4_PAE) | (1 << BIT_CR4_PGE)
  mov cr4, eax

  ; Enable Long Mode in EFER
  mov ecx, MSR_EFER
  rdmsr
  or eax, (1 << BIT_EFER_LME)
  wrmsr

  ; Enable paging
  mov eax, cr0
  or eax, (1 << BIT_CR0_PG)
  mov cr0, eax

  ; Jump to 64-bit code segment
  jmp SEG_CODE_0:long_mode_entry

; ===== Includes (mode 32)
%include "src/boot/mode32/print32.asm"
%include "src/boot/mode32/cpuid32.asm"
%include "src/boot/mode32/paging.asm"
%include "src/boot/mode32/pic.asm"
%include "src/boot/mode32/idt.asm"
; ===== Messages (mode 32)
msg_cpuid_unsupported: db 'CPUID not supported', 0
msg_mode64_unsupported: db 'Long mode not supported', 0

; ===== Long Mode =====
[bits 64]
long_mode_entry:
  ; Reload segment registers and set Kernel Stack Pointer
  cli
  mov ax, SEG_DATA_0
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov ss, ax
  mov rsp, KERN_STACK_TOP

  ; Load TSS
  mov ax, SEG_TSS
  ltr ax

  ; Load IDT
  lidt [idt64_descriptor]

  ; Load boot info
  call cpuid_read_all

  ; Push boot info for kernel
  mov rdi, boot_info

  ; Jump to kernel
  jmp KERN_BASE

  .halt:
    cli
    hlt
    jmp .halt

; ===== Includes (mode 64)
%include "src/boot/mode64/print64.asm"
%include "src/boot/mode64/isr64.asm"
%include "src/boot/mode64/cpuid64.asm"

; ===== Align Boot Stage 1 on the next 4kB boundary, 0x2000
times 4096 - ($ - $$) db 0

; ===== Align Global Structures on the next 4kB boundary, 0x3000
glob:
%include "src/boot/glob.asm"
times 4096 - ($ - glob) db 0