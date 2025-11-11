#!/bin/bash
set -euo pipefail

# Update apt packages and install dependencies
echo "> Updating apt packages and installing dependencies"
sudo apt-get update -y 
sudo apt-get install -y gpg lsb-release wget unzip curl jq openssl

# Install Ansible
echo "> Installing Ansible"
sudo apt-get install -y ansible
ansible --version


