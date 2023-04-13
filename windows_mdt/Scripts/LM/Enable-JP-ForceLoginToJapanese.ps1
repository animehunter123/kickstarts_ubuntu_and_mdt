#Computer Startup Script: gpoWin10-1909-PC-InstallLXPviaAppXPackage.ps1
$LOCALREPO = 'C:\repository'
$LANGLIST = 'en-us', 'ja-jp'

# foreach ($LANG in $LANGLIST) {
#     DISM /online  /Add-ProvisionedAppxPackage /PackagePath="$LOCALREPO\LocalExperiencePack\$LANG\LanguageExperiencePack.$LANG.Neutral.appx" /LicensePath:"$LOCALREPO\LocalExperiencePack\$LANG\License.xml" /norestart
#     #Non Injected images require the below commands manually (left intentionally commented because we dont want the GPO to run this)
#     Dism /online /Add-Package /PackagePath="$LOCALREPO\x64\langpacks\Microsoft-Windows-Client-Language-Pack_x64_$LANG.cab" /norestart
#     Dism /online /Add-Capability /capabilityname:Language.Basic~~~$LANG~0.0.1.0 /capabilityname:Language.Handwriting~~~$LANG~0.0.1.0 /capabilityname:Language.OCR~~~$LANG~0.0.1.0 /capabilityname:Language.Speech~~~$LANG~0.0.1.0 /capabilityname:Language.TextToSpeech~~~$LANG~0.0.1.0 /source:C:\repository  /norestart
# }
#Optionally you can check the ProvisionedAppxPackage installation results via this:  dism /online /get-capabilities |findstr /i en-us

Set-WinSystemLocale ja-jp
Set-Culture ja-jp
Set-WinUILanguageOverride ja-jp
Set-WinUserLanguageList ja-jp -Force

#Registry Workaround to set default language
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Nls\Language" -Name "InstallLanguage" -Value 0411

dism /online /Set-AllIntl:ja-jp  /Set-SysLocale:ja-jp /Set-UILang:ja-jp /set-userlocale:ja-jp
Dism /Image:"C:\mount\windows" /Set-SKUIntlDefaults:ja-jp 