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

mode32_print_registers:
  pusha

  ; Print EAX
  mov ebx, str_eax
  call mode32_print
  mov eax, [esp + 36] ; EAX is at 36 bytes offset from ESP after pusha
  call print_hex

  ; Print EBX
  mov ebx, str_ebx
  call mode32_print
  mov eax, [esp + 32] ; EBX is at 32 bytes offset from ESP after pusha
  call print_hex

  ; Print ECX
  mov ebx, str_ecx
  call mode32_print
  mov eax, [esp + 28] ; ECX is at 28 bytes offset from ESP after pusha
  call print_hex

  ; Print EDX
  mov ebx, str_edx
  call mode32_print
  mov eax, [esp + 24] ; EDX is at 24 bytes offset from ESP after pusha
  call print_hex

  mov ebx, str_nl
  call mode32_println

  ; Print ESI
  mov ebx, str_esi
  call mode32_print
  mov eax, [esp + 20] ; ESI is at 20 bytes offset from ESP after pusha
  call print_hex

  ; Print EDI
  mov ebx, str_edi
  call mode32_print
  mov eax, [esp + 16] ; EDI is at 16 bytes offset from ESP after pusha
  call print_hex

  ; Print EBP
  mov ebx, str_ebp
  call mode32_print
  mov eax, [esp + 12] ; EBP is at 12 bytes offset from ESP after pusha
  call print_hex

  ; Print ESP
  mov ebx, str_esp
  call mode32_print
  lea eax, [esp + 36] ; ESP is the current stack pointer + 36 bytes for pusha
  call print_hex

  ; Print EIP
  mov ebx, str_eip
  call mode32_print
  call get_eip
  call print_hex

  mov ebx, str_nl
  call mode32_println

  ; Print CR0
  mov ebx, str_cr0
  call mode32_print
  mov eax, cr0
  call print_hex

  ; Print CR2
  mov ebx, str_cr2
  call mode32_print
  mov eax, cr2
  call print_hex

  ; Print CR3
  mov ebx, str_cr3
  call mode32_print
  mov eax, cr3
  call print_hex

  ; Print CR4
  mov ebx, str_cr4
  call mode32_print
  mov eax, cr4
  call print_hex

  ; Print EFER MSR
  mov ebx, str_efer
  call mode32_print
  mov ecx, EFER_MSR
  rdmsr              ; Reads content is into EAX
  call print_hex

  mov ebx, str_nl
  call mode32_println

  popa
  ret

get_eip:
  mov eax, [esp]
  ret

print_hex:
  pusha
  mov ecx, 8
  .print_loop:
    rol eax, 4
    mov bl, al
    and bl, 0x0F
    cmp bl, 0x0A
    jl .digit
    add bl, 'A' - 0x0A
    jmp .store
  .digit:
    add bl, '0'
  .store:
    mov [esp + ecx - 1], bl
    loop .print_loop
  mov ebx, esp
  call mode32_print
  popa
  ret

str_nl  db " ", 0
str_eax db " |EAX: ", 0
str_ebx db " |EBX: ", 0
str_ecx db " |ECX: ", 0
str_edx db " |EDX: ", 0
str_esi db " |ESI: ", 0
str_edi db " |EDI: ", 0
str_ebp db " |EBP: ", 0
str_esp db " |ESP: ", 0
str_eip db " |EIP: ", 0
str_cr0 db " |CR0: ", 0
str_cr2 db " |CR2: ", 0
str_cr3 db " |CR3: ", 0
str_cr4 db " |CR4: ", 0
str_efer db " |EFER: ", 0