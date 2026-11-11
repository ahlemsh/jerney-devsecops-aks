# Jerney — DevSecOps Platform on Azure AKS

![CI/CD](https://github.com/ahlemsh/jerney-devsecops-aks/actions/workflows/ci-cd.yml/badge.svg)

Jerney is a full-stack blog platform built as a personal DevSecOps project. The goal was to design and ship a complete, production-grade delivery chain: from local development with Docker Compose, to infrastructure provisioning with Terraform, to a hardened Kubernetes deployment on Azure AKS — with security controls integrated at every stage of the CI/CD pipeline.

---

## Table of Contents

- [Architecture](#architecture)
- [Technology Stack](#technology-stack)
- [CI/CD Pipeline](#cicd-pipeline)
- [Repository Structure](#repository-structure)
- [Local Development](#local-development)
- [Infrastructure Provisioning (Terraform)](#infrastructure-provisioning-terraform)
- [Kubernetes Deployment](#kubernetes-deployment)
- [Required GitHub Secrets](#required-github-secrets)

---

## Architecture

```
Developer
    │
    │  git push
    ▼
GitHub Repository
    │
    │  GitHub Actions CI/CD (10 stages)
    ▼
GitHub Container Registry (GHCR)
    │
    │  Pull images
    ▼
Azure Kubernetes Service (AKS)
    │
    ├── Frontend (React + Nginx) ──── port 80
    │       │
    │       │  /api  (NetworkPolicy enforced)
    ▼
    ├── Backend (Node.js / Express) ── port 5000
    │       │
    │       │  PostgreSQL connection (NetworkPolicy enforced)
    ▼
    └── PostgreSQL 16 ─────────────── port 5432
```

The three services run in a dedicated `jerney` namespace. NetworkPolicies enforce strict traffic rules: only the frontend can reach the backend, and only the backend can reach the database.

---

## Technology Stack

### Application

| Layer    | Technology              |
|----------|-------------------------|
| Frontend | React, Vite, Nginx      |
| Backend  | Node.js, Express        |
| Database | PostgreSQL 16           |

### DevOps

| Tool                        | Role                                      |
|-----------------------------|-------------------------------------------|
| Docker / Docker Compose     | Containerization and local environment    |
| Kubernetes                  | Container orchestration                   |
| Azure Kubernetes Service    | Managed Kubernetes on Azure               |
| Terraform                   | Infrastructure as Code (AKS provisioning) |
| GitHub Actions              | CI/CD pipeline automation                 |
| GitHub Container Registry   | Container image storage                   |

### Security Tools

| Tool           | Stage         | Purpose                                    |
|----------------|---------------|--------------------------------------------|
| ESLint         | Lint          | Static code quality checks                 |
| Gitleaks       | Secrets Scan  | Detect hardcoded secrets in git history    |
| npm audit      | SCA           | Dependency vulnerability analysis          |
| Hadolint       | Dockerfile    | Dockerfile best practices linting          |
| Checkov        | IaC Scan      | Terraform and K8s manifest security scan  |
| SonarCloud     | SAST          | Static application security testing       |
| Trivy          | Image Scan    | Container image vulnerability scan        |
| OWASP ZAP      | DAST          | Dynamic application security testing      |
| securityContext | Runtime      | Non-root containers, read-only filesystem  |
| NetworkPolicy  | Runtime       | Pod-to-pod traffic restriction             |

---

## CI/CD Pipeline

The pipeline runs on every push and pull request to `main` and `azure-aks`. It is structured in 10 sequential stages:

```
Stage 1  │ Lint              ESLint on backend and frontend
Stage 2  │ Secrets Scan      Gitleaks on full git history
Stage 3  │ SCA               npm audit on backend and frontend
Stage 4  │ Dockerfile Lint   Hadolint on backend and frontend Dockerfiles
Stage 5  │ IaC Scan          Checkov on Terraform and Kubernetes manifests
Stage 6  │ SAST              SonarCloud scan + Quality Gate
Stage 7  │ Build/Scan/Push   Docker build → Trivy scan → push to GHCR
Stage 8  │ DAST              OWASP ZAP baseline scan against live stack
Stage 9  │ Manifest Update   Auto-update k8s/jerney.yaml with new image tag
Stage 10 │ Deploy            kubectl apply to AKS (azure-aks branch only)
```

Images are tagged with the short Git commit SHA and pushed to `ghcr.io/<owner>/jerney-backend` and `ghcr.io/<owner>/jerney-frontend`. The manifest update and AKS deployment only run on `push` events (not pull requests).

---

## Repository Structure

```
jerney-devsecops-aks/
├── backend/                    # Node.js / Express API
│   ├── src/
│   │   ├── index.js
│   │   ├── db.js
│   │   └── routes/
│   │       ├── posts.js
│   │       └── comments.js
│   ├── Dockerfile
│   └── package.json
│
├── frontend/                   # React app served by Nginx
│   ├── src/
│   │   ├── App.jsx
│   │   ├── pages/
│   │   └── components/
│   ├── nginx.conf
│   ├── Dockerfile
│   └── package.json
│
├── k8s/
│   └── jerney.yaml             # Namespace, Deployments, Services, NetworkPolicies
│
├── terraform/                  # Azure AKS infrastructure
│   ├── main.tf                 # AKS cluster
│   ├── network.tf              # VNet and subnet
│   ├── identity.tf             # Managed identity
│   ├── provider.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars
│
├── .github/workflows/
│   └── ci-cd.yml               # Full DevSecOps pipeline
│
├── docker-compose.yml          # Local development stack
├── .checkov.yml                # Checkov configuration
└── sonar-project.properties    # SonarCloud configuration
```

---

## Local Development

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) with Docker Compose

### Run the stack

```bash
docker compose up --build -d
```

```bash
# Check containers
docker compose ps

# View logs
docker compose logs -f

# Stop
docker compose down
```

The app is available at `http://localhost`.

---

## Infrastructure Provisioning (Terraform)

The Terraform configuration provisions an Azure AKS cluster with a dedicated VNet, subnet, and managed identity.

### Default configuration (`terraform.tfvars`)

| Variable            | Default value        |
|---------------------|----------------------|
| location            | westeurope           |
| resource_group_name | rg-jerney-devsecops  |
| aks_cluster_name    | aks-jerney           |
| node_count          | 1                    |
| node_vm_size        | Standard_D2s_v3      |
| vnet_cidr           | 10.20.0.0/16         |

### Commands

```bash
cd terraform

terraform init
terraform plan
terraform apply
```

---

## Kubernetes Deployment

The `k8s/jerney.yaml` manifest deploys the full stack into the `jerney` namespace with the following hardening in place:

- All containers run as **non-root** (`runAsNonRoot: true`, `runAsUser: 1000`)
- **Read-only root filesystem** on backend and frontend
- All Linux capabilities **dropped** (`capabilities.drop: ALL`)
- `automountServiceAccountToken: false` on all pods
- `seccompProfile: RuntimeDefault` on backend and frontend
- **NetworkPolicies** restrict traffic to: frontend → backend → database only
- Liveness and readiness probes on all three services
- Backend waits for the database via an **init container**

### Manual deploy

```bash
# Get AKS credentials
az aks get-credentials --resource-group rg-jerney-devsecops --name aks-jerney

# Apply manifests
kubectl apply -f k8s/jerney.yaml

# Verify rollout
kubectl rollout status deployment/jerney-backend -n jerney
kubectl rollout status deployment/jerney-frontend -n jerney
kubectl get pods -n jerney
kubectl get svc -n jerney
```

---

## Required GitHub Secrets

The pipeline requires the following secrets configured in the repository settings:

| Secret              | Description                                       |
|---------------------|---------------------------------------------------|
| `SONAR_TOKEN`       | SonarCloud authentication token                   |
| `AZURE_CREDENTIALS` | Azure service principal JSON for AKS deployment   |

`GITHUB_TOKEN` is provided automatically by GitHub Actions and requires no manual setup.
