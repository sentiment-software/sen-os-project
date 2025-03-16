; ===== CPUID: Request with initial value of EAX =====
CPUID_LEAF_BASIC_0 equ 0x0
CPUID_LEAF_BASIC_FEATURE equ 0x1
CPUID_LEAF_BASIC_CACHE equ 0x2
CPUID_LEAF_BASIC_PSN equ 0x3
CPUID_LEAF_CACHE_PARAMS equ 0x4
CPUID_LEAF_MONITOR equ 0x5
CPUID_LEAF_TPM equ 0x6
CPUID_LEAF_EXTF_STRUCT equ 0x7
CPUID_LEAF_EXT_TOPOLOGY equ 0xB
CPUID_LEAF_EXT_TOPOLOGY_V2 equ 0x1F

CPUID_LEAF_EXTF_0 equ 0x80000000
CPUID_LEAF_EXTF_1 equ 0x80000001
CPUID_LEAF_EXTF_2 equ 0x80000002
CPUID_LEAF_EXTF_3 equ 0x80000003
CPUID_LEAF_EXTF_4 equ 0x80000004
CPUID_LEAF_EXTF_5 equ 0x80000005
CPUID_LEAF_EXTF_6 equ 0x80000006
CPUID_LEAF_EXTF_7 equ 0x80000007
CPUID_LEAF_EXTF_8 equ 0x80000008


; ===== CPUID: Bit Flags & Positions =====
; 0x1.ECX
CPUID_BIT_SSE3 equ 0 ; SSE3 Extensions
CPUID_BIT_PCLMULQDQ equ 1 ; Carryless Multiplication
CPUID_BIT_DTES64 equ 2 ; 64-bit DS Area
CPUID_BIT_MONITOR equ 3 ; MONITOR / MWAIT instructions
CPUID_BIT_DSCPL equ 4 ; CPL Qualified Debug Store
CPUID_BIT_VMX equ 5 ; Virtual Machine Extensions
CPUID_BIT_SMX equ 6 ; Safer Mode Extensions
CPUID_BIT_EIST equ 7 ; Enhanced Intel SpeedStep(r) technology
CPUID_BIT_TM2 equ 8 ; Thermal Monitor 2
CPUID_BIT_SSSE3 equ 9 ; SSSE3 Extensions
CPUID_BIT_CNXTID equ 10 ; L1 Context ID
CPUID_BIT_SDBG equ 11 ; IA32_DEBUG_INTERFACE MSR
CPUID_BIT_FMA equ 12 ; FMA extension using YMM state
CPUID_BIT_CMPXCHG16B equ 13 ; CMPXCHG16B instruction
CPUID_BIT_XTPRUC equ 14 ; xTPR Update Control
CPUID_BIT_PDCM equ 15 ; IA32_PERF_CAPABILITIES MSR
CPUID_BIT_16 equ 16 ; Reserved
CPUID_BIT_PCID equ 17 ; Process-context identifiers
CPUID_BIT_DCA equ 18 ; Prefetch data from memory-mapped device
CPUID_BIT_SSE41 equ 19 ; SSE4.1 instructions
CPUID_BIT_SSE42 equ 20 ; SSE4.2 instructions
CPUID_BIT_X2APIC equ 21 ; x2APIC
CPUID_BIT_MOVBE equ 22 ; MOVBE instruction
CPUID_BIT_POPCNT equ 23 ; POPCNT instruction
CPUID_BIT_TSCDL equ 24 ; TSC Deadline
CPUID_BIT_AESNI equ 25 ; AES-NI
CPUID_BIT_XSAVE equ 26 ; XSAVE/XRSTOR/XSETBV/XGETBV/XCR0
CPUID_BIT_OSXSAVE equ 27 ; OS has set CR4.OSXSAVE[bit 18] to enable XSAVE features
CPUID_BIT_AVX equ 28 ; AVX instructions
CPUID_BIT_F16C equ 29 ; 16-bit floating point conversion instructions
CPUID_BIT_RDRAND equ 30 ; RDRAND instruction
CPUID_BIT_31 equ 31 ; Always 0, not used

; 0x1.EDX
CPUID_BIT_FPU equ 0 ; FPU On-Chip
CPUID_BIT_VME equ 1 ; Virtual 8086 Mode
CPUID_BIT_DE equ 2 ; Debugging Extensions
CPUID_BIT_PSE equ 3 ; Page Size Extension
CPUID_BIT_TSC equ 4 ; Time Stamp Counter
CPUID_BIT_MSR equ 5  ; RDMSR/WRMSR instructions
CPUID_BIT_PAE equ 6  ; Physical Address Extension
CPUID_BIT_MCE equ 7 ; Machine Check Exception
CPUID_BIT_CX8 equ 8 ; CMPXCHG8B instruction
CPUID_BIT_APIC equ 9 ; APIC On-Chip
CPUID_BIT_10 equ 10 ; Reserved
CPUID_BIT_SEP equ 11 ; SYSENTER/SYSEXIT instructions
CPUID_BIT_MTRR equ 12 ; Memory Type Range Registers
CPUID_BIT_PGE equ 13 ; PTE Global Bit
CPUID_BIT_MCA equ 14 ; Machine Check Attribute
CPUID_BIT_CMOV equ 15 ; Conditional move instructions (CMOVcc)
CPUID_BIT_PAT equ 16 ; Page Attribute Table
CPUID_BIT_PSA36 equ 17 ; 36-bit Page Size Extension
CPUID_BIT_PSN equ 18 ; Processor Serial Number
CPUID_BIT_CLFSH equ 19 ; CLFLUSH instruction
CPUID_BIT_20 equ 20 ; Reserved
CPUID_BIT_DS equ 21 ; Debug Store
CPUID_BIT_ACPI equ 22 ; Thermal Monitor & Software Controlled Clock Facilities
CPUID_BIT_MMX equ 23 ; Intel MMX Technology
CPUID_BIT_FXSR equ 24 ; FXSAVE/FXRSTOR instructions
CPUID_BIT_SSE equ 25 ; SSE
CPUID_BIT_SSE2 equ 26 ; SSE2
CPUID_BIT_SS equ 27 ; Self Snoop
CPUID_BIT_HTT equ 28 ; Max APIC IDs reserved field is Valid (CPUID.1.EBX[23:16])
CPUID_BIT_TM equ 29 ; Thermal Monitor
CPUID_BIT_30 equ 30 ; Reserved
CPUID_BIT_PBE equ 31 ; Pending Break Enable

; 0x1F.ECX
CPU_DOMAIN_LP equ 1
CPU_DOMAIN_CORE equ 2
CPU_DOMAIN_MODULE equ 3
CPU_DOMAIN_TILE equ 4
CPU_DOMAIN_DIE equ 5
CPU_DOMAIN_DIEGRP equ 6

; 0x80000001.ECX
CPUID_BIT_LAHF64 equ 0
CPUID_BIT_LZCNT equ 5
CPUID_BIT_PREFETCHW equ 8

; 0x80000001.EDX
CPUID_BIT_SYSCALLRET equ 11
CPUID_BIT_ED equ 20
CPUID_BIT_1GB_PAGE equ 26
CPUID_BIT_1GB_RDTSCP equ 26
CPUID_BIT_INTEL64 equ 29

