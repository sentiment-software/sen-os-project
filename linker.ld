OUTPUT_FORMAT(binary)
SECTIONS {
    . = 0x7C00;
    .boot0 :
    {
        boot0.o(.text)
        boot0.o(.data)
        boot0.o(.bss)
    }

    . = 0x1000;
    .boot1 :
    {
        boot1.o(.text)
        boot1.o(.data)
        boot1.o(.bss)
    }

    . = 0x100000;
    .text :
    {
        kernel.o(.text)
    }
    .data :
    {
        kernel.o(.data)
    }
    .bss :
    {
        kernel.o(.bss)
    }

    /DISCARD/ : {
        *(.eh_frame)
        *(.comment)
    }
}