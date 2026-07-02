# =============================================================================
# 07-db - HIPAA Compliance Profile
# =============================================================================
# Compliance controls enabled:
#   - 35-day backup retention — supports the HIPAA Security Rule's data
#     backup/disaster-recovery requirements (45 CFR 164.308(a)(7)) for PHI
#     stored in tenant schemas.
#   - Deletion protection — guards against accidental loss of PHI that must
#     be retrievable for the required retention period.
# =============================================================================

backup_retention_period = 35
deletion_protection     = true
