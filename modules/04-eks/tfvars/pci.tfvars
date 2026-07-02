# =============================================================================
# 04-eks - PCI Compliance Profile
# =============================================================================
# No profile-specific overrides — PCI DSS Req 3.5 (protect stored
# cryptographic material) is satisfied by the KMS-encrypted secrets store,
# independent of node sizing or Kubernetes version. Larger/dedicated node
# pools for cardholder-data workloads can be layered on via
# node_instance_types without changing this file's intent. Values kept
# identical to general.tfvars.
# =============================================================================

kubernetes_version   = "1.29"
node_instance_types  = ["m5.2xlarge"]
node_desired_size    = 3
node_min_size        = 3
node_max_size        = 20
