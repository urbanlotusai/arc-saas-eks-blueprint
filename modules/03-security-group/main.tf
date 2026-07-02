# =============================================================================
# Module: 03-security-group
# =============================================================================
# Provisions the security group shared by the EKS cluster, Aurora, and
# tenant-facing services.
# State file: modules/03-security-group/terraform.tfstate
# Depends on: 02-network (VPC ID)
# =============================================================================

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 7.0"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region = var.region

  default_tags {
    tags = var.tags
  }
}

# -----------------------------------------------------------------------------
# Data Sources
# -----------------------------------------------------------------------------

data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = var.state_bucket_name
    key    = "modules/02-network/terraform.tfstate"
    region = var.region
  }
}

# -----------------------------------------------------------------------------
# Locals
# -----------------------------------------------------------------------------

locals {
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
}

# -----------------------------------------------------------------------------
# Security Group Module
# -----------------------------------------------------------------------------

module "security_group" {
  source  = "sourcefuse/arc-security-group/aws"
  version = "0.0.5"

  name        = "${var.namespace}-${var.environment}-saas"
  description = "Security group for SaaS EKS cluster, Aurora, and services"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  ingress_rules = local.ingress_rules
  egress_rules  = local.egress_rules

  tags = var.tags
}
