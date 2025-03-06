#This script is for joining the lm.local domain
$ErrorActionPreference = 'SilentlyContinue'
Enable-WSManCredSSP -Role Client -DelegateComputer "*" -Force
Enable-WSManCredSSP -Role Server -Force

netsh advfirewall reset
# netsh firewall reset

$user="LM\mdt"
$domain="lm.local"
$password= ConvertTo-SecureString -String "INSERT_YOUR_PASSWORD_HERE" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential $user, $password
# $thisComputer = $env:COMPUTERNAME
Add-Computer -domainname $domain -credential $cred -force

$error.Clear()
exit 0