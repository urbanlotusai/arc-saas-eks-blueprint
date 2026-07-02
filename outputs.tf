output "kms_key_arn" {
  description = "ARN of the KMS CMK."
  value       = module.kms.key_arn
}

output "cluster_id" {
  description = "EKS cluster ID."
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "EKS cluster API server endpoint."
  value       = module.eks.cluster_endpoint
}

output "kubeconfig_command" {
  description = "Run this to update your local kubeconfig."
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_id}"
}

output "ecr_repository_url" {
  description = "ECR repository URL for tenant workload images."
  value       = module.ecr.repository_url
}

output "db_cluster_endpoint" {
  description = "Aurora writer endpoint for tenant data."
  value       = module.db.cluster_endpoint
}

output "cognito_user_pool_id" {
  description = "Cognito User Pool ID for tenant authentication."
  value       = module.cognito.user_pool_id
}

output "cognito_user_pool_arn" {
  description = "Cognito User Pool ARN."
  value       = module.cognito.user_pool_arn
}

output "cognito_user_pool_endpoint" {
  description = "Cognito User Pool endpoint for OAuth/OIDC discovery."
  value       = module.cognito.endpoint
}

output "waf_arn" {
  description = "WAF Web ACL ARN (REGIONAL). Attach to your ALB/Ingress."
  value       = module.waf.arn
}

output "vpc_id" {
  description = "ID of the SaaS platform VPC."
  value       = module.network.vpc_id
}
