# The Low side needs TightVNC Removed
$ErrorActionPreference=0

Write-host "Disabling TightVNC Server Silently..."
start -wait "C:\Program Files\TightVNC\tvnserver.exe" -arg "-remove -silent"

Write-Host "Script Complete."