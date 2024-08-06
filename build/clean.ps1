$target = "..\target"

Write-Host "Clean: Delete compiler target folder and its contents"
Get-ChildItem -Path $target -Recurse | Remove-Item -force -recurse
Remove-Item $target -Force