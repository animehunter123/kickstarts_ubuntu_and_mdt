#!/bin/bash

########################################################
## BTW!!!
## DONT WORRY, I HAVE SCRIPT FOR INSTALLING conda later!
## DONT USE YOUR DISTRO TO INSTALL IT!!!
########################################################

echo "Cleaning up this directory first (removing ./result_* files)..."
rm result_*.html 2>/dev/null
rm result_*.ini 2>/dev/null
rm nohup.out 2>/dev/null

echo "Installing wget and python3-pip... (apt and dnf)"
apt install -y wget 2>/dev/null
apt install -y python3-pip 2>/dev/null
dnf install -y wget 2>/dev/null
dnf install -y python3-pip 2>/dev/null

echo "Starting wget..."
rm -f 1-wget-result.html 2>/dev/null
wget https://pypi.org/simple/

echo "Renaming index.html to... 1-wget-result.html"
mv index.html result_01_wget.html

