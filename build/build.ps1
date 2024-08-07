$target = "..\target"
$source = "..\src\main"

if (!(Test-Path -Path $target)) {
    Write-Host "Creating build target directory: "$target
    [void](New-Item -Type Directory -Force -Path $target)
}

Write-Host "Compile boot0 (NASM)"
& nasm $source\boot\boot0.asm -f bin -o $target\boot0.bin