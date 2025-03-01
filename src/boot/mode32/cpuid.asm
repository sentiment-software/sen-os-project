[bits 32]

;------------------------------
; has_cpuid:
;
; Test whether the CPUID instruction is available without calling the CPUID.
; The method tests whether the EFALGS[21] bit can be flipped, based on Intel's manual.
;
; Return:
;   EAX = 0 - CPUID is not supported
;   EAX = 1 - CPUID is supported
;------------------------------
has_cpuid:
  pushfd                    ; Push EFALGS (call context)
  pushfd                    ; Push EFLAGS (test context)
  xor dword [esp], CPUID_ID ; Invert the ID bit on the stack
  popfd                     ; Pop EFLAGS with the ID bit inverted
  pushfd                    ; Push EFALGS (ID bit is inverted only if CPUID is supported)
  pop eax                   ; Pop the test EFLAGS value into EAX
  xor eax, [esp]            ; Unmask changed bits (test EFLAGS against original EFLAGS)
  popfd                     ; Pop EFLAGS (call context)
  and eax, CPUID_ID         ; Test EAX & ID
  jz .returnFalse           ; If = 0, return false (CPUID is not supported)
  mov eax, TRUE             ; Else return true (CPUID is supported)
  ret
  .returnFalse:
    mov eax, FALSE
    ret

;------------------------------
; has_cpuid_mode64:
;
; Test whether long mode is supported using CPUID.
; The method test the EDX[29] bit after calling CPUID instruction.
; The availability of the CPUID must be tested before calling this routine (has_cpuid).
;
; Return:
;   AX = 0 - Long mode is not supported
;   AX = 1 - Long mode is supported
;------------------------------
has_cpuid_mode64:
  mov eax, 0x80000001       ; Call CPUID with EAX = 0x80000001
  cpuid
  test edx, CPUID_MODE64    ; If EDX[29] is not set,
  jz .returnFalse           ; then return false
  mov eax, TRUE             ; else return true
  ret
  .returnFalse:
    mov eax, FALSE
    ret