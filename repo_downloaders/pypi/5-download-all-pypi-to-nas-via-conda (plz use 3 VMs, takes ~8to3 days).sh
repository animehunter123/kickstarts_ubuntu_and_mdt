#!/bin/bash

# PYTHONVERSION="3.9.18" # For use with Conda
PYTHONVERSION="3.14.2" # For use with Conda

# Directory where pip will store downloaded packages
TARGET="/mnt/OrioleNAS-Data/repos/pypi-DOWNLOAD_IN_PROGRESS-RENAME-TO-$PYTHONVERSION" # make sure you mounted it on your host

# FINAL SOURCE FILE TO READ PACKAGENAMES FROM
PYPILIST="result_02_parsed.ini"
# PYPILIST="result_02_parsed.ini.part_00"
# PYPILIST="result_02_parsed.ini.part_01"
# PYPILIST="result_02_parsed.ini.part_02"

echo "Information About this Script:

Will download to NAS: $TARGET

* This script will read in the list of packages from [result_02_parsed.ini] and download each one using pip.
* THIS TOOK ABOUT 8 DAYS TO RUN ON ROCKY9 (if 1 ESX, if you split to 3 VMs, it was 3 days)!!
* Please remember to run this in each VM tmux'd shell via: nohup ./5-download-all-pypi-packages.sh & ... And then just tail -f nohup.out to see how it goes

* To use 3 VMs:
1. make 3 rockys (1 on each ESXi/PVE)
2. run this to split it into 3 equivelent files 
split -n 3 -d result_02_parsed.ini result_02_parsed.ini.part_
3. then scp it to each vm, and then run this script on each vm but with the original filename edited in the script MANUALLY AT THE TOP. Like this, kinda:
cp result* ~ ; cp 5-download-all-pypi-to-*.sh  ~/ ; cd ~ ; vim the downloadscript.sh thingy AND FIX THE VARIABLES AT TOP....


* NOTE: You can optionally use conda to select a environment before launching this via:
  conda env list ; conda create -y -n $PYTHONVERSION python==$PYTHONVERSION ; newbashwindow; conda activate $PYTHONVERSION"
  
exit # Uncomment when ready. This is intentional exit TO MAKE SURE THE ADMIN UNDERSTANDS. ALSO DO NOT USE read-p it will stop the nohup from working.
# read -p "Press Enter to continue AND START DOWNLOAD (Or CTRL+C to cancel)..." 

# Ensure that conda is installed with the respective environment
if ! command -v conda &> /dev/null; then
    echo "conda is not found in the environment. Please install conda and try again."
    exit 1
fi

# Ensure we are running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please use sudo or run as root."
    exit 1
fi

echo "Creating DIR... $TARGET"
mkdir -p "$TARGET" 2>/dev/null

# Ensure that conda is activated with the respective environment, load it, then continue
source ~/.bashrc
echo "OK, Host Python version is:"
python --version
conda activate $PYTHONVERSION
echo "OK, Conda Python version is:"
python --version
echo "OK, for Conda above on this OS ARCHITECTURE..."

# Ensure the target directory exists
mkdir -p "$TARGET" 2>/dev/null

# Function to download a package
download_package() {
    package=$1
    echo "Processing package: $package"
    # Use timeout to limit the pip download to 5 minutes (300 seconds)
    if timeout 60 pip download "$package" -d "$TARGET" --no-cache-dir; then
        echo "Completed pip download for package: $package"
    else
        echo "Timed out or failed to download package: $package"
    fi
    echo "----------------------------------------"
}

export -f download_package
export TARGET

# Read result_02_parsed.ini line by line and download packages in parallel
cat $PYPILIST | xargs -n 1 -P 10 -I {} bash -c 'download_package "$@"' _ {}
echo "Process completed for all packages in $PYPILIST"

echo "Cleaning up local folder cached files like ./pip-pip-egg ..."
rm -rf pip-pip-egg-info-* pip-unpack-* pip-build-env-* pip-download-* pip-modern-metadata-* pip-req-tracker-*

echo "Chmodding 777 all files in target directory"
chmod 777 -R $TARGET

echo "Saving a file to indicate download is complete to nas"
printf "@@Finished Downloading Pypi.\n\n@@Platform Used Release is: $(cat /etc/*release)\n\n@@Architecture is:\n$(uname -a)\n\n@Python Version Used was: $(python --version)\n" > "$TARGET"/Pypi_ArchInfo_Downloaded_On_$(date +%Y-%m-%d_%H-%M-%S).log

echo "NOTE: 1. DONT FORGET TO NOTE DOWN WHICH VERSION OF PYTHON AND ARCHITECTURE YOU JUST DOWNLOADED!!!"
echo "NOTE: 2. DONT FORGET TO RUN SCRIPT #4 NOW. This is to rename all files to respective file then pip installs should work!!!!!!!!!!!!!!!!!!!"
echo "Script complete."
