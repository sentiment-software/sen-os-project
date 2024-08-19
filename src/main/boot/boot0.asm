[bits 16]                                     ; Use 16-bit instruction set for real mode
[org 0x7c00]                                  ; Set origin address to the boot sector address

boot_start:
  jmp 0x0:boot0_main                          ; Reload CS to 0 to fix boot segment discrepancy

boot0_main:
  xor ax, ax                                  ; Set segment registers to 0
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov ss, ax
  mov sp, boot_start                          ; Set down-growing stack pointer
  cld                                         ; Clear direction flag

  call mode16_clear_screen                    ; Clear the screen

  mov si, msg_boot0_start                     ; Print info message
  call mode16_print

  push dx                                     ; Pass disk number of bootable disk
  push dword ((boot1_start-boot0_start)/512)  ; Pass start sector
  push word ((kernel_end-boot1_start)/512)    ; Pass sector count
  push word boot1_start                       ; Pass buffer offset
  push word 0x0                               ; Pass buffer segment
  call mode16_read_disk                       ; Read upper boot stages from disk

  pop ax                                      ; Pop return code to AX
  cmp ax, 1                                   ; If AX = 1,
  je .print_disk_ok                           ;   then disk read was OK
  mov si, msg_disk_error                      ; Else print an error message and halt
  call mode16_print
  call halt

  .print_disk_ok:
    mov si, msg_disk_ok                       ; Print disk success message
    call mode16_print

  .boot0_ok:
    mov si, msg_boot0_ok                      ; Print boot success message
    call mode16_print
    jmp boot1_main                            ; Jump to boot1

; ===== Includes
%include "src/main/boot/mode16/halt.asm"
%include "src/main/boot/mode16/print.asm"
%include "src/main/boot/mode16/disk.asm"

; ===== Messages
msg_boot0_start dw 15
  db 'Boot 0: START', 13, 10
msg_boot0_ok dw 12
  db 'Boot 0: OK', 13, 10
msg_disk_ok dw 17
  db 'Boot 0: DISK OK', 13, 10
msg_disk_error dw 20
  db 'Boot 0: DISK ERROR', 13, 10

; ===== Padding
times 510 - ($ - $$) db 0   ; Pad to 510 bytes
dw 0xaa55                   ; Boot signature at 511:512 bytes