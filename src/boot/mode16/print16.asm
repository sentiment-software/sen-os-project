[bits 16]

;------------------------------
; mode16_print:
;
; Prints a null-terminated string to the screen using LODSB and BIOS INT=0x10/AH=0x0e.
;
; Input:
;   SI - Points to the start of the string.
;
; Output:
;   This method does not change the registers.
;------------------------------
print16:
  push ax                     ; Save working registers
  push si

  mov ah, 0x0E                ; Load interrupt function number into AH
  .loop:
    lodsb                     ; Load string byte into AL, increment SI
    cmp al, 0                 ; If AL = 0, return
    jz .return
    int 0x10                  ; Call interrupt
    jmp .loop                 ; Loop

  .return:
    pop si
    pop ax
    ret

;------------------------------
; clear16:
;
; Clears the screen in real mode.
;------------------------------
clear16:
  pusha                       ; Push GP registers (call context)
  mov ax, 0x0700              ; Set interrupt function 7 and parameter 0 (scroll window)
  mov bh, 0x07                ; Set color code (white on black)
  mov cx, 0x0000              ; Set start row = 0, col = 0
  mov dx, 0x184f              ; Set end row = 24 (0x18), col = 79 (0x4f)
  int 0x10                    ; Call interrupt
  popa                        ; Pop GP registers (call context)
  ret                         ; Return