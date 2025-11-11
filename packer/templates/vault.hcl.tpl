storage "file" {
  path = "/opt/vault/data"
}

listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_cert_file = "/etc/ssl/vault/vault.crt"
  tls_key_file  = "/etc/ssl/vault/vault.key"
}

ui = true

disable_mlock = true
api_addr = "https://0.0.0.0:8200"
cluster_addr = "https://0.0.0.0:8201"
