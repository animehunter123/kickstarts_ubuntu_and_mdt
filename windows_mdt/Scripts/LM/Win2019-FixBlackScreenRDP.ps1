#This script is for fixing the RDP Black Screen Issue (See Docs.ms)

$Win2019TermServer = "HKLM:\SOFTWARE\Microsoft\Terminal Server Client"

New-Item $Win2019TermServer -force -ea 0

New-ItemProperty -LiteralPath $Win2019TermServer -Name 'UseURCP' -Value '0' -PropertyType DWord -force -ea 0

Set-ItemProperty -Path $Win2019TermServer -Name 'UseURCP' -Value '0' -force -ea 0