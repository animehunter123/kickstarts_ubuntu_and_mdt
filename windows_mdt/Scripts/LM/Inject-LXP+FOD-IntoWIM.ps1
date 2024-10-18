#####################################################################################
##### Primary MDT Script for Windows 10 >1909+ ISO/WIM from Microsoft VLSC!!  #######
#####################################################################################
$ProgressPreference = 0

# This script [\\lm-mdt\c$\DeploymentShare\Scripts\LM] will RUN FROM THE MDT Server:
# It performs: https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/add-language-packs-to-windows
# 0. Pre-requisite: Import the latest 1909.2 ISO into MDT:\DeploymentShare\OperatingSystems\Windows10\IMAGES\1909CUSTOM 
# 1. DISM Mount the install.wim inside the deploymentshare to C:\mount\windows (from windows-adk-all)
# 2. DISM Inject LXP into the install.wim
# 3. DISM Inject RSAT into the install.wim
# 4. DISM Unmount the install.wim (and apply changes)
# 5. Now the MDT will be ready to kick a image with LXP/RSAT pre-installed. Note: The MDT TS requires Injected Images + WSUS, and this process takes >2 hours to create a reference image.
$LANG_FLAG = "JP"  #Use EN or JP 

# Logging
$LOGFILE = ".\logs\$LANG_FLAG-" + (get-date -format 'yyyyMMdd_hhmm') + ".log"
Start-Transcript -path $LOGFILE -append
write-host -fore Blue  "**************************************************************************************************************"
write-host -fore green "Starting MDT Language/FoD Injection into the ISO WIM file. Logging to $LOGFILE"
write-host -fore Blue  "**************************************************************************************************************"

#Mount Dir
mkdir C:\mount\windows -Force 2>$null

#Globals (LXP and FODs for 20H2; Mount the FOD ISOs)
$LXPISO1 = '\\172.16.0.5\iso\Microsoft\Win10-2XHX\Win10-x32x64-MultiLanguagePack\SW_DVD9_NTRL_Win_10_2004_32_64_ARM64_MultiLang_LangPackAll_LIP_X22-21307.ISO'
$LXPISO2 = '\\172.16.0.5\iso\Microsoft\Win10-2XHX\Win10-x32x64-MultiLanguagePack\SW_DVD9_NTRL_Win_10_2004_32_64_ARM64_MultLng_LngPkAll_LIP_7C_LXP_ONL_X22-74323.ISO'
$FODISO1 = '\\172.16.0.5\iso\Microsoft\Win10-2XHX\Win10-x64-FoD\SW_DVD9_NTRL_Win_10_2004_64Bit_MultiLang_FOD_1_X22-21311.ISO'
$FODISO2 = '\\172.16.0.5\iso\Microsoft\Win10-2XHX\Win10-x64-FoD\SW_DVD9_NTRL_Win_10_2004_64Bit_MultiLang_FOD_2_X22-21313.ISO'
$FODVOL1 = Mount-DiskImage -ImagePath $FODISO1 -PassThru | Get-DiskImage | Get-Volume
$FODDIR1 = $FODVOL1.DriveLetter
$FODVOL2 = Mount-DiskImage -ImagePath $FODISO2 -PassThru | Get-DiskImage | Get-Volume
$FODDIR2 = $FODVOL2.DriveLetter

$fod_cab_repo = "C:\repository-2XHX" # <----- MAKE SURE THIS IS READY BEFORE RUNNING THIS SCRIPT!!! (via running the "Create-CustomFoDRepository.ps1" script)
if (!(test-path $fod_cab_repo )) { 
    write-host -fore red "ERROR: Local FoD Cab Repository doesnt exist, please run Create-CustomFodRepository.ps1 powershell script to create: $fod_cab_repo" 
    exit 
}

#Dism ADK Module   ///  TODO we should try the DISM MOUNT with /optimize!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
import-module "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\DISM"
$env:Path = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\DISM;$env:Path"

#At this point, we want a fresh clean mounted install.wim, and so lets first unmount any existing ones that may exist:
if (  Get-WindowsImage -Mounted | Where-Object { $_.Path -eq "C:\mount\windows" } ) {
    write-host -fore green "Unmounting the previously mounted image and discarding changes..."
    DISM /Unmount-Wim /MountDir:"C:\mount\windows" /discard 
    DISM /cleanup-wim
    DISM /cleanup-mountpoints
}

