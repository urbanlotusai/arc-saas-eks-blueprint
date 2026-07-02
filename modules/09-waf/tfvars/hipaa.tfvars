# =============================================================================
# 09-waf - HIPAA Compliance Profile
# =============================================================================
# Compliance controls enabled:
#   - Tighter rate limit (2000 req/5min/IP) — supports the HIPAA Security
#     Rule's requirement for technical safeguards against unauthorized
#     access attempts (45 CFR 164.312(e)(1)) by curbing brute-force/DoS
#     traffic against tenant applications carrying PHI.
# =============================================================================

waf_rate_limit = 2000
