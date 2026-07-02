# =============================================================================
# 04-eks - HIPAA Compliance Profile
# =============================================================================
# No profile-specific overrides — HIPAA's technical-safeguard requirement for
# encryption at rest (45 CFR 164.312(a)(2)(iv)) is already met by the
# cluster_encryption_config wired to the 01-kms CMK, independent of node
# sizing or Kubernetes version. Values kept identical to general.tfvars.
# =============================================================================

kubernetes_version   = "1.29"
node_instance_types  = ["m5.2xlarge"]
node_desired_size    = 3
node_min_size        = 3
node_max_size        = 20
