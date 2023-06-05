variable "waypoint_project" {
  type        = string
  description = <<EOF
Name of the Waypoint project. The names of the RDS Postgres DB, Vault DB secrets
engine and policies will follow from this.
EOF
}

variable "dev_db_subnets" {
  type        = list(string)
  description = "AWS subnets to be assigned to the dev DB."
}

variable "prod_db_subnets" {
  type        = list(string)
  description = "AWS subnets to be assigned to the prod DB."
}

variable "dev_vpc_id" {
  type        = string
  description = "ID of the AWS VPC of the dev environment."
}

variable "prod_vpc_id" {
  type        = string
  description = "ID of the AWS VPC of the prod environment."
}

variable "vault_cidr" {
  type        = string
  description = "CIDR of the Vault cluster which connects to the DB."
}

variable "db_name" {
  type        = string
  description = "The name to be given to the database."
  default     = "appdb"
}

variable "dev_security_group_id" {
  type        = string
  description = "The ID of the security group where the app is running in the dev environment."
}

variable "prod_security_group_id" {
  type        = string
  description = "The ID of the security group where the app is running in the prod environment."
}
