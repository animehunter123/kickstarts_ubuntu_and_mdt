#!/bin/bash

# Define the source directory
# source_dir="./pypi-pipdownloaded"
#source_dir="/mnt/MY-SHARED-DATA/repos/pypi-pipdownloaded"
#source_dir="/mnt/MY-SHARED-DATA/repos/pypi-pipdownloaded_DOWNLOAD_IN_PROGRESS/"
#source_dir="/mnt/MY-SHARED-DATA/repos/pypi-pipdownloaded/"
source_dir="/volume1/MY-SHARED-DATA/repos/pypi-pipdownloaded" # If running from MY-NAS, this is faster

echo "Starting script to MOVE ALL FILES INTO TOP LEVEL AND REMOVE ALL SUBDIRS, thus all tgz/whl/zips are in ./simple/.. <-- TOP LEVEL!"
# NOW... Lets... RECREATE ./simple in the dir that has all the *.tar.gz and *.whl files

# Start in the repository root
#cd "/mnt/MY-SHARED-DATA/repos/pypi-pipdownloaded"
#cd $source_dir
cd "$source_dir" || { echo "Error: Directory '$source' doesn't exist, quitting! PLEASE CHECK WHAT HAPPENED!!!!!!!" >&2; exit 1; }


echo "Starting the process..."

# Move all files to the current directory
echo "Moving files to the current directory:"
find . -type f -print0 | while IFS= read -r -d '' file; do
    if [ "$(dirname "$file")" != "." ]; then
        echo "Moving: $file"
        mv -v "$file" .
    fi
done

echo "File moving complete."

# Remove empty directories
echo "Removing empty directories:"
find . -type d -empty -print -delete

echo "Empty directory removal complete."

# Optionally, remove all directories (including non-empty ones)
# Uncomment the next block if you want to use this option
echo "Removing all subdirectories (including non-empty ones):"
find . -mindepth 1 -type d -print -exec rm -rv {} +
echo "All subdirectory removal complete."

echo "Script complete. All files should now be in the current directory and subdirectories have been removed."
