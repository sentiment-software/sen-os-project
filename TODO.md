# List of things to do
#### Build Environment
- Create a platform independent Makefile (or just migrate it to unix)
- Build a dedicated toolchain (aka. compile a compiler)
- Document debug process

#### In Boot Stage 0
- Handle disk-read result code based on BIOS (either AL, AH or both can contain the result code)

#### In Boot Stage 1
- Identity map more than 2MB for kernel code execution.
- Write a 64-bit loader which loads the kernel in a higher memory address.<br>
  This may be done by ATA PIO for HDDs during boot.
- Write at least the necessary ISRs and map them in the IDT.<br>
  This probably better to be done in ASM as C could mess up the stack.
- Collect some information about the system and pass it to the kernel:
  - Run a proper CPUID check
  - Detect CPU type, topology, speed, logical processors, integrated GPU, ports, etc.
  - Detect memory, keyboard

#### Kernel
  - Simple scheduler
  - Simple console
