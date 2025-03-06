#!/bin/bash

# ###########################################################
# Run as nohup+root, and also read -p are intentionally disabled
exit # UNCOMMENT THIS AFTER YOU AGREE TO RUN THIS AS ROOT "nohup ./4-download-all-pypi-packages.sh &"
# ###########################################################

# Directory where pip will store downloaded packages
# TARGET="./pypi-pipdownloaded"
# TARGET="/mnt/OrioleNAS-Data/repos/pypi-pipdownloaded" # make sure you mounted it on your host
TARGET="/mnt/OrioleNAS-Data/repos/pypi-DOWNLOAD_IN_PROGRESS" # make sure you mounted it on your host
PYTHONVERSION="3.9.18" # For use with Conda

echo "Information About this Script:"
echo "This script will read in the list of packages from [result_02_parsed.ini] and download each one using pip."
echo "THIS TOOK ABOUT 8 DAYS TO RUN ON ROCKY9!!"
echo "Please remember to run this in your shell via: nohup ./4-download-all-pypi-packages.sh &"
echo "And then just tail -f nohup.out to see how it goes"
echo "NOTE: You can optionally use conda to select a environment before launching this via:"
echo "  conda env list ; conda create -y -n py3.9.18 python==3.9.18 ; newbashwindow; conda activate py3.9.18"
# read -p "Press Enter to continue AND START DOWNLOAD (Or CTRL+C to cancel)..." # Dont need this since it is prompted below

# Ensure that conda is installed with the respective environment
if ! command -v conda &> /dev/null; then
    echo "conda is not found in the environment. Please install conda and try again."
    exit 1
fi

# Ensure that conda is activated with the respective environment, load it, then continue
source ~/.bashrc
echo "OK, Host Python version is:"
python --version
conda activate $PYTHONVERSION
echo "OK, Conda Python version is:"
python --version
echo "OK, for Conda above on this OS ARCHITECTURE..."
# read -p "Is this correct? Press Enter to continue AND START DOWNLOAD (Or CTRL+C to cancel)..."

# Ensure the target directory exists
mkdir -p "$TARGET" 2>/dev/null

# Function to download a package
download_package() {
    package=$1
    echo "Processing package: $package"
    # Use timeout to limit the pip download to 5 minutes (300 seconds)
    # if timeout 300 pip download "$package" -d "$TARGET" --no-cache-dir; then
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
cat result_02_parsed.ini | xargs -n 1 -P 10 -I {} bash -c 'download_package "$@"' _ {}
echo "Process completed for all packages in result_02_parsed.ini"

echo "Cleaning up local folder cached files like ./pip-pip-egg ..."
rm -rf pip-pip-egg-info-* pip-unpack-* pip-build-env-* pip-download-* pip-modern-metadata-* pip-req-tracker-*

echo "Chmodding 777 all files in target directory"
chmod 777 -R $TARGET

echo "NOTE: 1. DONT FORGET TO NOTE DOWN WHICH VERSION OF PYTHON AND ARCHITECTURE YOU JUST DOWNLOADED!!!"
echo "NOTE: 2. DONT FORGET TO RUN SCRIPT #4 NOW. This is to rename all files to respective file then pip installs should work!!!!!!!!!!!!!!!!!!!"
echo "Script complete."
