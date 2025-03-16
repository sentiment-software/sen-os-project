%include "src/boot/definitions/cpuid.asm"
%include "src/boot/definitions/bootinfo.asm"

[bits 64]

; --------------------------------------------------
; cpuid_read_all: Reads all required CPUID leafs for boot info
cpuid_read_all:
  call cpuid_read_leaf_basic_0
  call cpuid_read_leaf_basic_1
  call cpuid_read_leaf_extf_0
  call cpuid_read_leaf_extf_1
  call cpuid_enumerate_topology
  ret

; --------------------------------------------------
; cpuid_read_leaf_basic_0: Reads the Basic Information Leaf 0 (0x0).
cpuid_read_leaf_basic_0:
  push rax
  push rbx
  push rcx
  push rdx

  mov eax, CPUID_LEAF_BASIC_0
  cpuid
  mov dword [boot_info.cpuid_max_basic], eax
  mov dword [boot_info.cpu_vendor_id], ebx
  mov dword [boot_info.cpu_vendor_id + 4], edx
  mov dword [boot_info.cpu_vendor_id + 8], ecx
  mov dword [boot_info.cpu_vendor_id + 12], 0  ; Terminate string and pad to qword

  .return:
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; --------------------------------------------------
; cpuid_read_leaf_basic_1: Reads the Basic Information Leaf 1 (0x1).
cpuid_read_leaf_basic_1:
  push rax
  push rbx
  push rcx
  push rdx

  mov eax, CPUID_LEAF_BASIC_FEATURE
  cpuid

  mov dword [boot_info.cpu_version_info], eax
  mov byte [boot_info.cpu_brand_index], bl
  mov byte [boot_info.cpu_clflush_size], bh
  mov dword [boot_info.cpu_features], ecx
  mov dword [boot_info.cpu_features + 4], edx

  shr ebx, 16
  and ebx, 0xFF
  mov byte [boot_info.cpu_leg_lp_count], bl
  bt edx, CPUID_BIT_APIC
  jnc .return
  mov eax, CPUID_LEAF_BASIC_FEATURE
  cpuid
  shr ebx, 24
  mov byte [boot_info.cpu_leg_apic_id], bl
  jmp .return

  .return:
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; --------------------------------------------------
; cpuid_read_leaf_extf_0: Reads the Extended Function Leaf 0 (0x80000000).
cpuid_read_leaf_extf_0:
  push rax
  push rbx
  push rcx
  push rdx

  mov eax, CPUID_LEAF_EXTF_0
  cpuid
  mov dword [boot_info.cpuid_max_extf], eax

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
    bt ecx, CPUID_BIT_LAHF64
    jnc .test_lzcnt
    or eax, INFO_CPU_EXTF_LAHF_64
  .test_lzcnt:
    bt ecx, CPUID_BIT_LZCNT
    jnc .test_prefetchw
    or eax, INFO_CPU_EXTF_LZCNT
  .test_prefetchw:
    bt ecx, CPUID_BIT_PREFETCHW
    jnc .test_syscallret
    or eax, INFO_CPU_EXTF_PREFETCHW
  .test_syscallret:
    bt edx, CPUID_BIT_SYSCALLRET
    jnc .test_ed
    or eax, INFO_CPU_EXTF_SYSCALLRET
  .test_ed:
    bt edx, CPUID_BIT_ED
    jnc .test_1gb_page
    or eax, INFO_CPU_EXTF_ED
  .test_1gb_page:
    bt edx, CPUID_BIT_1GB_PAGE
    jnc .test_rdtscp
    or eax, INFO_CPU_EXTF_1GB_PAGE
  .test_rdtscp:
    bt edx, CPUID_BIT_1GB_RDTSCP
    jnc .test_intel64
    or eax, INFO_CPU_EXTF_RDTSCP
  .test_intel64:
    bt edx, CPUID_BIT_INTEL64
    jnc .return
    or eax, INFO_CPU_EXTF_INTEL_64
  .return:
    mov byte [boot_info.cpu_extf], al
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; --------------------------------------------------
; cpuid_enumerate_topology:
;   Algorithm to enumerate the CPU topology.
;   Based on the Intel 64 architecture processor topology enumeration document.
;   Requires boot_info.cpuid_max_basic to be loaded.
cpuid_enumerate_topology:
  push rax
  push rbx
  push rcx
  push rdx

  ; Clear MISC[22] reserved bit if it's set
  mov ecx, MSR_MISC
  rdmsr
  bt eax, BIT_MISC_22
  jnc .test_max_1f
  or eax, (0 << BIT_MISC_22)
  wrmsr

  .test_max_1f:
    cmp dword [boot_info.cpuid_max_basic], CPUID_LEAF_EXT_TOPOLOGY_V2
    jb .test_max_b
    mov eax, CPUID_LEAF_EXT_TOPOLOGY_V2
    xor ecx, ecx
    cpuid
    test ebx, ebx
    jnz .enum_leaf_ext_topology_v2

  .test_max_b:
    cmp dword [boot_info.cpuid_max_basic], CPUID_LEAF_EXT_TOPOLOGY
    jb .test_max_4
    mov eax, CPUID_LEAF_EXT_TOPOLOGY
    xor ecx, ecx
    cpuid
    test ebx, ebx
    jnz .enum_leaf_ext_topology_v1

  .test_max_4:
    cmp dword [boot_info.cpuid_max_basic], 0x4
    jb .return ; Legacy branch is already tested in Leaf 0x1. TODO: implement here later to decouple routines
    jmp .return ; TODO: jmp .enum_leaf_1_4

  .enum_leaf_ext_topology_v2:
    mov eax, CPUID_LEAF_EXT_TOPOLOGY_V2
    xor ecx, ecx
    jmp .enum_loop

  .enum_leaf_ext_topology_v1:
    mov eax, CPUID_LEAF_EXT_TOPOLOGY
    xor ecx, ecx
    ; Flow to .enum_loop

  .enum_loop:
    push rax
    push rcx
    cpuid                    ; Query next leaf of the topology
    mov ebx, ecx             ; Save ECX for level check
    shr ebx, 8
    and ebx, 0xFF
    test ebx, ebx            ; If Domain Type = 0, done
    jz .return_enum_loop
    cmp ebx, 7
    jae .return_enum_loop    ; If Domain Type >= 7, done
    and eax, 0xF             ; Prepare Shift value
    cmp ebx, CPU_DOMAIN_LP   ; If Domain Type in ECX[15:8] is "Logical Processor"
    je .enum_loop_lp         ; Then save the logical processor shift value
    mov byte [boot_info.cpu_core_shift], al ; Else save the core shift value
    jmp .enum_loop_inc

  .enum_loop_lp:
    mov byte [boot_info.cpu_lp_shift], al

  .enum_loop_inc:
    pop rcx                   ; Restore input (ECX)
    pop rax                   ; Restore leaf ID (EAX)
    inc rcx
    jmp .enum_loop

  .return_enum_loop:
    pop rcx ; 2 loop values are still in
    pop rax
  .return:
    pop rdx ; Routine
    pop rcx
    pop rbx
    pop rax
    ret

