#!/bin/bash

#Variables
#nohup_log="./logs/$(basename -- "$0").$(date +'%Y%m%d-%H%M').log"
nohup_log="/mnt/OrioleNAS-Data/repos/logs/$(basename -- "$0").$(date +'%Y%m%d-%H%M').log"

#Input Source from the Internet Mirrors
#rsync_url='mirror.arizona.edu/blahdyblah' # <--- another one
#rsync_url='rsync://mirror.umd.edu/ubuntu' # <--- worked really well
#rsync_url='rsync://ftp.jaist.ac.jp/pub/Linux/ubuntu' #Japan University Official Mirror 4GBps (but they BAN your IP if you run 2 rsyncs)
#rsync_url='rsync://mirror.misakamikoto.network/ubuntu' #Korea University Official Mirror 1GBps (Our Rsync Avg=1.95MB/s)
#rsync_url='rsync://mirror.usi.edu/rocky' #Korea University Official Mirror 1GBps (Our Rsync Avg=1.95MB/s)
rsync_url='rsync://ftp.udx.icscoe.jp/rocky' #Akihabara 10Gbs

#Output Folders:
#rsync_dest='/mnt/OrioleNAS-Data/repos/apt/'
#rsync_dest='/mnt/OrioleNAS-Data/repos/rocky'
#rsync_dest='/mnt/OrioleNAS-Data/repos/rocky_94_DOWNLOAD_IN_PROGRESS'
rsync_dest='/mnt/OrioleNAS-Data/repos/rocky'

#Main()
mkdir $rsync_dest 2>/dev/null 1>/dev/null
echo "Rsync (with --delete !!!) download is now in progress --- please verify log via:    tail -f $nohup_log"
nohup rsync --delete --exclude '*.src.rpm' --exclude="*/debug/*" --exclude="*/source/*" --exclude='*/aarch64/*' --exclude='*/ppc64le/*' --exclude='*/s390x/*' --info=progress2 -avtz $rsync_url $rsync_dest 2>&1 1>$nohup_log &

echo "* Do not forget to check log via:    tail -f $nohup_log"
echo "* Do not forget to check [$rsync_dest]."
