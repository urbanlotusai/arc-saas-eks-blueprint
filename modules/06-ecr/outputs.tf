output "repository_url" {
  description = "ECR repository URL for tenant workload images."
  value       = module.ecr.repository_url
}
