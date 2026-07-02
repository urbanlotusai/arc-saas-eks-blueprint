output "arn" {
  description = "WAF Web ACL ARN (REGIONAL). Attach to your ALB/Ingress."
  value       = module.waf.arn
}
