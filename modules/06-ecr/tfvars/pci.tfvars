# =============================================================================
# 06-ecr - PCI Compliance Profile
# =============================================================================
# No profile-specific overrides — PCI DSS Req 6.3/11.3 vulnerability-scanning
# intent is already satisfied by scan_on_push, and immutable tags support
# Req 10's change-tracking/non-repudiation goals. Values kept identical to
# general.tfvars.
# =============================================================================

image_tag_mutability = "IMMUTABLE"
scan_on_push         = true
