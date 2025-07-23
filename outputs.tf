output "alb_url" {
  description = "URL of the Application Load Balancer"
  value       = "http://${module.Amrize_Testing_LB.alb_dns_name}"
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.VPCs.vpc_id
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ECS.ecs_cluster_id
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = module.ECR.repository_url
}
