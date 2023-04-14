#!/bin/bash

#1. install it:
# sudo apt install apt-mirror

#2. we set up a custom /etc/apt/mirror.list (backuped/removed contents) and added:
# sudo cp /etc/apt/mirror.list /etc/apt/mirror.list.orig
# lmadmin@linux:~$ sudo cat /etc/apt/mirror.list 
#  ############# config ##################
#  set base_path   /mnt/INSERT_YOUR_NFSSHARE_HERE/repos/docker 
#  deb https://download.docker.com/linux/ubuntu groovy stable
#  deb https://download.docker.com/linux/ubuntu focal stable


#3. Copied the key TO THE LM-NAS REPO
# https://download.docker.com/linux/ubuntu/gpg to /mnt/INSERT_YOUR_NFSSHARE_HERE/repos/docker/mirror/download.docker.com/linux/


#4. Now launch it so that it syncs to the base_path you set in the mirror.list file, via:


#Variables
nohup_log="./logs/$(basename -- "$0").$(date +'%Y%m%d-%H%M').log"

#Main()
echo "Starting \`apt-mirror\` --- please verify log via:    tail -f $nohup_log"
nohup /usr/bin/apt-mirror  2>&1 1>$nohup_log &

