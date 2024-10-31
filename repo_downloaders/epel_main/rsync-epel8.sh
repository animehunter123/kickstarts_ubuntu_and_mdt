#!/bin/bash

#Variables
#nohup_log="./logs/$(basename -- "$0").$(date +'%Y%m%d-%H%M').log"
nohup_log="/mnt/MY_NAS/repos/logs/$(basename -- "$0").$(date +'%Y%m%d-%H%M').log"
rsync_url='rsync://mirror.umd.edu/fedora/epel/8/Everything/x86_64'
rsync_dest='/mnt/MY_NAS/repos/epel_DOWNLOAD_IN_PROGRESS/8/Everything'

#Main()
mkdir -p $rsync_dest 2>/dev/null 1>/dev/null
echo "Starting \`rsync\` --- please verify log via:    tail -f $nohup_log"
echo "@@@ IMPORTANT: Always Sync EPEL before your TARGET OS REPO (centos/rocky) @@@"
nohup rsync -avz $rsync_url $rsync_dest 2>&1 1>$nohup_log &

