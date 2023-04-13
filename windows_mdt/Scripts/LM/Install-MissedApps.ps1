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

