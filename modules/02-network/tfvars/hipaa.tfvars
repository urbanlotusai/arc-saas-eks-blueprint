# =============================================================================
# 02-network - HIPAA Compliance Profile
# =============================================================================
# No profile-specific overrides — HIPAA does not mandate a specific VPC
# addressing scheme. Network isolation is enforced via 03-security-group,
# not by CIDR choice. Value kept identical to general.tfvars.
# =============================================================================

vpc_cidr = "10.0.0.0/16"
