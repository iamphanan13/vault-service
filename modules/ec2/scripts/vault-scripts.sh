#!/bin/bash
set -euo pipefail

CERT_DIR="/etc/ssl/vault"

# Pull S3 Certificate from S3 Bucket
aws s3 cp s3://vault-key-20251112/prod/tls/vault.crt ${CERT_DIR}/vault.crt
aws s3 cp s3://vault-key-20251112/prod/tls/vault.key ${CERT_DIR}/vault.key

# Set permission for vault.key
sudo chmod 600 ${CERT_DIR}/vault.key
# Set permission for vault.crt
sudo chmod 644 ${CERT_DIR}/vault.crt

sudo chown -R vault:vault ${CERT_DIR}/vault.crt ${CERT_DIR}/vault.key


# Copy vault.crt to /usr/local/share/ca-certificates
ls -la ${CERT_DIR}
sudo cp ${CERT_DIR}/vault.crt /usr/local/share/ca-certificates/vault.crt
# Update ca-certificates
sudo update-ca-certificates

# Get Instance Metadata
PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

# Replace placeholders in Vault config
sudo sed -i "s/{{ private_ip }}/${PRIVATE_IP}/g" /etc/vault.d/vault.hcl
sudo sed -i "s/{{ node_id }}/${INSTANCE_ID}/g" /etc/vault.d/vault.hcl

# Restart Vault service
sudo systemctl restart vault
sudo systemctl status vault

# Test these command
# export VAULT_ADDR="https://vault.internal:8200"
# vault operator init -format=json > "vault-unseal-keys-$(date +%Y%m%d-%H%M%S).json"

