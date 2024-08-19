boot0_start:
  times 90 db 0
  %include "src/main/boot/boot0.asm"
boot0_end:

boot1_start:
  %include "src/main/boot/boot1.asm"
  align 512, db 0
boot1_end:

kernel_start:
  %include "src/main/boot/kernel.asm"
  align 512, db 0
kernel_end: