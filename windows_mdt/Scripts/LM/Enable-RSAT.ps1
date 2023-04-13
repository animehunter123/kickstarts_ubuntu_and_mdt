#RSAT Workaround:
$currentWU = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" | select -ExpandProperty UseWUServer
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value 0
Restart-Service wuauserv
Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability –Online
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value $currentWU
Restart-Service wuauserv

#Install RSAT
Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability -Online 2>$null
Update-Help -Force 2>$null