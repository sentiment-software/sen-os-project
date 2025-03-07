%include "src/boot/definitions/vga.asm"

[bits 64]

; Initialize the console
; Start on the line 2 not to overwrite the protected mode message.
console:
  .line:   dd 1
  .col:    dd 0
  .offset: dd VGA_PAGE_1_BASE + (VGA_LINE_LENGTH * 2)
  .page:   dd 0

  ; Updates the offset based on the current cursor values
  ; Calculates: offset := (2 * line * VGA_LINE_LENGTH) + (2 * col) + VGA_BUFFER
  .updateOffset:
    push rax
    push rbx
    push rdx
    mov eax, dword [.line]
    mov ebx, (2 * VGA_LINE_LENGTH)
    mul ebx
    mov ebx, dword [.col]
    add eax, ebx
    add eax, ebx
    add eax, VGA_BUFFER
    mov dword [.offset], eax
    pop rdx
    pop rbx
    pop rax
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
print:
  push rax
  push rbx
  push rdx
  .loop:
    xor eax, eax
    mov edx, dword [console.offset]
    mov ah, VGA_BLACK_ON_GRAY
    mov al, [ebx]

    cmp al, 0          ; If = 0, end of string, return
    je .return
    cmp al, 10         ; If = 10, new line
    je .newline

    mov [edx], ax      ; Put character in VGA buffer
    inc ebx            ; Next character position in string
    call console.next  ; Next cursor position on console
    jmp .loop

  .newline:
    call console.newline
    jmp .loop

  .return:
    pop rdx
    pop rbx
    pop rax
    ret

println:
  call print
  call console.newline
  ret

; Clears the screen using the VGA memory
clear:
  push rax
  push rdx

  mov dword [console.line], 0
  mov dword [console.col], 0
  call console.updateOffset
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
    pop rdx
    pop rax
    ret