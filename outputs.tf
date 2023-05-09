output "dev" {
  value = module.dev
  description = "all outputs from the waypoint ecs terraform module for the dev workspace"
}

output "prod" {
  value = module.prod
  description = "all outputs from the waypoint ecs terraform module for the prod workspace"
}