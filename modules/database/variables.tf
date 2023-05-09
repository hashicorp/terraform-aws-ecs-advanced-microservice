variable "app_name" {
  type = string
}

variable "dev_db_subnets" {
  type = list(string)
}

variable "prod_db_subnets" {
  type = list(string)
}

variable "dev_vpc_id" {
  type = string
}

variable "prod_vpc_id" {
  type = string
}

variable "vault_cidr" {
  type = string
}

variable "db_name" {
  type    = string
  default = "appdb"
}

variable "dev_security_group_id" {
  type        = string
  description = "The ID of the security group where the app is running in the dev environment."
}

variable "prod_security_group_id" {
  type        = string
  description = "The ID of the security group where the app is running in the prod environment."
}
