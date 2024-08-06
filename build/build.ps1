$target = "..\target"
$source = "..\src\main"

if (!(Test-Path -Path $target)) {
    Write-Host "Creating build target directory: "$target
    [void](New-Item -Type Directory -Force -Path $target)
}

Write-Host "Compile bootloader (NASM)"
Write-Host "nasm $source\bootloader\bootloader.asm -f bin -o $target\bootloader.bin"
& nasm $source\bootloader\bootloader.asm -f bin -o $target\bootloader.bin