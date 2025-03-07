OUTPUT_FORMAT(binary)       /* Flat binary for booting */
OUTPUT_ARCH(i386:x86-64)    /* x86-64 target */
ENTRY(kmain)                /* Start at kmain */

SECTIONS {
    . = 0xA000;                    /* Kernel base address at 0xA0000 */
    .text : {
        KEEP(*(.text.kmain))   /* Force kernel_entry first */
        *(.text*)              /* Other code follows */
    }
    .data : { *(.data) }
    .bss : { *(.bss) }

    /* Discard unneeded sections */
    /DISCARD/ : {
        *(.eh_frame)
        *(.comment)
    }
}