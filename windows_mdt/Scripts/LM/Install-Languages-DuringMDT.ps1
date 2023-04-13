#This script installs the FoD Cab Capabilities during MDT. (Not currently used in the task sequence, can be used in a GPO Later if needed)

#Variables
$ErrorActionPreference = 'silentlycontinue'
$languages = "ja-jp", "ar-sa", "zh-CN", "zh-tw", "ko-kr", "ru-ru"
$fod_dir = "\\lm-nas.lm.local\ISO\Microsoft\Win10-2XHX\Win10-x64-FoD\SW_DVD9_NTRL_Win_10_2004_64Bit_MultiLang_FOD_MERGED"

#Mount the FoD Directory to allow this powershell session to gain access to it.
New-SmbMapping -LocalPath i: -RemotePath "\\lm-nas.lm.local\ISO" -UserName INSERT_YOUR_USERNAME_HERE -Password INSERT_YOUR_PASSWORD_HERE -ea 0 | out-null

#Loop through languages, and install each capability
foreach ($lang in $languages) {
    $capability_list = "Language.Basic~~~$LANG~0.0.1.0",  
    "Language.Handwriting~~~$LANG~0.0.1.0",
    "Language.OCR~~~$LANG~0.0.1.0", 
    "Language.Speech~~~$LANG~0.0.1.0", 
    "Language.TextToSpeech~~~$LANG~0.0.1.0"
    foreach ($capability in $capability_list) {
        write-host -fore green "Adding capability for language [$lang] : [$capability]..."
        write-host -fore green "Executing... Add-WindowsCapability -Name $capability -online -source $fod_dir -LimitAccess"
        Add-WindowsCapability -Name $capability -online -source $fod_dir -LimitAccess 
    }
}

#The last Japanese Package with a odd name:
Add-WindowsCapability -Name Fonts-Jpan -online -source $fod_dir -LimitAccess 
# Add-WindowsCapability -Name Fonts-Hans -online -source $fod_dir -LimitAccess 

#Cleanup
Remove-SmbMapping -LocalPath i: -Force -ea 0 | out-null


































# #TODO: This is separate from the LOCALE GPO for: Set-WinHomeLocation New-WinUserLanguageList Set-WinSystemLocale Set-Culture Set-WinUserLanguageList Set-WinUILanguageOverride

# #Install CAB LIP Packs via DISM:
# $LXPDIRSTR = '\\lm-nas.lm.local\ISO\Microsoft\Win10-20H2.1\Win10-x32x64-MultiLanguagePack\SW_DVD9_NTRL_Win_10_2004_32_64_ARM64_MultiLang_LangPackAll_LIP_X22-21307\LocalExperiencePack'
# $LIPDIRSTR = '\\lm-nas.lm.local\ISO\Microsoft\Win10-20H2.1\Win10-x32x64-MultiLanguagePack\SW_DVD9_NTRL_Win_10_2004_32_64_ARM64_MultiLang_LangPackAll_LIP_X22-21307\x64\langpacks'
# #$LANGLIST = 'en-us'
# $LANGLIST = 'ja-jp'
# Add-AppxPackage -Path "$LXPDIRSTR\$LANGLIST\LanguageExperiencePack.$LANGLIST.Neutral.appx"
# DISM /online /add-package /packagepath="$LIPDIRSTR\Microsoft-Windows-Client-Language-Pack_x64_$LANGLIST.cab"

# #Install LXP Packs via Add Appx Provisioned Packages
# $LXPDIRSTR = '\\lm-nas.lm.local\ISO\Microsoft\Win10-20H2.1\Win10-x32x64-MultiLanguagePack\SW_DVD9_NTRL_Win_10_2004_32_64_ARM64_MultiLang_LangPackAll_LIP_X22-21307\LocalExperiencePack'
# # $LANGLIST = "ja-jp", "ar-sa", "zh-cn", "en-us"
# foreach ($LANG in $LANGLIST) {
#     DISM /online  /Add-ProvisionedAppxPackage /PackagePath="$LXPDIRSTR\$LANG\LanguageExperiencePack.$LANG.Neutral.appx" /LicensePath:"$LXPDIRSTR\$LANG\License.xml"
#     #Non Injected images require the below commands manually (left intentionally commented because we dont want the GPO to run this)
#     Dism /online /Add-Package /PackagePath="$LXPDIRSTR\x64\langpacks\Microsoft-Windows-Client-Language-Pack_x64_$LANG.cab"
#     Dism /online /Add-Capability /capabilityname:Language.Basic~~~$LANG~0.0.1.0 /capabilityname:Language.Handwriting~~~$LANG~0.0.1.0 /capabilityname:Language.OCR~~~$LANG~0.0.1.0 /capabilityname:Language.Speech~~~$LANG~0.0.1.0 /capabilityname:Language.TextToSpeech~~~$LANG~0.0.1.0 /source:C:\repository
# }
# #Finally you can verify the ProvisionedAppxPackage via:  dism /online /get-capabilities |findstr /i en-us

# #Add All Language Packs to the User Language List
# # $LANGLIST = "ja-jp", "ar-sa", "zh-cn", "en-us"
# foreach ($LANG in $LANGLIST ) {
#     $A = Get-WinUserLanguageList
#     $A.Add($LANG)
#     Set-WinUserLanguageList $A -force
# }

# # Finally, set this user to English:
# # set-winuserlanguagelist en-us -force
