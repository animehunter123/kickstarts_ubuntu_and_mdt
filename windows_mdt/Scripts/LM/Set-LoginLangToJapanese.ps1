$ErrorActionPreference = 'SilentlyContinue'

write-host -fore green "Setting Locale and Culture via Powershell cmdlets..."
Set-Culture ja-jp
Set-WinSystemLocale ja-jp -verbose
Set-WinUILanguageOverride ja-jp -verbose
Set-WinUserLanguageList ja-jp -Force -verbose

#Registry Workaround to set default language
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Nls\Language" -Name "InstallLanguage" -Value 0411

#Registry for WelcomeScreen
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\MUI\Settings" -Name "PreferredUILanguages" -Value "ja-JP"

write-host -fore green "Script Complete."
