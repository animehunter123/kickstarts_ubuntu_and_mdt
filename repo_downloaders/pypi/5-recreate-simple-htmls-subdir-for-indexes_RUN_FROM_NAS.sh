#!/bin/bash

# Define the source directory (with wheels/zips/tars)
# TARGET=`pwd`
# TARGET="/volume1/OrioleNAS-Data/repos/pypi-pipdownloaded" # If running from lm-nas, this is faster (Remember if synology root you need to run chmod after this script to be publically viewable)
TARGET="/volume1/OrioleNAS-Data/repos/pypi-DOWNLOAD_IN_PROGRESS" # If running from lm-nas, this is faster (Remember if synology root you need to run chmod after this script to be publically viewable)

echo "Information About this Script:"
echo " 0. This script recreates a ./simple with html anchors linking back to the top level tgz/whl/zip files."
echo " 1. It might be a good idea to run this directly from the NAS -- but YOU need to edit script!!! AND CHMOD WWW AFTERWARDS!!!!"
echo " 2. THIS WILL BLOW AWAY YOUR ./simple DIRECTORY! "
echo " 3. THIS SCRIPT CAN TAKE 24 HOURS to create a ./simple directory with SOFTLINKS to top level targz/whl/egg files appropriately. "
read -p "Press Enter to continue (Or CTRL+C to cancel)..." #  <-- disabled for now, using a exit check later!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

echo "Starting script to re-create './simple' subdir from wheels/tgz in source. Attempting to cd into [$TARGET]."
# NOW... Lets... RECREATE ./simple in the dir that has all the *.tar.gz and *.whl files

# Start in the repository root
#cd "/mnt/OrioleNAS-Data/repos/pypi-pipdownloaded"
cd "$TARGET" || { echo "Error: Directory '$source' doesn't exist, quitting! PLEASE CHECK WHAT HAPPENED!!!!!!!" >&2; exit 1; }

# Recreate simple directory (it will host a index.html to properly follow PEP 503 requirements for http pypi repo).
echo "Re-Creating ./simple that is EMPTY, I am currently in:"
pwd
echo "Removing: ./simple ..."
rm -rf simple
echo "Creating empty: ./simple ..."
mkdir -p simple

# Create main index.html
echo "<!DOCTYPE html><html><body>" > simple/index.html

# Loop through all .tar.gz, .whl, and .egg files
for file in *.tar.gz *.whl *.egg *.zip; do

    # Skip if no files match the pattern, else echo the file name
    [ -e "$file" ] || continue
    echo "Processing File: [$file]..."

    # Extract package name (everything before the first hyphen)
    package_name=$(echo "$file" | sed -E 's/^([^-]+).*/\1/')
    
    # Normalize package name
    normalized_name=$(echo "$package_name" | tr '[:upper:]' '[:lower:]' | sed -E 's/[-_.]+/-/g')
    
    # Create package directory if it doesn't exist
    mkdir -p "simple/$normalized_name"
    
    # Add to main index.html
    echo "<a href=\"$normalized_name/\">$normalized_name</a><br>" >> simple/index.html
    
    # Create or append to package-specific index.html
    echo "<a href=\"../../$file#sha256=$(sha256sum "$file" | cut -d' ' -f1)\">$file</a><br>" >> "simple/$normalized_name/index.html"

    # echo "Moving file from pkgname [$package_name] to nrmlname [$normalized_name]..."
    # mv "$file" "./simple/$normalized_name/"
done

# Close main index.html
echo "</body></html>" >> simple/index.html

# Ensure package-specific index.html files are properly formatted
for dir in simple/*/; do
    sed -i '1i<!DOCTYPE html><html><body>' "$dir/index.html"
    echo "</body></html>" >> "$dir/index.html"
done

echo "PEP 503 structure created successfully!"


echo "Script complete. 
See the *.log inside of it. 
Rename it from $TARGET to whatever you want. (Remember to leave the ./simple html's inside of it.
You can now move this dir to a webserver, and pip install from it!"


