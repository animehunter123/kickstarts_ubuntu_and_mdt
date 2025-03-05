#!/bin/bash

PYTHONVERSION="3.9.18" # For use with Conda

echo "The host python version (we dont use), current version is:"
python --version

echo "Installing Conda"

# IF ROCKY, ITS EASY:
dnf install -y conda 2>/dev/null

# IF UBUNTU IT IS LONG 
if grep -q "Ubuntu" /etc/os-release; then
    echo "Ubuntu environment detected. Proceeding with Conda installation."
    # Download the latest Miniconda installer
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
    # Install Miniconda silently
    bash miniconda.sh -b -p $HOME/miniconda
    # Remove the installer
    rm miniconda.sh
    # Initialize conda for bash
    $HOME/miniconda/bin/conda init bash
    $HOME/miniconda/bin/conda init fish
    # Reload the shell configuration
    source ~/.bashrc
    # Disable auto-activation of base environment
    conda config --set auto_activate_base false
    # Verify installation
    conda --version
    echo "Conda installation complete. Please restart your terminal or run 'source ~/.bashrc' to use conda."
else
    echo "Continuing, since ubuntu wasnt detected."
fi

# Ensure that conda is installed with the respective environment
if ! command -v conda &> /dev/null; then
    echo "conda is not found in the environment. Please install conda and try again."
    echo "ROCKY has it already in repos, Ubuntu needs it installed via shell script."
    exit 1
fi

# Ensure that conda is installed with the respective environment
source ~/.bashrc
conda create -y -n $PYTHONVERSION python==$PYTHONVERSION ; 
conda activate $PYTHONVERSION
conda init bash
echo "OK, Finished Installing Conda, and Conda Downloading the python version $PYTHONVERSION"
python --version
exit