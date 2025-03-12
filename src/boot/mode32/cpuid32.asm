%include "src/boot/definitions/cpuid.asm"

[bits 32]

;------------------------------
; cpuid_supported:
;
; Test whether the CPUID instruction is available.
; The EFALGS[21] bit indicates CPUID instruction support.
;
; Return:
;   EAX = 0 - CPUID is not supported
;   EAX > 0 - CPUID is supported
;------------------------------
cpuid_supported:
  pushfd                        ; Push EFALGS (call context)
  pushfd                        ; Push EFLAGS (test context)
  xor dword [esp], EFLAGS_CPUID ; Invert the ID bit on the stack
  popfd                         ; Pop EFLAGS with the ID bit inverted
  pushfd                        ; Push EFALGS (ID bit is inverted only if CPUID is supported)
  pop eax                       ; Pop the test EFLAGS value into EAX
  xor eax, [esp]                ; Unmask changed bits (test EFLAGS against original EFLAGS)
  popfd                         ; Pop EFLAGS (call context)
  and eax, EFLAGS_CPUID         ; Test EAX & ID => EAX (=0: unsupported, >0 supported)
  ret

;------------------------------
; cpuid_has_mode64:
;
; Test whether long mode is supported using CPUID.
; The method test the EDX[29] bit after calling CPUID instruction.
; The availability of the CPUID must be tested before calling this routine (cpuid_supported).
;
; Return:
;   EAX = 0 - Long mode is not supported
;   EAX = 1 - Long mode is supported
;------------------------------
cpuid_has_mode64:
  push eax
  push edx
  mov eax, CPUID_LEAF_EXTF_1
  cpuid
  test edx, CPUID_EDX_INTEL_64
  jz .returnFalse
  mov eax, 0x1
  jmp .return
  .returnFalse:
    mov eax, 0x0
  .return:
    pop edx
    pop eax
    ret