# =============================================================================
# 03-security-group - HIPAA Compliance Profile
# =============================================================================
# No profile-specific overrides — the ingress rule already restricts Aurora
# access to the VPC CIDR only (no 0.0.0.0/0 database exposure), which
# satisfies the network-access-control intent of HIPAA 45 CFR 164.312(a)(1)
# without further tightening. Value kept identical to general.tfvars.
# =============================================================================

vpc_cidr = "10.0.0.0/16"
