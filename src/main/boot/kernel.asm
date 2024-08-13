[bits 64]                      ; Use 64 bit instruction set in long mode (I really wanted to write this for a while)

%define DATA_SEG    0x0010
%define VRAM       0xB8000

kernel_main:
  mov ax, DATA_SEG              ; Set up segment registers
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov ss, ax

  mov edi, 0xb8000

  ; Test me!
  mov rax, 0x1F6C1F6C1F651F48
  mov [edi], rax
  mov rax, 0x1F6F1F571F201F6F
  mov [edi + 8], rax
  mov rax, 0x1F211F641F6C1F72
  mov [edi + 16], rax

  .halt:
    hlt
    jmp .halt