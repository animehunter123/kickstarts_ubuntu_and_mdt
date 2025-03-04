#!/bin/bash

# This script downloads the latest version of docker-ce and its dependencies from the official centos7 repo and creates a local yum repo for it.

sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

docker_dest='/mnt/OrioleNAS-Data/repos/docker'

mkdir $docker_dest 2>/dev/null 1>/dev/null

cd $docker_dest

sudo dnf download --resolve docker-ce docker-ce-cli containerd.io docker-compose-plugin

yum install -y createrepo

createrepo .

curl https://download.docker.com/linux/centos/gpg -o docker.gpg.key


echo "Done, you can do something like below to add it to your yum repos..."

printf " Put the below in... sudo vi /etc/yum.repos.d/docker-ce.repo
[local-docker]
name=Local Docker Repository
baseurl=file:///var/www/html/docker-repo
enabled=1
gpgcheck=0
"

echo "Script complete."