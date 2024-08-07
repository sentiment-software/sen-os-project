[bits 16]                   ; Use 16-bit instruction set for real mode
[org 0x7c00]                ; Set origin address to the boot sector address

cli                         ; Disable interrupts

xor ax, ax                  ; Set AX=0.
mov ds, ax                  ; Set DS to 0 through AX for lgdt (DS can't be set directly)

lgdt [gdt_desc]             ; Load the GDT into linear address space

mov eax, cr0                ; Set CR0[0] to 1 to enable protected mode.
or eax, 1                   ; This has to be done through a 32-bit general-register, as
mov cr0, eax                ; the control register can't be set directly

jmp 0x8:mode32_start        ; Far jump to the code segment to the address of the mode32_start label

[bits 32]                   ; Use 32-bit instruction set for protected mode
mode32_start:
  mov ax, 0x10              ; Save data segment identifier
  mov ds, ax                ; Set the data segment register to the valid data segment
  mov ss, ax                ; Set the stack segment register to the valid data segment
  mov esp, 0x90000          ; Set the stack pointer to 0x90000 (in free memory space of the first MB)

  ; Test by printing to the screen using 32-bit instructions and addressing
  ; If we're not in protected mode here, this will fail
  mov byte [ds:0xb8000], 'P'  ; ASCII for P
  mov byte [ds:0xb8001], 0x2a ; Set color mode

keep_alive:
  jmp keep_alive  ; hang around

; Global Descriptor Table
; See: https://github.com/sentiment-software/sen-os-project/wiki/Bootloader
gdt:                        ; GDT - Start address
gdt_null:                   ; GDT - Null segment
  dd 0
  dd 0
gdt_code:                   ; GDT - Code segment
  dw 0xffff
  dw 0
  db 0
  db 10011010b
  db 11001111b
  db 0
gdt_data:                   ; GDT- Data segment
  dw 0xffff
  dw 0
  db 0
  db 10010010b
  db 11001111b
  db 0
gdt_end:                    ; GDT - End address

gdt_desc:                   ; GDT meta-descriptor
  dw gdt_end - gdt - 1      ; Calculate length (compile time)
  dd gdt                    ; Set GDT Address


times 510 - ($ - $$) db 0   ; Pad to 510 bytes
dw 0xaa55                   ; Boot signature at 511:512 bytes