#!/bin/bash
set -euo pipefail

VAULT_VERSION="1.21.0"


# Update apt packages and install dependencies
echo "> Updating apt packages and installing dependencies"
sudo apt-get update -y 
sudo apt-get install -y gpg lsb-release wget unzip curl jq openssl

# Install AWS CLI
echo "> Installing AWS CLI"
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

echo "> AWS CLI version: $(aws --version)"

# Install Vault 
echo "> Installing Vault ${VAULT_VERSION}"
curl -fsSL -o vault.zip https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip
sudo unzip vault.zip -d /usr/local/bin
sudo chmod 0755 /usr/local/bin/vault
vault -v 

# Create Vault user and directories
echo "> Creating vault user and directories..."
sudo useradd --system --home /etc/vault.d --shell /bin/false vault || true
sudo mkdir -p /etc/vault.d /opt/vault/data /etc/ssl/vault
sudo chown -R vault:vault /etc/vault.d /opt/vault/data /etc/ssl/vault
# wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
# echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
# sudo apt update && sudo apt install vault

# Output Vault version

echo "> Vault version: $(vault version)"


