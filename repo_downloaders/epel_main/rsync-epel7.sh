#!/bin/bash

#Variables
nohup_log="./logs/$(basename -- "$0").$(date +'%Y%m%d-%H%M').log"
rsync_url='rsync://mirror.umd.edu/fedora/epel/7/x86_64'
rsync_dest='/mnt/MYSITENAS-Data/repos/epel/7/'

#Main()
echo "Starting \`rsync\` --- please verify log via:    tail -f $nohup_log"
echo "@@@ IMPORTANT: Always Sync EPEL before your TARGET OS REPO (centos/rocky) @@@"
nohup rsync -avz $rsync_url $rsync_dest 2>&1 1>$nohup_log &



# nohup rsync -avz rsync://mirror.umd.edu/fedora/epel/7/x86_64 /mnt/MYSITENAS-Data/Repos/epel/7/ &
