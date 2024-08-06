[bits 16]                   ; Use 16-bit instruction set for real mode.
[org 0x7c00]                ; Set origin address to the boot sector address.

mov al, 65                  ; ASCII for character 'A'
call printChar              ; Call print procedure

jmp $                    		; Infinite loop, hang it here.

printChar:
  mov ah, 0x0E	; Tell BIOS that we need to print one character on screen.
  mov bh, 0x00	; Page number
  mov bl, 0x07	; Text attribute 0x07 is lightgrey font on black background

int 0x10	      ; Video interrupt
ret		          ; Return to calling procedure

times 510 - ($ - $$) db 0   ; Pad to 510 bytes
dw 0xaa55                   ; Boot signature at 511:512 bytes