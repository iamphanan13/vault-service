#!/bin/bash
set -euo pipefail

CERT_DIR="/etc/ssl/vault"


# Pull S3 Certificate from S3 Bucket to Instance vault-1
sudo aws s3 cp s3://vault-certificate-2026/servers/vault1/vault1.crt ${CERT_DIR}/vault1.crt
sudo aws s3 cp s3://vault-certificate-2026/servers/vault1/vault1.key ${CERT_DIR}/vault1.key
sudo aws s3 cp s3://vault-certificate-2026/servers/vault1/vault1-fullchain.crt ${CERT_DIR}/vault1-fullchain.crt

# Set permission for vault.key
sudo chmod 600 ${CERT_DIR}/vault1.key
# Set permission for vault.crt and vault-fullchain.crt
sudo chmod 644 ${CERT_DIR}/vault1.crt ${CERT_DIR}/vault1-fullchain.crt

sudo chown -R vault:vault ${CERT_DIR}/vault1.crt ${CERT_DIR}/vault1.key ${CERT_DIR}/vault1-fullchain.crt

# Copy vault.crt to /usr/local/share/ca-certificates
ls -la ${CERT_DIR}
sudo cp ${CERT_DIR}/vault1.crt /usr/local/share/ca-certificates/vault1.crt
sudo cp ${CERT_DIR}/vault1-fullchain.crt /usr/local/share/ca-certificates/vault1-fullchain.crt

# Update ca-certificates
sudo update-ca-certificates

# Create vault.hcl file
cat <<EOF | sudo tee /etc/vault.d/vault.hcl
storage "dynamodb" {
  ha_enabled = "true"
  region = "ap-southeast-1"
  table = "vault-table"
}

seal "awskms" {
  region = "ap-southeast-1"
  kms_key_id = "arn:aws:kms:ap-southeast-1:448049825151:key/9836016b-7949-4bce-92ec-0861131f91eb"
}

listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_cert_file = "/etc/ssl/vault/vault1-fullchain.crt"
  tls_key_file  = "/etc/ssl/vault/vault1.key"
}

ui = true
disable_mlock = true
api_addr = "https://vault.internal.service:8200"
cluster_addr = "https://10.0.10.10:8201"  
EOF

# Restart Vault service
sudo systemctl restart vault
sudo systemctl status vault

# # Test these command
# export VAULT_ADDR="https://10.0.10.10:8200"
# vault operator init -format=json > "vault-unseal-keys-$(date +%Y%m%d-%H%M%S).json"
