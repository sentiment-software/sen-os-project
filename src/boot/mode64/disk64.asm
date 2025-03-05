[bits 64]
load64:
    ; ATA PIO read (simplified, assumes LBA28)
    mov dx, 0x1F6           ; Drive/Head port
    mov al, 0xE0            ; Master drive, LBA mode
    out dx, al

    mov dx, 0x1F2           ; Sector count
    mov al, 32              ; 32 sectors
    out dx, al

    mov dx, 0x1F3           ; LBA low
    mov al, 17              ; Start sector
    out dx, al
    mov dx, 0x1F4           ; LBA mid
    xor al, al
    out dx, al
    mov dx, 0x1F5           ; LBA high
    out dx, al

    mov dx, 0x1F7           ; Command port
    mov al, 0x20            ; Read sectors
    out dx, al

    ; Wait for DRQ
    mov dx, 0x1F7
.wait:
    in al, dx
    test al, 0x08           ; DRQ bit
    jz .wait

    ; Read 32 sectors (16kB) to 0x100000
    mov rdi, KERNEL_BASE    ; 0x100000
    mov rcx, 32 * 256       ; 32 sectors × 256 words
    mov dx, 0x1F0           ; Data port
    rep insw                ; Read words into [RDI]

    ret