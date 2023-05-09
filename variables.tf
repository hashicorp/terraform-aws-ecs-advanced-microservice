variable "project_name" {
  type        = string
  description = "Name of the Waypoint project."
}

variable "dev_vault_token" {
  sensitive   = true
  type        = string
  description = <<EOF
The Vault token to be used for creating the database secrets engine, KV secrets
engine, policies, and other resources in the dev Vault cluster.
EOF
}

variable "prod_vault_token" {
  sensitive = true
  type      = string
  description = <<EOF
The Vault token to be used for creating the database secrets engine, KV secrets
engine, policies, and other resources in the dev Vault cluster.
EOF
}

variable "dev_vault_address" {
  type = string
  description = "The address of the dev Vault cluster."
}

variable "prod_vault_address" {
  type = string
  description = "The address of the prod Vault cluster."
}

variable "aws_account_id" {
  type      = string
  sensitive = true
  description = "The ID of the AWS account used for the AWS auth method in Vault."
}

variable "github_token" {
  type        = string
  sensitive   = true
  description = "The token used to copy a GitHub repo template for the new Waypoint project's repo."
}

variable "github_repo_owner" {
  type        = string
  description = <<EOF
The GitHub owner of the template GitHub repository and the owner of the
repository to be created. This token needs permissions to create, update and
delete repos.
EOF
}

variable "aws_region" {
  default = "us-east-2"
}

variable "tfc_org" {
  type = string
  description = "The TFC organization to use for remote state output."
}

variable "day_zero_infra_tfc_workspace_name" {
  type = string
  description = "The TFC workspace to use for remote state output for day zero org infra."
}

variable "vault_tfc_workspace_name" {
  type = string
  description = "The TFC workspace to use for remote state output for Vault."
}