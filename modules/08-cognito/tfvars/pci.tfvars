# =============================================================================
# 08-cognito - PCI Compliance Profile
# =============================================================================
# Compliance controls enabled:
#   - MFA required (mfa_configuration = "ON") — satisfies PCI DSS Req 8.4.2
#     (MFA for all access into the cardholder data environment).
#   - 14-character minimum password length — exceeds PCI DSS Req 8.3.6's
#     12-character minimum for a stronger baseline.
# =============================================================================

mfa_configuration       = "ON"
password_minimum_length = 14
