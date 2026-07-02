# =============================================================================
# Module: 08-cognito
# =============================================================================
# Provisions the Cognito User Pool used for tenant identity and
# authentication (OIDC/OAuth2, SAML-ready).
# State file: modules/08-cognito/terraform.tfstate
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
# Cognito Module
# -----------------------------------------------------------------------------

module "cognito" {
  source  = "sourcefuse/arc-cognito-userpool/aws"
  version = "0.0.1"

  name = "${var.namespace}-${var.environment}-tenants"

  # MFA: optional for general, required for HIPAA/PCI
  mfa_configuration = var.mfa_configuration

  password_policy = {
    minimum_length                   = var.password_minimum_length
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }

  # App client for each SaaS application
  clients = {
    saas_app = {
      name                          = "${var.namespace}-${var.environment}-app-client"
      generate_secret               = true
      callback_urls                 = var.cognito_callback_urls
      logout_urls                   = var.cognito_logout_urls
      allowed_oauth_flows           = ["code"]
      allowed_oauth_scopes          = ["openid", "email", "profile"]
      supported_identity_providers  = ["COGNITO"]
      explicit_auth_flows = [
        "ALLOW_USER_PASSWORD_AUTH",
        "ALLOW_REFRESH_TOKEN_AUTH",
        "ALLOW_USER_SRP_AUTH"
      ]
    }
  }

  tags = var.tags
}
