#!/bin/bash

#Variables
nohup_log="./logs/$(basename -- "$0").$(date +'%Y%m%d-%H%M').log"
rsync_url='rsync://linux.dell.com/repo/hardware/DSU_20.01.00/os_dependent/'
rsync_dest='/mnt/OrioleNAS-Data/repos/dell'  #NO TRAILING SLASH

#Main()
echo "Starting \`rsync\` --- please verify log via:    tail -f $nohup_log"
nohup rsync -avz $rsync_url $rsync_dest 2>&1 1>$nohup_log &



# nohup rsync -avz rsync://mirror.umd.edu/fedora/linux /mnt/OrioleNAS-Data/repos/fedora &
# nohup rsync -avz rsync://mirror.umd.edu/centos /mnt/OrioleNAS-Data/repos/centos/ 2>&1 1>$nohup_log &