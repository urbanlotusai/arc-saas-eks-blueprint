output "cluster_endpoint" {
  description = "Aurora writer endpoint for tenant data."
  value       = module.db.cluster_endpoint
}

output "cluster_reader_endpoint" {
  description = "Aurora reader endpoint."
  value       = module.db.cluster_reader_endpoint
}

output "cluster_arn" {
  description = "Aurora cluster ARN."
  value       = module.db.cluster_arn
}
