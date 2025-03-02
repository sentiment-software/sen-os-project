%include "src/boot/definitions/page.asm"

[bits 32]

; Identity maps the first 128MiB in 4kB pages
init_pages:
  push ebp
  mov ebp, esp
  push ebx

  ; Clear paging structure area in 4-byte chunks
  xor eax, eax
  mov ecx, (PAGE_ALLOC_END + 1) / 4
  mov edi, PAGE_ALLOC_BASE
  rep stosd

  ; Setup PML4[0] -> PDP_BASE
  mov eax, PDP_BASE | PAGE_PRESENT | PAGE_WRITE
  mov [PML4_BASE], eax
;  mov dword [PML4_BASE + 4], 0    ; Upper 32 bits

  ; Setup PDP[0] -> PD_BASE
  mov eax, PD_BASE | PAGE_PRESENT | PAGE_WRITE
  mov [PDP_BASE], eax
;  mov dword [PDP_BASE + 4], 0

  ; Fill PD: 512 entries, each pointing to a PT
  mov edi, PD_BASE
  mov eax, PT_BASE | PAGE_PRESENT | PAGE_WRITE
  mov ecx, PT_COUNT         ; 512 PTs for 1GB
  .fill_pd:
    mov [edi], eax
;    mov dword [edi + 4], 0
    add edi, 8              ; Next entry
    add eax, PAGE_SIZE      ; Next PT address
    loop .fill_pd

    ; Fill PTs: 512 PTs, each with 512 entries (4KB pages)
    mov edi, PT_BASE
    mov eax, PAGE_PRESENT | PAGE_WRITE ; Start mapping from 0x0
    mov ebx, PT_COUNT         ; Outer loop counter (64 PTs)
  .fill_pts_outer:
    mov ecx, 512            ; Inner loop: 512 entries per PT
  .fill_pts_inner:
    mov [edi], eax
;    mov dword [edi + 4], 0
    add edi, 8
    add eax, PAGE_SIZE      ; Next 4KB page
    loop .fill_pts_inner
    dec ebx
    jnz .fill_pts_outer

    pop ebx
    mov esp, ebp
    pop ebp
    ret
