%include "src/boot/definitions/definitions.asm"
%include "src/boot/definitions/memorymap.asm"
%include "src/boot/definitions/segments.asm"
%include "src/boot/definitions/vga.asm"

[org BOOT_1_BASE]

[bits 16]
boot1_main:
  cli
  call enable_a20
  call enter_protected_mode

; ===== Enter Protected Mode =====
[bits 16]
enter_protected_mode:
  ; Load minimal GDT
  lgdt [gdt32_descriptor]

  ; Enable Protected Mode
  mov eax, cr0
  or eax, CR0_PE_BIT
  mov cr0, eax

  jmp SEG_CODE_32:protected_mode_entry

; ===== Includes (mode 16)
%include "src/boot/mode32/gdt32.asm"
%include "src/boot/mode16/halt.asm"
%include "src/boot/mode16/print16.asm"
%include "src/boot/mode16/a20.asm"

; ===== Protected Mode =====
[bits 32]
protected_mode_entry:
  ; Reload segment registers to 0x10, flush instruction pipeline
  mov ax, SEG_DATA_32
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov ss, ax
  mov esp, PM_STACK_TOP

  call mode32_clear

  mov eax, 0
  mov ebx, msg_protected_mode_enabled
  call mode32_print

  ; Test CPUID.ID
  call has_cpuid
  cmp eax, FALSE
  je .cpuid_not_supported
  mov ebx, msg_cpuid_supported
  call mode32_println

  ; Test CPUID.MODE64
  call has_cpuid_mode64
  cmp eax, FALSE
  je .mode64_not_supported
  mov ebx, msg_mode64_supported
  call mode32_println

  ; Set up page tables
  call paging_setup_64MB
  mov ebx, msg_paging_loaded
  call mode32_println

  ; Remap PIC
  call remap_pic
  mov ebx, msg_remap_pic_ok
  call mode32_println

  ; Set up GDT and TSS
  call setup_gdt_tss
  mov ebx, msg_gdt_tss_loaded
  call mode32_println

  ; Set up IDT
  call setup_idt
  mov ebx, msg_idt_loaded
  call mode32_println

  cli
  hlt

  ; Enter long mode
  call enter_long_mode

  .cpuid_not_supported:
    mov ebx, msg_cpuid_unsupported
    call mode32_println
    cli
    hlt
  .mode64_not_supported:
    mov ebx, msg_mode64_unsupported
    call mode32_println
    call halt
    cli
    hlt

enter_long_mode:
  mov ebx, msg_entering_long_mode
  call mode32_println

  ; Load long mode GDT
  lgdt [gdt64_descriptor]

  ; Enable PAE and PGE
  mov eax, cr4
  or eax, CR4_PAE_BIT | CR4_PGE_BIT
  mov cr4, eax

  ; Enable Long Mode in EFER
  mov ecx, EFER_MSR
  rdmsr
  or eax, EFER_LME_BIT
  wrmsr

  ; Enable paging
  ; CR3 is already set to PML4_BASE in paging
  mov eax, cr0
  or eax, CR0_PG_BIT
  mov cr0, eax

  cli
  hlt

  ; Jump to 64-bit code segment
  jmp SEG_CODE_0:long_mode_entry

; ===== Includes (mode 32)
%include "src/boot/mode64/gdt64.asm"
%include "src/boot/mode32/print32.asm"
%include "src/boot/mode32/cpuid.asm"
%include "src/boot/mode32/paging.asm"
%include "src/boot/mode32/pic.asm"
%include "src/boot/mode32/idt.asm"
; ===== Messages (mode 32 - dd)
msg_protected_mode_enabled: db 'Boot 1: Protected Mode Enabled', 0
msg_cpuid_supported: db 'Boot 1: CPUID supported', 0
msg_cpuid_unsupported: db 'Boot 1: CPUID not supported', 0
msg_mode64_supported: db 'Boot 1: Long mode supported', 0
msg_mode64_unsupported: db 'Boot 1: Long mode not supported', 0
msg_paging_loaded: db 'Boot 1: Page tables loaded', 0
msg_remap_pic_ok: db 'Boot 1: PIC remapped', 0
msg_gdt_tss_loaded: db 'Boot 1: GDT and TSS loaded', 0
msg_idt_loaded: db 'Boot 1: IDT loaded', 0
msg_entering_long_mode: db 'Boot 1: Entering long mode', 0

; ===== Long Mode =====
[bits 64]
long_mode_entry:
  mov ax, SEG_DATA_0 ; Data Selector (Ring 0)
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov ss, ax
  mov rsp, KERN_STACK_TOP

  ; Load TSS
  mov ax, SEG_TSS    ; TSS selector
  ltr ax

  ; Load IDT
  lidt [idt_descriptor]

  mov byte [VGA_BUFFER], 'L'  ; Write 'L' to screen
  mov byte [VGA_BUFFER + 1], 0x1F

  call mode64_clear_screen
  call print_welcome_message

  ;sti

  .halt:
    cli
    hlt
    jmp .halt

[bits 64]
mode64_clear_screen:
  push rax
  push cx
  mov edi, VGA_BUFFER          ; Set VRAM address
  mov rax, 0x0020002000200020  ; Set to black spaces
  mov cx, 100                  ; Init counter
  .clear_loop:
    mov [edi], rax
    add edi, 8
    dec cx
    jnz .clear_loop
  pop cx
  pop rax
  ret

[bits 64]
print_welcome_message:
  mov edi, VGA_BUFFER           ; Point to VRAM
  mov rax, 0x1f631f6c1f651f57
  mov [edi], rax
  mov rax, 0x1f201f651f6d1f6f
  mov [edi + 8], rax
  mov rax, 0x1f6d1f201f6f1f74
  mov [edi + 16], rax
  mov rax, 0x1f2d1f661f201f79
  mov [edi + 24], rax
  mov rax, 0x1f6e1f691f6b1f63
  mov [edi + 32], rax
  mov rax, 0x1f651f6b1f201f67
  mov [edi + 40], rax
  mov rax, 0x1f6c1f651f6e1f72
  mov [edi + 48], rax
  mov rax, 0x1f001f001f001f21
  mov [edi + 56], rax
  ret

; ===== IRSs
[bits 64]
isr_default:
    push rax
    mov rdi, VGA_BUFFER
    mov rax, 0x1f631f6e1f6b1f55
    mov [rdi], rax
    mov rax, 0x1f771f6f1f6e1f6b
    mov [rdi + 8], rax
    mov rax, 0x1f6e1f201f6e1f77
    mov [rdi + 16], rax
    mov rax, 0x1f6e1f692f1f7421
    mov [rdi + 24], rax
    mov rax, 0x1f6e1f7421
    mov [rdi + 32], rax
    pop rax
    iretq

[bits 64]
isr_gpf:
    push rax
    mov rdi, VGA_BUFFER
    mov rax, 0x1f631f6e1f6b1f55
    mov [rdi], rax
    mov rax, 0x1f771f6f1f6e1f6b
    mov [rdi + 8], rax
    mov rax, 0x1f6e1f201f6e1f77
    mov [rdi + 16], rax
    mov rax, 0x1f6e1f692f1f7421
    mov [rdi + 24], rax
    mov rax, 0x1f6e1f7421
    mov [rdi + 32], rax
    hlt
    pop rax
    iretq

times 4096 - ($ - $$) db 0