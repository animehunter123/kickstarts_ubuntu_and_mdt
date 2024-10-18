#!/bin/bash

echo "@@ Installing MATE Desktop..."
set +e # disable exit on error for this bash script
yum clean all
yum groupinstall -y "Server with GUI"
yum group install -y "MATE Desktop"
yum install -y terminator meld kate
systemctl disable initial-setup
systemctl disable initial-setup-text
systemctl disable initial-setup-graphical
systemctl disable initial-setup-reconfiguration
pushd .
cd /usr/share/xsessions
mkdir OLD
mv * OLD
mv OLD/mate.desktop .
systemctl set-default graphical.target
# systemctl isolate graphical.target
popd