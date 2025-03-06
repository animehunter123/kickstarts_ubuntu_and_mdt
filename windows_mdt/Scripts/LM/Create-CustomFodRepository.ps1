#This script will create a custom fod repository which is required before running the Inject LXP/FOD script on a fresh MS Official ISO.
#It uses the http://docs.ms >> "Add Language Pack to Windows" webpage.
# Disks we use in our Image are:
# 1. MultiLang_LangPackAll_LIP
# 2. FoD Disk 1
# 3. FoD Disk 2


#Globals (LXP and FODs for 20H2; Mount the FOD ISOs)
$fod_cab_repo = "C:\repository-2XHX" 
$LXPISO1 = '\\\iso\Microsoft\Win10-2XHX\Win10-x32x64-MultiLanguagePack\SW_DVD9_NTRL_Win_10_2004_32_64_ARM64_MultiLang_LangPackAll_LIP_X22-21307.ISO'
# $LXPISO2 = '\\\iso\Microsoft\Win10-20H2\Win10-x32x64-MultiLanguagePack\SW_DVD9_NTRL_Win_10_2004_32_64_ARM64_MultLng_LngPkAll_LIP_11C_LXP_ONLY_X22-47511.ISO'
$FODISO1 = '\\\iso\Microsoft\Win10-2XHX\Win10-x64-FoD\SW_DVD9_NTRL_Win_10_2004_64Bit_MultiLang_FOD_1_X22-21311.ISO'
$FODISO2 = '\\\iso\Microsoft\Win10-2XHX\Win10-x64-FoD\SW_DVD9_NTRL_Win_10_2004_64Bit_MultiLang_FOD_2_X22-21313.ISO'
$LXPVOL1 = Mount-DiskImage -ImagePath $LXPISO1 -PassThru | Get-DiskImage | Get-Volume
$LXPDIR1 = $LXPVOL1.DriveLetter
$FODVOL1 = Mount-DiskImage -ImagePath $FODISO1 -PassThru | Get-DiskImage | Get-Volume
$FODDIR1 = $FODVOL1.DriveLetter
$FODVOL2 = Mount-DiskImage -ImagePath $FODISO2 -PassThru | Get-DiskImage | Get-Volume
$FODDIR2 = $FODVOL2.DriveLetter

#Make sure your C Drive has at least 20GB available
$REMAINING_SPACE = Get-WMIObject Win32_Logicaldisk -filter "deviceid='C:'"  |
Select PSComputername,DeviceID,
@{Name="SizeGB";Expression={$_.Size/1GB -as [int]}},
@{Name="FreeGB";Expression={[math]::Round($_.Freespace/1GB,2)}} | select FreeGB 
if ($REMAINING_SPACE.FreeGB -lt 20 ) { 
    write-host -red "ERROR: Less then 20GB remaining in the C-Drive. Cancelling."
    exit
}

#Dism ADK Module   ///  TODO we should try the DISM MOUNT with /optimize!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
import-module "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\DISM"
$env:Path = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\DISM;$env:Path"

#Copy FoD CAB FILES
write-host -fore green "Welcome. This script creates a custom FoD Cab repository (~9GB) required for injecting RSAT/Languages into the image."
write-host -fore green "It takes about 5 minutes to run, please be patient."
md $fod_cab_repo -ea 0 | out-null
write-host -fore yellow "Copying FoD1 Cabs to $fod_cab_repo..."
copy-item -recurse -force "$FODDIR1`:\*" $fod_cab_repo
write-host -fore yellow "Copying FoD2 Cabs to $fod_cab_repo..."
copy-item -recurse -force "$FODDIR2`:\*" $fod_cab_repo

#Copy LangPack CAB FILES
write-host -fore yellow "Copying LangPack Cabs to $fod_cab_repo..."
copy-item -recurse -force "$LXPDIR1`:\x64\langpacks\*" $fod_cab_repo 

write-host -fore green "Script complete."