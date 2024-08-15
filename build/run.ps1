Write-Host "Starting emulator (QEMU, x86_64, raw)"
& qemu-system-x86_64 -drive format=raw,file=..\target\bootloader.bin