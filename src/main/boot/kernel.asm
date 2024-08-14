[bits 64]                        ; Use 64 bit instruction set in long mode
                                 ; I really wanted to write that for a while

kernel_main:
  mov ax, 0x10                   ; Set up segment registers
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov ss, ax

  mov edi, 0xb8000               ; Point to VRAM

  ; Test me!
  mov rax, 0x1F6C1F6C1F651F48
  mov [edi], rax
  mov rax, 0x1F6F1F571F201F6F
  mov [edi + 8], rax
  mov rax, 0x1F211F641F6C1F72
  mov [edi + 16], rax

  .halt_kernel:
    hlt
    jmp .halt_kernel
