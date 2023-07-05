# Copyright (c) HashiCorp, Inc.

variable "waypoint_project" {
  type        = string
  description = "Name of the Waypoint project."

  validation {
    condition     = !contains(["-"], var.waypoint_project)
    error_message = "waypoint_project must not contain dashes."
  }
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
  sensitive   = true
  type        = string
  description = <<EOF
The Vault token to be used for creating the database secrets engine, KV secrets
engine, policies, and other resources in the dev Vault cluster.
EOF
}

variable "dev_vault_address" {
  type        = string
  description = "The address of the dev Vault cluster."
}

variable "prod_vault_address" {
  type        = string
  description = "The address of the prod Vault cluster."
}

variable "aws_account_id" {
  type        = string
  sensitive   = true
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

variable "git_user" {
  type        = string
  description = "The user for the git commit which renders the repo template."
}

variable "git_email" {
  type        = string
  description = "The email address for the git commit which renders the repo template."
}

variable "git_repo_visibility" {
  type        = string
  description = "The visibility of the new GitHub repo. Must be 'private', 'internal', or 'public'."
  default     = "public"
}

variable "aws_region" {
  type        = string
  default     = "us-east-2"
  description = "The AWS region where the app infrastructure will be created.s"
}

variable "tfc_org" {
  type        = string
  description = "The TFC organization to use for remote state output."
}

variable "day_zero_infra_tfc_workspace_name" {
  type        = string
  description = "The TFC workspace to use for remote state output for day zero org infra."
}

variable "vault_tfc_workspace_name" {
  type        = string
  description = "The TFC workspace to use for remote state output for Vault."
}

variable "datadog_api_key" {
  type        = string
  sensitive   = true
  description = "The DataDog API key which authenticates the Terraform provider, and DataDog agent."
}

variable "datadog_app_key" {
  type        = string
  sensitive   = true
  description = "The DataDog app key which authenticates the Terraform provider."
}

variable "waypoint_address" {
  type        = string
  description = "The address of the Waypoint server. This will be stored in the new repo's secrets."
  sensitive   = true
}

variable "waypoint_token" {
  type        = string
  description = <<EOF
A Waypoint token with access to your server. This will be stored in the new
repo's secrets."
EOF
  sensitive   = true
}
