# =============================================================================
# 06-ecr - General Compliance Profile
# =============================================================================
# No profile-specific overrides — immutable tags and scan-on-push are always
# on regardless of compliance profile.
# =============================================================================

image_tag_mutability = "IMMUTABLE"
scan_on_push         = true
