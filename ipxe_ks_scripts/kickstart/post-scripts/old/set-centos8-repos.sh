#!/bin/bash

cd /etc/yum.repos.d/
rm -f *.repo
wget -c http://MY-GITLAB/lm/repos/-/raw/master/centos8-lmnas.repo
wget -c http://MY-GITLAB/lm/repos/-/raw/master/epel8-lmnas.repo

yum clean all
yum repolist
