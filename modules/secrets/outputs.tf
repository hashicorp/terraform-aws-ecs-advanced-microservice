# Copyright (c) HashiCorp, Inc.

output "vault_dev_kv_secrets_engine_path" {
  value = vault_mount.dev_app_kv.path
}

output "vault_prod_kv_secrets_engine_path" {
  value = vault_mount.prod_app_kv.path
}
