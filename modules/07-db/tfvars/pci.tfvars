# =============================================================================
# 07-db - PCI Compliance Profile
# =============================================================================
# Compliance controls enabled:
#   - 35-day backup retention — supports PCI DSS Req 10.5.1/10.7 evidence
#     retention expectations for cardholder-data systems.
#   - Deletion protection — guards against accidental loss of the
#     cardholder-data store and its audit trail.
# =============================================================================

backup_retention_period = 35
deletion_protection     = true
