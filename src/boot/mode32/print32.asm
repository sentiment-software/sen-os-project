%include "src/boot/definitions/vga.asm"

[bits 32]

; Simple implementation of a console buffer
; We can keep track of the printed lines, so we don't have to calculate this on the caller's side
console32:
  .line: dd 0
  .col: dd 0
  .offset: dd VGA_PAGE_1_BASE

  ; Increments cursor position
console32_nextChar:
  pusha
  mov eax, dword [console32.col]
  inc eax
  cmp eax, (VGA_LINE_LENGTH - 1)           ; If we are still in line
  jle .incOffset                      ;    then just increase the buffer offset

  mov ebx, dword [console32.line]             ; Else, move to new line
  inc ebx
  mov eax, 0
  .incOffset:
    add dword [console32.offset], 2
    mov dword [console32.col], eax
    mov dword [console32.line], ebx
    popa
    ret

  ; Resets cursor position
console32_clear:
  mov dword [console32.line], 0
  mov dword [console32.col], 0
  mov dword [console32.offset], VGA_PAGE_1_BASE
  ret

  ; Sets cursor position based on EAX:
  ;   EAX[31:16]: Line number (between 0-24)
  ;   EAX[15:0]:  Column number (between 0-79)
console32_seekTo:
  pusha
  push eax                        ; Save EAX as we need it for mul
  shr eax, 16                     ; Move the [31-16] bits of EAX into [15-0] (line number)
  mov dword [console32.line], eax          ; Save the line number
  mov ecx, (2 * VGA_LINE_LENGTH)  ; Move the multiplier into ECX
  mul ecx                         ; EDX:EAX := EAX * ECX => EDX=0,EAX=Line offset
  mov edx, eax                    ; (Line offset) is in EDX
  pop eax                         ; Get back original EAX
  and eax, 0x0000FFFF             ; Get the column number by masking the line number bits
  mov dword [console32.col], eax           ; Save the column number
  add edx, eax                    ; (Line + Column) offset is in EDX
  add edx, VGA_PAGE_1_BASE        ; (PageBase + Line + Column) offset is in EDX
  mov dword [console32.offset], edx        ; Save this offset
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
mode32_print:
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

    mov [edx], ax                            ; Put character in VGA buffer
    inc ebx                                  ; Next character position in string
    call console32_nextChar             ; Next cursor position on console
    jmp .loop

  .newline:
    call console32_seekToNewLine
    jmp .loop

  .return:
    popa
    ret

mode32_println:
  call mode32_print
  call console32_seekToNewLine
  ret

; Clears the screen using the VGA memory
mode32_clear:
  pusha

  mov edx, VGA_BUFFER
  mov ecx, VGA_PAGE_1_END
  mov al, 0x20 ; The [SPACE] character
  mov ah, VGA_BLACK_ON_GRAY

  .loop:
    test ecx, ecx
    jz .return
    mov [edx], ax
    add edx, 2
    dec ecx
    jmp .loop

  .return:
    call console32_clear
    popa
    ret
