# NUX repository is provided without rsync protocol, so LFTP is required for this (or reposync)

#0. Make a LM-NAS folder: mkdir /mnt/OrioleNAS-Data/repos/nux/

#1. Set up your repos conf (BE VERY CAREFUL) 
# NOTE: Nux requires your yum repos conf to be:
# [root@lm-spacewalk yum.repos.d]# cat /etc/yum.repos.d/nux-repos-for-reposync.repo
# [nux-dextop]
# name=Nux.Ro Dextop EL RPMs
# baseurl=http://li.nux.ro/download/nux/dextop/el$releasever/$basearch/ http://mirror.li.nux.ro/li.nux.ro/nux/dextop/el$releasever/$basearch/
# enabled=0
# gpgcheck=1
# gpgkey=http://li.nux.ro/download/nux/RPM-GPG-KEY-nux.ro
# [nux-misc]
# name=Nux.Ro Misc EL RPMs
# baseurl=http://li.nux.ro/download/nux/misc/el$releasever/$basearch/ http://mirror.li.nux.ro/li.nux.ro/nux/misc/el$releasever/$basearch/
# enabled=0
# gpgcheck=1
# gpgkey=http://li.nux.ro/download/nux/RPM-GPG-KEY-nux.ro

nohup_log="/mnt/OrioleNAS-Data/repos/logs/$(basename -- "$0").$(date +'%Y%m%d-%H%M').log"
echo "Starting \`reposync\` of nux-misc... (DO NOT PRESS CTRL C)."
echo "Please tail the log file via:        tail -f $nohup_log"
cd /mnt/OrioleNAS-Data/repos/nux/
nohup reposync -r nux-misc -p /mnt/OrioleNAS-Data/repos/nux/      2>&1 1>$nohup_log 
echo "Finished nux-misc."
echo "Starting reposync of nux-dextop..."
# WAIT FOR THIS TO FINISH before running the next reposync!!!!!!!!!! !! !!
nohup reposync -r nux-dextop -p /mnt/OrioleNAS-Data/repos/nux/   2>&1 1>>$nohup_log  &    
echo "Finished nux-misc."


# NOTE: Nux requires your yum repos conf to be:
# [nux-dextop]
# name=Nux.Ro Dextop EL RPMs
# baseurl=http://li.nux.ro/download/nux/dextop/el$releasever/$basearch/ http://mirror.li.nux.ro/li.nux.ro/nux/dextop/el$releasever/$basearch/
# enabled=0
# gpgcheck=1
# gpgkey=http://li.nux.ro/download/nux/RPM-GPG-KEY-nux.ro
# [nux-misc]
# name=Nux.Ro Misc EL RPMs
# baseurl=http://li.nux.ro/download/nux/misc/el$releasever/$basearch/ http://mirror.li.nux.ro/li.nux.ro/nux/misc/el$releasever/$basearch/
# enabled=0
# gpgcheck=1
# gpgkey=http://li.nux.ro/download/nux/RPM-GPG-KEY-nux.ro