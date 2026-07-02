# Getting Started

See **[docs/INSTALL.md](docs/INSTALL.md)** for tool installation.

```bash
cp examples/general.tfvars terraform.tfvars
# Set cognito_callback_urls to your SaaS app redirect URIs
terraform init && terraform apply
$(terraform output -raw kubeconfig_command)
```

Tenant onboarding pattern:
1. Create a Kubernetes namespace per tenant: `kubectl create ns tenant-acme`
2. Apply network policies to isolate tenant namespaces
3. Use Cognito User Pool groups to map tenants to EKS RBAC roles
4. Provision a tenant schema in Aurora (schema-per-tenant isolation)
