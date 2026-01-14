#!/bin/bash
set -euo pipefail


VAULT_VERSION="1.21.0"


# Update apt packages and install dependencies
echo "> Updating apt packages and installing dependencies"
sudo apt-get update -y 
sudo apt-get install -y gpg lsb-release wget unzip curl jq openssl apt-transport-https 

# Install Ansible
echo "> Installing Ansible"
sudo apt-get install -y ansible
ansible --version

# Install AWS CLI
echo "> Installing AWS CLI"
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip aws

# Install Vault 
echo "> Installing Vault ${VAULT_VERSION}"
curl -fsSL -o vault.zip https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip
sudo unzip vault.zip -d /usr/local/bin
sudo chmod 0755 /usr/local/bin/vault
sudo rm -f vault.zip 
vault -v 

# Install Grafana
echo "> Installing Grafana"
sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
sudo apt-get update -y 
sudo apt-get install -y grafana
# Enable and start Grafana server
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable grafana-server

