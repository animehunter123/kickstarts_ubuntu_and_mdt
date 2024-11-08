#!/bin/bash

echo "NOTE:
1. Its a good idea to run this directly from the NAS -- but very carefully!!! AND CHMOD WWW AFTERWARDS!!!!
2. THIS WILL BLOW AWAY YOUR ./simple DIRECTORY! 
3. THIS SCRIPT CAN TAKE 24 HOURS to create a ./simple directory with all targz/whl/egg files appropriately. 

PRESS CONTROL+C TO CANCEL or ANY ENTER TO CONTINUE... <-- disabled for now, using a exit check later.
"
# Define the source directory
# source_dir="./pypi-pipdownloaded"
#source_dir="/mnt/MY-SHARED-DATA/repos/pypi-pipdownloaded"
#source_dir="/mnt/MY-SHARED-DATA/repos/pypi-pipdownloaded_DOWNLOAD_IN_PROGRESS/"
#source_dir="/mnt/MY-SHARED-DATA/repos/pypi-pipdownloaded/"
source_dir="/volume1/MY-SHARED-DATA/repos/pypi-pipdownloaded" # If running from MY-NAS, this is faster (REMEMBER IF SYNOLOGY ROOT YOU NEED TO RUN CHMOD AFTER THIS SCRIPT TO BE PUBLICALLY VIEWABLE

echo "Starting script to create './simple' subdir from wheels/tgz in source. Attempting to cd into [$source_dir]."
# NOW... Lets... RECREATE ./simple in the dir that has all the *.tar.gz and *.whl files

# Start in the repository root
#cd "/mnt/MY-SHARED-DATA/repos/pypi-pipdownloaded"
#cd $source_dir
cd "$source_dir" || { echo "Error: Directory '$source' doesn't exist, quitting! PLEASE CHECK WHAT HAPPENED!!!!!!!" >&2; exit 1; }

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
for file in *.tar.gz *.whl *.egg; do

    # Skip if no files match the pattern, else echo the file name
    [ -e "$file" ] || continue
    echo "Processing File: [$file]..."

    # Extract package name (everything before the first hyphen)
    package_name=$(echo "$file" | sed -E 's/^([^-]+).*/\1/')
    
    # Normalize package name
    normalized_name=$(echo "$package_name" | tr '[:upper:]' '[:lower:]' | sed -E 's/[-_.]+/-/g')
    
    # Create package directory if it doesn't exist
    mkdir -p "simple/$normalized_name"
    
#    echo "Moving file from pkgname [$package_name] to nrmlname [$normalizard_name]..."
#    mv $file ./simple/$normalized_name/
    
    # Add to main index.html
    echo "<a href=\"$normalized_name/\">$normalized_name</a><br>" >> simple/index.html
    
    # Create or append to package-specific index.html
    echo "<a href=\"../../$file#sha256=$(sha256sum "$file" | cut -d' ' -f1)\">$file</a><br>" >> "simple/$normalized_name/index.html"

    echo "Moving file from pkgname [$package_name] to nrmlname [$normalized_name]..."
    mv "$file" "./simple/$normalized_name/"
    #mv "$file" "./simple/$normalized_name/" || { echo "UH OHHHH" ; exit ; }
done

# Close main index.html
echo "</body></html>" >> simple/index.html

# Ensure package-specific index.html files are properly formatted
for dir in simple/*/; do
    sed -i '1i<!DOCTYPE html><html><body>' "$dir/index.html"
    echo "</body></html>" >> "$dir/index.html"
done

echo "PEP 503 structure created successfully!"


echo "Script complete. You can now move this dir to a webserver, and pip install from it!"


