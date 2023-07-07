# Copyright (c) HashiCorp, Inc.

# Creates the app code repo from a template with CI configured for GitHub
# Actions
module "ci" {
  source              = "./modules/ci"

  # Creating the repo triggers CI to run the first deployment,
  # which we don't want to happen until all infrastructure is in place.
  depends_on = [
    "module.database",
    "module.secrets",
    "module.telemetry",
    "module.dev",
    "module.prod",
  ]

  waypoint_project    = var.waypoint_project
  template_repo_name  = "waypoint-template-go-protobuf-api"
  github_org_name     = var.github_repo_owner
  github_token        = var.github_token
  git_user            = var.git_user
  git_email           = var.git_email
  git_repo_visibility = var.git_repo_visibility
  aws_region          = var.aws_region
  aws_account_id      = var.aws_account_id
  waypoint_token      = var.waypoint_token
  waypoint_address    = var.waypoint_address
}

# Creates dev and prod DBs, as well as a Vault mount for a database secrets
# engine for just-in-time DB credentials
module "database" {
  providers = {
    vault.dev  = vault.dev
    vault.prod = vault.prod
  }
  source                 = "./modules/database"
  waypoint_project       = var.waypoint_project
  dev_db_subnets         = data.tfe_outputs.org_day_zero_infra.values.database_subnets["dev"]
  prod_db_subnets        = data.tfe_outputs.org_day_zero_infra.values.database_subnets["prod"]
  dev_vpc_id             = data.tfe_outputs.org_day_zero_infra.values.vpc_id["dev"]
  prod_vpc_id            = data.tfe_outputs.org_day_zero_infra.values.vpc_id["prod"]
  vault_cidr             = data.tfe_outputs.org_day_zero_infra.values.hvn_cidr_block
  dev_security_group_id  = module.dev.security_group_id
  prod_security_group_id = module.prod.security_group_id
}

# Creates dev and prod Vault resources, which will enable Waypoint to auth to
# Vault via IAM to retrieve app secrets
module "secrets" {
  providers = {
    vault.dev  = vault.dev
    vault.prod = vault.prod
  }
  source                             = "./modules/secrets"
  waypoint_project                   = var.waypoint_project
  dev_db_secrets_engine_policy_name  = module.database.dev_db_secrets_engine_policy_name
  prod_db_secrets_engine_policy_name = module.database.prod_db_secrets_engine_policy_name
  vault_dev_aws_auth_method_path     = data.tfe_outputs.vault.values.vault_dev_aws_auth_method_path
  vault_prod_aws_auth_method_path    = data.tfe_outputs.vault.values.vault_prod_aws_auth_method_path
  aws_account_id                     = var.aws_account_id
}

# Creates dashboards and alerts
module "telemetry" {
  providers = {
    vault.dev  = vault.dev
    vault.prod = vault.prod
  }
  source                            = "./modules/telemetry"
  waypoint_project                  = var.waypoint_project
  aws_account_id                    = var.aws_account_id
  vault_dev_kv_secrets_engine_path  = module.secrets.vault_dev_kv_secrets_engine_path
  vault_prod_kv_secrets_engine_path = module.secrets.vault_prod_kv_secrets_engine_path
  ecs_cluster_names = [
    data.tfe_outputs.org_day_zero_infra.nonsensitive_values.ecs_cluster_name["dev"],
    data.tfe_outputs.org_day_zero_infra.nonsensitive_values.ecs_cluster_name["prod"]
  ]

  // TODO: Use an API key which is not the same API key used to auth the provider
  datadog_api_key = var.datadog_api_key
}

resource "tls_private_key" "tls_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "tls_cert" {
  private_key_pem = tls_private_key.tls_private_key.private_key_pem

  subject {
    common_name  = "megaton.com"
    organization = "Vault-Tec"
  }

  validity_period_hours = 1460

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "alb_cert" {
  private_key      = tls_private_key.tls_private_key.private_key_pem
  certificate_body = tls_self_signed_cert.tls_cert.cert_pem
}

# TODO: Add a bastion host for dev - the dev ALB is not exposed to the internet
# A bastion host would enable the developer to test their deployed service

# Creates resources for application to run in a dev environment
module "dev" {
  source  = "hashicorp/waypoint-ecs/aws"
  version = "0.0.2"

  # App-specific config
  waypoint_project = local.lowercased_waypoint_project
  application_port = 8080 # TODO(izaak): allow to be configured via input variables. It's pretty draconian to not allow app devs to choose this.

  waypoint_workspace = "dev"

  # Module config
  alb_internal = true
  create_ecr   = false # Prod creates the ecr registry

  # Existing infrastructure
  aws_region                   = var.aws_region
  vpc_id                       = data.tfe_outputs.org_day_zero_infra.values.vpc_id["dev"]
  public_subnets               = data.tfe_outputs.org_day_zero_infra.values.public_subnets["dev"]
  private_subnets              = data.tfe_outputs.org_day_zero_infra.values.private_subnets["dev"]
  ecs_cluster_name             = data.tfe_outputs.org_day_zero_infra.values.ecs_cluster_name["dev"]
  log_group_name               = data.tfe_outputs.org_day_zero_infra.values.log_group_name["dev"]
  task_role_custom_policy_arns = [data.tfe_outputs.org_day_zero_infra.values.datadog_iam_policy_arn]

  tags = {
    env      = "dev"
    workload = "microservice"
    project  = var.waypoint_project
  }
}

# Creates resources for application to run in a prod environment
module "prod" {
  source  = "hashicorp/waypoint-ecs/aws"
  version = "0.0.2"

  # App-specific config
  waypoint_project = local.lowercased_waypoint_project
  application_port = 8080 # TODO(izaak): allow to be configured via input variables. It's pretty draconian to not allow app devs to choose this.

  waypoint_workspace = "prod"

  # Module config
  alb_internal     = false
  create_ecr       = true
  force_delete_ecr = true

  # Existing infrastructure
  aws_region                   = var.aws_region
  vpc_id                       = data.tfe_outputs.org_day_zero_infra.values.vpc_id["prod"]
  public_subnets               = data.tfe_outputs.org_day_zero_infra.values.public_subnets["prod"]
  private_subnets              = data.tfe_outputs.org_day_zero_infra.values.private_subnets["prod"]
  ecs_cluster_name             = data.tfe_outputs.org_day_zero_infra.nonsensitive_values.ecs_cluster_name["prod"]
  log_group_name               = data.tfe_outputs.org_day_zero_infra.nonsensitive_values.log_group_name["prod"]
  task_role_custom_policy_arns = [data.tfe_outputs.org_day_zero_infra.values.datadog_iam_policy_arn]

  tags = {
    env      = "prod"
    workload = "microservice"
    project  = var.waypoint_project
  }
}

resource "aws_security_group_rule" "prod_ingress_rule" {
  from_port         = 443
  protocol          = "TCP"
  security_group_id = module.prod.alb_security_group_id
  to_port           = 443
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

## TODO: Waypoint config sources for the two Vault clusters, Waypoint runners, and runner profiles
