[bits 64]

isr_default:
  push rbx
  hlt
  pop rbx
  iretq

isr_gpf:
    push rbx
    hlt
    pop rbx
    iretq