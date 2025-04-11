#!/bin/bash

#############################################################################
# Description: Downloads the latest docker-ce and dependencies from Rocky 9/CentOS
#              repository and creates a local yum repo.
# 
# Output: Creates local repository at specified destination with all required
#         Docker packages and GPG key
#############################################################################

# Configuration
DOCKER_DEST='/mnt/OrioleNAS-Data/repos/docker'
DOCKER_REPO_URL='https://download.docker.com/linux/centos'
DOCKER_GPG_KEY="${DOCKER_REPO_URL}/gpg"

# Create destination directory if it doesn't exist
echo "Creating destination directory..."
mkdir -p "${DOCKER_DEST}"

# Add Docker repository
echo "Adding Docker repository..."
sudo dnf config-manager --add-repo "${DOCKER_REPO_URL}/docker-ce.repo"

# Change to destination directory
cd "${DOCKER_DEST}" || exit 1

# Download Docker packages and dependencies
echo "Downloading Docker packages and dependencies..."
sudo dnf download --resolve docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Install createrepo and create local repository
echo "Creating local repository..."
yum install -y createrepo
createrepo .

# Download Docker GPG key
echo "Downloading Docker GPG key..."
curl "${DOCKER_GPG_KEY}" -o docker.gpg.key

# Print instructions for repository configuration
echo -e "\nLocal Docker repository setup complete!"
echo -e "\nTo configure the local repository, create or edit: /etc/yum.repos.d/docker-ce.repo"
cat << 'EOF'

[local-docker]
name=Local Docker Repository
baseurl=file:///var/www/html/docker-repo
enabled=1
gpgcheck=0

EOF

echo "Script complete."
exit


















































# If the above doesnt work, try the below, leaving it here for now

# #!/bin/bash

# # This script downloads the latest version of docker-ce and its dependencies from the official rocky9 (which is the centos folder) repo and creates a local yum repo for it.

# sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# docker_dest='/mnt/OrioleNAS-Data/repos/docker'

# mkdir $docker_dest 2>/dev/null 1>/dev/null

# cd $docker_dest

# sudo dnf download --resolve docker-ce docker-ce-cli containerd.io docker-compose-plugin

# yum install -y createrepo

# createrepo .

# curl https://download.docker.com/linux/centos/gpg -o docker.gpg.key


# echo "Done, you can do something like below to add it to your yum repos..."

# printf " Put the below in... sudo vi /etc/yum.repos.d/docker-ce.repo
# [local-docker]
# name=Local Docker Repository
# baseurl=file:///var/www/html/docker-repo
# enabled=1
# gpgcheck=0
# "

# echo "Script complete."

