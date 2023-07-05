# Copyright (c) HashiCorp, Inc.

### AUTH METHODS ###
# TODO: GetCallerIdentity permission
resource "vault_aws_auth_backend_role" "vault_dev_aws_auth_backend_role" {
  provider  = vault.dev
  backend   = var.vault_dev_aws_auth_method_path
  role      = "app"
  auth_type = "iam"

  # This needs to be a wildcard, because the task role isn't created until
  # the No Code module is applied for the app
  # TODO: Can the task role ARN be pulled during the No Code run?
  bound_iam_principal_arns = ["arn:aws:iam::${var.aws_account_id}:role/*"]

  # Grants access to KV secrets as well as dynamic DB secrets
  token_policies = [vault_policy.dev_kv_policy.name, var.dev_db_secrets_engine_policy_name]
}

# TODO: How to assign GetCallerIdentity permission
resource "vault_aws_auth_backend_role" "vault_prod_aws_auth_backend_role" {
  provider  = vault.prod
  backend   = var.vault_prod_aws_auth_method_path
  role      = "app"
  auth_type = "iam"

  # This needs to be a wildcard, because the task role isn't created until
  # the No Code module is applied for the app
  # TODO: Can the task role ARN be pulled during the No Code run?
  bound_iam_principal_arns = ["arn:aws:iam::${var.aws_account_id}:role/*"]

  # Grants access to KV secrets as well as dynamic DB secrets
  token_policies = [vault_policy.prod_kv_policy.name, var.prod_db_secrets_engine_policy_name]
}

### POLICIES ###
resource "vault_policy" "dev_kv_policy" {
  provider = vault.dev
  name     = "dev-kv-policy"
  policy   = <<EOF
path "${vault_generic_secret.dev_env.path}" {
  capabilities = [ "read" ]
}
EOF
}

resource "vault_policy" "prod_kv_policy" {
  provider = vault.prod
  name     = "prod-kv-policy"
  policy   = <<EOF
path "${vault_generic_secret.prod_env.path}" {
  capabilities = [ "read" ]
}
EOF
}

### SECRETS ENGINES ###
resource "vault_mount" "dev_app_kv" {
  provider = vault.dev
  path     = "${var.waypoint_project}-kv"
  type     = "kv-v2"
}

resource "vault_generic_secret" "dev_env" {
  provider  = vault.dev
  data_json = "{ \"env\": \"dev\"}"
  path      = "${vault_mount.dev_app_kv.path}/config"
}

resource "vault_mount" "prod_app_kv" {
  provider = vault.prod
  path     = "${var.waypoint_project}-kv"
  type     = "kv-v2"
}

resource "vault_generic_secret" "prod_env" {
  provider  = vault.prod
  data_json = "{ \"env\": \"prod\"}"
  path      = "${vault_mount.prod_app_kv.path}/config"
}
