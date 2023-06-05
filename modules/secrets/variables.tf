variable "waypoint_project" {
  type        = string
  description = <<EOF
Name of the Waypoint project. This is included in the path of the KV secrets
engine mounts.
EOF
}

variable "aws_account_id" {
  type        = string
  description = <<EOF
The ID of the AWS account to which Vault will authenticate against for the AWS
auth method.
EOF
}

variable "dev_db_secrets_engine_policy_name" {
  type        = string
  description = "The name of the DB secrets engine in the dev environment."
}

variable "prod_db_secrets_engine_policy_name" {
  type        = string
  description = "The name of the DB secrets engine in the prod environment."
}

variable "vault_dev_aws_auth_method_path" {
  type        = string
  description = "The path to the AWS auth method in the dev environment."
}

variable "vault_prod_aws_auth_method_path" {
  type        = string
  description = "The path to the AWS auth method in the prod environment."
}
