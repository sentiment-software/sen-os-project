%include "src/definitions/cpuid.asm"
%include "src/definitions/registers.asm"

[bits 32]

; This cpuid32 implementation only checks flags required for long mode.

;------------------------------
; cpuid_supported: Tests whether the CPUID instruction is available using EFALGS[21] bit.
;
; Return:
;   EAX = 0 - CPUID is not supported
;   EAX > 0 - CPUID is supported
;------------------------------
cpuid_supported:
  pushfd                                   ; Push EFALGS (call context)
  pushfd                                   ; Push EFLAGS (test context)
  xor dword [esp], (1 << BIT_EFLAGS_CPUID) ; Invert the ID bit on the stack
  popfd                                    ; Pop EFLAGS with the ID bit inverted
  pushfd                                   ; Push EFALGS (ID bit is inverted only if CPUID is supported)
  pop eax                                  ; Pop the test EFLAGS value into EAX
  xor eax, [esp]                           ; Unmask changed bits (test EFLAGS against original EFLAGS)
  popfd                                    ; Pop EFLAGS (call context)
  and eax, (1 << BIT_EFLAGS_CPUID)         ; Test EAX & ID => EAX (=0 unsupported, >0 supported)
  ret

;------------------------------
; cpuid_test_all_mode64:
;
; Tests whether every instruction required to enter long mode is supported using CPUID.
; Tested flags are Intel64, PAE, PGE, MSR
;
; Return:
;   EAX = 0 - Long mode is not supported (any one of the tests failed)
;   EAX > 0 - Long mode is supported (all the tests passed)
;------------------------------
cpuid_test_all_mode64:
  push ebx
  push ecx
  push edx

  mov eax, CPUID_LEAF_EXTF_1
  cpuid
  bt edx, CPUID_BIT_INTEL64
  jnc .returnFalse

  mov eax, CPUID_LEAF_BASIC_FEATURE
  cpuid
  bt edx, CPUID_BIT_MSR
  jnc .returnFalse
  bt edx, CPUID_BIT_PAE
  jnc .returnFalse
  bt edx, CPUID_BIT_PGE
  jnc .returnFalse
  mov eax, 1
  jmp .return

  .returnFalse:
    xor eax, eax
  .return:
    pop edx
    pop ecx
    pop ebx
    ret