#!/bin/bash

echo "@@ Setting CentOS 7 Configuration..."
set +e # disable exit on error for this bash script

echo "@@ Setting CentOS 7 History size to 800000..."
echo 'export HISTSIZE=800000' >> /etc/bashrc

echo "@@ Setting CentOS 7 Repos..."
cd /etc/yum.repos.d/
rm -f *.repo
wget -c http://INSERT_YOUR_WEBSERVER_HERE.YOURDOMAIN.COM/http-git/kickstart/pre-scripts/centos7-lmnas-all-yum.repo
yum clean all
yum repolist

echo "@@ Setting CentOS 7 Resolv.conf..."
pushd .
cd /etc
cat <<EOF > resolv.conf
search YOURDOMAIN.COM
nameserver 172.16.0.111
nameserver 172.16.0.112
EOF
popd 

echo "@@ Creating the lmadmin user..."
useradd lmadmin
echo -e "INSERT_YOUR_PASS_HERE\nINSERT_YOUR_PASS_HERE" | passwd lmadmin
usermod -aG wheel lmadmin
usermod -aG root lmadmin
echo 'lmadmin ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/lmadmin

echo "@@ Setting SSHd config..."
sed -i 's/#PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/' /etc/ssh/sshd_config
sed -i 's/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config
sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config
sed -i 's/^Host .*/Host \*\n/' /etc/ssh/ssh_config
# sed -i "s/^Host \*/Host \*\n    StrictHostKeyChecking no\n    UserKnownHostsFile \/dev\/null\n    IdentityFile ~\/.ssh\/id_rsa\n    HostKeyAlgorithms \*\n    Ciphers `ssh -Q cipher|tr "\n" "," | sed "s/,$//"`\n    KexAlgorithms `ssh -Q kex|tr "\n" "," | sed "s/,$//"`/" /etc/ssh/ssh_config
# echo "Setting SSHd keys..."
# ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
# ssh-keygen -f /etc/ssh/ssh_host_ecdsa_key -N '' -t ecdsa
# ssh-keygen -f /etc/ssh/ssh_host_ed25519_key -N '' -t ed25519

# echo "Setting pip.conf..."
# TODO: Disable PIP.CONF on low side, because low-side uses internet pypi instead of nexus (no need to import the 888GB into lowside nexus)
# wget -O /etc/pip.conf http://172.16.0.5:8082/pip/pip.conf

echo "@@ Installing Basic (NON-GUI) Packages..."
yum -y install vim epel-release telnet openssh-server openssh-clients net-tools iproute python-pip python3-pip htop tmux open-vm-tools unzip p7zip git nfs-utils cifs-utils curl byobu fish iotop ncdu 

