#!/bin/bash

cd /etc/yum.repos.d/
rm -f *.repo
wget -c http://MY-GITLAB/lm/repos/-/raw/master/centos7-lmnas.repo
wget -c http://MY-GITLAB/lm/repos/-/raw/master/epel7-lmnas.repo
wget -c http://MY-GITLAB/lm/repos/-/raw/master/nux-lmnas.repo

yum clean all
yum repolist