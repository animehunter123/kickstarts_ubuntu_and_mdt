$erroractionpreference=0

$product="NCPA"

write-host -fore green "Removing the $product..."

# METHOD 1
choco uninstall -yf nagios-ncpa

# METHOD 2
#Set-Location 'C:\Program Files\mcafee\Agent\x86' ;
#try { Start-Process -Wait '.\FrmInst.exe' -ArgumentList '/forceuninstall','/silent' -NoNewWindow -ea 0 | out-null } catch {}

# METHOD 3
#write-host -fore green "Removing the remainder of the mcafee products..."
#try { (Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like 'NCPA*' } ).Uninstall() ; } catch {}
