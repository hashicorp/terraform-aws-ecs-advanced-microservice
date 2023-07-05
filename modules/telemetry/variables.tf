# Copyright (c) HashiCorp, Inc.

variable "waypoint_project" {
  type        = string
  description = <<EOF
Name of the Waypoint project. The dashboard will use this in its name and 
widgets.
EOF
}

variable "aws_account_id" {
  type        = string
  description = <<EOF
ID of the account with which DataDog will integrate to retrieve metrics.
EOF
}

variable "vault_dev_kv_secrets_engine_path" {
  type        = string
  description = <<EOF
The path to the Vault KV secrets engine in the dev environment for the Waypoint
project.
EOF
}

variable "vault_prod_kv_secrets_engine_path" {
  type = string
}

variable "datadog_api_key" {
  type        = string
  sensitive   = true
  description = <<EOF
The DataDog API key to be stored in Vault, and which will authenticate the
DataDog Agent in AWS ECS.
EOF
}

variable "ecs_cluster_names" {
  type        = list(string)
  description = "The names of the ECS clusters to be monitored for application metrics."
}
