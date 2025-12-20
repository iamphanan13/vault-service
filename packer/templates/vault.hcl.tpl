storage "dynamodb" {
  ha_mode = "true"
  region = "ap-southeast-1"
  table = "vault-table"
}


seal "awskms" {
  region = "ap-southeast-1"
  kms_key_id = "arn:aws:kms:ap-southeast-1:448049825151:key/9836016b-7949-4bce-92ec-0861131f91eb"
}


listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_cert_file = "/etc/ssl/vault/vault.crt"
  tls_key_file  = "/etc/ssl/vault/vault.key"
}

ui = true

disable_mlock = true
api_addr = "https://:8200"
cluster_addr = "https://:8201"