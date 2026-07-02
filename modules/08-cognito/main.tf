module "cognito" {
  source  = "sourcefuse/arc-cognito-userpool/aws"
  version = "0.0.1"

  name = var.name

  mfa_configuration = var.mfa_configuration
  password_policy   = var.password_policy
  clients           = var.clients

  tags = var.tags
}
