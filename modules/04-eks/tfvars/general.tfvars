# =============================================================================
# 04-eks - General Compliance Profile
# =============================================================================
# No profile-specific overrides — cluster version and node sizing are not
# compliance-driven attributes in this blueprint. Secrets are always
# encrypted with the 01-kms CMK regardless of profile.
# =============================================================================

kubernetes_version   = "1.29"
node_instance_types  = ["m5.2xlarge"]
node_desired_size    = 3
node_min_size        = 3
node_max_size        = 20
