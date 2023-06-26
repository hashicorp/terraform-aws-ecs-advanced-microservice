resource "aws_security_group" "dev_vault_ingress" {
  name        = "${local.name}-dev_database_ingress_vault"
  description = "Allow ingress traffic from Vault to RDS for dynamic secrets"

  vpc_id = var.dev_vpc_id

  ingress {
    from_port   = 5432
    cidr_blocks = [var.vault_cidr]
    protocol    = "TCP"
    to_port     = 5432
  }

  # Allow egress to anything
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "dev_app_ingress" {
  name        = "${local.name}-dev_database_ingress_app"
  description = "Allow ingress traffic from app running in ECS dev environment"

  vpc_id = var.dev_vpc_id

  ingress {
    from_port       = 5432
    protocol        = "TCP"
    to_port         = 5432
    security_groups = [var.dev_security_group_id]
  }
}

resource "aws_security_group" "prod_vault_ingress" {
  name        = "${local.name}-prod_database_ingress_vault"
  description = "Allow ingress traffic from Vault to RDS for dynamic secrets"

  vpc_id = var.prod_vpc_id

  ingress {
    from_port   = 5432
    cidr_blocks = [var.vault_cidr]
    protocol    = "TCP"
    to_port     = 5432
  }

  # Allow egress to anything
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "prod_app_ingress" {
  name        = "${local.name}-prod_database_ingress_app"
  description = "Allow ingress traffic from app running in ECS prod environment"

  vpc_id = var.prod_vpc_id

  ingress {
    from_port       = 5432
    protocol        = "TCP"
    to_port         = 5432
    security_groups = [var.prod_security_group_id]
  }
}

module "dev_database" {
  source = "terraform-aws-modules/rds/aws"
  version = "5.9.0"

  identifier             = "${local.name}-dev-database"
  engine                 = "postgres"
  engine_version         = "14"
  family                 = "postgres14" # DB parameter group
  major_engine_version   = "14"         # DB option group
  instance_class         = "db.t4g.large"
  allocated_storage      = 20
  username               = "app"
  publicly_accessible    = false
  db_name                = var.db_name
  skip_final_snapshot    = true
  subnet_ids             = var.dev_db_subnets
  vpc_security_group_ids = [aws_security_group.dev_vault_ingress.id, aws_security_group.dev_app_ingress.id]
  db_subnet_group_name   = "dev-db"
}

module "prod_database" {
  source = "terraform-aws-modules/rds/aws"
  version = "5.9.0"

  identifier             = "${local.name}-prod-database"
  engine                 = "postgres"
  engine_version         = "14"
  family                 = "postgres14" # DB parameter group
  major_engine_version   = "14"         # DB option group
  instance_class         = "db.t4g.large"
  allocated_storage      = 20
  username               = "app"
  publicly_accessible    = false
  db_name                = var.db_name
  skip_final_snapshot    = true
  subnet_ids             = var.prod_db_subnets
  vpc_security_group_ids = [aws_security_group.prod_vault_ingress.id, aws_security_group.prod_app_ingress.id]
  db_subnet_group_name   = "prod-db"
}

resource "vault_database_secrets_mount" "dev_database_secrets_engine" {
  provider = vault.dev
  path     = "${var.waypoint_project}-database"

  postgresql {
    name              = "${var.waypoint_project}-database"
    connection_url    = "postgresql://{{username}}:{{password}}@${module.dev_database.db_instance_endpoint}/appdb"
    verify_connection = true
    username          = module.dev_database.db_instance_username
    password          = module.dev_database.db_instance_password
    allowed_roles = [
      local.db_role_name
    ]
  }
}

resource "vault_database_secret_backend_role" "dev_app_role" {
  provider = vault.dev

  backend             = vault_database_secrets_mount.dev_database_secrets_engine.path
  creation_statements = ["CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";"]
  db_name             = vault_database_secrets_mount.dev_database_secrets_engine.postgresql[0].name
  name                = local.db_role_name
}

resource "vault_database_secrets_mount" "prod_database_secrets_engine" {
  provider = vault.prod
  path     = "${var.waypoint_project}-database"

  postgresql {
    name              = "${var.waypoint_project}-database"
    connection_url    = "postgresql://{{username}}:{{password}}@${module.prod_database.db_instance_endpoint}/appdb"
    verify_connection = true
    username          = module.prod_database.db_instance_username
    password          = module.prod_database.db_instance_password
    allowed_roles = [
      local.db_role_name
    ]
  }
}

resource "vault_database_secret_backend_role" "prod_app_role" {
  provider = vault.prod

  backend             = vault_database_secrets_mount.prod_database_secrets_engine.path
  creation_statements = ["CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";"]
  db_name             = vault_database_secrets_mount.prod_database_secrets_engine.postgresql[0].name
  name                = local.db_role_name
}

resource "vault_policy" "dev_app_db_policy" {
  provider = vault.dev
  name     = "${var.waypoint_project}-db-policy"
  policy   = <<EOF
path "${vault_database_secrets_mount.dev_database_secrets_engine.path}/${vault_database_secret_backend_role.dev_app_role.name}" {
  capabilities = [ "read", "create" ]
}
EOF
}

resource "vault_policy" "prod_app_db_policy" {
  provider = vault.prod
  name     = "${var.waypoint_project}-db-policy"
  policy   = <<EOF
path "${vault_database_secrets_mount.prod_database_secrets_engine.path}/${vault_database_secret_backend_role.prod_app_role.name}" {
  capabilities = [ "read", "create" ]
}
EOF
}
