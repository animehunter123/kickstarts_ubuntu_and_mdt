#!/bin/bash

dnf --enablerepo=epel8,PowerTools group -y install "KDE Plasma Workspaces" "base-x"
#echo "exec /usr/bin/startkde" >> ~/.xinitrc

dnf group install kde-desktop -y
dnf group install kde-media -y
dnf group install kde-apps -y

yum install -y "sddm\*"

systemctl set-default graphical.target
systemctl enable sddm -f

