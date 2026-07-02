# ═══════════════════════════════════════════════════════════════════════════════
# 1. KMS — root of the encryption trust chain
#    Outputs consumed by: module.eks, module.db, module.s3
# ═══════════════════════════════════════════════════════════════════════════════
module "kms" {
  source = "./modules/01-kms"

  alias                   = local.kms_alias
  policy                  = data.aws_iam_policy_document.kms.json
  description             = "CMK for ${local.name_prefix} Multi-Tenant SaaS on EKS"
  deletion_window_in_days = var.kms_deletion_window

  tags = local.tags
}

# ═══════════════════════════════════════════════════════════════════════════════
# 2. Network — VPC + subnets for the SaaS platform
# ═══════════════════════════════════════════════════════════════════════════════
module "network" {
  source = "./modules/02-network"

  name        = local.name_prefix
  namespace   = var.namespace
  environment = var.environment
  cidr_block  = var.vpc_cidr

  tags = local.tags
}

# ═══════════════════════════════════════════════════════════════════════════════
# 3. Security Group — EKS cluster, tenant workloads, and DB
# ═══════════════════════════════════════════════════════════════════════════════
module "security_group" {
  source = "./modules/03-security-group"

  name        = "${local.name_prefix}-saas"
  description = "Security group for SaaS EKS cluster, Aurora, and services"
  vpc_id      = module.network.vpc_id

  ingress_rules = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr]
      description = "Aurora PostgreSQL from within VPC"
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound"
    }
  ]

  tags = local.tags
}

# ═══════════════════════════════════════════════════════════════════════════════
# 4. EKS — Kubernetes cluster; tenants run in isolated namespaces
#    Outputs consumed by: module.eks_addons, kubernetes/helm providers
# ═══════════════════════════════════════════════════════════════════════════════
module "eks" {
  source = "./modules/04-eks"

  name        = local.cluster_name
  namespace   = var.namespace
  environment = var.environment

  kubernetes_version = var.kubernetes_version

  vpc_config = {
    vpc_id             = module.network.vpc_id
    subnet_ids         = data.aws_subnets.private.ids
    security_group_ids = [module.security_group.id]
  }

  cluster_encryption_config = [
    {
      provider_key_arn = module.kms.key_arn
      resources        = ["secrets"]
    }
  ]

  managed_node_groups = {
    saas = {
      instance_types = var.node_instance_types
      desired_size   = var.node_desired_size
      min_size       = var.node_min_size
      max_size       = var.node_max_size
      disk_size      = 100
      # Taint to enforce namespace-based tenant isolation
      # taints = [{ key = "dedicated", value = "saas", effect = "NO_SCHEDULE" }]
    }
  }

  tags = local.tags
}

# ═══════════════════════════════════════════════════════════════════════════════
# 5. EKS Addons — VPC CNI, CoreDNS, kube-proxy, EBS CSI
# ═══════════════════════════════════════════════════════════════════════════════
module "eks_addons" {
  source = "./modules/05-eks-addon"

  cluster_name = module.eks.cluster_id

  addons = {
    vpc-cni            = { addon_version = "v1.16.0-eksbuild.1" }
    coredns            = { addon_version = "v1.11.1-eksbuild.4" }
    kube-proxy         = { addon_version = "v1.29.0-eksbuild.1" }
    aws-ebs-csi-driver = { addon_version = "v1.26.0-eksbuild.1" }
  }

  tags = local.tags
}

# ═══════════════════════════════════════════════════════════════════════════════
# 6. ECR — container registry for tenant workload images
# ═══════════════════════════════════════════════════════════════════════════════
module "ecr" {
  source = "./modules/06-ecr"

  name                 = local.ecr_repo_name
  image_tag_mutability = "IMMUTABLE"
  scan_on_push         = true

  lifecycle_policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Expire untagged images after 1 day"
      selection    = { tagStatus = "untagged", countType = "sinceImagePushed", countUnit = "days", countNumber = 1 }
      action       = { type = "expire" }
    }]
  })

  tags = local.tags
}

# ═══════════════════════════════════════════════════════════════════════════════
# 7. Aurora DB — multi-tenant data store (schema-per-tenant pattern)
#    Outputs consumed by: (tenant services via secrets at runtime)
# ═══════════════════════════════════════════════════════════════════════════════
module "db" {
  source = "./modules/07-db"

  name        = local.db_name
  namespace   = var.namespace
  environment = var.environment

  engine         = var.db_engine
  engine_version = var.db_engine_version
  port           = 5432

  username = var.db_username

  vpc_id = module.network.vpc_id
  db_subnet_group_data = {
    subnet_ids = data.aws_subnets.private.ids
  }

  kms_key_id              = module.kms.key_arn
  instance_class          = var.db_instance_class
  backup_retention_period = local.is_strict ? 35 : 7
  deletion_protection     = local.is_strict

  tags = local.tags
}

# ═══════════════════════════════════════════════════════════════════════════════
# 8. Cognito User Pool — tenant identity and authentication
#    Supports SSO/SAML federation for enterprise tenants
# ═══════════════════════════════════════════════════════════════════════════════
module "cognito" {
  source = "./modules/08-cognito"

  name = local.cognito_pool_name

  # MFA: optional for general, required for HIPAA
  mfa_configuration = local.is_strict ? "ON" : "OPTIONAL"

  # Password policy
  password_policy = {
    minimum_length                    = local.is_strict ? 14 : 8
    require_lowercase                 = true
    require_numbers                   = true
    require_symbols                   = true
    require_uppercase                 = true
    temporary_password_validity_days  = 7
  }

  # App client for each SaaS application
  clients = {
    saas_app = {
      name                         = "${local.name_prefix}-app-client"
      generate_secret              = true
      callback_urls                = var.cognito_callback_urls
      logout_urls                  = var.cognito_logout_urls
      allowed_oauth_flows          = ["code"]
      allowed_oauth_scopes         = ["openid", "email", "profile"]
      supported_identity_providers = ["COGNITO"]
      explicit_auth_flows = [
        "ALLOW_USER_PASSWORD_AUTH",
        "ALLOW_REFRESH_TOKEN_AUTH",
        "ALLOW_USER_SRP_AUTH"
      ]
    }
  }

  tags = local.tags
}

# ═══════════════════════════════════════════════════════════════════════════════
# 9. WAF — ALB-scoped Web ACL protecting tenant workloads
#    WAF is REGIONAL for ALB; attach to the ALB after apply
# ═══════════════════════════════════════════════════════════════════════════════
module "waf" {
  source = "./modules/09-waf"

  web_acl_name           = local.waf_name
  web_acl_default_action = "ALLOW"
  web_acl_scope          = "REGIONAL"

  web_acl_visibility_config = {
    cloudwatch_metrics_enabled = true
    metric_name                = "${local.name_prefix}-waf"
    sampled_requests_enabled   = true
  }

  web_acl_rules = [
    {
      name     = "RateLimit"
      priority = 1
      action   = "block"
      statement = {
        rate_based_statement = {
          limit              = local.waf_rate_limit
          aggregate_key_type = "IP"
        }
      }
      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "${local.name_prefix}-rate-limit"
        sampled_requests_enabled   = true
      }
    }
  ]

  # HIPAA: enable AWS managed rules for known-bad inputs and SQLi
  # web_acl_rule_json = jsonencode([
  #   { Name = "AWSManagedRulesKnownBadInputsRuleSet", Priority = 10, ... }
  # ])

  tags = local.tags
}
