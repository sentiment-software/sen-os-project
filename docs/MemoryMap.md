# Memory Map

| Start   | End     | Section                                                        | Size   |
|---------|---------|----------------------------------------------------------------|--------|
| 0x0000  | 0x03FF  | IVT                                                            | 1 kB   |
| 0x0400  | 0x04FF  | BDA                                                            | 256 b  |
| 0x0800  | 0x0FFF  | Boot Stack (SP)                                                | 2 kB   |
| 0x1000  | 0x1FFF  | Boot Stage 1                                                   | 4 kB   |
| 0x2000  | 0x2FFF  | Global Structures (64-bit):<br>TSS, GDT, GDTD, IDTP, Boot Info | 4 kB   |
| 0x3000  | 0x3FFF  | IDT (64-bit)                                                   | 4 kB   |
| 0x4000  | 0x9FFF  | Paging Structure Allocation                                    | 24 kB  |
| 0x10000 | 0x7DFFF | Kernel                                                         | 440 kB |
| 0x7E000 | 0x7FFFF | Kernel Stack (RSP)                                             | 8 kB   |
| 0x80000 | 0xFFFFF | **Reserved**                                                   | 128 kB |
