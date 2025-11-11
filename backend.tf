terraform {
  backend "s3" {
    bucket = "terraform-state-bucket-20251110"
    key    = "vault-project/terraform-vault.tfstate"
    region = "ap-southeast-1"
    # Use lockfile instead of DynamoDB to avoid the cost of DynamoDB
    use_lockfile = true
  }
}