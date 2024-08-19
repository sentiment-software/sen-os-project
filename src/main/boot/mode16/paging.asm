[bits 16]

; ===== Messages
msg_init_paging dw 21
db 'Boot 1: INIT PAGING', 13, 10

;------------------------------
; init_paging:
;
; Initializes the paging structure.
; TODO: (1) Currently the simples implementation is used as a sample & testing.
; TODO: (2) Newer CPUs support Level-5 paging, consider supporting it.
;------------------------------
init_paging:
  mov si, msg_init_paging           ; Print info message
  call mode16_print

  mov edi, PAGING_DATA              ; Point EDI to a free space to create the paging structures

  ; TODO: should push whole EDI?
  push di                           ; Save DI as REP STOSD alters it
  mov ecx, 0x1000                   ; Set up REP counter in ECX
  xor eax, eax                      ; Set EAX to 0 (for STOSD)
  cld                               ; Clear direction flag (for STOSD)
  rep stosd                         ; Loop STOSD (EAX -> [EDI]; ECX--)
  pop di                            ; Restore DI

  ; Build the Page Map Level 4. ES:DI points to the PML4 table
  lea eax, [es:di + 0x1000]         ; EAX = Address of the PDPT
  or eax, PAGE_PRESENT | PAGE_WRITE ; Set flags
  mov [es:di], eax                  ; Store the value of EAX as the first PML4E

  ; Build the Page Directory Pointer Table (PDPT).
  lea eax, [es:di + 0x2000]         ; Put the address of the PD in to EAX
  or eax, PAGE_PRESENT | PAGE_WRITE ; Set flags
  mov [es:di + 0x1000], eax         ; Store the value of EAX as the first PDPT-Entry

  ; Build the Page Directory (PD).
  lea eax, [es:di + 0x3000]          ; Put the address of the PT in to EAX.
  or eax, PAGE_PRESENT | PAGE_WRITE  ; Set flags
  mov [es:di + 0x2000], eax          ; Store to value of EAX as the first PD-Entry.

  push di                            ; Save DI
  lea di, [di + 0x3000]              ; Point DI to the PT.
  mov eax, PAGE_PRESENT | PAGE_WRITE ; Move the flags into EAX - and point it to 0x0000.

  ; Build the Page Table (PT).
  .loop_page_table:
    mov [es:di], eax
    add eax, 0x1000
    add di, 8
    cmp eax, 0x200000                 ; End after 2MiB
    jb .loop_page_table

  pop di                              ; Restore DI
  ret