# Deployment Reference

## Deploy

```bash
cp examples/general.tfvars terraform.tfvars
terraform init && terraform plan && terraform apply
$(terraform output -raw kubeconfig_command)
```

## Tenant isolation strategy

This blueprint supports **namespace-per-tenant** isolation on a shared EKS cluster:

1. **Authentication:** Cognito User Pool with tenant-scoped groups
2. **Routing:** Kubernetes Ingress with hostname-based tenant routing
3. **Data:** Aurora schema-per-tenant (one schema per tenant in the shared cluster)
4. **Network:** Kubernetes NetworkPolicy to block cross-namespace traffic

For stronger isolation, use separate node groups with taints per tenant tier.

## Cognito setup

```bash
# Get the Cognito app client secret
aws cognito-idp describe-user-pool-client \
  --user-pool-id $(terraform output -raw cognito_user_pool_id) \
  --client-id <app_client_id>
```

## Tear down

```bash
terraform destroy
```

Note: Under the `hipaa` profile, Aurora has `deletion_protection = true`. Disable first:
```bash
terraform apply -var='compliance_profile=general'
terraform destroy
```
