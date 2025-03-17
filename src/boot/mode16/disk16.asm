%include "src/definitions/disk.asm"

[bits 16]

;------------------------------
; load16:
;
; Loads sectors from a disk into memory using BIOS INT 0x13/AH=0x42.
; It builds Disk Address Packets (DAPs) based on the specified input.
; If sector count is greater than 127, this method will process the sectors in multiple loops.
; This is due to compatibility reasons.
;
; Input:
;   Push the following values to the stack before call in this order:
;     - [word] Disk number on the low byte (Pushed first)
;     - [word] Start sector (upper 16 bits)
;     - [word] Start sector (lower 16 bits)
;     - [word] Number of sectors to read into buffer
;     - [word] Buffer offset
;     - [word] Buffer segment (<- Pushed last / Stack top)
;
; Working registers:
;   This routine does not change the registers.
;
; Output:
;   Result code is in AL:
;      00h    Success
;      01h    Invalid function in AH or invalid parameter
;      02h    Address mark not found
;      03h    Disk write-protected
;      04h    Sector not found/read error
;      05h    Reset failed (hard disk)
;      05h    Data did not verify correctly (TI Professional PC)
;      06h    Disk changed (floppy)
;      07h    Drive parameter activity failed (hard disk)
;      08h    DMA overrun
;      09h    Data boundary error (attempted DMA across 64K boundary or >80h sectors)
;      0Ah    Bad sector detected (hard disk)
;      0Bh    Bad track detected (hard disk)
;      0Ch    Unsupported track or invalid media
;      0Dh    Invalid number of sectors on format (PS/2 hard disk)
;      0Eh    Control data address mark detected (hard disk)
;      0Fh    DMA arbitration level out of range (hard disk)
;      10h    Uncorrectable CRC or ECC error on read
;      11h    Data ECC corrected (hard disk)
;      20h    Controller failure
;      31h    No media in drive (IBM/MS INT 13 extensions)
;      32h    Incorrect drive type stored in CMOS (Compaq)
;      40h    Seek failed
;      80h    Timeout (not ready)
;      AAh    Drive not ready (hard disk)
;      B0h    Volume not locked in drive (INT 13 extensions)
;      B1h    Volume locked in drive (INT 13 extensions)
;      B2h    Volume not removable (INT 13 extensions)
;      B3h    Volume in use (INT 13 extensions)
;      B4h    Lock count exceeded (INT 13 extensions)
;      B5h    Valid eject request failed (INT 13 extensions)
;      B6h    Volume present but read protected (INT 13 extensions)
;      BBh    Undefined error (hard disk)
;      CCh    Write fault (hard disk)
;      E0h    Status register error (hard disk)
;      FFh    Sense operation failed (hard disk)
; TODO: Some BIOSes return the result code in AH, some in AL, some in both.
;------------------------------
load16:
  pop word [ret_ptr]                        ; Pop the return pointer and save it
  pop word [dap.bufferSegment]              ; Pop the DAP values
  pop word [dap.bufferOffset]
  pop word [dap.sectorCount]
  pop word [dap.lowerLBA]
  pop word [dap.lowerLBA + 2]
  pop word [disk_number]                    ; Pop the disk number
  push bx                                   ; Save GP registers (call-context)
  push cx
  push dx
  push si

  .readCycleCount:                          ; Calculate the # of read cycles:
    mov ax, [dap.sectorCount]               ;   ceil(sectorCount / SECTOR_LIMIT)
    xor dx, dx
    mov bx, SECTOR_LIMIT
    div bx                                  ; DX:AX / BX => DX=remainder, AX=quotient
  .read_loop:
    cmp ax, 1                               ; If AX >= 1,
    jae .read_sector_limit                  ;   then we read with the sector limit,
    cmp dx, 0                               ;   else if DX = 0
    je .return                              ;     then reading is done and OK,
    mov word [dap.sectorCount], dx          ; otherwise read the remaining sectors.
    xor dx, dx                              ; Clear the remainder to compare later
    jmp .read_disk
  .read_sector_limit:
    mov word [dap.sectorCount], SECTOR_LIMIT
  .read_disk:
    pusha                                   ; Save GP registers (read-loop context)
    mov dx, [disk_number]                   ; Move disk number to DL
    and dx, 0x00FF                          ; Sanitize DX (DH=0, DL=disk number)
    mov si, dap                             ; Point SI to the DAP
    mov ah, 0x42                            ; Load interrupt function number into AH
    int 0x13                                ; Call interrupt
    popa                                    ; Restore GP registers (read-loop context)
    jc .return                              ; If CF is set, there was an error, error code is in AX
  .loopAx:
    cmp ax, 0                               ; If AX = 0,
    je .loopDx                              ;   then compare DX
    dec ax                                  ; Else AX--
    jmp .read_loop                          ; Loop
  .loopDx:
    cmp dx, 0                               ; If DX = 0,
    je .return                              ;   then reading is done and OK
    jmp .read_loop                          ; Else loop
  .return:
    and ax, 0x00FF                          ; Result code in AL, sanitize AH
    pop si                                  ; Restore GP registers (call context)
    pop dx
    pop cx
    pop bx
    push word [ret_ptr]                     ; Push the return pointer value
    mov word [ret_ptr], 0                   ; Clear the variable
    ret                                     ; Return with result code in AH

;------------------------------
; Disk Address Packet
;------------------------------
dap:
  .packetSize:    db 0x10 ; Packet size (16 bytes)
  .dapNull:       db 0    ; Always 0
  .sectorCount:   dw 0x7F ; Number of sectors to load (max = 127 on some BIOS)
  .bufferOffset:  dw 0x0  ; Offset of target buffer (16-bits)
  .bufferSegment: dw 0x0  ; Segment of target buffer (16-bits)
  .lowerLBA:      dd 0x0  ; Lower 32 bits of 48-bit starting LBA
  .higherLBA:     dd 0x0  ; Upper 32 bits of 48-bit starting LBA

;------------------------------
; Variables
;------------------------------
disk_number    dw 0x0080  ; Disk number (Default: 0x80 = 1st floppy disk)
ret_ptr        dw 0x0     ; Return pointer of the caller