#Make sure we have enough scratch space
$REMAINING_SPACE = Get-WmiObject Win32_Logicaldisk -filter "deviceid='C:'" | 
    Select PSComputername,DeviceID,
    @{Name="SizeGB";Expression={$_.Size/1GB -as [int]}},
    @{Name="FreeGB";Expression={[math]::Round($_.Freespace/1GB,2)}} | select FreeGB
if ($REMAINING_SPACE.FreeGB -lt 20) {
    write-host -fore red "ERROR: Less than 20GB remaining in the C-Drive. FAILED."
    exit
}

# Language of the ISO we are injecting: EN or JP
write-host -fore green "Attempting to MOUNT the image..."
if ( $LANG_FLAG -eq "EN") {
    #English ISO:
    $TARGETWIMDIR =   'C:\DeploymentShare\Operating Systems\ENT_21H1_ENGLISH_INJECTED\sources'  #Path to "install.wim" file after MDT Import on the MDT server (Must be C Drive)
    Set-Location $TARGETWIMDIR
    DISM /Mount-Image /ImageFile:install.wim /Index:3 /MountDir:"C:\mount\windows"   #For English W10 Ent ISO (1909.2, 2004.1, 20H2.1, etc...)
}
elseif ( $LANG_FLAG -eq "JP") {
    #Japanese ISO: (Only Choose 1 ISO, either JP or EN commented out)
    $TARGETWIMDIR = 'C:\DeploymentShare\Operating Systems\ENT_21H1_JAPANESE_INJECTED\sources'  #Path to "install.wim" file after MDT Import on the MDT server (Must be C Drive)
    Set-Location $TARGETWIMDIR
    DISM /Mount-Image /ImageFile:install.wim /Index:2 /MountDir:"C:\mount\windows" #For Japanese W10 Ent ISO (1909.2, and 2004.1)
}
else {
    write-host -fore red "Incorrect Language Flag: $LANG_FLAG"
    exit
}

# ##########################################
# Reference Webpages:
# https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/add-language-packs-to-windows
# https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/available-language-packs-for-windows
# https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/available-language-packs-for-windows#language-interface-packs-lips
# ##########################################

#LXP SECTION
#TODO Error Handling for Dism needed, for now just watch the logs, and can ignore Error: 87(NameNotRecog), and Error: 3(FileNotFound)
#TODO Error Example: An error occurred trying to open - E:\x64\langpacks\Microsoft-Windows-Client-Language-Pack_x64_ja-jp.cab Error: 0x80070003

function Inject-LXPFromISO {
    param ($LXPISO1, $LXPISO2)      
    #Inject LangPacks, via the FOD to LP mapping table spreadsheet: https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/features-on-demand-language-fod
    write-host -fore blue "Starting... Inject-LXPFromISO for $LXPISO1..."
    #Mount the LANGUAGE ISOs:
    import-module -Force storage -ea 0 | out-null
    $LXPVOL1 = Mount-DiskImage -ImagePath $LXPISO1 -PassThru | Get-DiskImage | Get-Volume
    $LXPDIR1 = $LXPVOL1.DriveLetter
    $LXPACKS = $LXPDIR1.ToString() + ":\x64\langpacks".ToString()    
    $LXPVOL2 = Mount-DiskImage -ImagePath $LXPISO2 -PassThru | Get-DiskImage | Get-Volume
    $LXPDIR2 = $LXPVOL2.DriveLetter
    
    if ($LANG_FLAG -eq "EN") {
        write-host -fore green "`nDism Injecting Microsoft-Windows-Client-Language-Pack_x64_ja-jp.cab..."
        Dism /Image:"C:\mount\windows" /Add-Package /PackagePath="$fod_cab_repo\Microsoft-Windows-Client-Language-Pack_x64_ja-jp.cab"
        $LXPDIRSTR = $LXPDIR2.ToString()+":\LocalExperiencePack\ja-jp\"
        write-host -fore green "`nDism Injecting LanguageExperiencePack.ja-JP.Neutral.appx..."
        DISM /Image:"C:\mount\windows" /Add-ProvisionedAppxPackage /PackagePath="$LXPDIRSTR\LanguageExperiencePack.ja-JP.Neutral.appx" /LicensePath:"$LXPDIRSTR\License.xml"
    }
    else {
        write-host -fore green "`nDism Injecting Microsoft-Windows-Client-Language-Pack_x64_en-us.cab..."
        Dism /Image:"C:\mount\windows" /Add-Package /PackagePath="$fod_cab_repo\Microsoft-Windows-Client-Language-Pack_x64_en-us.cab"
        $LXPDIRSTR = $LXPDIR1.ToString()+":\LocalExperiencePack\en-us\"    
        write-host -fore green "`nDism Injecting LanguageExperiencePack.en-US.Neutral.appx..."
        DISM /Image:"C:\mount\windows" /Add-ProvisionedAppxPackage /PackagePath="$LXPDIRSTR\LanguageExperiencePack.en-US.Neutral.appx" /LicensePath:"$LXPDIRSTR\License.xml"
    }
    
    
    #Extra Input Methods
    $EXTRALANGS = "ar-SA", "zh-CN", "zh-TW", "ko-KR", "ru-RU"
    foreach ($LANG in $EXTRALANGS) {
        $LXPDIRSTR = $LXPDIR1.ToString()+":\LocalExperiencePack\$LANG\"
        write-host -fore green "`nDism Injecting extra language $LANG..."
        DISM /Image:"C:\mount\windows" /Add-ProvisionedAppxPackage /PackagePath="$LXPDIRSTR\LanguageExperiencePack.$LANG.Neutral.appx" /LicensePath:"$LXPDIRSTR\License.xml"
    }
    # write-host -fore blue "Finished... Inject-LXPFromISO for $LXPISO1..."
    Get-DiskImage -ImagePath $LXPISO1 | Dismount-DiskImage 
    Get-DiskImage -ImagePath $LXPISO2 | Dismount-DiskImage 
}

