# output.tf

# أسماء كل ECS Services
output "ecs_services" {
  description = "List of all ECS service names"
  value       = [for s in aws_ecs_service.services : s.name]
}

# ARN لكل Task Definition
output "task_definitions" {
  description = "ARNs of all ECS task definitions"
  value       = [for t in aws_ecs_task_definition.tasks : t.arn]
}

# Cluster ARN
output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.microservices_cluster.arn
}

# Cluster Name
output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.microservices_cluster.name
}

# Security Group ID
output "ecs_security_group_id" {
  description = "Security Group used for ECS services"
  value       = aws_security_group.ecs_sg.id
}