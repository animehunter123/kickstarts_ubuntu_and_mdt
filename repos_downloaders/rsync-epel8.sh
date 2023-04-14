#!/bin/bash

###EPEL 8 requires pre-making this path:
###/mnt/INSERT_YOUR_NFSSHARE_HERE/repos/epel/8/Everything/

#Variables
nohup_log="./logs/$(basename -- "$0").$(date +'%Y%m%d-%H%M').log"
rsync_url='rsync://mirror.umd.edu/fedora/epel/8/Everything/x86_64'
# rsync_dest='/mnt/INSERT_YOUR_NFSSHARE_HERE/repos/epel/8/'
rsync_dest='/mnt/INSERT_YOUR_NFSSHARE_HERE/repos/epel/8/Everything'

#Main()
echo "Starting \`rsync\` --- please verify log via:    tail -f $nohup_log"
nohup rsync -avz $rsync_url $rsync_dest 2>&1 1>$nohup_log &

# nohup rsync -avz rsync://mirror.umd.edu/fedora/epel/8/Everything/x86_64 /mnt/INSERT_YOUR_NFSSHARE_HERE/Repos/epel/8/ &
