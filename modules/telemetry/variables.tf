variable "app_name" {
  type = string
}

variable "aws_account_id" {
  type        = string
  description = "ID of the account with which DataDog will integrate to retrieve metrics."
}

variable "vault_dev_kv_secrets_engine_path" {
  type = string
}

variable "vault_prod_kv_secrets_engine_path" {
  type = string
}

variable "datadog_api_key" {
  type      = string
  sensitive = true
}
