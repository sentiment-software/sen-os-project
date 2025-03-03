[bits 64]

msg_err_default: db 'Error #Default', 0
msg_err_gpf: db 'Error #GPF', 0

isr_default:
  push rbx
  mov rbx, msg_err_default
  call println
  hlt
  pop rbx
  iretq

isr_gpf:
    push rbx
    mov rbx, msg_err_gpf
    call println
    hlt
    pop rbx
    iretq