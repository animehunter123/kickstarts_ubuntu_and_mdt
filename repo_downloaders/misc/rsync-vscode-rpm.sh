#!/bin/bash

#Variables
nohup_log="./logs/$(basename -- "$0").$(date +'%Y%m%d-%H%M').log"
pushd .

#Input Source from the Internet Mirrors
#rsync_url='mirror.arizona.edu/blahdyblah' # <--- another one
rsync_url='rsync://packages.microsoft.com/yumrepos/vscode' 

#Output Folders:
#rsync_dest='/mnt/MYSITENAS-Data/repos/apt/'
rsync_dest='/mnt/MYSITENAS-Data/repos/vscode-rpm/'

#Main()
echo "Customized download is now in progress --- please verify log via:    tail -f $nohup_log"
#nohup rsync -avtz $rsync_url $rsync_dest 2>&1 1>$nohup_log &
#nohup rsync  --info=progress2 --delete -avtz $rsync_url $rsync_dest 2>&1 1>$nohup_log &

echo "@Creating ./vscode-rpm if not exists..."
mkdir ./vscode-rpm 2>/dev/null

echo "@Installing createrepo_c (ubuntu), or if you are centos/rocky just use modify this script please..."
apt install -y createrepo-c

echo "@Wgetting repodata..."
cd ./vscode-rpm
pushd .
/bin/mv config.repo config.repo.old 2>/dev/null
wget http://packages.microsoft.com/yumrepos/vscode/config.repo

echo "@Downloading only the latest VSCode RPMs..."
mkdir Packages 2>/dev/null
mkdir Packages/c 2>/dev/null
#packages=`curl http://packages.microsoft.com/yumrepos/vscode/Packages/c/`
rm -f index.html*
echo "@Parsing package index for latest version of x86_64 regular code version rpm..."
wget  http://packages.microsoft.com/yumrepos/vscode/Packages/c/ 
latest=`grep rpm index.html | sed 's/<a href.*>code/code/' | sed 's/rpm.*/rpm/' | grep x86_64 | grep code-[0-9] | tail -n 1`
cd Packages/c
wget  http://packages.microsoft.com/yumrepos/vscode/Packages/c/$latest
popd

echo "Creating a ./repodata via createrepo_c implementation..."
createrepo_c .

popd 
echo "* Do not forget to check log via:    tail -f $nohup_log"
echo "* Do not forget to check [$rsync_dest]."
