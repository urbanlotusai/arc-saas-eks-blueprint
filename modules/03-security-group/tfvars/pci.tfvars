# =============================================================================
# 03-security-group - PCI Compliance Profile
# =============================================================================
# No profile-specific overrides — the ingress rule already restricts Aurora
# (cardholder-data store) access to the VPC CIDR only, satisfying PCI DSS
# Req 1.3 (restrict inbound/outbound to what is necessary). Value kept
# identical to general.tfvars.
# =============================================================================

vpc_cidr = "10.0.0.0/16"
