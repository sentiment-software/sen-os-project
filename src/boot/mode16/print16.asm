[bits 16]

; Prints a null-terminated string to the screen using BIOS INT=0x10/AH=0x0E.
; Input:
;   SI - Points to the start of the string.
print16:
  push ax                     ; Save working registers
  push si

  mov ah, 0x0E                ; Load interrupt function number into AH
  .loop:
    lodsb                     ; Load string byte into AL, increment SI
    test al, al               ; If AL = 0, return
    jz .return
    int 0x10                  ; Call interrupt
    jmp .loop                 ; Loop

  .return:
    pop si
    pop ax
    ret

; Clears the screen using BIOS INT=0x10/AX=0x0700
clear16:
  pusha                       ; Push GP registers (call context)
  mov ax, 0x0700              ; Set interrupt function 7 and parameter 0 (scroll window)
  mov bh, 0x07                ; Set color code (white on black)
  mov cx, 0x0000              ; Set start row = 0, col = 0
  mov dx, 0x184f              ; Set end row = 24 (0x18), col = 79 (0x4f)
  int 0x10                    ; Call interrupt
  popa                        ; Pop GP registers (call context)
  ret                         ; Return

; Hides the cursor using BIOS INT=0x10/AX=0x2607
hide_cursor16:
  push ax
  push cx
  mov ax, 0x0100
  mov cx, 0x2607
  int 0x10
  pop cx
  pop ax
  ret

; Prints the value of AX as hex.
printhex16:
  push ax                     ; Save working registers
  push bx
  push cx

  mov bx, ax                  ; Copy AX to BX
  mov cx, 4                   ; Set loop counter to 4 for 4 hex digits

  .loop:
    rol bx, 4                 ; Rotate left 4 bits to get next hex digit in AL
    mov al, bl                ; Move lower 4 bits of BX to AL
    and al, 0x0F              ; Mask upper 4 bits of AL
    cmp al, 9                 ; Check if digit is 0-9 or A-F
    jbe .digit_is_number
    add al, 'A' - 10          ; Convert to ASCII letter
    jmp .print_digit

  .digit_is_number:
    add al, '0'               ; Convert to ASCII number

  .print_digit:
    mov ah, 0x0E
    int 0x10
    loop .loop                ; Loop until all digits are printed

    pop cx                    ; Restore working registers
    pop bx
    pop ax
    ret