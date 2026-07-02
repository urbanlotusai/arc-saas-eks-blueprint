# =============================================================================
# 09-waf - PCI Compliance Profile
# =============================================================================
# Compliance controls enabled:
#   - Strictest rate limit (1000 req/5min/IP) — supports PCI DSS Req 6.4.2
#     (deploy an automated technical solution that detects/prevents
#     web-based attacks) for tenant applications in the cardholder data
#     environment.
# =============================================================================

waf_rate_limit = 1000
