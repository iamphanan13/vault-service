#!/bin/bash
set -euo pipefail

CERT_NAME="vault.internal"
CERT_DIR="/etc/ssl/vault"

echo "Generating self-signed certificate for ${CERT_NAME}..."
sudo openssl req -x509 -nodes -newkey rsa:4096 \
  -keyout ${CERT_DIR}/vault.key \
  -out ${CERT_DIR}/vault.crt \
  -days 3650 \
  -subj "/CN=${CERT_NAME}/O=InternalVault"

sudo chmod 600 ${CERT_DIR}/vault.key
sudo chown -R vault:vault ${CERT_DIR}

echo "Certificates generated at ${CERT_DIR}/vault.crt"
