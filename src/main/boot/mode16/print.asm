[bits 16]

;------------------------------
; mode16_print:
;
; Prints a string to the screen using LODSB and BIOS INT=0x10/AH=0x0e.
; The string has to be represented as the first word (16-bits) being the length in bytes,
; followed by the ASCII characters.
;
; Input:
;   SI - Points to the start of the string variable.
;
; Working registers:
;   AX, CX, SI - saved and restored from stack.
;
; Output:
;   This method does not change the registers.
;------------------------------
mode16_print:
  push ax                     ; Save working registers
  push cx
  push si
  mov cx, word [si]           ; Move the length into the counter
  jcxz .return                ; If length is 0, return to avoid loading garbage
  add si, 2                   ; Move the pointer to the first character
  .string_loop:
    lodsb                     ; Load string byte into AL, increment SI
    mov ah, 0x0e              ; Load interrupt function number into AH
    int 0x10                  ; Call interrupt
    dec cx                    ; Decrease CX, sets ZF if 0
    jnz .string_loop          ; Loop
  pop si                      ; Restore working registers
  pop cx
  pop ax
  .return:
    ret                       ; Return