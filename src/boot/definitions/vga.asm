; ===== VGA =====

; ===== Text Mode Buffer =====
VGA_BUFFER      equ 0xB8000 ; Base address of the buffer
VGA_BUFFER_END  equ 0xBFFFF ; Limit address of the buffer
VGA_PAGE_SIZE   equ 0xFA0   ; Page size (4000 bytes)
VGA_PAGE_COUNT  equ 8       ; Number of pages in the 32kB buffer
VGA_LINE_LENGTH equ 80      ; Character length of one line (160 bytes)

; ===== Page Buffers =====
VGA_PAGE_1_BASE equ VGA_BUFFER
VGA_PAGE_1_END  equ VGA_PAGE_1_BASE + VGA_PAGE_SIZE - 1

; ===== Colors =====
VGA_COLOR_BLACK        equ 0x0
VGA_COLOR_BLUE         equ 0x1
VGA_COLOR_GREEN        equ 0x2
VGA_COLOR_CYAN         equ 0x3
VGA_COLOR_RED          equ 0x4
VGA_COLOR_PURPLE       equ 0x5
VGA_COLOR_BROWN        equ 0x6
VGA_COLOR_GRAY         equ 0x7
VGA_COLOR_DARK_GRAY    equ 0x8
VGA_COLOR_LIGHT_BLUE   equ 0x9
VGA_COLOR_LIGHT_GREEN  equ 0xA
VGA_COLOR_LIGHT_CYAN   equ 0xB
VGA_COLOR_LIGHT_RED    equ 0xC
VGA_COLOR_LIGHT_PURPLE equ 0xD
VGA_COLOR_YELLOW       equ 0xE
VGA_COLOR_WHITE        equ 0xF
; ===== Font Color & Background Combinations =====
VGA_BLACK_ON_WHITE     equ VGA_COLOR_BLACK | (VGA_COLOR_WHITE << 4)
VGA_BLACK_ON_GRAY      equ VGA_COLOR_BLACK | (VGA_COLOR_GRAY << 4)
VGA_BLACK_ON_DARK_GRAY equ VGA_COLOR_BLACK | (VGA_COLOR_DARK_GRAY << 4)
VGA_WHITE_ON_BLACK     equ VGA_COLOR_WHITE | (VGA_COLOR_BLACK << 4)
VGA_GRAY_ON_DARK_GRAY  equ VGA_COLOR_GRAY | (VGA_COLOR_DARK_GRAY << 4)

