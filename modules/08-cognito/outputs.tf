output "user_pool_id" {
  description = "Cognito User Pool ID for tenant authentication."
  value       = module.cognito.user_pool_id
}

output "user_pool_arn" {
  description = "Cognito User Pool ARN."
  value       = module.cognito.user_pool_arn
}

output "endpoint" {
  description = "Cognito User Pool endpoint for OAuth/OIDC discovery."
  value       = module.cognito.endpoint
}
