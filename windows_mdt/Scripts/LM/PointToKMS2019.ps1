#If the source OS is Windows Server 2019, then point it to the KMS server (this needs to be "GPO"'d):


$oscaption = Get-ComputerInfo | select WindowsProductName, WindowsVersion, OsHardwareAbstractionLayer


if ($oscaption -eq "Windows Server 2019 Standard") {
    #I need to test this, and check if it affects the registry correctly of 
    #HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform
    slmgr.vbs /skms lm-kms2019.YOURDOMAIN.COM:1688    
}