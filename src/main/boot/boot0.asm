[bits 16]                                     ; Use 16-bit instruction set for real mode
[org 0x7c00]                                  ; Set origin address to the boot sector address

boot_start:
  jmp 0x0:mode16_main                         ; Reload CS to 0 to fix boot segment discrepancy

mode16_main:
  xor ax, ax                                  ; Set segment registers to 0
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov ss, ax
  mov sp, boot_start                          ; Set down-growing stack pointer
  cld                                         ; Clear direction flag

  mov [disk], dl                              ; Store disk number of bootable disk
  mov ax, (boot1_start - boot0_start) / 512   ; Start sector
  mov cx, (kernel_end - boot1_start) / 512    ; Number of sectors
  mov bx, boot1_start                         ; Buffer offset
  xor dx, dx                                  ; Buffer segment
  call mode16_read_disk                       ; Read upper boot stages from disk

  mov si, msg_boot0_ok
  call mode16_print

  jmp boot1_main                               ; Jump to boot1

mode16_read_disk:
  .verify_sector_count:
    cmp cx, 127
    jbe .read_disk
    pusha
    mov cx, 127
    call mode16_read_disk
    popa
    add eax, 127
    add dx, 127 * 512 / 16
    sub cx, 127
    jmp .verify_sector_count

  .read_disk:
    mov [dap.lowerLBA], ax
    mov [dap.sectorCount], cx
    mov [dap.bufferSegment], dx
    mov [dap.bufferOffset], bx
    mov dl, [disk]
    mov si, dap
    mov ah, 0x42
    int 0x13
    jc .disk_error
    ret

  .disk_error:
    mov si, msg_disk_error
    call mode16_print
    jmp halt

mode16_print:
  push ax
  push cx
  push si
  mov cx, word [si]
  add si, 2
  .string_loop:
    lodsb
    mov ah, 0eh
    int 10h
  loop .string_loop, cx
  pop si
  pop cx
  pop ax
  ret

halt:
  hlt
  jmp halt

; Disk Address Packet
dap:
  .packetSize:    db 0x10 ; Packet size (16 bytes)
  .dapNull:       db 0    ; Always 0
  .sectorCount:   dw 0x7F ; Number of sectors to load (max = 127 on some BIOS)
  .bufferOffset:  dw 0x0  ; Offset of target buffer (16-bits)
  .bufferSegment: dw 0x0  ; Segment of target buffer (16-bits)
  .lowerLBA:      dd 0x0  ; Lower 32 bits of 48-bit starting LBA
  .higherLBA:     dd 0x0  ; Upper 32 bits of 48-bit starting LBA

disk db 0x80

msg_disk_error dw 20
db 'Boot 0: DISK ERROR', 13, 10
msg_boot0_ok dw 12
db 'Boot 0: OK', 13, 10

times 510 - ($ - $$) db 0   ; Pad to 510 bytes
dw 0xaa55                   ; Boot signature at 511:512 bytes