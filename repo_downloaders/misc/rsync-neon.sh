#!/bin/bash

#Variables
nohup_log="./logs/$(basename -- "$0").$(date +'%Y%m%d-%H%M').log"
rsync_url='rsync://archive.neon.kde.org/user/'
rsync_dest='/tmp/poo'
#rsync_dest='/mnt/OrioleNAS-Data/repos/neon/'

#Main()
echo "Starting \`rsync\` --- please verify log via:    tail -f $nohup_log"
nohup rsync -avz $rsync_url $rsync_dest 2>&1 1>$nohup_log &
