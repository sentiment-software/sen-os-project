%include "src/definitions/pic.asm"

[bits 32]

;------------------------------
; remap_pic:
;
; Remaps the Programmable Interrupt Controller
; In long mode IRQ 0-15 conflicts with the CPU exceptions, therefore this
; moves IRQs out of the CPU exception range (0x00-0x1F)
; Leaves all IRQs disabled until a proper IDT is set later in the kernel)
;------------------------------
remap_pic:
  push ax                       ; Push working registers (call context)
  push si

  mov al, 0xFF                  ; Disable IRQs
  out PIC1_DATA, al
  out PIC2_DATA, al
  nop
  nop

  mov al, ICW1_INIT | ICW1_ICW4 ; ICW1: Send initialization command (= 0x11) to both PICs
  out PIC1_COMMAND, al
  out PIC2_COMMAND, al
  mov al, 0x20                  ; ICW2: Set vector offset of 1st PIC to 0x20 (i.e. IRQ0 => INT 32)
  out PIC1_DATA, al
  mov al, 0x28                  ; ICW2: Set vector offset of 2nd PIC to 0x28 (i.e. IRQ8 => INT 40)
  out PIC2_DATA, al
  mov al, 4                     ; ICW3: tell 1st PIC that there is a 2nd PIC at IRQ2 (= 00000100)
  out PIC1_DATA, al
  mov al, 2                     ; ICW3: tell 2nd PIC its "cascade" identity (= 00000010)
  out PIC2_DATA, al
  mov al, ICW4_8086             ; ICW4: Set mode to 8086/88 mode
  out PIC1_DATA, al
  out PIC2_DATA, al

  mov al, 0xFF                  ; OCW1: mask all interrupts
  out PIC1_DATA, al
  out PIC2_DATA, al

  pop si                        ; Pop working registers (call context)
  pop ax
  ret                           ; Return