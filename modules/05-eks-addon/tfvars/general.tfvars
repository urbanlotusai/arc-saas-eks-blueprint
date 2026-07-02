# =============================================================================
# 05-eks-addon - General Compliance Profile
# =============================================================================
# No profile-specific overrides — add-on versions are not a compliance-driven
# attribute in this blueprint.
# =============================================================================

addons = {
  vpc-cni            = { addon_version = "v1.16.0-eksbuild.1" }
  coredns            = { addon_version = "v1.11.1-eksbuild.4" }
  kube-proxy         = { addon_version = "v1.29.0-eksbuild.1" }
  aws-ebs-csi-driver = { addon_version = "v1.26.0-eksbuild.1" }
}
