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
Deploying all modules gives you:

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
| **Minutes, not days** | A complete, secured multi-tenant SaaS stack normally takes days of Terraform wiring — this deploys with a handful of commands. |
| **Secure by default** | Single KMS CMK encrypts EKS secrets, Aurora, and ECR. WAF rate-limits all tenant traffic. MFA optional on general, required on HIPAA/PCI. |
| **Compliance-ready** | Built-in `general` / `hipaa` / `pci` profiles flip MFA mode, password policy, Aurora PITR (35 days), deletion protection, and WAF rate limits — no manual edits. |
| **Multi-tenant from day one** | Namespace-per-tenant on EKS; schema-per-tenant in Aurora. Cognito pools with per-client OAuth2 flows and callback URLs. |
| **Enterprise SSO ready** | Cognito User Pool supports SAML federation — add your IdP (Okta, Azure AD) as an identity provider post-apply. |
| **Portable & auditable** | Pure Terraform. Version-controlled, reproducible across environments and accounts. |
| **Independent per-module state** | Each module is its own Terraform root with its own state file — blast radius of a bad plan/apply is scoped to one module, not the whole platform. |

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
- **AWS account + credentials** (`aws configure`)
- **kubectl** installed ([install guide](https://kubernetes.io/docs/tasks/tools/))

### 2. Clone

```bash
git clone https://github.com/urbanlotusai/arc-saas-eks-blueprint.git
cd arc-saas-eks-blueprint
```

This blueprint uses **independent per-module Terraform state** — there is no root `main.tf`. Each `modules/NN-name/` is applied on its own, with cross-module values (like the KMS key ARN, VPC ID, and EKS cluster name) resolved via `terraform_remote_state` data sources rather than a parent module.

### 3. Bootstrap the state backend (once per environment)

```bash
make bootstrap ENV=dev REGION=us-east-1 NAMESPACE=myorg
```

Creates the S3 state bucket + DynamoDB lock table every module's backend uses.

### 4. Deploy all modules

```bash
make apply ENV=dev REGION=us-east-1 NAMESPACE=myorg
```

This runs `terraform init` + `apply` across `modules/01-kms` through `modules/09-waf` in order.

### Deploy a single module with a compliance profile

```bash
./scripts/apply-module.sh 07-db dev us-east-1 hipaa
```

Copies `modules/07-db/tfvars/hipaa.tfvars` → `terraform.tfvars` for that module, then inits/plans/applies it alone.

| Step | With `make` (all modules) | Single module |
|---|---|---|
| Validate | `make validate` | `cd modules/<NN-name> && terraform validate` |
| Preview | `make plan` | `./scripts/apply-module.sh <name> <env> <region> <profile>` then inspect the plan |
| Deploy | `make apply` | `./scripts/apply-module.sh <name> <env> <region> <profile>` |

### 5. Set up kubectl and onboard tenants

```bash
# Update local kubeconfig
CLUSTER_ID=$(cd modules/04-eks && terraform output -raw cluster_id)
aws eks update-kubeconfig --region us-east-1 --name "$CLUSTER_ID"

# Create a namespace per tenant
kubectl create namespace tenant-a
kubectl create namespace tenant-b

# Tenants authenticate via Cognito — retrieve the pool ID and client for your app config
cd modules/08-cognito && terraform output user_pool_id && terraform output endpoint
```

---

## Compliance profiles

| Profile | Effect |
|---|---|
| `general` | MFA optional, 8-char passwords, 7-day Aurora PITR, WAF rate limit 5000 |
| `hipaa` | MFA required, 14-char passwords, 35-day Aurora PITR + deletion protection, WAF rate limit 2000 |
| `pci` | MFA required, 14-char passwords, 35-day Aurora PITR + deletion protection, WAF rate limit 1000 |

Apply a profile to any module with `./scripts/apply-module.sh <module> <env> <region> <profile>`.

---

## Key outputs

```bash
cd modules/04-eks    && terraform output cluster_id cluster_endpoint
cd modules/06-ecr    && terraform output repository_url
cd modules/07-db     && terraform output cluster_endpoint
cd modules/08-cognito && terraform output user_pool_id user_pool_arn endpoint
cd modules/09-waf    && terraform output arn
cd modules/01-kms    && terraform output key_arn
cd modules/02-network && terraform output vpc_id
```

---

## Project structure

```
arc-saas-eks-blueprint/
├── bootstrap/                 # creates the S3 + DynamoDB state backend (apply first)
│   ├── main.tf · variables.tf · outputs.tf
├── modules/                   # each folder is an independent Terraform root
│   ├── 01-kms/
│   │   ├── config.hcl         # static backend key
│   │   ├── main.tf            # own backend "s3" {}, own provider, own module block
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── tfvars/{general,hipaa,pci}.tfvars
│   ├── 02-network/
│   ├── 03-security-group/
│   ├── 04-eks/
│   ├── 05-eks-addon/
│   ├── 06-ecr/
│   ├── 07-db/
│   ├── 08-cognito/
│   └── 09-waf/
├── scripts/
│   └── apply-module.sh        # apply one module with a chosen compliance profile
├── Makefile                   # bootstrap / init / plan / apply / validate / fmt / build-sample
├── .terraform-version         # tfenv pin (1.9.8)
├── sample-app/                # Dockerized Node app + k8s manifests proving the stack end-to-end
│   ├── index.js · Dockerfile · package.json
│   ├── k8s/                   # namespace, deployment, service manifests
│   └── README.md
├── docs/
│   ├── INSTALL.md             # macOS · Linux · Windows setup guide
│   └── DEPLOYMENT.md          # full deployment reference + rollback
├── GETTING-STARTED.md         # beginner walkthrough + tenant onboarding
├── CONTRIBUTING.md
├── CHANGELOG.md · LICENSE · NOTICE · VERSION
└── README.md
```

---

## Documentation

- **[GETTING-STARTED.md](GETTING-STARTED.md)** — zero-to-live walkthrough including tenant onboarding
- **[docs/INSTALL.md](docs/INSTALL.md)** — install Terraform, AWS CLI, and kubectl on macOS / Linux / Windows
- **[docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)** — full deployment reference, Cognito SAML setup, tenant onboarding, rollback
- **`modules/*/tfvars/{general,hipaa,pci}.tfvars`** — per-module compliance-profile example files

---

## Important notes

- **WAF scope is REGIONAL** — attach the WAF Web ACL (`modules/09-waf` `arn` output) to your ALB/Ingress controller after apply. WAF is not auto-attached in this blueprint.
- **Tenant isolation is namespace-level on Kubernetes** — additional RBAC policies (NetworkPolicy, ResourceQuota) per namespace are recommended before going to production. See [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md).
- **Schema-per-tenant in Aurora** — this blueprint provisions the Aurora cluster. Tenant schemas must be created by your application migration scripts; they are not Terraform-managed.
- **Cognito SAML federation** — to add an enterprise IdP (Okta, Azure AD), configure a SAML identity provider on the Cognito User Pool post-apply via the AWS Console or additional Terraform resources.
- **`kubernetes`/`helm` providers dropped** — the old single-shared-state `version.tf` configured `kubernetes`/`helm` providers off `module.eks` outputs for potential future Helm-based add-ons, but no resource in the 9 ARC module blocks actually used them. Since this conversion is scoped to those 9 modules, they are not carried over; add them back in your own Helm-based add-on module if needed, wired via `data.terraform_remote_state.eks` instead of a local module reference.

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
