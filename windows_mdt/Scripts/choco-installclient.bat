@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

choco feature enable -n allowGlobalConfirmation
choco feature enable -n allowEmptyChecksums
choco source add -n=lm-choco -s=http://lm-choco.YOURDOMAIN.COM:8081/repository/chocolatey-hosted/
choco source disable -n=chocolatey
choco list

REM THIS IS ANOTHER TEST TEMPORARILY
choco install procexp