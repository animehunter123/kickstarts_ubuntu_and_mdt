#!/bin/bash

#echo "REMOVING PREVIOUS SYNC..."
#rm -rf ../../proxmox/download.proxmox.com/

# METHOD 1: Using wget2 (kinda slow), of Debian 12 (bookworm), 64-bit PC
echo "DOWNLOADING PROXMOX COMMUNITY REPO...(-r recursive, -c continue, robots to be aggresive, no-parent to avoid downloading sibling directories). Starting..."
pushd .
cd ../../proxmox/
mkdir -p download.proxmox.com/debian/pve/dists 2>/dev/null 1>/dev/null
mkdir -p download.proxmox.com/debian/pve/dists/bookworm 2>/dev/null 1>/dev/null
wget2 -r -c --max-threads=8 -e robots=off --no-parent 'http://download.proxmox.com/debian/pve/dists/bookworm/' # Dont forget the trailing slash
chmod -R 777 *
popd

# METHOD 2: POM: Using the proxmox-offline-mirror method (bookmark = 8.4.1)
# See Docs: https://pom.proxmox.com/
# This requires using a debian 12 bookworm vm to sync it. Install a debian 12 vm,
# and then ensure sources.list has:    deb http://download.proxmox.com/debian/pbs-client bookworm main
# Then you should be able to run the below commands.
# proxmox-offline-mirror setup
# proxmox-offline-mirror config media add \
#   --id pve-bookworm \
#   --mirrors proxmox-ve-bookworm-no-subscription \
#   --mirrors debian-bookworm \
#   --sync true \
#   --verify true \
#   --mountpoint ../../proxmox/
# proxmox-offline-mirror medium sync pve-bookworm

echo "Script completed, but please remember to point your debian and proxmox sources.list via:

# Add this to /etc/apt/sources.list, per docs: https://pve.proxmox.com/wiki/Package_Repositories#sysadmin_no_subscription_repo
# Proxmox VE pve-no-subscription repository provided by proxmox.com, (CHANGE THE BELOW TO YOUR NAS!!!!!!!!!!!)
deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription

Script complete.
"
