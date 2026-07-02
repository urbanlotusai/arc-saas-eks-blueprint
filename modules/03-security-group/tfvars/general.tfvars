# =============================================================================
# 03-security-group - General Compliance Profile
# =============================================================================
# No profile-specific overrides — the Aurora ingress rule is scoped to the
# VPC CIDR regardless of compliance profile. vpc_cidr must match the value
# used in 02-network/tfvars/general.tfvars.
# =============================================================================

vpc_cidr = "10.0.0.0/16"
