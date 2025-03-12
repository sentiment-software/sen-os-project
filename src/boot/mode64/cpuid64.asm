%include "src/boot/definitions/cpuid.asm"
%include "src/boot/definitions/bootinfo.asm"

[bits 64]

; --------------------------------------------------
; cpuid_read_all: Reads all required CPUID leafs for boot info
cpuid_read_all:
  call cpuid_read_leaf_basic_1
  call cpuid_read_leaf_extf_1
  ret

; --------------------------------------------------
; cpuid_read_leaf_basic_1: Reads the Basic Information Leaf 0 (0x0).
cpuid_read_leaf_basic_1:
  push rax
  push rbx
  push rcx
  push rdx

  mov eax, CPUID_LEAF_BASIC_0
  cpuid

  mov dword [boot_info.cpu_basic_max], eax
  mov dword [boot_info.cpu_vendor_id], ebx
  mov dword [boot_info.cpu_vendor_id + 4], edx
  mov dword [boot_info.cpu_vendor_id + 8], ecx

  .return:
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; --------------------------------------------------
; cpuid_read_leaf_extf_1: Reads the Extended Function Leaf 1 (0x80000001).
cpuid_read_leaf_extf_1:
  push rax
  push rbx
  push rcx
  push rdx
  
  mov eax, CPUID_LEAF_EXTF_1
  cpuid

  mov dword [boot_info.cpu_extf_sig], eax
  xor eax, eax
  .test_lahf64:
    bt ecx, CPUID_ECX_LAHF_64
    jnc .test_lzcnt
    or eax, INFO_CPU_EXTF_LAHF_64
  .test_lzcnt:
    bt ecx, CPUID_ECX_LZCNT
    jnc .test_prefetchw
    or eax, INFO_CPU_EXTF_LZCNT
  .test_prefetchw:
    bt ecx, CPUID_ECX_PREFETCHW
    jnc .test_syscallret
    or eax, INFO_CPU_EXTF_PREFETCHW
  .test_syscallret:
    bt edx, CPUID_EDX_SYSCALLRET
    jnc .test_ed
    or eax, INFO_CPU_EXTF_SYSCALLRET
  .test_ed:
    bt edx, CPUID_EDX_ED
    jnc .test_1gb_page
    or eax, INFO_CPU_EXTF_ED
  .test_1gb_page:
    bt edx, CPUID_EDX_1GB_PAGE
    jnc .test_rdtscp
    or eax, INFO_CPU_EXTF_1GB_PAGE
  .test_rdtscp:
    bt edx, CPUID_EDX_1GB_RDTSCP
    jnc .test_intel64
    or eax, INFO_CPU_EXTF_RDTSCP
  .test_intel64:
    bt edx, CPUID_EDX_INTEL_64
    jnc .return
    or eax, INFO_CPU_EXTF_INTEL_64
  .return:
    mov [boot_info.cpu_extf], eax
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret
