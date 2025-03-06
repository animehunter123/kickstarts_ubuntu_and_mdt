# NOTE: The high-side version of this file is fully complete. The low side should only include MS Office in this post install script.
$ErrorActionPreference=0

# Install/Upgrade to Office 2021 with Visio
write-host -fore green "Beginning the installation for Office 2021 LTSC + Visio..."
pushd 
C:
cd \
md temp 
cd temp
md MDT-OfficeVisio2021
cd MDT-OfficeVisio2021
write-host -fore green "Copying files from the NAS..."
New-SmbMapping -LocalPath j: -RemotePath "\\192.168.0.5\iso\Microsoft\Office2021+Visio+KMS\MDT-OfficeVisio2021" -UserName "lm\mdt" -Password 'INSERT_YOUR_PASSWORD_HERE' 
cp -recurse -force J:\* .
write-host -fore green "Installing/Upgrading to Office 2021 with Visio..."
start-process "powershell.exe" -arg ".\setup.install_office_2021.ps1" -wait
cd ..
rm -recurse -force MDT-OfficeVisio2021
popd
Remove-SmbMapping -localpath j: -force


# Workaround to ensure that the AWS Shortcuts are installed into the Windows 10 Default Account Shell
write-host "Copying from EU GPO Shortcuts to Local User's Desktop..."
$destination_file="DESKTOP-SHORTCUTS_USED_BY_GPO.zip"
$destination_dir = "C:\Users\Public\Desktop"
c:
cd \
md temp -ea 0 | out-null
cd temp
rm -Force $destination_file
wget "http://lm-webserver.lm.local/eu/GPO/DESKTOP-SHORTCUTS_USED_BY_GPO.zip" -out $destination_file
Expand-Archive -Path $destination_file -DestinationPath $destination_dir -Force -verbose
rm -force $destination_file -ea 0 | out-null



# TODO: Next version I want to disable the welcome user screen to speed up logins: https://theitbros.com/capture-windows-10-reference-image/
