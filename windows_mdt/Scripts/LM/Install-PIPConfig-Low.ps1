$erroractionpreference=0

write-host -fore green "Installing PIP Dependencies..."
if (!(test-path -Path "C:\ProgramData\pip")) {
  mkdir "C:\ProgramData\pip" -force -ea 0 | out-null
}
Invoke-WebRequest "http://lm-nas.lm.local:8082/pip/pip.ini" -OutFile "C:\programdata\pip\pip.ini" -ea 0 
Start-Process "C:\Python38\Scripts\pip.exe" -ArgumentList "install wget" -NoNewWindow -Wait
