bits 64

section .text.kernel_entry
global kernel_entry

extern kmain
extern cpuidReadAll

kernel_entry:
;  mov rax, 0xFEE00020
;  mov eax, [rax]
;  shr rax, 24
;  mov [current_apic_id], rax

  ; Load CPU info
  call cpuidReadAll

  ; Push CPU info for kernel
  mov rdi, CpuInfo

  call kmain
  cli
  hlt

section .data
extern CpuInfo
current_apic_id dq 0