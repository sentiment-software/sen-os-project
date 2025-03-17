%include "src/definitions/vga.asm"

[bits 32]

; Simple implementation of a console buffer
; We can keep track of the printed lines, so we don't have to calculate this on the caller's side
console32:
  .line:   dd 0
  .col:    dd 0
  .offset: dd VGA_PAGE_1_BASE

  ; Updates the offset based on the current cursor values
  ; Calculates: offset := (2 * line * VGA_LINE_LENGTH) + (2 * col) + VGA_BUFFER
  .updateOffset:
    push eax
    push ebx
    push edx
    mov eax, dword [.line]
    mov ebx, (2 * VGA_LINE_LENGTH)
    mul ebx
    mov ebx, dword [.col]
    add eax, ebx
    add eax, ebx
    add eax, VGA_BUFFER
    mov dword [.offset], eax
    pop edx
    pop ebx
    pop eax
    ret

  ; Moves the cursor to a new line
  .newline:
    add dword [.line], 1
    mov dword [.col], 0
    call .updateOffset
    ret

  ; Moves the cursor to the next character
  .next:
    add dword [.col], 1
    cmp dword [.col], VGA_LINE_LENGTH
    jge .nextNewLine
    call .updateOffset
    ret
  .nextNewLine:
    call .newline
    ret


; Prints a null terminated string to the VGA memory
; Inputs:
;   EBX: Pointer to the string's first character
print32:
  push eax
  push ebx
  push edx
  .loop:
    xor eax, eax
    mov edx, dword [console32.offset]
    mov ah, VGA_BLACK_ON_GRAY
    mov al, [ebx]

    cmp al, 0            ; If = 0, end of string, return
    je .return
    cmp al, 10           ; If = 10, new line
    je .newline

    mov [edx], ax        ; Put character in VGA buffer
    inc ebx              ; Next character position in string
    call console32.next  ; Next cursor position on console
    jmp .loop

  .newline:
    call console32.newline
    jmp .loop

  .return:
    pop edx
    pop ebx
    pop eax
    ret

; Prints a null-terminated string and a new line
println32:
  call print32
  call console32.newline
  ret

; Clears the screen by clearing the first page in the VGA memory
clear32:
  push eax
  push edx

  mov dword [console32.line], 0
  mov dword [console32.col], 0
  call console32.updateOffset
  mov edx, VGA_BUFFER
  mov al, ' '
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