
Import-Module "C:\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"

New-PSDrive -Name "DS001" -PSProvider MDTProvider -Root "C:\DeploymentShare"

# Import-MDTApplication -path "DS001:\Applications" -enable "True" -Name "4Sysops MyApplication 1" -ShortName "MyApplication" -Version "1" -Publisher "4Sysops" -Language "EN" -CommandLine "MyCommandLine" -WorkingDirectory ".\Applications\4Sysops MyApplication 1" -ApplicationSourcePath "C:\MyApplication" -DestinationFolder "4Sysops MyApplication 1" –Verbose

#Get our mdt PSDrive:
get-psdrive

#Get our apps:
cd DS001:Applications
cd .\MISC
cd .\LEGACY-NONJ
foreach ($i in Get-ChildItem -path *) { echo $i ; }
