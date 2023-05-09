# Creates the app code repo from a template with CI configured for GitHub
# Actions
module "ci" {
  source             = "./ci"
  repo_name          = var.project_name
  template_repo_name = "waypoint-template-go-protobuf-api"
  github_org_name    = "HashiCorp-Sandbox"
  github_token       = var.github_token
}

# Creates dev and prod DBs, as well as a Vault mount for a database secrets
# engine for just-in-time DB credentials
module "database" {
  providers = {
    vault.dev  = vault.dev
    vault.prod = vault.prod
  }
  source          = "./database"
  app_name        = var.project_name
  dev_db_subnets  = data.tfe_outputs.org_day_zero_infra.nonsensitive_values.database_subnets["dev"]
  prod_db_subnets = data.tfe_outputs.org_day_zero_infra.nonsensitive_values.database_subnets["prod"]
  dev_vpc_id      = data.tfe_outputs.org_day_zero_infra.nonsensitive_values.vpc_id["dev"]
  prod_vpc_id     = data.tfe_outputs.org_day_zero_infra.nonsensitive_values.vpc_id["prod"]
  vault_cidr      = data.tfe_outputs.org_day_zero_infra.nonsensitive_values.hvn_cidr_block
}

# Creates dev and prod Vault resources, which will enable Waypoint to auth to
# Vault via IAM to retrieve app secrets
module "secrets" {
  providers = {
    vault.dev  = vault.dev
    vault.prod = vault.prod
  }
  source                             = "./secrets"
  app_name                           = var.project_name
  dev_db_secrets_engine_policy_name  = module.database.dev_db_secrets_engine_policy_name
  prod_db_secrets_engine_policy_name = module.database.prod_db_secrets_engine_policy_name
  vault_dev_aws_auth_method_path     = data.tfe_outputs.vault.values.vault_dev_aws_auth_method_path
  vault_prod_aws_auth_method_path    = data.tfe_outputs.vault.values.vault_prod_aws_auth_method_path
  aws_account_id                     = var.aws_account_id
}

# Creates dashboards and alerts
#module "telemetry" {
#  source         = "./telemetry"
#  app_name       = var.project_name
#  aws_account_id = var.aws_account_id
#}

# Creates resources for application to run in a dev environment
module "dev" {
  source  = "hashicorp/waypoint-ecs/aws"
  version = "0.0.1"

  # App-specific config
  waypoint_project = var.project_name
  application_port = 3000 # TODO(izaak): allow to be configured via input variables. It's pretty draconian to not allow app devs to choose this.

  waypoint_workspace = "dev"

  # Module config
  alb_internal = true
  create_ecr   = false # Prod creates the ecr registry

  # Existing infrastructure
  aws_region       = var.aws_region
  vpc_id           = data.tfe_outputs.org_day_zero_infra.nonsensitive_values.vpc_id["dev"]
  public_subnets   = data.tfe_outputs.org_day_zero_infra.nonsensitive_values.private_subnets["dev"]
  private_subnets  = data.tfe_outputs.org_day_zero_infra.nonsensitive_values.public_subnets["dev"]
  ecs_cluster_name = data.tfe_outputs.org_day_zero_infra.nonsensitive_values.ecs_cluster_name["dev"]
  log_group_name   = data.tfe_outputs.org_day_zero_infra.nonsensitive_values.log_group_name["dev"]

  tags = {
    env      = "dev"
    corp     = "acmecorp"
    workload = "microservice"
    project  = var.project_name
  }
}

# Creates resources for application to run in a prod environment
module "prod" {
  source  = "hashicorp/waypoint-ecs/aws"
  version = "0.0.1"

  # App-specific config
  waypoint_project = var.project_name
  application_port = 3000 # TODO(izaak): allow to be configured via input variables. It's pretty draconian to not allow app devs to choose this.

  waypoint_workspace = "prod"

  # Module config
  alb_internal = false
  create_ecr   = true

  # Existing infrastructure
  aws_region       = var.aws_region
  vpc_id           = data.tfe_outputs.org_day_zero_infra.nonsensitive_values.vpc_id["prod"]
  public_subnets   = data.tfe_outputs.org_day_zero_infra.nonsensitive_values.private_subnets["prod"]
  private_subnets  = data.tfe_outputs.org_day_zero_infra.nonsensitive_values.public_subnets["prod"]
  ecs_cluster_name = data.tfe_outputs.org_day_zero_infra.nonsensitive_values.ecs_cluster_name["prod"]
  log_group_name   = data.tfe_outputs.org_day_zero_infra.nonsensitive_values.log_group_name["prod"]

  tags = {
    env      = "prod"
    corp     = "acmecorp"
    workload = "microservice"
    project  = var.project_name
  }
}

## TODO: Waypoint config sources for the two Vault clusters, Waypoint runners, and runner profiles
