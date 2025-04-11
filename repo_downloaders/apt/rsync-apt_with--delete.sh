#!/bin/bash

#Variables
#nohup_log="./logs/$(basename -- "$0").$(date +'%Y%m%d-%H%M').log"
nohup_log="/mnt/OrioleNAS-Data/repos/logs/$(basename -- "$0").$(date +'%Y%m%d-%H%M').log"

#Input Source from the Internet Mirrors
#rsync_url='mirror.arizona.edu/blahdyblah' # <--- another one
#rsync_url='rsync://mirror.umd.edu/ubuntu' # <--- worked really well (but 80-200kb/sec)
#rsync_url='rsync://ftp.jaist.ac.jp/pub/Linux/ubuntu' #Japan University Official Mirror 4GBps (but they BAN your IP if you run 2 rsyncs)
#rsync_url='rsync://mirror.misakamikoto.network/ubuntu' #Korea University Official Mirror 1GBps (Our Rsync Avg=1.95MB/s)
rsync_url='rsync://ftp.udx.icscoe.jp/ubuntu/' #Akihabara 100 Gps, see: https://launchpad.net/ubuntu/+mirror/ftp.udx.icscoe.jp-archive

#Output Folders:
#rsync_dest='/mnt/INSERT_YOUR_NFSSHARE_HERE/repos/apt/'
#rsync_dest='/mnt/INSERT_YOUR_NFSSHARE_HERE/repos/apt_DOWNLOAD_IN_PROGRESS/'
# rsync_dest='/mnt/OrioleNAS-Data/repos/apt_2404_DOWNLOAD_IN_PROGRESS'
rsync_dest='/mnt/OrioleNAS-Data/repos/apt'

#Main()
echo "Creating dest dir $rsync_dest if it doesnt exist..."
mkdir $rsync_dest 2>/dev/null 1>/dev/null

printf "Rsync now in progress (WITH --DELETE)..."
#nohup rsync -avtz $rsync_url $rsync_dest 2>&1 1>$nohup_log &
nohup rsync --delete --info=progress2 -avtz $rsync_url $rsync_dest 2>&1 1>$nohup_log &
ps -efaww|grep -i rsync | grep delete

echo   "OK. Download started. Wait a few days, and check log, and check ps to make sure it is no longer running."
printf "* Check nohup ==>  tail -f $nohup_log \n"
echo   "* Final resul ==>  ls $rsync_dest"
