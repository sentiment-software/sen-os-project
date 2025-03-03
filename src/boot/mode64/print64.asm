[bits 64]

; Initialize the console
; Start on the line 2 not to overwrite the protected mode message.
console:
  .line:   dd 1
  .col:    dd 0
  .offset: dd VGA_PAGE_1_BASE + (VGA_LINE_LENGTH * 2)
  .page:   dd 0


  ; Increments cursor position
console_nextChar:
  push rax
  push rbx
  mov eax, dword [console.col]
  inc eax
  cmp eax, (VGA_LINE_LENGTH - 1)           ; If we are still in line
  jle .incOffset                           ; then just increase the buffer offset

  mov ebx, dword [console.line]             ; Else, move to new line
  inc ebx
  mov eax, 0
  .incOffset:
    add dword [console.offset], 2
    mov dword [console.col], eax
    mov dword [console.line], ebx
    pop rbx
    pop rax
    ret

; Sets cursor position based on EAX:
;   EAX[31:16]: Line number (between 0-24)
;   EAX[15:0]:  Column number (between 0-79)
console_seekTo:
  push rax
  push rcx
  push rdx
  push rax                        ; Save RAX again as we need it for mul
  shr eax, 16                     ; Move the [31-16] bits of EAX into [15-0] (line number)
  mov dword [console.line], eax          ; Save the line number
  mov ecx, (2 * VGA_LINE_LENGTH)  ; Move the multiplier into ECX
  mul ecx                         ; EDX:EAX := EAX * ECX => EDX=0,EAX=Line offset
  mov edx, eax                    ; (Line offset) is in EDX
  pop rax                         ; Get back original EAX
  and eax, 0x0000FFFF             ; Get the column number by masking the line number bits
  mov dword [console.col], eax           ; Save the column number
  add edx, eax                    ; (Line + Column) offset is in EDX
  add edx, VGA_PAGE_1_BASE        ; (PageBase + Line + Column) offset is in EDX
  mov dword [console.offset], edx        ; Save this offset
  pop rdx
  pop rcx
  pop rax
  ret

  ; Set cursor position to next line
  ; Naive implementation, it just iterates .nextChar until we reach it
console_seekToNewLine:
  push rax
  .loop:
    call console_nextChar
    mov eax, dword [console.col]
    cmp eax, 0
    jne .loop
  pop rax
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
    mov ah, VGA_BLACK_ON_GRAY
    mov al, [ebx]
    mov edx, dword [console.offset]

    cmp al, 0       ; If = 0, end of string, return
    je .return
    cmp al, 10      ; If = 10, new line
    je .newline

    mov [edx], ax                            ; Put character in VGA buffer
    inc ebx                                  ; Next character position in string
    call console_nextChar             ; Next cursor position on console
    jmp .loop

  .newline:
    call console_seekToNewLine
    jmp .loop

  .return:
    pop rdx
    pop rbx
    pop rax
    ret

println:
  call print
  call console_seekToNewLine
  ret

; Clears the screen using the VGA memory
clear:
  push rax
  push rcx
  push rdx

  mov dword [console.line], 0
  mov dword [console.col], 0
  mov dword [console.offset], VGA_PAGE_1_BASE

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
    pop rdx
    pop rcx
    pop rax
    ret