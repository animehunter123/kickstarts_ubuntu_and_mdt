#This script is only for our testing "TrustedRootInstaller" purposes to Disable the McAfee or Windows firewall:

#1. Install nsudo
choco install -y -f nsudo

#2. Run Commands to disable the Windows Defender while elevated to TrustedRootInstaller
& "C:\Program Files\nsudo\NSudo_8.0_All_Components\NSudo Launcher\x64\NSudoLC.exe" '-U:T' '-P:E' powershell.exe '"Set-MpPreference -DisableIntrusionPreventionSystem $true -DisableIOAVProtection $true -DisableRealtimeMonitoring $true -DisableScriptScanning $true -EnableControlledFolderAccess Disabled -EnableNetworkProtection AuditMode -Force -MAPSReporting Disabled -SubmitSamplesConsent NeverSend"'
Get-MpPreference | findstr /i moni #To verify if DisableRealtimeMonitoring is now actually $true

& "C:\Program Files\nsudo\NSudo_8.0_All_Components\NSudo Launcher\x64\NSudoLC.exe" '-U:T' '-P:E' reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /f /v  DisableAntiSpyware /t REG_DWORD /d 00000000
& "C:\Program Files\nsudo\NSudo_8.0_All_Components\NSudo Launcher\x64\NSudoLC.exe" '-U:T' '-P:E' powershell.exe 'Stop-Service WinDefend ; Set-Service WinDefend -StartupType Disabled ; Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -Value 1 ;  Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows Defender" -Name "DisableRoutinelyTakingAction" -Value 1'

 










# OLD CODE WAS:
# #This script is only for our testing "TrustedRootInstaller" purposes to Disable the McAfee or Windows firewall:
# #1. Install nsudo
# choco install -y -f nsudo
# #2. Run Commands to disable the Windows Defender while elevated to TrustedRootInstaller
# & cmd /c NSudoLC.exe '-U:T' '-P:E' powershell.exe '"Set-MpPreference -DisableIntrusionPreventionSystem $true -DisableIOAVProtection $true -DisableRealtimeMonitoring $true -DisableScriptScanning $true -EnableControlledFolderAccess Disabled -EnableNetworkProtection AuditMode -Force -MAPSReporting Disabled -SubmitSamplesConsent NeverSend"'
# Get-MpPreference | findstr /i moni #To verify if DisableRealtimeMonitoring is now actually $true

# & cmd /c NSudoLC.exe '-U:T' '-P:E' reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /f /v  DisableAntiSpyware /t REG_DWORD /d 00000000
# & cmd /c NSudoLC.exe '-U:T' '-P:E' powershell.exe 'Stop-Service WinDefend ; Set-Service WinDefend -StartupType Disabled ; Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -Value 1 ;  Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows Defender" -Name "DisableRoutinelyTakingAction" -Value 1'