#Inject Master first, then the second ISO.
Inject-LXPFromISO $LXPISO1 $LXPISO2 
# Inject-LXPFromISO $LXPISO2 $FOD1PATH

#Set Language and SKU Defaults (choose english or japanese appropriately)
write-host -fore green "`nDism Injecting Language SKU Defaults..."
if ($LANG_FLAG -eq "EN") {
    Dism /Image:"C:\mount\windows" /Set-AllIntl:en-us  /Set-SysLocale:en-us /Set-UILang:en-us /set-userlocale:en-us
    Dism /Image:"C:\mount\windows" /Set-SKUIntlDefaults:en-us 
}
else {
    Dism /Image:"C:\mount\windows" /Set-AllIntl:ja-jp  /Set-SysLocale:ja-jp /Set-UILang:ja-jp /set-userlocale:ja-jp
    Dism /Image:"C:\mount\windows" /Set-SKUIntlDefaults:ja-jp 
}

#Inject the remaining cab's required for ime to work correctly using the FoD Disk 
#TODO: FIX the... Error: 87: The add-package option is unknown. 
write-host -fore green "`nDism Injecting IME Cabs from $fod_cab_repo..."
if ($LANG_FLAG -eq "EN") {
    $FODDIR1_TRIMMED = $FODDIR1.ToString().Trim()
    $LANGFEATURESDIR = $FODDIR1_TRIMMED+":\*languagefeatures*ja-jp*"
    foreach ($i in ls -Name $LANGFEATURESDIR ) {
        write-host "`nDism Injecting IME Cab: $i..."
        Dism /Image:"C:\mount\windows" /Add-Package /PackagePath="$fod_cab_repo\$i" /Source:"$fod_cab_repo"
    }
    $LANGFEATURESFONTDIR = $FODDIR1_TRIMMED+":\*languagefeatures*fonts*jpan*"
    foreach ($i in ls -Name $LANGFEATURESFONTDIR ) {
        write-host "`nDism Injecting IME Cab: $i..."
        Dism /Image:"C:\mount\windows" /Add-Package /packagepath="$fod_cab_repo\$i" /source:"$fod_cab_repo"
    }  
}
else {
    $FODDIR1_TRIMMED = $FODDIR1.ToString().Trim()
    $LANGFEATURESDIR = $FODDIR1_TRIMMED+":\*languagefeatures*en-us*"
    foreach ($i in ls -Name $LANGFEATURESDIR ) {
        write-host "`nDism Injecting IME Cab: $i..."
        Dism /Image:"C:\mount\windows" /Add-Package /packagepath="$fod_cab_repo\$i" /source:"$fod_cab_repo"
    }
}

