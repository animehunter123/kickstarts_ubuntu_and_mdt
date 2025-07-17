#!/bin/bash

#echo "REMOVING PREVIOUS SYNC..."
#rm -rf ../../proxmox/download.proxmox.com/

echo "DOWNLOADING PROXMOX COMMUNITY REPO...(-r recursive, -c continue, robots to be aggresive, no-parent to avoid downloading sibling directories). Starting..."
pushd .
cd ../../proxmox/
wget2 -r -c --max-threads=8 -e robots=off --no-parent 'http://download.proxmox.com/debian/pve/'
chmod -R 777 *
popd

echo "Script completed, but please remember to point your debian and proxmox sources.list via:

# Add this to /etc/apt/sources.list, per docs: https://pve.proxmox.com/wiki/Package_Repositories#sysadmin_no_subscription_repo
# Proxmox VE pve-no-subscription repository provided by proxmox.com, (CHANGE THE BELOW TO YOUR NAS!!!!!!!!!!!)
deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription

Script complete.
"
