[bits 16]

%define PAGE_PRESENT (1 << 0)
%define PAGE_WRITE   (1 << 1)
%define CODE_SEG      0x0008
%define PAGING_DATA   0x9000

boot1_main:
  mov si, msg_boot1_start
  call mode16_print

  call check_mode64_support
  call enable_a20
  call init_paging
  call remap_pic
  call init_mode64

; ===== Includes
%include "src/main/boot/mode16/a20.asm"

init_paging:
  mov si, msg_init_paging
  call mode16_print
  mov edi, PAGING_DATA              ; Point edi to a free space to create the paging structures.

  push di                           ; Save DI as REP STOSD alters it.
  mov ecx, 0x1000
  xor eax, eax
  cld
  rep stosd
  pop di                            ; Get DI back.

  ; Build the Page Map Level 4. ES:DI points to the Page Map Level 4 table.
  lea eax, [es:di + 0x1000]         ; EAX = Address of the Page Directory Pointer Table.
  or eax, PAGE_PRESENT | PAGE_WRITE ; Set flags
  mov [es:di], eax                  ; Store the value of EAX as the first PML4E.

  ; Build the Page Directory Pointer Table.
  lea eax, [es:di + 0x2000]         ; Put the address of the Page Directory in to EAX.
  or eax, PAGE_PRESENT | PAGE_WRITE ; Set flags
  mov [es:di + 0x1000], eax         ; Store the value of EAX as the first PDPTE.

  ; Build the Page Directory.
  lea eax, [es:di + 0x3000]          ; Put the address of the Page Table in to EAX.
  or eax, PAGE_PRESENT | PAGE_WRITE  ; Set flags
  mov [es:di + 0x2000], eax          ; Store to value of EAX as the first PDE.

  push di                            ; Save DI
  lea di, [di + 0x3000]              ; Point DI to the page table.
  mov eax, PAGE_PRESENT | PAGE_WRITE ; Move the flags into EAX - and point it to 0x0000.

  ; Build the Page Table.
  .loop_page_table:
    mov [es:di], eax
    add eax, 0x1000
    add di, 8
    cmp eax, 0x200000                 ; End after 2MiB
    jb .loop_page_table

  pop di                              ; Restore DI
  ret

; Remaps the Programmable Interrupt Controller
; This is needed because in long mode IRQ 0-15 conflicts with the CPU exceptions.
; Leaves all IRQs disabled until a proper IDT is set later in the kernel)
remap_pic:
  push ax

  mov al, 0xFF       ; Disable IRQs
  out PIC1_DATA, al
  out PIC2_DATA, al
  nop
  nop

  mov al, ICW1_INIT | ICW1_ICW4 ; ICW1: Send initialization command (= 0x11) to both PICs
  out PIC1_COMMAND, al
  out PIC2_COMMAND, al
  mov al, 0x20       ; ICW2: Set vector offset of 1st PIC to 0x20 (i.e. IRQ0 => INT 32)
  out PIC1_DATA, al
  mov al, 0x28       ; ICW2: Set vector offset of 2nd PIC to 0x28 (i.e. IRQ8 => INT 40)
  out PIC2_DATA, al
  mov al, 4          ; ICW3: tell 1st PIC that there is a 2nd PIC at IRQ2 (= 00000100)
  out PIC1_DATA, al
  mov al, 2          ; ICW3: tell 2nd PIC its "cascade" identity (= 00000010)
  out PIC2_DATA, al
  mov al, ICW4_8086  ; ICW4: Set mode to 8086/88 mode
  out PIC1_DATA, al
  out PIC2_DATA, al

  mov al, 0xFF       ; OCW1: mask all interrupts
  out PIC1_DATA, al
  out PIC2_DATA, al

  pop ax
  ret

; Checks whether long mode is supported.
; If long mode is not supported, we stop the execution and halt the CPU.
; TODO: to support mode32, instead of halting, we can return the result and let main code manage.
check_mode64_support:
  mov eax, 0x80000000            ; Test whether cpuid is available.
  cpuid
  cmp eax, 0x80000001
  jb .mode64_not_supported

  mov eax, 0x80000001            ; Call CPUID with EAX = 0x80000001
  cpuid
  test edx, (1 << 29)            ; It sets bit 29 in the EDX if long mode is supported.
  jz .mode64_not_supported       ; If it's not set, long mode is not supported.

  mov si, msg_mode64_supported   ; Print long mode is supported message
  call mode16_print
  ret

 .mode64_not_supported:
    mov si, msg_mode64_unsupported
    call mode16_print
    jmp halt                      ; If long mode is not supported, we halt the CPU

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

  lgdt[gdt_desc]            ; Load the GDT into GDTR

  jmp CODE_SEG:kernel_main  ; Set CS with 64-bit segment and jump to the good stuff.

; Global Descriptor Table
; Read/Write, Non-Conforming, Expand-Down
gdt:
gdt_null:
  dq 0x0000000000000000  ; Null segment
gdt_code:
  dw 0xffff              ; Limit bits 0-15 (ignored in mode 64)
  dw 0x0000              ; Base bits 0-15 (ignored in mode 64)
  db 0x00                ; Base bits 16-23 (ignored in mode 64)
  db 10011010b           ; Access byte
  db 10100000b           ; Flags and limit bits 16-19
  db 0x00                ; Base bits 24-31 (ignored in mode 64)
gdt_data:
  dw 0xffff              ; Limit bits 0-15 (in expand-down mode, limit is the lower bound)
  dw 0x0000              ; Base bits 0-15
  db 0x00                ; Base bits 16-23
  db 10010010b           ; Access byte
  db 11000000b           ; Flags and limit bits 16-19
  db 0x00                ; Base bits 24-31
gdt_end:

gdt_desc:
  dw gdt_end - gdt - 1
  dd gdt

; Messages
msg_boot1_start dw 15
db 'Boot 1: START', 13, 10
msg_mode64_supported dw 26
db 'Boot 1: MODE64 SUPPORTED', 13, 10
msg_mode64_unsupported dw 28
db 'Boot 1: MODE64 UNSUPPORTED', 13, 10
msg_init_paging dw 21
db 'Boot 1: INIT PAGING', 13, 10

; Constants
PIC1_COMMAND    equ 0x20 ; Command port of 1st PIC
PIC1_DATA       equ 0x21 ; Data port of 1st PIC
PIC2_COMMAND    equ 0xA0 ; Command port of 2nd PIC
PIC2_DATA       equ 0xA1 ; Data port of 2nd PIC
PIC_EOI         equ 0x20 ; EOI (End of interrupt) command (= 0x20)

ICW1_ICW4       equ 0x01 ; Initialization Command Word 4 is needed
ICW1_SINGLE     equ 0x02 ; Single mode (0: Cascade mode)
ICW1_INTERVAL4  equ 0x04 ; Call address interval 4 (0: 8)
ICW1_LEVEL      equ 0x08 ; Level triggered mode (0: Edge mode)
ICW1_INIT       equ 0x10 ; Initialization - required!

ICW4_8086       equ 0x01 ; 8086/88 mode (0: MCS-80/85 mode)
ICW4_AUTO_EOI   equ 0x02 ; Auto End Of Interrupt (0: Normal EOI)
ICW4_BUF_SLAVE  equ 0x08 ; Buffered mode/slave
ICW4_BUF_MASTER equ 0x0C ; Buffered mode/master
ICW4_SFNM       equ 0x10 ; Special Fully Nested Mode