[bits 64]                        ; Use 64 bit instruction set in long mode
                                 ; I really wanted to write that for a while

kernel_main:
  mov ax, 0x10                   ; Set up segment registers
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov ss, ax

  call mode64_clear_screen
  call print_welcome_message

  .halt_kernel:
    hlt
    jmp .halt_kernel

mode64_clear_screen:
  push rax
  push cx
  mov edi, 0xb8000             ; Set VRAM address
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

print_welcome_message:
    mov edi, 0xb8000               ; Point to VRAM
    ; Test me!
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
    mov rax, 0x1F001F001F001f21
    mov [edi + 56], rax
    ret