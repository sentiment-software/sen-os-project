; ===== Boot Information Definitions ====
INFO_CPU_EXTF_LAHF_64 equ (1 << 0) ; LAHF/SAHF available in 64-bit mode.
INFO_CPU_EXTF_LZCNT equ (1 << 1) ; LZCNT available.
INFO_CPU_EXTF_PREFETCHW equ (1 << 2) ; PREFETCHW available.
INFO_CPU_EXTF_SYSCALLRET equ (1 << 3) ; SYSCALL/SYSRET available.
INFO_CPU_EXTF_ED equ (1 << 4) ; Execute Disable Bit available.
INFO_CPU_EXTF_1GB_PAGE equ (1 << 5) ; 1-GByte pages are available.
INFO_CPU_EXTF_RDTSCP equ (1 << 6) ; RDTSCP and IA32_TSC_AUX are available.
INFO_CPU_EXTF_INTEL_64 equ (1 << 7) ; Intel 64 Architecture available.