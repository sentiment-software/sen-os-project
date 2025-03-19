[bits 64]

; Loads sectors from the primary disk into memory.
; Inputs:
;   RDI -> Target buffer
;   RBX = Start sector (cyl 0)
;   BSI = Sector count
; Does not preserve any registers as currently we call it right before the jump to the kernel.
load64:
  .loop_read:
    ; ATA PIO read (simplified, assumes LBA28)
    mov dx, 0x1F6           ; Drive/Head port
    mov al, 0xE0            ; Master drive, LBA mode
    out dx, al

    mov dx, 0x1F2           ; Sector count
    mov al, 1               ; Read 1 sector at a time
    out dx, al

    mov dx, 0x1F3           ; LBA low
    mov al, bl              ; Start sector
    out dx, al

    mov dx, 0x1F4           ; LBA mid
    xor al, al
    out dx, al

    mov dx, 0x1F5           ; LBA high
    out dx, al

    mov dx, 0x1F7           ; Command port
    mov al, 0x20            ; Read sectors with retry
    out dx, al

    ; Wait for DRQ
    mov dx, 0x1F7
  .wait:
    in al, dx
    test al, 0x08           ; DRQ bit
    jz .wait
    test al, 0x80           ; BSY bit
    jnz .wait

    ; Read sector to RDI
    mov dx, 0x1F0           ; Data port
    mov rcx, 256            ; 256 words
    rep insw                ; Read words into [RDI], increment RDI

    inc rbx
    dec rsi
    jnz .loop_read

    ret