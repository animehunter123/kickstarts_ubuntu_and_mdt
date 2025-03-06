$ErrorActionPreference=0






# 1. Uninstall Old McAfee Versions and Agents
$ErrorActionPreference=0
$ProgressPreference=0

write-host -fore green "Removing the mcafee agent (Change to non-managed mode, then remove)..."
Set-Location 'C:\Program Files\mcafee\Agent\x86' ;
try { Start-Process -Wait '.\FrmInst.exe' -ArgumentList '/remove=agent','/silent' -NoNewWindow -ea 0 | out-null } catch {}
try { Start-Process -Wait '.\FrmInst.exe' -ArgumentList '/forceuninstall','/silent' -NoNewWindow -ea 0 | out-null } catch {}

write-host -fore green "Removing the remainder of the mcafee products..."
try { (Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like 'mcafee*' } ).Uninstall() ; } catch {}

Write-host -fore green "Stopping any remaining processes..."
$processes = @(
    "macmnsvc",
    "macompatsvc",
    "masvc",
    "mctray",
    "mfecanary",
    "mfeesp",
    "mfehcs",
    "mfemactl",
    "mfemms",
    "mfevtps"
)
foreach ($process in $processes) {
    try {
        $runningProcess = Get-Process -Name $process -ErrorAction SilentlyContinue
        if ($runningProcess) {
            Stop-Process -Name $process -Force -ea 0 | out-null
        } 
    } catch {}    
}

write-host -fore green "Script complete. Check the Windows Installed Programs, and all McAfee should be gone."

# write-host -fore green "Removing the mcafee agent (Change to non-managed mode, then remove)..."
# Set-Location 'C:\Program Files\mcafee\Agent\x86' ;
# Start-Process -Wait '.\FrmInst.exe' -ArgumentList '/remove=agent','/silent' -NoNewWindow
# Start-Process -Wait '.\FrmInst.exe' -ArgumentList '/forceuninstall','/silent' -NoNewWindow
# write-host -fore green "Removing the remainder of the mcafee products..."
# (Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like 'mcafee*' } ).Uninstall() ;
# write-host -fore green "Script complete. Check the Windows Installed Programs, and all McAfee should be gone."





# 2. Uninstall Old Trellix Versions and Agents
$ErrorActionPreference=0
$ProgressPreference=0

write-host -fore green "Removing the trellix agent (Change to non-managed mode, then remove)..."
Set-Location 'C:\Program Files\mcafee\Agent\x86' ;
try { Start-Process -Wait '.\FrmInst.exe' -ArgumentList '/remove=agent','/silent' -NoNewWindow -ea 0 | out-null } catch {}
try { Start-Process -Wait '.\FrmInst.exe' -ArgumentList '/forceuninstall','/silent' -NoNewWindow -ea 0 | out-null } catch {}

write-host -fore green "Removing the remainder of the trellix products..."
try { (Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like 'trellix*' } ).Uninstall() ; } catch {}

Write-host -fore green "Stopping any remaining processes..."
$processes = @(
    "macmnsvc",
    "macompatsvc",
    "masvc",
    "mctray",
    "mfecanary",
    "mfeesp",
    "mfehcs",
    "mfemactl",
    "mfemms",
    "mfevtps"
)
foreach ($process in $processes) {
    try {
        $runningProcess = Get-Process -Name $process -ErrorAction SilentlyContinue
        if ($runningProcess) {
            Stop-Process -Name $process -Force -ea 0 | out-null
        } 
    } catch {}    
}

write-host -fore green "Script complete. Check the Windows Installed Programs, and all Trellix should be gone."







# 3. Install Trellix From LOW NAS
$ErrorActionPreference=0
$ProgressPreference=0

# NOTE: I noticed sometimes i have to reboot the windows 10, then run the setup again.
write-host "Installing Trellix (Agent, SP, TP), takes about 10 minutes..." -fore green

# Define the network path
$networkPath = "\\INSERT_SHARED_FOLDER_HERE.lm.local\OrioleNAS-Data\software\Trellix Antivirus\Trellix Endpoint Security for Windows Threat Prevention\Trellix_Endpoint_Security_10.7.0.6390.9_Standalone_Client_Install_ENS"

# Define credentials (Make sure you create this in AD and give it a password)
$username = "lm.local\trellix"
$password = ConvertTo-SecureString "INSERT_YOUR_PASSWORD_HERE" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($username, $password)

# # CIFS METHOD Mount the network folder to a drive letter using the credentials
# $driveLetter = "Z:"
# New-PSDrive -Name $driveLetter.TrimEnd(':') -PSProvider FileSystem -Root $networkPath -Credential $credential -Persist
# Write-Host "Changing directory to $driveLetter, and listing contents..."
# Set-Location -Path $driveLetter
# Get-ChildItem

# HTTP METHOD
md c:\temp
c:
cd c:\temp
$baseUrl = "http://lm-webserver.lm.local/software/Trellix%20Antivirus/Trellix%20Endpoint%20Security%20for%20Windows%20Threat%20Prevention/Trellix_Endpoint_Security_10.7.0.6390.9_Standalone_Client_Install_ENS"
$files = @(
    "ATP.zip",
    "Common.zip",
    "EPDeploy.xml",
    "EpInstallStrings.zip",
    "FW.zip",
    "msxml6.msi",
    "msxml6_x64.msi",
    "setupEP.exe",
    "TP.zip",
    "WC.zip"
)
foreach ($file in $files) {
    if (-not (Test-Path $file)) {
        $url = "$baseUrl/$file"
        Invoke-WebRequest $url -O $file
        # wget.exe $url -O $file
    }
}

write-host "Installing Trellix (Agent, SP, TP)..."
#Start-Process -FilePath $setupPath -ArgumentList $arguments -Wait -NoNewWindow -Credential $credential
# start ".\setupEP.exe" -wait -arg "/qn",'ADDLOCAL="tp"'
# try { Start-Process ".\setupEP.exe" -wait -arg "/qn" } catch {}
# try { Start-Process ".\setupEP.exe" -wait -arg "/qn",'ADDLOCAL="tp"' } catch {}
try { Start-Process ".\setupEP.exe" -wait -arg "/qn",'ADDLOCAL="fw,tp,atp,wc"' } catch {}
# try { Start-Process ".\setupEP.exe" -wait -arg 'ADDLOCAL="fw,tp,atp,wc"' } catch {} # Once again just in case



write-host "Cleaning up C:\temp..."
foreach ($file in $files) {
    if (Test-Path $file) {
        Remove-Item $file -Force
        Write-Host "Removed: $file"
    } else {
        Write-Host "File not found: $file"
    }
}


write-host -fore green 'NOTE: You may need to run the Trellix Agent installer again to finish the setup to point it at the epo server.'
write-host -fore green 'Script complete. Check the Windows Installed Programs, and Trellix should be installed.'