#Inject Rsat FODs, requires GPO see: https://docs.microsoft.com/en-us/windows/deployment/update/fod-and-lang-packs
write-host -fore green "`nDism Injecting Capabilities (Rsat, Languages)..."
Dism /Image:"C:\mount\windows" /add-capability `
	/CapabilityName:Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0 `
	/CapabilityName:Rsat.BitLocker.Recovery.Tools~~~~0.0.1.0 `
	/CapabilityName:Rsat.CertificateServices.Tools~~~~0.0.1.0 `
	/CapabilityName:Rsat.DHCP.Tools~~~~0.0.1.0 `
	/CapabilityName:Rsat.Dns.Tools~~~~0.0.1.0 `
	/CapabilityName:Rsat.FailoverCluster.Management.Tools~~~~0.0.1.0 `
	/CapabilityName:Rsat.FileServices.Tools~~~~0.0.1.0 `
	/CapabilityName:Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0 `
	/CapabilityName:Rsat.IPAM.Client.Tools~~~~0.0.1.0 `
	/CapabilityName:Rsat.LLDP.Tools~~~~0.0.1.0 `
	/CapabilityName:Rsat.NetworkController.Tools~~~~0.0.1.0 `
	/CapabilityName:Rsat.NetworkLoadBalancing.Tools~~~~0.0.1.0 `
	/CapabilityName:Rsat.RemoteAccess.Management.Tools~~~~0.0.1.0 `
	/CapabilityName:Rsat.RemoteDesktop.Services.Tools~~~~0.0.1.0 `
	/CapabilityName:Rsat.ServerManager.Tools~~~~0.0.1.0 `
	/CapabilityName:Rsat.Shielded.VM.Tools~~~~0.0.1.0 `
	/CapabilityName:Rsat.StorageReplica.Tools~~~~0.0.1.0 `
	/CapabilityName:Rsat.VolumeActivation.Tools~~~~0.0.1.0 `
	/CapabilityName:Rsat.WSUS.Tools~~~~0.0.1.0 `
	/CapabilityName:Rsat.StorageMigrationService.Management.Tools~~~~0.0.1.0 `
	/CapabilityName:Rsat.SystemInsights.Management.Tools~~~~0.0.1.0 `
	/capabilityname:Language.Basic~~~ar-SA~0.0.1.0 `
	/capabilityname:Language.Basic~~~en-US~0.0.1.0 `
	/capabilityname:Language.Basic~~~ja-JP~0.0.1.0 `
	/capabilityname:Language.Basic~~~ko-KR~0.0.1.0 `
	/capabilityname:Language.Basic~~~ru-RU~0.0.1.0 `
	/capabilityname:Language.Basic~~~zh-CN~0.0.1.0 `
	/capabilityname:Language.Basic~~~zh-TW~0.0.1.0 `
	/capabilityname:Language.Handwriting~~~ar-SA~0.0.1.0 `
	/capabilityname:Language.Handwriting~~~en-US~0.0.1.0 `
	/capabilityname:Language.Handwriting~~~ja-JP~0.0.1.0 `
	/capabilityname:Language.Handwriting~~~ko-KR~0.0.1.0 `
	/capabilityname:Language.Handwriting~~~ru-RU~0.0.1.0 `
	/capabilityname:Language.Handwriting~~~zh-CN~0.0.1.0 `
	/capabilityname:Language.Handwriting~~~zh-TW~0.0.1.0 `
	/capabilityname:Language.OCR~~~ar-SA~0.0.1.0 `
	/capabilityname:Language.OCR~~~en-US~0.0.1.0 `
	/capabilityname:Language.OCR~~~ja-JP~0.0.1.0 `
	/capabilityname:Language.OCR~~~ko-KR~0.0.1.0 `
	/capabilityname:Language.OCR~~~ru-RU~0.0.1.0 `
	/capabilityname:Language.OCR~~~zh-CN~0.0.1.0 `
	/capabilityname:Language.OCR~~~zh-TW~0.0.1.0 `
	/capabilityname:Language.Speech~~~ar-SA~0.0.1.0 `
	/capabilityname:Language.Speech~~~en-US~0.0.1.0 `
	/capabilityname:Language.Speech~~~ja-JP~0.0.1.0 `
	/capabilityname:Language.Speech~~~ko-KR~0.0.1.0 `
	/capabilityname:Language.Speech~~~ru-RU~0.0.1.0 `
	/capabilityname:Language.Speech~~~zh-CN~0.0.1.0 `
	/capabilityname:Language.Speech~~~zh-TW~0.0.1.0 `
	/capabilityname:Language.TextToSpeech~~~ar-SA~0.0.1.0 `
	/capabilityname:Language.TextToSpeech~~~en-US~0.0.1.0 `
	/capabilityname:Language.TextToSpeech~~~ja-JP~0.0.1.0 `
	/capabilityname:Language.TextToSpeech~~~ko-KR~0.0.1.0 `
	/capabilityname:Language.TextToSpeech~~~ru-RU~0.0.1.0 `
	/capabilityname:Language.TextToSpeech~~~zh-CN~0.0.1.0 `
	/capabilityname:Language.TextToSpeech~~~zh-TW~0.0.1.0 `
	/CapabilityName:Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0 `
	/CapabilityName:Rsat.BitLocker.Recovery.Tools~~~~0.0.1.0 `
	/CapabilityName:Rsat.CertificateServices.Tools~~~~0.0.1.0 `
	/CapabilityName:Rsat.DHCP.Tools~~~~0.0.1.0 `
	/CapabilityName:Rsat.Dns.Tools~~~~0.0.1.0 `
	/CapabilityName:Rsat.FailoverCluster.Management.Tools~~~~0.0.1.0 `
	/CapabilityName:Rsat.FileServices.Tools~~~~0.0.1.0 `
	/CapabilityName:Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0 `
	/CapabilityName:Rsat.IPAM.Client.Tools~~~~0.0.1.0 `
	/CapabilityName:Rsat.LLDP.Tools~~~~0.0.1.0 `
	/CapabilityName:Rsat.NetworkController.Tools~~~~0.0.1.0 `
	/CapabilityName:Rsat.NetworkLoadBalancing.Tools~~~~0.0.1.0 `
	/CapabilityName:Rsat.RemoteAccess.Management.Tools~~~~0.0.1.0 `
	/CapabilityName:Rsat.RemoteDesktop.Services.Tools~~~~0.0.1.0 `
	/CapabilityName:Rsat.ServerManager.Tools~~~~0.0.1.0 `
	/CapabilityName:Rsat.Shielded.VM.Tools~~~~0.0.1.0 `
	/CapabilityName:Rsat.StorageReplica.Tools~~~~0.0.1.0 `
	/CapabilityName:Rsat.VolumeActivation.Tools~~~~0.0.1.0 `
	/CapabilityName:Rsat.WSUS.Tools~~~~0.0.1.0 `
	/CapabilityName:Rsat.StorageMigrationService.Management.Tools~~~~0.0.1.0 `
	/CapabilityName:Rsat.SystemInsights.Management.Tools~~~~0.0.1.0 `
	/source:"$fod_cab_repo"

