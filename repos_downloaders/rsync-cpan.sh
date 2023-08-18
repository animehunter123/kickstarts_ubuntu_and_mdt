#!/bin/bash

#Variables
nohup_log="./logs/$(basename -- "$0").$(date +'%Y%m%d-%H%M').log"

#Main()
echo "Rsync download is now in progress --- please verify log via:    tail -f $nohup_log"
#nohup rsync -avtz $rsync_url $rsync_dest 2>&1 1>$nohup_log &
nohup rsync -av --delete cpan-rsync.perl.org::CPAN /mnt/OrioleNAS-Data/repos/cpan 2>&1 1>$nohup_log &

echo "* Do not forget to check log via:    tail -f $nohup_log"
echo "* Do not forget to check [$rsync_dest]."
