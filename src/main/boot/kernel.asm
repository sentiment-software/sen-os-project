[bits 64]                        ; Use 64 bit instruction set in long mode
                                 ; I really wanted to write that for a while

kernel_main:
  mov ax, DATA_SEG_DPL0          ; Set up segment registers
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov ss, ax

  call mode64_clear_screen
  call print_welcome_message
  ;;call test_gdt64 ;TODO: this fails the test

  .halt_kernel:
    hlt
    jmp .halt_kernel

mode64_clear_screen:
  push rax
  push cx
  mov edi, VRAM_START          ; Set VRAM address
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
  mov edi, VRAM_START           ; Point to VRAM
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
  mov rax, 0x1f001f001f001f21
  mov [edi + 56], rax
  ret

; Tests GDT by trying to access memory addresses
; TODO: fails. Once we will have the TSS, IDT and ISRs set up, we can handle exceptions.
test_gdt64:
  ; Below 2MB
  mov rax, 0x00000000001ffffe
  mov byte [rax], 0xaa
  xor rbx, rbx
  mov rbx, [rax]
  cmp rbx, 0xaa
  jne .testFailed2Mb

  ; Below 4GB (>2MB)
  mov rax, 0x0000000012345678
  mov byte [rax], 0xaa
  xor rbx, rbx
  mov rbx, [rax]
  cmp rbx, 0xaa
  jne .testFailed4Gb

  ; Between 4-8GB
  mov rax, 0x0000000101234567
  mov byte [rax], 0xaa
  xor rbx, rbx
  mov rbx, [rax]
  cmp rbx, 0xaa
  jne .testFailed8Gb
  jmp .testSuccess
  ret ; > Unreachable RET

  .testFailed2Mb:
    mov edi, (VRAM_START + VRAM_ADD_LINE)
    mov rax, 0x4f004f004f464f32
    mov [edi], rax
    ret
  .testFailed4Gb:
    mov edi, (VRAM_START + VRAM_ADD_LINE + 8)
    mov rax, 0x4f004f004f464f32
    mov [edi], rax
    ret
  .testFailed8Gb:
    mov edi, (VRAM_START + VRAM_ADD_LINE + 16)
    mov rax, 0x4f004f004f464f38
    mov [edi], rax
    ret
  .testSuccess:
    mov edi, (VRAM_START + VRAM_ADD_LINE + 24)
    mov rax, 0x2f002f002f462f38
    mov [edi], rax
    ret