# ── Profile: pci_dss ──────────────────────────────────────────────────────────
# Activates the PCI DSS overlay:
#   - MFA required, 14-char passwords
#   - Aurora PITR 35 days + deletion_protection = true
#   - WAF rate limit clamped to 1000 req/IP (tighter than HIPAA)
#   - Log retention 365 days

environment = "prod"
namespace   = "myorg"

compliance_profile = "pci_dss"

db_password           = "CHANGEME-UseSecretsManagerInProd"
kubernetes_version    = "1.29"
cognito_callback_urls = ["https://app.example.com/callback"]
cognito_logout_urls   = ["https://app.example.com/logout"]

# PCI DSS: larger nodes recommended for isolation
node_instance_types = ["m5.xlarge"]
node_desired_size   = 3
node_min_size       = 3
node_max_size       = 10