#Injecting WSL Feature: from: https://docs.microsoft.com/en-us/windows/wsl/wsl2-install
dism.exe /Image:"C:\mount\windows"  /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all
#NOT NEEDED because REFERENCE here, because CHOCOLATEY will do this: (Commented Out Until W10-2004) dism.exe /Image:"C:\mount\windows"  /enable-feature /featurename:VirtualMachinePlatform /all 

#Remove Unneeded AppxProvisioned Bloatware packages:
# We got the list of apps via: dism /image:C:\mount\windows /get-provisionedappxpackages > C:\temp\apps.txt
# Then pick the ones we want to remove... via referencing:  https://www.reddit.com/r/sysadmin/comments/40t6p7/cleaning_up_windows_10_enterprise/
# For Roaming Profiles, Microsoft said: https://docs.microsoft.com/en-us/windows-server/storage/folder-redirection/deploy-roaming-user-profiles#step-7-optionally-specify-a-start-layout-for-windows-10-pcs
$apps=@( 	
    "Microsoft.BingWeather"
    # "Microsoft.DesktopAppInstaller"
    "Microsoft.GetHelp"
    "Microsoft.Getstarted"
    # "Microsoft.HEIFImageExtension"
    # "Microsoft.LanguageExperiencePackar-SA"
    # "Microsoft.LanguageExperiencePacken-US"
    # "Microsoft.LanguageExperiencePackja-JP"
    # "Microsoft.LanguageExperiencePackko-KR"
    # "Microsoft.LanguageExperiencePackru-RU"
    # "Microsoft.LanguageExperiencePackzh-CN"
    # "Microsoft.LanguageExperiencePackzh-TW"
    "Microsoft.Messaging"
    "Microsoft.Microsoft3DViewer"
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftSolitaireCollection"
    # "Microsoft.MicrosoftStickyNotes"
    "Microsoft.MixedReality.Portal"
    # "Microsoft.MSPaint"
    "Microsoft.Office.OneNote"
    "Microsoft.OneConnect"
    "Microsoft.People"
    "Microsoft.Print3D"
    # "Microsoft.ScreenSketch"
    "Microsoft.SkypeApp"
    # "Microsoft.StorePurchaseApp"
    # "Microsoft.VP9VideoExtensions"
    "Microsoft.Wallet"
    # "Microsoft.WebMediaExtensions"
    # "Microsoft.WebpImageExtension"
    # "Microsoft.Windows.Photos"
    # "Microsoft.WindowsAlarms"
    # "Microsoft.WindowsCalculator"
    # "Microsoft.WindowsCamera"
    "microsoft.windowscommunicationsapps"
    "Microsoft.WindowsFeedbackHub"
    "Microsoft.WindowsMaps"
    # "Microsoft.WindowsSoundRecorder"
    # "Microsoft.WindowsStore"
    # "Microsoft.Xbox.TCUI"
    "Microsoft.XboxApp"
    "Microsoft.XboxGameOverlay"
    "Microsoft.XboxGamingOverlay"
    "Microsoft.XboxIdentityProvider"
    "Microsoft.XboxSpeechToTextOverlay"
    "Microsoft.YourPhone"
    "Microsoft.ZuneMusic"
    "Microsoft.ZuneVideo"   
    "Microsoft.WindowsCamera"	
)
foreach ($app in $apps) {	
    write-host -fore green "Removing Unneeded AppX: $app..." 
	Get-AppXProvisionedPackage -path "C:\mount\windows" | Where-Object DisplayName -EQ $app | Remove-AppxProvisionedPackage -ea 0
}

