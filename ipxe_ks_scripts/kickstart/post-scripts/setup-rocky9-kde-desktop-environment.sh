#!/bin/bash

echo "@@ Installing KDE Plasma Workspaces..."
set +e # disable exit on error for this bash script

# With these 2 lines, it works but the Loginscreen is a white screen (Need to fix this)
yes | sudo dnf groupinstall -y "Server with GUI"
yes | sudo dnf groupinstall -y 'KDE Plasma Workspaces' 
systemctl set-default graphical.target


# Failed attempt code to remove the white screen below
# yes | sudo systemctl disable lightdm.service 
# yes | sudo systemctl enable sddm.service 
# mkdir /root/old_xsessions 
# mv /usr/share/xsessions/gnome* /root/old_xsessions/
# mv /usr/share/xsessions/x* /root/old_xsessions/
# mv /usr/bin/gnome-shell /usr/bin/gnome-shell.old

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

# echo "@@ Disabling SDDM, and Enabling GDM3 to fix known Plasma White Login Screen Bug..."
# sudo systemctl stop sddm
# sudo dnf install -y gdm
# sudo systemctl disable sddm
# sudo systemctl enable gdm

echo "@@ Setting KDE as default desktop environment (both x11/wayland)..."
# sudo dnf groupinstall -y "KDE Plasma Workspaces"
echo "exec /usr/bin/startkde" > /etc/X11/xinit/Xclients  
echo "exec /usr/bin/startkde" > /etc/xdg/plasma-workspace/env/set_wayland_session.sh
echo "exec /usr/bin/startkde" > /usr/share/wayland-sessions/plasma.desktop
sed -i 's/^#DefaultSession=.*$/DefaultSession=plasma.desktop/' /etc/gdm/custom.conf
sed -i 's/^Session=.*$/Session=plasma/' /etc/skel/.dmrc
printf '\nDESKTOP=KDE\n' >> /etc/sysconfig/desktop
# systemctl restart display-manager.service

# Note: code = VSCode, and this is installed from our local repo "./repos/vscode-rpm"
echo "@@ Installing Graphical GUI Apps..."
yes | sudo dnf install -y \
  code \
  terminator \
  meld \
  gvim \
  firefox \
  chromium \
  konqueror

echo "@@ Cleaning up yum/epel repos..."
mkdir /root/old_repos
/bin/mv /etc/yum.repos.d/Rocky* /root/old_repos
/bin/mv /etc/yum.repos.d/epel* /root/old_repos
yum clean all
