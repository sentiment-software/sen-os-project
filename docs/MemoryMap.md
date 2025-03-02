# Memory Map

| Start   | End     | Section            | Size   |
|---------|---------|--------------------|--------|
| 0x0000  | 0x03FF  | IVT                | 1 kB   |
| 0x0400  | 0x04FF  | BDA                | 256 b  |
| 0x0500  | 0x06FF  | Boot Stack (SP)    | 512 b  |
| 0x0700  | 0x16FF  | Boot Stage 1       | 4 kB   |
| 0x1700  | 0x446FF | Page tables        | 36 kB  |
| 0x44700 | 0x456FF | IDT                | 4 kB   |
| 0x45700 | 0x476FF | Kernel Stack (RSP) | 2 kB   |
| 0x47700 | 0x7FFFF | Kernel Entry Point | 464 kB |
| 0xB8000 | 0xBFFFF | VGA Text Buffer    | 32kB   |   
