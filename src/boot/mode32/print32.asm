%include "src/boot/definitions/vga.asm"

[bits 32]

; Simple implementation of a console buffer
; We can keep track of the printed lines, so we don't have to calculate this on the caller's side
console32:
  .line:   dd 0
  .col:    dd 0
  .offset: dd VGA_PAGE_1_BASE

; Increments cursor position
console32_nextChar:
  pusha
  mov eax, dword [console32.col]
  inc eax
  cmp eax, (VGA_LINE_LENGTH - 1)      ; If we are still in line
  jle .incOffset                      ;    then just increase the buffer offset

  mov ebx, dword [console32.line]     ; Else, move to new line
  inc ebx
  mov eax, 0
  .incOffset:
    add dword [console32.offset], 2
    mov dword [console32.col], eax
    mov dword [console32.line], ebx
    popa
    ret

; Set cursor position to next line
; Naive implementation, it just iterates .nextChar until we reach it
console32_seekToNewLine:
  push eax
  .loop:
    call console32_nextChar
    mov eax, dword [console32.col]
    cmp eax, 0
    jne .loop
    pop eax
    ret


; Prints a null terminated string to the VGA memory
; Inputs:
;   EBX: Pointer to the string's first character
print32:
  pusha
  .loop:
    xor eax, eax
    mov ah, VGA_BLACK_ON_GRAY
    mov al, [ebx]
    mov edx, dword [console32.offset]

    cmp al, 0       ; If = 0, end of string, return
    je .return
    cmp al, 10      ; If = 10, new line
    je .newline

    mov [edx], ax                       ; Put character in VGA buffer
    inc ebx                             ; Next character position in string
    call console32_nextChar             ; Next cursor position on console
    jmp .loop

  .newline:
    call console32_seekToNewLine
    jmp .loop

  .return:
    popa
    ret

println32:
  call print32
  call console32_seekToNewLine
  ret

; Clears the screen by clearing the first page in the VGA memory
clear32:
  push eax
  push edx

  mov dword [console32.line], 0
  mov dword [console32.col], 0
  mov dword [console32.offset], VGA_PAGE_1_BASE
  mov edx, VGA_BUFFER
  mov al, 0x20 ; The [SPACE] character
  mov ah, VGA_BLACK_ON_GRAY

  .loop:
    cmp edx, (VGA_BUFFER + VGA_PAGE_SIZE)
    jge .return
    mov [edx], ax
    add edx, 2
    jmp .loop

  .return:
    pop edx
    pop eax
    ret