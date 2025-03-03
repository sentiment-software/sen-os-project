%include "src/boot/definitions/paging.asm"

[bits 32]

; Initialize a minimal paging structure.
; Identity maps the first 2MB using a "Page Directory Mapping a 2MB page" and loads CR3.
init_pages:
  pusha

  ; Clear paging structure area in 4-byte chunks
  xor eax, eax
  mov ecx, (PAGE_ALLOC_SIZE / 4)
  mov edi, PAGE_ALLOC_BASE
  rep stosd

  ; Setup PML4[0] -> PDP_BASE
  mov edi, PML4_BASE
  mov eax, PDP_BASE | PAGE_PRESENT | PAGE_WRITE
  mov [edi], eax

  ; Setup PDP[0] -> PD_BASE
  mov edi, PDP_BASE
  mov eax, PD_BASE | PAGE_PRESENT | PAGE_WRITE
  mov [edi], eax

  ; Setup PD mapping a 2MB page at 0x0-0x1FFFFF
  mov edi, PD_BASE
  mov eax, 0x0| PAGE_PRESENT | PAGE_WRITE | PD_2MB
  mov [edi], eax

  ; Load CR3 with PML4 address
  mov eax, PML4_BASE ;(PML4_BASE << 12)
  mov cr3, eax

  popa
  ret
