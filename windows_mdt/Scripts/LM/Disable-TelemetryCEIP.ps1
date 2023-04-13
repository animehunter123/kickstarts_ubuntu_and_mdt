# Disable telemetry
write-Host "***Disabling telemetry...***"
reg add "HKLM\Software\Policies\Microsoft\Windows\DataCollection" /f /t REG_DWORD /v AllowTelemetry /d 0
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /f /v "AITEnable" /t REG_DWORD /d 0
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /f /v "DisableUAR" /t REG_DWORD /d 1

write-Host "***Disabling CEIP scheduled tasks...***"
reg add "HKLM\SOFTWARE\Policies\Microsoft\SQMClient\Windows" /f /v "CEIPEnable" /t REG_DWORD /d 0
schtasks /Change /TN "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /Disable 
schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /Disable
schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask" /Disable
schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /Disable
