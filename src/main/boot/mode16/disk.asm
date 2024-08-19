[bits 16]

%define CODE_DISK_OK       0
%define CODE_DISK_ERROR    1
%define CODE_METHOD_ERROR  2
%define SECTOR_LIMIT     127

;------------------------------
; mode16_read_disk:
;
; Reads sectors from a disk using using BIOS INT 0x13/AH=0x42.
; It builds Disk Address Packets (DAPs) based on the specified input.
; If sector count is greater than 127, this method will process the sectors in multiple loops.
; This is due to compatibility reasons.
;
; Input:
;   Push the following stack of values before call (top is last):
;     - [word] Buffer segment (Pushed last)
;     - [word] Buffer offset
;     - [word] Number of sectors
;     - [word] Start sector
;     - [word] Disk number on the low byte (Pushed first)
;
; Working registers:
;   EAX, BX, CX, DX, SI - saved and restored from stack.
;
; Output:
;   Result code is pushed to stack:
;     0 = Success
;     1 = Disk error
;------------------------------
mode16_read_disk:
  pop word [ret_ptr]                        ; Pop the return pointer and save it
  pop word [dap.bufferSegment]              ; Pop the DAP values
  pop word [dap.bufferOffset]
  pop word [dap.sectorCount]
  pop dword [dap.lowerLBA]
  pop word [disk_number]                    ; Pop the disk number
  pusha                                     ; Save GP registers (call-context)

  .readCycleCount:                          ; Calculate the # of read cycles:
    mov ax, [dap.sectorCount]               ;   ceil(sectorCount / SECTOR_LIMIT)
    xor dx, dx
    mov bx, SECTOR_LIMIT
    div bx                                  ; DX:AX / BX => DX=remainder, AX=quotient
  .read_loop:
    cmp ax, 1                               ; If AX >= 1,
    jae .read_sector_limit                  ;   then we read with the sector limit,
    cmp dx, 0                               ;   else if DX = 0
    je .disk_ok                             ;     then reading is done and OK,
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
    jc .disk_error                          ; If CF is set, there was an error
  .loopAx:
    cmp ax, 0                               ; If AX = 0,
    je .loopDx                              ;   then compare DX
    dec ax                                  ; Else AX--
    jmp .read_loop                          ; Loop
  .loopDx:
    cmp dx, 0                               ; If DX = 0,
    je .disk_ok                             ;   then reading is done and OK
    jmp .read_loop                          ; Else loop
  .disk_ok:
    popa                                    ; Restore GP registers (call context)
    push CODE_DISK_OK                       ; Push the OK return code - must be after popa
    jmp .return                             ; Jump to return
  .disk_error:
    popa                                    ; Restore GP registers (call context)
    push CODE_DISK_ERROR                    ; Push the error return code - must be after popa
  .return:
    push word [ret_ptr]                     ; Push the return pointer value
    mov word [ret_ptr], 0                   ; Clear the variable
    ret                                     ; Return

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
disk_number    dw 0x0080
ret_ptr        dw 0x0