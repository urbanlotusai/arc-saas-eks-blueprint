# =============================================================================
# 07-db - General Compliance Profile
# =============================================================================
# Standard tenant Aurora cluster. Backup retention and deletion protection
# are kept low/off to reduce dev/test cost and friction; storage is still
# always encrypted with the 01-kms CMK regardless of profile.
# =============================================================================

backup_retention_period = 7
deletion_protection     = false
