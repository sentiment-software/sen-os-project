%include "src/boot/definitions/memorymap.asm"
%include "src/boot/definitions/segments.asm"

[org 0x7c00]                    ; Set origin address to the boot sector address

[bits 16]
boot_start:
  jmp SEG_ZERO:boot0_main       ; Reload CS to 0x0 to fix boot segment discrepancy

boot0_main:
  xor ax, ax                    ; Set all segment registers to 0x0
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov ss, ax
  mov sp, BOOT_STACK_TOP        ; Set boot stack pointer (down-growing)

  push dx                                        ; Pass disk number of bootable disk
  push word 0                                    ; Pass start sector (upper 16 bits)
  push word 1                                    ; Pass start sector (lower 16 bits)
  push word ((BOOT_1_END - BOOT_1_BASE) / 512)   ; Pass sector count
  push word BOOT_1_BASE                          ; Pass target buffer offset
  push word SEG_ZERO                             ; Pass target buffer segment
  call mode16_read_disk                          ; Read upper boot stages from disk

  pop ax                                         ; Pop return code to AX
  cmp ax, 0x1                                    ; If AX = 0x1 then disk read failed, halt
  je .halt

  jmp SEG_ZERO:BOOT_1_BASE                       ; Jump to boot stage 1

  .halt:
    cli
    hlt
    jmp .halt

; ===== Includes
%include "src/boot/mode16/disk.asm"

; ===== Padding
times 510 - ($ - $$) db 0   ; Pad to 510 bytes
dw 0xaa55                   ; Boot signature at 511:512 bytes