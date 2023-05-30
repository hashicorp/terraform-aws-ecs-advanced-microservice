output "dev_db_secrets_engine_policy_name" {
  value = vault_policy.dev_app_db_policy.name
}

output "prod_db_secrets_engine_policy_name" {
  value = vault_policy.prod_app_db_policy.name
}

output "dev_db_hostname" {
  value = module.dev_database.db_instance_endpoint
}

output "dev_db_port" {
  value = module.dev_database.db_instance_port
}

output "prod_db_hostname" {
  value = module.prod_database.db_instance_endpoint
}

output "prod_db_port" {
  value = module.prod_database.db_instance_port
}

output "db_name" {
  value = var.db_name
}
