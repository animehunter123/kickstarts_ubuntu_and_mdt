#!/bin/bash

echo "@@ Installing KDE Plasma Workspaces..."
set +e # disable exit on error for this bash script
yes | sudo dnf groupinstall -y 'KDE Plasma Workspaces' ;
yes | sudo systemctl disable lightdm.service ;
yes | sudo systemctl enable sddm.service ; 
systemctl set-default graphical.target

# echo "Installing MATE Desktop..."
# yum clean all
# yum groupinstall -y "Server with GUI"
# yum group install -y "MATE Desktop"
# yum install -y terminator meld kate
# systemctl disable initial-setup
# systemctl disable initial-setup-text
# systemctl disable initial-setup-graphical
# systemctl disable initial-setup-reconfiguration
# pushd .
# cd /usr/share/xsessions
# mkdir OLD
# mv * OLD
# mv OLD/mate.desktop .
# # systemctl isolate graphical.target
# popd

# Note: code = VSCode, and this is installed from our local repo "./repos/vscode-rpm"
echo "@@ Installing Graphical GUI Apps..."
yes | sudo dnf install -y \
  terminator \
  meld \
  gvim \
  code \
  firefox \
  chromium \
  konqueror

# echo "Disabling SDDM, and Enabling GDM3 to fix known Plasma White Login Screen Bug..."
# sudo systemctl stop sddm
# sudo dnf install -y gdm
# sudo systemctl disable sddm
# sudo systemctl enable gdm

# Finally, cleanup any leftover repo files that may have sneakily been left behind
echo "@@ Cleaning up yum/epel repos..."
mkdir /root/old_repos
/bin/mv /etc/yum.repos.d/Rocky* /root/old_repos
/bin/mv /etc/yum.repos.d/epel* /root/old_repos
yum clean all
