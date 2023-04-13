#Install the PSWindows Update Module, and load it
& "C:\ProgramData\chocolatey\choco.exe" install -y -f PSWindowsUpdate-psmodule
cp "C:\ProgramData\chocolatey\lib\PSWindowsUpdate\" "C:\Windows\System32\WindowsPowerShell\v1.0\Modules" -recurse -force
import-module PSWindowsUpdate

# #Download and Install all the Critical and Security Updates
# #OLD WAY:  Download-WindowsUpdate; Install-WindowsUpdate
# Get-WindowsUpdate -Install -AcceptAll -IgnoreReboot 
# #Download-WindowsUpdate -Install -AcceptAll -IgnoreReboot # -IgnoreRebootRequired
# #Install-WindowsUpdate -Install -AcceptAll -IgnoreReboot  # -IgnoreRebootRequired