variable "namespace" {
  description = "Organization or team namespace"
  type        = string
  default     = "arc"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
    Project   = "arc-saas-eks-blueprint"
  }
}

variable "state_bucket_name" {
  description = "S3 bucket name for Terraform state"
  type        = string
}

variable "mfa_configuration" {
  description = "Cognito MFA mode: OFF, OPTIONAL, or ON."
  type        = string
  default     = "OPTIONAL"
}

variable "password_minimum_length" {
  description = "Minimum password length required by the Cognito password policy."
  type        = number
  default     = 8
}

variable "cognito_callback_urls" {
  description = "List of allowed callback URLs for the Cognito app client (your SaaS login redirect URIs)."
  type        = list(string)
  default     = ["https://app.example.com/callback"]
}

variable "cognito_logout_urls" {
  description = "List of allowed logout URLs for the Cognito app client."
  type        = list(string)
  default     = ["https://app.example.com/logout"]
}
