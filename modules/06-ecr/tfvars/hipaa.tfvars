# =============================================================================
# 06-ecr - HIPAA Compliance Profile
# =============================================================================
# No profile-specific overrides — immutable tags and scan-on-push already
# provide the image-integrity and vulnerability-scanning controls relevant to
# HIPAA workloads; there is no HIPAA-specific ECR setting to flip. Values
# kept identical to general.tfvars.
# =============================================================================

image_tag_mutability = "IMMUTABLE"
scan_on_push         = true
