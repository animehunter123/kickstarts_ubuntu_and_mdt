#!/bin/bash

#1. install it:
# sudo apt install apt-mirror

#2. we set up a custom /etc/apt/mirror.list (backuped/removed contents) and added:
# sudo cp /etc/apt/mirror.list /etc/apt/mirror.list.orig
# root@ah-kub2004:/mnt/INSERT_YOUR_NFSSHARE_HERE/repos/neon# cat mirror.list | grep -v '^#'
# set mirror_path  /nas/repos/neon
# set nthreads     20
# set _tilde 0
# deb http://archive.neon.kde.org/user/ focal main

#3. Copied the key TO THE LM-NAS REPO
#  wget -q -O - http://archive.neon.kde.org/public.key

#4. Now launch it so that it syncs to the base_path you set in the mirror.list file, via:

#####################################################################################################
## NOTE FOR APT-MIRROR, the 2017 is old, and the creators reccomended: https://github.com/Stifler6996/apt-mirror.git
## SO IM USING THAT 
#####################################################################################################

#Variables
nohup_log="./logs/$(basename -- "$0").$(date +'%Y%m%d-%H%M').log"

#Main()
echo "Starting \`apt-mirror\` --- please verify log via:    tail -f $nohup_log"
nohup /usr/bin/apt-mirror  2>&1 1>$nohup_log &



##Postfix... https://github.com/apt-mirror/apt-mirror/issues/102
#echo "There is a but in Mar2020 for the apt-mirror sanitization bug, see: https://github.com/apt-mirror/apt-mirror/issues/102"
#echo "Performing workaround... so that it properly downloads filenames correctly with @ signs..."
#echo "Mirroring files to dep11 directory from http://archive.neon.kde.org/user/dists/focal/main/dep11/ now..."
#wget 'http://archive.neon.kde.org/user/dists/focal/main/dep11/icons-48x48@2.tar.gz' -O '/mnt/INSERT_YOUR_NFSSHARE_HERE/repos/neon/archive.neon.kde.org/user/dists/focal/main/dep11/icons-48x48@2.tar.gz'
#wget 'http://archive.neon.kde.org/user/dists/focal/main/dep11/icons-48x48@2.tar' -O '/mnt/INSERT_YOUR_NFSSHARE_HERE/repos/neon/archive.neon.kde.org/user/dists/focal/main/dep11/icons-48x48@2.tar'
#wget 'http://archive.neon.kde.org/user/dists/focal/main/dep11/icons-64x64@2.tar.gz' -O '/mnt/INSERT_YOUR_NFSSHARE_HERE/repos/neon/archive.neon.kde.org/user/dists/focal/main/dep11/icons-64x64@2.tar.gz'
#wget 'http://archive.neon.kde.org/user/dists/focal/main/dep11/icons-64x64@2.tar' -O '/mnt/INSERT_YOUR_NFSSHARE_HERE/repos/neon/archive.neon.kde.org/user/dists/focal/main/dep11/icons-64x64@2.tar'
#wget 'http://archive.neon.kde.org/user/dists/focal/main/dep11/icons-128x128@2.tar.gz' -O '/mnt/INSERT_YOUR_NFSSHARE_HERE/repos/neon/archive.neon.kde.org/user/dists/focal/main/dep11/icons-128x128@2.tar.gz'
#wget 'http://archive.neon.kde.org/user/dists/focal/main/dep11/icons-128x128@2.tar' -O '/mnt/INSERT_YOUR_NFSSHARE_HERE/repos/neon/archive.neon.kde.org/user/dists/focal/main/dep11/icons-128x128@2.tar'

##Postfix#2... mirror the binary-all directory
echo "Postfix#2, fixing the binary-all directory..."
mkdir -p /mnt/INSERT_YOUR_NFSSHARE_HERE/repos/neon/archive.neon.kde.org/user/dists/focal/main/binary-all
wget 'http://archive.neon.kde.org/user/dists/focal/main/binary-all/Packages' -O /mnt/INSERT_YOUR_NFSSHARE_HERE/repos/neon/archive.neon.kde.org/user/dists/focal/main/binary-all/Packages
wget 'http://archive.neon.kde.org/user/dists/focal/main/binary-all/Packages.bz2' -O /mnt/INSERT_YOUR_NFSSHARE_HERE/repos/neon/archive.neon.kde.org/user/dists/focal/main/binary-all/Packages.bz2
wget 'http://archive.neon.kde.org/user/dists/focal/main/binary-all/Packages.gz' -O /mnt/INSERT_YOUR_NFSSHARE_HERE/repos/neon/archive.neon.kde.org/user/dists/focal/main/binary-all/Packages.gz
wget 'http://archive.neon.kde.org/user/dists/focal/main/binary-all/Release' -O /mnt/INSERT_YOUR_NFSSHARE_HERE/repos/neon/archive.neon.kde.org/user/dists/focal/main/binary-all/Release