# Remove OneDrive Setup 
$mountdir="C:\mount\windows"
$onedriveexe="$($mountdir)\Windows\SysWOW64\onedrivesetup.exe"
takeown /F $onedriveexe /A
icacls $onedriveexe /T /C /grant "everyone:F"
Remove-Item $onedriveexe -Force -ea 0
reg load HKEY_LOCAL_MACHINE\WIM $mountdir\Users\Default\ntuser.dat
reg delete "HKEY_LOCAL_MACHINE\WIM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v OneDriveSetup /f
reg add "HKEY_LOCAL_MACHINE\WIM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /f
reg add "HKEY_LOCAL_MACHINE\WIM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v DisableWindowsConsumerFeatures /t REG_DWORD /d 1 /f
reg unload HKEY_LOCAL_MACHINE\WIM

#Unmount/Cleanup is: https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/mount-and-modify-a-windows-image-using-dism
write-host -fore green "`nDism Cleaning Image and Committing Changes..."
Dism /Image:"C:\mount\windows" /cleanup-image /StartComponentCleanup /ResetBase
Dism /Unmount-Wim /MountDir:"C:\mount\windows" /commit
Get-DiskImage -Volume $FODVOL1 | Dismount-DiskImage 
Get-DiskImage -Volume $FODVOL2 | Dismount-DiskImage 

#FINAL STEP REQUIRED (DO NOT DELETE THIS SECTION!!!)
#1. Open up the MDT GUI >> C:\DeploymentShare > Task Sequences > Right click the "BLD-W10J-REF1909" > Properties 
#2. OS Info > Edit Unnattend.xml > (This should open WSIM, if it errors, Reboot the MDT server and open the install.wim once with WSIM then close it, and try this button in MDT again)
#3. In the Unattend.xml in WSIM Gui > Answer File, set these:
#   * Unattend\Components\7oobeSystem\amd64_MS-Windows-International-Core_neutral:
#   ** Input Locale: 0411:00000409   (to set to Japanese Input Locale)
#   ** SystemLocale/UILanguage/UserLocale: ja-JP  (or en-US if english is default user account you want)
#Further information:    https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/automate-oobe
#TODO: We need a gpo-W10-1909-ImproveSigninTime from:
#https://docs.microsoft.com/en-us/windows/client-management/mandatory-user-profile#apply-policies-to-improve-sign-in-time
#TODO: We need to Remove Apps from wim file to optimize ROAMING PROFILES, the list is: (step 7 of the below page)
#https://docs.microsoft.com/en-us/windows-server/storage/folder-redirection/deploy-roaming-user-profiles

Write-host "Script Complete. Do not forget to edit unattend.xml if you need JP Local 0411 in the MDT Task."
Stop-Transcript