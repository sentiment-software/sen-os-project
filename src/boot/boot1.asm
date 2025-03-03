%include "src/boot/definitions/memorymap.asm"
%include "src/boot/definitions/registers.asm"
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

  mov ebx, msg_protected_mode_enabled
  call mode32_println

  ; Test CPUID.ID
  call has_cpuid
  cmp eax, 0x0
  je .cpuid_not_supported

  ; Test CPUID.MODE64
  call has_cpuid_mode64
  cmp eax, 0x0
  je .mode64_not_supported

  call init_pages
  call remap_pic
  call setup_idt
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
  mov eax, cr0
  or eax, CR0_PG_BIT
  mov cr0, eax

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
msg_protected_mode_enabled: db 'Protected Mode Enabled', 0
msg_cpuid_unsupported: db 'CPUID not supported', 0
msg_mode64_unsupported: db 'Long mode not supported', 0

; ===== Long Mode =====
[bits 64]
long_mode_entry:
  cli
  mov ax, SEG_DATA_0 ; Data Selector (Ring 0)
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
  lidt [idt_descriptor]

  mov ebx, msg_long_mode_enabled
  call println

  .halt:
    cli
    hlt
    jmp .halt

; ===== Includes (mode 64)
%include "src/boot/mode64/print64.asm"
%include "src/boot/mode64/irs64.asm"

; ===== Messages
msg_long_mode_enabled: db 'Long mode enabled! (Yay)', 0

times 4096 - ($ - $$) db 0