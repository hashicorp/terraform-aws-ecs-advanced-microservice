# Copyright (c) HashiCorp, Inc.

output "dev" {
  value       = module.dev
  description = "all outputs from the waypoint ecs terraform module for the dev workspace"
  sensitive   = true
}

output "prod" {
  value       = module.prod
  description = "all outputs from the waypoint ecs terraform module for the prod workspace"
  sensitive   = true
}

output "ecr_uri" {
  value     = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${local.lowercased_waypoint_project}"
  sensitive = true
}

output "acm_cert_arn" {
  value = aws_acm_certificate.alb_cert.arn
}

output "db" {
  value = module.database
}

output "appconfig_application" {
  value = aws_appconfig_application.appconfig_application.id
  description = "The ID of the AWS AppConfig application."
}

output "appconfig_configuration_profile" {
  value = aws_appconfig_configuration_profile.appconfig_configuration_profile.id
  description = "The ID of the AWS AppConfig configuration profile."
}
