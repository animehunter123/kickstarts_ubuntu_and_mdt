#Mount the NAS
pushd 
New-SmbMapping -LocalPath j: -RemotePath \\192.168.0.5\ISO -UserName mdt -Password 'INSERT_YOUR_PASSWORD_HERE' 
j:

#Install the CAB
cd .\Microsoft\Win10-LXP-LanguagePacks\x64\langpacks
Add-WindowsPackage -Online -PackagePath Microsoft-Windows-Client-Language-Pack_x64_ja-jp.cab 

# This section does not work from the OOBE WIN_PE of MDT, so instead we have to use DISM to modify
# the install.wim of the original boot image. We are using MS Docs for this:
# https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/add-language-packs-to-windows
# cd ..
# cd ..
# cd .\LocalExperiencePack\ja-jp
# Add-AppxProvisionedPackage -PackagePath .\LanguageExperiencePack.ja-jp.Neutral.appx   -Online -LicensePath .\License.xml

popd
Remove-SmbMapping -LocalPath j: -Force