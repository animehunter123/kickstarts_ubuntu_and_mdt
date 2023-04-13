$ProgressPreference = 0
$nuggetFileName = "chocolatey.0.10.15.nupkg.zip"
Invoke-WebRequest 'http://lm-nexus.lm.local/repository/lm-chocolatey/chocolatey/0.10.15' -outfile "$nuggetFileName"
Expand-Archive -Path "$nuggetFileName"  -Force  #-DestinationPath "$tempDir"
    
$chocInstallPS1 = ".\chocolatey.0.10.15.nupkg\tools\chocolateyInstall.ps1"
& $chocInstallPS1

choco feature enable -n allowGlobalConfirmation
choco feature enable -n allowEmptyChecksums
choco source add -n=lm-nexus -s=http://lm-nexus.lm.local/repository/lm-chocolatey/
choco source disable -n=chocolatey
choco list

