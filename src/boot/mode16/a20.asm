[bits 16]

; ===== Messages
msg_a20_enabled dw 12
db 'A20 enabled', 13, 10


;------------------------------
; enable_a20:
;
; Tries to enable the A20 line using BIOS, Keyboard Controller and Port 92.
;
; Returns:
;   AX = 0 - A20 disabled
;   AX = 1 - A20 enabled
;------------------------------
enable_a20:
  call test_a20
  test ax, ax
  jnz .returnOk

  call enable_a20_bios
  call test_a20
  test ax, ax
  jnz .returnOk

  call enable_a20_keyboard
  call test_a20
  test ax, ax
  jnz .returnOk

  call enable_a20_io92
  call test_a20
  test ax, ax
  jnz .returnOk

  ; Return 0
  xor ax, ax
  ret

  .returnOk:
    mov ax, 1
    ret

;------------------------------
; test_a20:
;
; Tests whether the A20 line is enabled.
; This method uses memory access on addresses which use the A20 line.
;
; Return:
;   AX = 0 - A20 disabled
;   AX = 1 - A20 enabled
;------------------------------
test_a20:
  pushf                       ; Save registers (call context)
  push ds
  push es
  push di
  push si

  xor ax, ax                  ; ax = 0
  mov es, ax                  ; es = 0
  not ax                      ; ax = 0xFFFF
  mov ds, ax                  ; ds = 0xFFFF
  mov di, 0x500               ; 0x500 and 0x510 are guaranteed to be free
  mov si, 0x510

  mov dl, byte [es:di]        ; Save original values on these addresses
  push dx
  mov dl, byte [ds:si]
  push dx

  mov byte [es:di], 0x00      ; [es:di] is 0x0000:0x1000
  mov byte [ds:si], 0xff      ; [ds:si] is 0xFFFF:0x1010
  cmp byte [es:di], 0xff      ; If the A20 line is disabled, [es:di] will contain 0xFF
  mov ax, 0x0                 ; A20 disabled
  je .a20_disabled
  mov ax, 0x1                 ; A20 enabled

  .a20_disabled:
    pop dx                    ; Restore registers (call context)
    mov byte [ds:si], dl
    pop dx
    mov byte [es:di], dl
    pop si
    pop di
    pop es
    pop ds
    popf
    ret

;------------------------------
; enable_a20_bios:
;
; Enables A20 line using BIOS.
;------------------------------
enable_a20_bios:
  push ax
  mov ax, 0x2403        ; Query A20 gate Support (later PS/2s systems)
  int 0x15
  jb .return            ; INT 0x15 is not supported
  cmp ah, 0
  jnz .return           ; INT 0x15 is not supported
  mov ax, 0x2402        ; Get A20 gate Status
  int 0x15
  jb .return            ; Couldn't get status
  cmp ah, 0
  jnz .return           ; Couldn't get status
  cmp al, 1
  jz .return            ; A20 is already activated
  mov ax, 0x2401        ; Enable A20 gate
  int 0x15
  jb .return            ; Couldn't enable the A20 gate
  cmp ah, 0
  jnz .return           ; Couldn't enable the A20 gate
  .return:
    pop ax
    ret

;------------------------------
; enable_a20_keyboard:
;
; Enables A20 line using the keyboard controller.
;------------------------------
enable_a20_keyboard:
  call .a20wait
  mov al, 0xad           ; Disable keyboard.
  out 0x64, al
  call .a20wait
  mov al, 0xd0           ; Read from input.
  out 0x64, al
  call .a20wait2
  in al,0x60
  push eax
  call .a20wait
  mov al, 0xd1           ; Write to output.
  out 0x64, al
  call .a20wait
  pop eax
  or al, 2
  out 0x60, al
  call .a20wait
  mov al, 0xae           ; Enable keyboard.
  out 0x64, al
  call .a20wait
  ret
  .a20wait:
    in al, 0x64
    test al, 2
    jnz .a20wait
    ret
  .a20wait2:
    in al, 0x64
    test al, 1
    jz .a20wait2
    ret

;------------------------------
; enable_a20_io92:
;
; Enables A20 line using port 92
;------------------------------
enable_a20_io92:
  in al, 0x92            ; Read from port 0x92
  test al, 2             ; Check if bit al[1] is set.
  jnz .return            ; If bit al[1] is already set, return.
  or al, 2               ; Set al[1].
  and al, 0xfe           ; Set bit 0 is 0 (it causes a fast reset).
  out 0x92, al           ; Write to port 0x92
 .return:
   ret