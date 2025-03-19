OUTPUT_FORMAT(binary)                  /* Flat binary for booting */
OUTPUT_ARCH(i386:x86-64)               /* x86-64 target */
ENTRY(kernel_entry)                    /* Start at kernel_entry */

SECTIONS {
    . = 0x100000;                        /* Kernel base address at 0xA000 */
    .text : {
        KEEP(*(.text.kernel_entry))    /* Force kernel_entry first */
        *(.text*)                      /* Other code follows */
    }
    .data : { *(.data) }
    .bss : { *(.bss) }

    /* Discard unneeded sections */
    /DISCARD/ : {
        *(.eh_frame)
        *(.comment)
    }
}