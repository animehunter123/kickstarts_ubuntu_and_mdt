#!/bin/bash

echo "This script will read in the list of packages from [result_02_parsed.ini] and download each one using pip."
echo "THIS TOOK ABOUT 8 DAYS TO RUN ON ROCKY9!!"
echo "Please remember to run this in your shell via: nohup ./4-download-all-pypi-packages.sh &"
echo "And then just tail -f nohup.out to see how it goes"

# Directory where pip will store downloaded packages
# TARGET="./pypi-pipdownloaded"
TARGET="/mnt/MY_NAS/repos/pypi-pipdownloaded" # make sure you mounted it on your host

# Ensure the target directory exists
mkdir -p "$TARGET"

# Function to download a package
download_package() {
    package=$1
    echo "Processing package: $package"

    # Use timeout to limit the pip download to 5 minutes (300 seconds)
    if timeout 300 pip download "$package" -d "$TARGET" --no-cache-dir; then
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

echo "CHMODDING 777 ALL FILES IN TARGET DIRECTORY"
chmod 777 -R $TARGET

echo "DONT FORGET TO RUN SCRIPT #4 NOW!!!!!!!!!!!!!!!!!!!"
echo "Script complete. Please run Script #4 to rename all files to respective file then pip installs should work"
