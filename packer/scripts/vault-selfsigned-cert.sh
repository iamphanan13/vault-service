#!/bin/bash
set -euo pipefail

CERT_NAME="vault.internal"
CERT_DIR="/etc/ssl/vault"

# Remove this part due to security reason
# echo "Generating self-signed certificate for ${CERT_NAME}..."
# sudo mkdir -p ${CERT_DIR}
# sudo openssl req -x509 -newkey rsa:4096 -sha256 -days 365 -nodes \
#   -keyout ${CERT_DIR}/vault.key -out ${CERT_DIR}/vault.crt \
#   -subj "/CN=${CERT_NAME}" \
#   -addext "subjectAltName=DNS:${CERT_NAME},IP:127.0.0.1"
# Remove this part due to security reason

# sudo chmod 600 ${CERT_DIR}/vault.key
sudo mkdir -p ${CERT_DIR}
sudo chown -R vault:vault ${CERT_DIR}

# echo "Certificates generated at vault.crt"

# Update certificate in update-ca-certificates
# sudo cp ${CERT_DIR}/vault.crt /usr/local/share/ca-certificates/vault.crt
# sudo update-ca-certificates



