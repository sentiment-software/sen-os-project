# Memory Map

| Start   | End     | Section             | Size  |
|---------|---------|---------------------|-------|
| 0x0000  | 0x03FF  | IVT                 | 1 kB  |
| 0x0400  | 0x04FF  | BDA                 | 256 b |
| 0x0500  | 0x06FF  | Boot Stack (SP)     | 512 b |
| 0x0700  | 0x16FF  | Boot Stage 1        | 4 kB  |
| 0x1700  | 0x19FFF | (Free)              | -     |
| 0x20000 | 0x23FFF | Initial page tables | 16kB  |
| 0x24000 | 0x450FF | (Free)              | -     |
| 0x45000 | 0x45FFF | IDT                 | 4 kB  |
| 0x46000 | 0x47FFF | Kernel Stack (RSP)  | 8 kB  |
| 0x48000 | 0x7FFFF | (Free)              | -     |
| 0xB8000 | 0xBFFFF | VGA Text Buffer     | 32kB  |   
