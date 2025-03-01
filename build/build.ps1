$target = "..\target"
$source = "..\src\main"

if (!(Test-Path -Path $target)) {
    Write-Host "Creating build target directory: "$target
    [void](New-Item -Type Directory -Force -Path $target)
}

Write-Host "Compile bootloader (NASM)"
& nasm $source\boot\boot0.asm -f bin -o $target\boot0.bin
& nasm $source\boot\boot1.asm -f bin -o $target\boot1.bin