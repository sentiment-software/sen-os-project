[bits 16]

%define PAGE_PRESENT (1 << 0)
%define PAGE_WRITE   (1 << 1)
%define CODE_SEG      0x0008
%define PAGING_DATA   0x9000

boot1_main:
  mov si, msg_boot1_start
  call mode16_print

  call check_mode64_support
  test eax, eax
  jz .mode64_not_supported

  mov si, msg_mode64_supported
  call mode16_print

  call mode16_enable_a20
  jmp halt
  call init_paging
  call remap_pic
  call init_mode64

  .mode64_not_supported:
    mov si, msg_mode64_unsupported
    call mode16_print
    jmp halt

; Enable the A20 line using BIOS, keyboard controller or IO92 port.
mode16_enable_a20:
  call mode16_check_a20
  test ax,ax
  jnz .return

  mov si, msg_a20_enable_with_bios
  call mode16_print
  call mode16_enable_a20_bios
  call mode16_check_a20
  cmp ax, ax
  jnz .return

  mov si, msg_a20_enable_with_keyboard
  call mode16_print
  call mode16_enable_a20_keyboard
  call mode16_check_a20
  cmp ax, ax
  jnz .return

  mov si, msg_a20_enable_with_io92
  call mode16_print
  call mode16_enable_a20_io92
  call mode16_check_a20
  cmp ax, ax
  jnz .return

  jmp halt               ; We couldn't enable A20, halt the CPU

  .return:
    ret

; Checks whether A20 line is enabled.
; Sets AX=0 if A20 is disabled, AX<>0 if it is enabled.
mode16_check_a20:
  pushf
  push ds
  push es
  push di
  push si
  cli                         ; Disable interrupts

  xor ax, ax                  ; ax = 0
  mov es, ax                  ; es = 0
  not ax                      ; ax = 0xFFFF
  mov ds, ax                  ; ds = 0xFFFF
  mov di, 0x0500              ; 0x0500 and 0x0510 are guaranteed to be free
  mov si, 0x0510

  mov dl, byte [es:di]        ; Save original values on these addresses
  push dx
  mov dl, byte [ds:si]
  push dx

  mov byte [es:di], 0x00      ; [es:di] is 0x0000:0x0500
  mov byte [ds:si], 0xFF      ; [ds:si] is 0xFFFF:0x0510
  cmp byte [es:di], 0xFF      ; If the A20 line is disabled, [es:di] will contain 0xFF
  je .a20_disabled            ; A20 disabled
  jmp .a20_enabled            ; A20 enabled
  .a20_enabled:
    mov si, msg_a20_enabled
    call mode16_print
    mov ax, 1
    jmp .restore_values
  .a20_disabled:
    mov si, msg_a20_disabled
    call mode16_print
    mov ax, 0
    jmp .restore_values
  .restore_values:
    pop dx
    mov byte [ds:si], dl
    pop dx
    mov byte [es:di], dl
    pop si
    pop di
    pop es
    pop ds
    popf
    sti
    ret

; Enables A20 line using BIOS interrupt.
; Set AX=0 on failure, AX<>0 on success.
mode16_enable_a20_bios:
  mov ax,2403h          ; Query A20 gate Support (later PS/2s systems)
  int 15h
  jb .failure           ; INT 15h is not supported
  cmp ah, 0
  jnz .failure          ; INT 15h is not supported
  mov ax, 2402h         ; Get A20 gate Status
  int 15h
  jb .failure           ; Couldn't get status
  cmp ah, 0
  jnz .failure          ; Couldn't get status
  cmp al, 1
  jz .success           ; A20 is already activated
  mov ax, 2401h         ; Enable A20 gate
  int 15h
  jb .failure           ; Couldn't enable the A20 gate
  cmp ah, 0
  jnz .failure          ; Couldn't enable the A20 gate
 .success:
    mov ax, 1
    ret
 .failure:
    mov ax, 0
    ret

; Enables A20 line using the keyboard controller
mode16_enable_a20_keyboard:
  cli                    ; Disable interrupts
  call a20wait
  mov al, 0xad           ; Disable keyboard.
  out 0x64, al
  call a20wait
  mov al, 0xd0           ; Read from input.
  out 0x64, al
  call a20wait2
  in al,0x60
  push eax
  call a20wait
  mov al, 0xd1           ; Write to output.
  out 0x64, al
  call a20wait
  pop eax
  or al, 2
  out 0x60, al
  call a20wait
  mov al, 0xae           ; Enable keyboard.
  out 0x64, al
  call a20wait
  sti                    ; Enables interrupts.
  ret

a20wait:
  in      al, 0x64
  test    al, 2
  jnz     a20wait
  ret

a20wait2: ; TODO: check if needed
  in      al, 0x64
  test    al, 1
  jz      a20wait2
  ret

; Enables A20 line using port 92
mode16_enable_a20_io92:
  in al, 0x92  ; Read from port 0x92
  test al, 2   ; Check if bit al[1] is set.
  jnz .return  ; If bit al[1] is already set, return.
  or al, 2     ; Set al[1].
  and al, 0xFE ; Make sure bit 0 is 0 (it causes a fast reset).
  out 0x92, al ; Write to port 0x92
 .return:
   ret

init_paging:
  mov edi, PAGING_DATA ; Point edi to a free space to create the paging structures.

  ; Zero out the 16KiB buffer. Since we are doing a rep stosd, count should be bytes/4.
  push di         ; Save DI as REP STOSD alters it.
  mov ecx, 0x1000
  xor eax, eax
  cld
  rep stosd
  pop di          ; Get DI back.

  ; Build the Page Map Level 4. ES:DI points to the Page Map Level 4 table.
  lea eax, [es:di + 0x1000]         ; EAX = Address of the Page Directory Pointer Table.
  or eax, PAGE_PRESENT | PAGE_WRITE ; OR EAX with the flags (present flag, writable flag).
  mov [es:di], eax                  ; Store the value of EAX as the first PML4E.

  ; Build the Page Directory Pointer Table.
  lea eax, [es:di + 0x2000]         ; Put the address of the Page Directory in to EAX.
  or eax, PAGE_PRESENT | PAGE_WRITE ; OR EAX with the flags (present flag, writable flag).
  mov [es:di + 0x1000], eax         ; Store the value of EAX as the first PDPTE.

  ; Build the Page Directory.
  lea eax, [es:di + 0x3000]          ; Put the address of the Page Table in to EAX.
  or eax, PAGE_PRESENT | PAGE_WRITE  ; OR EAX with the flags (present flag, writable flag).
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

; Checks whether long mode is supported
check_mode64_support:
  mov eax, 0x80000000 ; Test if extended processor info in available.
  cpuid
  cmp eax, 0x80000001
  jb .not_supported

  mov eax, 0x80000001 ; After calling CPUID with EAX = 0x80000001,
  cpuid
  test edx, (1 << 29) ; (bit 29) turned on in the EDX (extended feature flags).

  jz .not_supported   ; If it's not set, there is no long mode.
  ret

 .not_supported:
    xor eax, eax
    ret

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
msg_a20_enabled dw 21
db 'Boot 1: A20 ENABLED', 13, 10
msg_a20_disabled dw 22
db 'Boot 1: A20 DISABLED', 13, 10
msg_a20_enable_with_bios dw 30
db 'Boot 1: A20 ENABLE WITH BIOS', 13, 10
msg_a20_enable_with_keyboard dw 45
db 'Boot 1: A20 ENABLE WITH KEYBOARD CONTROLLER', 13, 10
msg_a20_enable_with_io92 dw 30
db 'Boot 1: A20 ENABLE WITH IO92', 13, 10

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