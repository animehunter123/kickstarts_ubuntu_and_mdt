#!/bin/bash

#Variables
nohup_log="./logs/$(basename -- "$0").$(date +'%Y%m%d-%H%M').log"
#rsync_url='http://archive.kernel.org/centos/'
rsync_url='rsync://mirror.umd.edu/centos' #NOTE: This doesnt have the old RHEL5/6
rsync_dest='/mnt/INSERT_YOUR_NFSSHARE_HERE/repos/centos/'

#Main()
echo "Starting \`rsync\` --- please verify log via:    tail -f $nohup_log"
nohup rsync -avz $rsync_url $rsync_dest 2>&1 1>$nohup_log &


# Example of a rsync command:
# nohup rsync -avz rsync://mirror.umd.edu/centos /mnt/INSERT_YOUR_NFSSHARE_HERE/repos/centos/ 2>&1 1>$nohup_log &