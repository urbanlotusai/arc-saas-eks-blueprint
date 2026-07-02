# =============================================================================
# 02-network - PCI Compliance Profile
# =============================================================================
# No profile-specific overrides — PCI DSS Req 1 (network segmentation) is
# satisfied via subnetting/security groups, not by the VPC CIDR itself.
# Value kept identical to general.tfvars.
# =============================================================================

vpc_cidr = "10.0.0.0/16"
