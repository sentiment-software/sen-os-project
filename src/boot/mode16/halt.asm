[bits 16]

;------------------------------
; halt:
;
; Enters an infinite loop which halts the CPU using hlt instruction.
; Once called, there is no return from here.
;------------------------------
halt:
  cli
  hlt
  jmp halt
