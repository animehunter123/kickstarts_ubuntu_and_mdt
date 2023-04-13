# This script is used during when you F12 with MDT, and will install the apps passed in as a argument to this script.

# Check the Args
$choco_config_file = $Args[0]
if (!(test-path $choco_config_file)) {
    write-error "File not found: $choco_config_file"
    exit
}

# Open and read line by line into array
foreach ($line in (Get-Content "$choco_config_file") ) {
    # If line does not start with # or ' continue... and choco install it.
    if ( !( ($line.Length -eq 0) -or ($line -cmatch ('^#')) ) ) {
        write-host (get-date) " --- Installing: $line..."
        start-process "C:\ProgramData\chocolatey\choco.exe" -argumentlist "install -yf $line" -wait
        write-host (get-date) " --- Finished installing: $line"
    }
}
