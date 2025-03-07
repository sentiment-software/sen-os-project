%include "src/boot/definitions/memorymap.asm"

[bits 32]

; Setup IDT for long mode
setup_idt:
    ; Clear IDT memory (4KB)
    mov edi, IDT_BASE
    xor eax, eax
    mov ecx, 1024        ; 4096 bytes / 4 bytes per stosd
    rep stosd

    ; Fill IDT with default ISR
    mov edi, IDT_BASE
    mov ecx, 256         ; 256 vectors
    mov eax, isr_default ; Default ISR address
.loop_default:
    call set_idt_entry   ; Set entry with eax as ISR
    add edi, 16          ; Next entry
    loop .loop_default

    ; Override vector 13 (GPF) with specific ISR
    mov edi, IDT_BASE + 13 * 16
    mov eax, isr_gpf
    call set_idt_entry

    ret

; Set one IDT entry at edi with ISR address in eax
set_idt_entry:
    mov [edi], ax             ; Offset low (bits 0-15)
    mov word [edi + 2], 0x08  ; Selector (Ring 0 code from GDT)
    mov byte [edi + 4], 0     ; IST (0 = use RSP0 from TSS)
    mov byte [edi + 5], 0x8E  ; Type: Interrupt Gate, DPL=0, Present
    shr eax, 16
    mov [edi + 6], ax         ; Offset mid (bits 16-31)
    shr eax, 16
    mov [edi + 8], eax        ; Offset high (bits 32-63)
    mov dword [edi + 12], 0   ; Reserved
    ret

