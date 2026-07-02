# =============================================================================
# 08-cognito - General Compliance Profile
# =============================================================================
# Standard tenant identity pool. MFA is optional and passwords require only
# the AWS-recommended 8-character minimum to keep onboarding friction low.
# =============================================================================

mfa_configuration       = "OPTIONAL"
password_minimum_length = 8
