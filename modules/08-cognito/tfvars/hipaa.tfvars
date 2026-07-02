# =============================================================================
# 08-cognito - HIPAA Compliance Profile
# =============================================================================
# Compliance controls enabled:
#   - MFA required (mfa_configuration = "ON") — supports HIPAA's
#     person/entity authentication requirement (45 CFR 164.312(d)) for
#     tenant users accessing PHI.
#   - 14-character minimum password length — strengthens the access-control
#     safeguard in 45 CFR 164.312(a)(1) beyond the AWS default.
# =============================================================================

mfa_configuration       = "ON"
password_minimum_length = 14
