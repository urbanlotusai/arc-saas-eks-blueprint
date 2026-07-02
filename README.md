<div align="center">

# ARC Multi-Tenant SaaS on EKS Blueprint

### Production multi-tenant SaaS platform on EKS — in one `terraform apply`

**A SourceFuse ARC Blueprint**

![Version](https://img.shields.io/badge/version-1.0.0-E8392A)
![License](https://img.shields.io/badge/license-Apache--2.0-1A1A2E)
![Terraform](https://img.shields.io/badge/terraform-%3E%3D1.3-7B42BC)
![AWS Provider](https://img.shields.io/badge/aws--provider-%3E%3D5.0-FF9900)
![ARC Modules](https://img.shields.io/badge/ARC%20modules-9-E8392A)

</div>

---

## What is this?

A **ready-to-deploy Terraform blueprint** that provisions a production-grade multi-tenant SaaS
platform on Amazon EKS using **9 [SourceFuse ARC](https://registry.terraform.io/namespaces/modules/sourcefuse) modules**.
One `terraform apply` gives you:

- **EKS cluster** (namespace-per-tenant isolation, encrypted secrets)
- **Cognito User Pool** (tenant auth, MFA, OIDC/OAuth2, SAML-ready)
- **Aurora PostgreSQL** (schema-per-tenant, KMS-encrypted, PITR on strict profiles)
- **ECR** container registry (immutable tags, scan-on-push)
- **WAF** (REGIONAL Web ACL with rate limiting, protects the ALB)
- A single **KMS CMK** encrypting all data at rest

No hand-wiring of Cognito app clients, KMS grants, WAF scopes, or namespace RBAC policies. The hard, error-prone parts are already solved and pinned.

---

## Why use this blueprint?

| Advantage | What it means for you |
|---|---|
| **Minutes, not days** | A complete, secured multi-tenant SaaS stack normally takes days of Terraform wiring — this deploys in one command. |
| **Secure by default** | Single KMS CMK encrypts EKS secrets, Aurora, and ECR. WAF rate-limits all tenant traffic. MFA optional on general, required on HIPAA. |
| **Compliance-ready** | Built-in `general` / `hipaa` / `pci_dss` profiles flip MFA mode, password policy, Aurora PITR (35 days), deletion protection, and WAF rate limits — no manual edits. |
| **Multi-tenant from day one** | Namespace-per-tenant on EKS; schema-per-tenant in Aurora. Cognito pools with per-client OAuth2 flows and callback URLs. |
| **Enterprise SSO ready** | Cognito User Pool supports SAML federation — add your IdP (Okta, Azure AD) as an identity provider post-apply. |
| **Portable & auditable** | Pure Terraform. Version-controlled, reproducible across environments and accounts. |
| **Beginner-friendly** | One `Makefile`, copy-paste examples per profile, and step-by-step docs for macOS, Linux, and Windows. |

---

## Architecture

```
  Tenant A browser ─────┐
  Tenant B browser ─────┤──► Cognito User Pool (auth)
  Tenant C browser ─────┘         │ JWT
                                   ▼
                             WAF (REGIONAL)
                                   │
                             ALB (Ingress)
                                   │
                            EKS Cluster
                         ┌────────────────────┐
                         │  ns: tenant-a      │
                         │  ns: tenant-b      │
                         │  ns: tenant-c      │
                         └─────────┬──────────┘
                                   │
                          Aurora PostgreSQL
                      (schema-a / schema-b / schema-c)
                            (KMS-encrypted)

  ECR → tenant workload images
  └── KMS CMK ── EKS secrets · Aurora · ECR
```

---

## The 9 ARC modules

| Module | Version | Role |
|---|---|---|
| [arc-kms](https://registry.terraform.io/modules/sourcefuse/arc-kms/aws) | 1.0.11 | Customer Managed Key — root of the encryption trust chain |
| [arc-network](https://registry.terraform.io/modules/sourcefuse/arc-network/aws) | 3.0.14 | VPC + public/private subnets |
| [arc-security-group](https://registry.terraform.io/modules/sourcefuse/arc-security-group/aws) | 0.0.5 | Cluster and DB access control |
| [arc-eks](https://registry.terraform.io/modules/sourcefuse/arc-eks/aws) | 6.0.4 | EKS cluster + managed node groups |
| [arc-eks-addon](https://registry.terraform.io/modules/sourcefuse/arc-eks-addon/aws) | 1.0.3 | VPC CNI, CoreDNS, kube-proxy, EBS CSI |
| [arc-ecr](https://registry.terraform.io/modules/sourcefuse/arc-ecr/aws) | 0.0.4 | Tenant workload container registry |
| [arc-db](https://registry.terraform.io/modules/sourcefuse/arc-db/aws) | 4.0.4 | Aurora PostgreSQL — schema-per-tenant |
| [arc-cognito-userpool](https://registry.terraform.io/modules/sourcefuse/arc-cognito-userpool/aws) | 0.0.1 | Tenant identity, MFA, OIDC/OAuth2 |
| [arc-waf](https://registry.terraform.io/modules/sourcefuse/arc-waf/aws) | 1.0.6 | REGIONAL Web ACL protecting the ALB |

---

## Quick start

### 1. Prerequisites

- **Terraform** `>= 1.3` ([install guide](docs/INSTALL.md))
- **AWS credentials** configured (`aws configure`)
- **kubectl** installed ([install guide](https://kubernetes.io/docs/tasks/tools/))

### 2. Configure

```bash
git clone https://github.com/sourcefuse/arc-saas-eks-blueprint.git
cd arc-saas-eks-blueprint

cp examples/general.tfvars terraform.tfvars
```

Edit the mandatory values in `terraform.tfvars`:

| Variable | Example |
|---|---|
| `environment` | `prod` |
| `namespace` | `myorg` |
| `db_password` | `YourSecureDBPassword` |
| `cognito_callback_urls` | `["https://app.example.com/callback"]` |
| `cognito_logout_urls` | `["https://app.example.com/logout"]` |

### 3. Deploy

| Step | With `make` | Raw Terraform (all OS) |
|---|---|---|
| Validate | `make validate` | `terraform init -backend=false && terraform validate` |
| Preview | `make plan` | `terraform plan` |
| Deploy | `make apply` | `terraform init && terraform apply` |

### 4. Set up kubectl and onboard tenants

```bash
# Update local kubeconfig
$(terraform output -raw kubeconfig_command)

# Create a namespace per tenant
kubectl create namespace tenant-a
kubectl create namespace tenant-b

# Tenants authenticate via Cognito — retrieve the pool ID and client for your app config
terraform output cognito_user_pool_id
terraform output cognito_user_pool_endpoint
```

---

## Compliance profiles

| Profile | Effect |
|---|---|
| `general` | MFA optional, 8-char passwords, 7-day Aurora PITR, WAF rate limit 5000 |
| `hipaa` | MFA required, 14-char passwords, 35-day Aurora PITR + deletion protection, WAF rate limit 2000 |
| `pci_dss` | MFA required, 14-char passwords, 35-day Aurora PITR + deletion protection, WAF rate limit 1000 |

---

## Key outputs

```bash
terraform output cluster_id                 # EKS cluster name
terraform output cluster_endpoint           # EKS API server endpoint
terraform output kubeconfig_command         # aws eks update-kubeconfig ...
terraform output ecr_repository_url         # push tenant workload images here
terraform output db_cluster_endpoint        # Aurora writer endpoint
terraform output cognito_user_pool_id       # Cognito pool ID for app config
terraform output cognito_user_pool_arn      # Cognito pool ARN
terraform output cognito_user_pool_endpoint # OIDC discovery URL
terraform output waf_arn                    # WAF Web ACL ARN — attach to ALB
terraform output kms_key_arn                # CMK
terraform output vpc_id                     # VPC ID
```

---

## Project structure

```
arc-saas-eks-blueprint/
├── main.tf                   # 9 ARC module blocks, in dependency order
├── variables.tf              # all inputs with types & descriptions
├── locals.tf                 # naming, tags, compliance overlays (is_hipaa, is_strict)
├── data.tf                   # caller identity, KMS policy, subnet lookups, EKS auth
├── outputs.tf                # cluster ID, Cognito IDs, Aurora endpoint, ECR URL
├── version.tf                # Terraform + AWS + kubernetes + helm provider pins
├── terraform.tfvars.example  # copy to terraform.tfvars
├── examples/
│   ├── README.md
│   ├── general.tfvars
│   ├── hipaa.tfvars
│   └── pci_dss.tfvars
├── docs/
│   ├── INSTALL.md            # macOS · Linux · Windows setup guide
│   └── DEPLOYMENT.md        # full deployment + tenant onboarding + rollback
├── GETTING-STARTED.md        # beginner walkthrough + tenant onboarding
├── CONTRIBUTING.md
├── CHANGELOG.md · LICENSE · NOTICE · Makefile · VERSION
└── README.md
```

---

## Documentation

- **[GETTING-STARTED.md](GETTING-STARTED.md)** — zero-to-live walkthrough including tenant onboarding
- **[docs/INSTALL.md](docs/INSTALL.md)** — install Terraform, AWS CLI, and kubectl on macOS / Linux / Windows
- **[docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)** — full deployment reference, Cognito SAML setup, tenant onboarding, rollback
- **[examples/README.md](examples/README.md)** — compliance-profile example files

---

## Important notes

- **WAF scope is REGIONAL** — attach the WAF Web ACL (`waf_arn` output) to your ALB/Ingress controller after apply. WAF is not auto-attached in this blueprint.
- **Tenant isolation is namespace-level on Kubernetes** — additional RBAC policies (NetworkPolicy, ResourceQuota) per namespace are recommended before going to production. See [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md).
- **Schema-per-tenant in Aurora** — this blueprint provisions the Aurora cluster. Tenant schemas must be created by your application migration scripts; they are not Terraform-managed.
- **Two providers need EKS to exist** — the `kubernetes` and `helm` providers reference `module.eks` outputs and can only configure after the first apply.
- **Cognito SAML federation** — to add an enterprise IdP (Okta, Azure AD), configure a SAML identity provider on the Cognito User Pool post-apply via the AWS Console or additional Terraform resources.

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

Apache License 2.0 — see [LICENSE](LICENSE) and [NOTICE](NOTICE).

---

<div align="center">

### Built by [SourceFuse](https://www.sourcefuse.com)

Part of the **ARC** (Accelerated Reference Cloud) blueprint family.
Explore all ARC modules on the [Terraform Registry](https://registry.terraform.io/namespaces/modules/sourcefuse).

</div>
