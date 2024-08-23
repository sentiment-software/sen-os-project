[bits 16]

init_mode64:
  mov edi, PAGING_DATA      ; Move paging data to EDI
  mov eax, 10100000b        ; Set PAE and PGE bits in CR4
  mov cr4, eax
  mov edx, edi              ; Set CR3 to the PML4
  mov cr3, edx
  mov ecx, 0xc0000080       ; Read from EFER MSR
  rdmsr
  or eax, 0x00000100        ; Set the Long Mode Enable bit
  wrmsr
  mov ebx, cr0
  or ebx, 0x80000001
  mov cr0, ebx              ; Long mode, paging and protected mode enabled

  lgdt[gdt64_desc]          ; Load the GDT into GDTR
  ret