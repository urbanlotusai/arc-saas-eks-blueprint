locals {
  name_prefix        = "${var.namespace}-${var.environment}"
  kms_alias          = "alias/${local.name_prefix}-saas"
  cluster_name       = "${local.name_prefix}-eks"
  db_name            = "${local.name_prefix}-tenant-db"
  ecr_repo_name      = "${local.name_prefix}-app"
  waf_name           = "${local.name_prefix}-alb-waf"
  cognito_pool_name  = "${local.name_prefix}-tenants"

  tags = {
    Environment       = var.environment
    Namespace         = var.namespace
    ManagedBy         = "terraform"
    Application       = "saas-eks"
    ComplianceProfile = var.compliance_profile
  }

  is_strict          = var.compliance_profile == "hipaa"
  log_retention_days = local.is_strict ? 365 : 90
}
