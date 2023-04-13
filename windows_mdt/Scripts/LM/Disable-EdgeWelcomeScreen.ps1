$ErrorActionPreference=0
$regParent = "HKLM:\SOFTWARE\Policies\Microsoft"
$regFolder = "Edge"
$regKey = "HideFirstRunExperience" # need to set to 32Bit DWORD 0x00000001

if((Test-Path -LiteralPath "$regParent\$regFolder") -ne $true) {  
    New-Item "$regParent\$regFolder" -force -ea SilentlyContinue 
    New-ItemProperty -LiteralPath "$regParent\$regFolder" -Name $regKey -Value "1" -PropertyType DWORD -Force -ea SilentlyContinue;
};

