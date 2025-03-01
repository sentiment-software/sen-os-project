[bits 32]

; Setup for mapping 64MB memory with 2MB pages
paging_setup_64MB:
    ; Clear 12kB for PML4, PDP, PD
    mov edi, PML4_BASE      ; 0x3000
    mov cr3, edi
    xor eax, eax
    mov ecx, 0x300          ; 12kB / 4 = 3072 dwords
    rep stosd

    ; PML4[0] -> PDP
    mov edi, PML4_BASE      ; 0x3000
    mov dword [edi], PDP_BASE | 0x3  ; 0x4003 (Present + Writable)
    mov dword [edi + 4], 0x0

    ; PDP[0] -> PD
    mov edi, PDP_BASE       ; 0x4000
    mov dword [edi], PD_BASE | 0x3   ; 0x5003
    mov dword [edi + 4], 0x0

    ; PD[0-31] -> 64MB (32 × 2MB pages)
    mov edi, PD_BASE        ; 0x5000
    mov eax, 0x83           ; 0x000000 | Present + Writable + 2MB Page
    mov ecx, 32             ; 32 entries = 64MB
  .fill_pd:
    mov [edi], eax
    mov dword [edi + 4], 0x0
    add eax, 0x200000       ; Next 2MB page
    add edi, 8
    loop .fill_pd
    ret

; Setup for mapping 8GB memory with 2MB pages
paging_setup_8GB:
  ; Clear 36KB of memory for PML4 (4KB), PDP (4KB), and 8 PDs (8 × 4KB = 32KB)
  mov edi, PML4_BASE
  mov cr3, edi           ; Load CR3 with PML4 address
  xor eax, eax
  mov ecx, 0x900         ; 36KB / 4 bytes per stosd = 9,216 dwords
  rep stosd              ; Zero out PML4, PDP, and PDs

  ; Setup PML4[0] to point to PDP
  mov edi, PML4_BASE
  mov dword [edi], (PDP_BASE | PAGE_PRESENT | PAGE_WRITE)
  mov dword [edi + 4], 0x0 ; High 32 bits (0 for < 4GB)

  ; Setup PDP[0-7] to point to 8 PD tables
  mov edi, PDP_BASE
  mov eax, (PD_BASE | PAGE_PRESENT | PAGE_WRITE) ; First PD
  mov ecx, 8 ; 8 PDP entries
  .fill_pdp:
    mov [edi], eax                   ; Low 32 bits
    mov dword [edi + 4], 0x0         ; High 32 bits
    add eax, PD_SIZE                 ; Next PD table (4KB apart)
    add edi, 8                       ; Next PDP entry
    loop .fill_pdp

    ; Setup 8 PD tables, each with 512 entries (2MB pages)
    mov edi, PD_BASE
    mov eax, PAGE_PRESENT | PAGE_WRITE | PAGE_2MB ; Start at 0x000000, Present + Writable + Page Size (2MB)
    mov ecx, 4096                                 ; 8 PDs × 512 entries = 4096 2MB pages (8GB)
  .fill_pd:
    mov [edi], eax                   ; Low 32 bits
    mov dword [edi + 4], 0x0         ; High 32 bits (0 for < 4GB)
    add eax, 0x200000                ; Next 2MB page
    add edi, 8                       ; Next PD entry
    loop .fill_pd
    ret