#!/bin/bash

# Define the source directory
# TARGET="/volume1/OrioleNAS-Data/repos/pypi-pipdownloaded" # If running from lm-nas, this is faster
TARGET="/volume1/OrioleNAS-Data/repos/pypi-DOWNLOAD_IN_PROGRESS" # If running from lm-nas, this is faster

echo "Information About this Script:"
echo "This script will to MOVE ALL tgz/whl/zip FILES BACK INTO TOP LEVEL."
echo "Thus... all tgz/whl/zips are in pypi-pipdownloaded/"
echo "NOTE: ALWAYS RUN THIS SCRIPT DIRECTLY FROM THE NAS, and CHMOD WWW AFTERWARDS!!!"
read -p "Press Enter to continue (Or CTRL+C to cancel)..."

echo "Starting script: to MOVE ALL FILES INTO TOP LEVEL AND REMOVE ALL SUBDIRS, thus all tgz/whl/zips are in ./simple/.. <-- TOP LEVEL!"

# Start in the repository root
#cd "/mnt/OrioleNAS-Data/repos/pypi-pipdownloaded"
cd "$TARGET" || { echo "Error: Directory '$source' doesn't exist, quitting! PLEASE CHECK WHAT HAPPENED!!!!!!!" >&2; exit 1; }


# Move all files to the current directory
echo "Moving files to the current directory: $TARGET"
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

# Remove all directories (including non-empty ones)
echo "Removing all subdirectories (including non-empty ones):"
find . -mindepth 1 -type d -print -exec rm -rv {} +
echo "All subdirectory removal complete."

echo "Script complete. All files should now be in the current directory and subdirectories have been removed."
