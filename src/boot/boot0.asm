%include "src/boot/definitions/memorymap.asm"
%include "src/boot/definitions/segments.asm"

[org 0x7C00]
[bits 16]

boot_entry:
  ; Reload CS to 0x0 to fix boot segment discrepancy
  jmp SEG_ZERO:boot0_main

boot0_main:
  ; Reload segment registers and set Boot Stack Pointer (down-growing)
  xor ax, ax
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov ss, ax
  mov sp, BOOT_STACK_TOP

  ; Save the boot disk number
  mov bx, dx

  ; Load Boot Stage 1 & Global Structures at 0x1000
  push bx                                        ; Pass disk number of bootable disk
  push word 0                                    ; Pass start sector (upper 16 bits)
  push word BOOT_1_SECTOR                        ; Pass start sector (lower 16 bits)
  push word ((BOOT_1_SIZE + GLOB_SIZE) / 512)    ; Pass sector count
  push word BOOT_1_BASE                          ; Pass target buffer offset
  push word SEG_ZERO                             ; Pass target buffer segment
  call load16                                    ; Read upper boot stages from disk
  pop ax                                         ; Pop return code to AX
  cmp ax, 0x0                                    ; If AX = 0x0 then disk read failed, halt
  je .halt

  ; Load Kernel at 0x10000
; TODO: compile kernel into bin to call this
;  push bx
;  push word 0
;  push word KERN_SECTOR
;  push word (KERN_SIZE / 512)
;  push word KERN_BASE
;  push word SEG_ZERO
;  call load16
;  pop ax
;  cmp ax, 0x0
;  je .halt

  ; Jump to Boot Stage 1
  jmp SEG_ZERO:BOOT_1_BASE

  .halt:
    cli
    hlt
    jmp .halt

; ===== Includes
%include "src/boot/mode16/disk16.asm"

; ===== Align on a 512 byte boundary
times 510 - ($ - $$) db 0

; ===== Boot Sector Signature
dw 0xAA55