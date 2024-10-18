#!/bin/bash

echo "@@ Setting Rocky 9 Configuration..."
set +e # disable exit on error for this bash script

echo "@@ Setting Rocky 9 History size to 800000..."
echo 'export HISTSIZE=800000' >> /etc/bashrc

echo "@@ Setting Rocky 9 Repos..."
pushd .
cd /etc/yum.repos.d/
mkdir /root/old_repos
/bin/cp *.repo /root/old_repos
rm -f *.repo
# wget -c http://INSERT_YOUR_WEBSERVER_HERE.YOURDOMAIN.COM/http-git/kickstart/pre-scripts/rocky8-lmnas-all-yum.repo
# TODO: We should add rpmfusion to this script (after the line of EPEL is required, per docs)
curl http://INSERT_YOUR_WEBSERVER_HERE.YOURDOMAIN.COM/http-git/kickstart/pre-scripts/rocky9-lmnas-all-yum.repo -o rocky9-lmnas-all-yum.repo
yum clean all
yum repolist
popd 

echo "@@ Setting Rocky 9 Resolv.conf..."
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

echo "@@ Rocky 9 Specific: Enabling CRB Repository to handle EPEL Dependencies..."
/usr/bin/crb enable

echo "@@ Installing Basic (NON-GUI) Packages..."
yum -y install \
  vim \
  epel-release \
  openssh-server \
  openssh-clients \
  net-tools \
  iproute \
  python3-pip \
  htop \
  tmux \
  open-vm-tools \
  unzip \
  p7zip \
  git \
  nfs-utils \
  cifs-utils \
  curl \
  fish \
  iotop \
  byobu \
  telnet \
  ncdu

# Rocky9 and so forth have a more empty sshd config, lets append our settings to it
printf '

# LM SSHD Configuration for Rocky9
UsePAM no
GSSAPIAuthentication no
PermitRootLogin yes
UseDNS no

' >> /etc/ssh/sshd_config

#Review the below configurations later (ssh1 is no longer supported, so this is my workaround for ssh2)
#Host *
#    StrictHostKeyChecking no
#    UserKnownHostsFile /dev/null
#    IdentityFile ~/.ssh/id_rsa
#    HostKeyAlgorithms *
#    Ciphers `ssh -Q cipher|tr "\n" "," | sed "s/,$//"`
#    KexAlgorithms `ssh -Q kex|tr "\n" "," | sed "s/,$//"`

echo "@@ Rocky9 disabling firewall..."
systemctl stop firewalld
systemctl disable firewalld

echo "@@ Cleaning up yum/epel repos..."
mkdir /root/old_repos
/bin/mv /etc/yum.repos.d/Rocky* /root/old_repos
/bin/mv /etc/yum.repos.d/epel* /root/old_repos
yum clean all
