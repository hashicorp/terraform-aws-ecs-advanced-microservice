provider "aws" {
  # Set env vars
  region = var.aws_region
}

provider "github" {
  owner = var.github_repo_owner
  token = var.github_token
}
#
#provider "datadog" {
#  # Set "DD_API_KEY" env var
#}

# TODO: Enable authentication of Terraform to Vault without necessity of root token
provider "vault" {
  alias   = "dev"
  token   = var.dev_vault_token
  address = var.dev_vault_address
}

provider "vault" {
  alias   = "prod"
  token   = var.prod_vault_token
  address = var.prod_vault_address
}

provider "tfe" {}