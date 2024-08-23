; Boolean
%define FALSE            (0)
%define TRUE             (1)

; CPUID flags
%define CPUID_ID         (1 << 21)
%define CPUID_MODE64     (1 << 29)

; Disk
%define SECTOR_LIMIT     127

; Paging
%define PAGE_PRESENT     (1 << 0)
%define PAGE_WRITE       (1 << 1)
%define PAGING_DATA      0x9000

; GDT
%define CODE_SEG         0x0008