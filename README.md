# Azure-kubernetes-iac-deployment
Production-ready Kubernetes environment using Terraform, implementing Node Affinity for workload isolation and Azure Load Balancer for public ingress.
# Scalable AKS Infrastructure with Terraform and Node Affinity

## Project Overview
This project demonstrates a production-grade deployment of an Azure Kubernetes Service (AKS) cluster using **Infrastructure as Code (IaC)**. The architecture features a remote state backend, multi-node pool configuration, and advanced Kubernetes scheduling using **Node Affinity**. The final workload is a containerized '2048' web application exposed via an Azure Standard Load Balancer.

## Architecture Highlights
- **Infrastructure:** Terraform (v1.0+)
- **Cloud Provider:** Azure (AZURRM & AZAPI Providers)
- **Orchestration:** Managed Kubernetes (AKS)
- **State Management:** Remote Backend via Azure Blob Storage
- **Security:** Azure AD Authentication (RBAC) & SSH Key Encryption
- **Networking:** Azure Standard Load Balancer (Public VIP)

[Image of AKS Cluster Architecture with Node Pools and Load Balancer]

## Project Structure
```text
├── main.tf                 # Core Provider and Resource Group definitions
├── variables.tf            # Parameterized variables (Region, SKU, Prefixes)
├── aks-cluster.tf          # AKS Cluster and Secondary Node Pool (Blue Pool)
├── providers.tf            # Backend configuration for State Locking
├── deployment-definition.yml # Kubernetes Deployment with Node Affinity
└── service-definition.yml    # Kubernetes LoadBalancer Service
```

## Technical Implementation Details

### 1. Remote State & Locking
To ensure team collaboration and prevent state corruption, I implemented a remote backend.
- **Storage:** Azure Blob Storage (`state7674`)
- **Security:** Enabled `use_azuread_auth` to eliminate the need for static access keys, utilizing RBAC (`Storage Blob Data Owner`) for identity-based access.

### 2. Infrastructure Provisioning (Terraform)
The cluster was designed with two distinct node pools:
- **System Pool:** Handles core Kubernetes services (Coredns, Metrics-server).
- **User Pool (Internal):** A specialized pool labeled with `color=blue`, reserved for application workloads.
- **SKU Selection:** Utilized `Standard_D2s_v3` to optimize for regional hardware availability and performance.

### 3. Workload Orchestration (Kubernetes)
The deployment utilizes **Node Affinity** to ensure workload isolation:
- **Rule:** `requiredDuringSchedulingIgnoredDuringExecution`
- **Constraint:** Pods are strictly scheduled on nodes where the label `color` is `blue`.
- **Self-Healing:** Configured 3 replicas to ensure high availability.

### 4. Identity & "Secretless" Security
A key engineering decision was to move away from static secrets.
* **Identity-Based Access:** Unlike traditional setups that use Storage Account Keys or Key Vault secrets, this project utilizes **Azure Managed Identity**.
* **RBAC Enforcement:** Access to the Terraform State is governed by the `Storage Blob Data Owner` role.
* **The Benefit:** This eliminates the "Secret Lifecycle" problem. There are no keys to rotate, no passwords in the code, and no risk of credential leakage in the GitHub repository.

## Troubleshooting & Engineering Decisions

During the lifecycle of this project, several real-world cloud constraints were identified and resolved:

| Issue | Resolution |
| :--- | :--- |
| **SKU Quota Restriction** | Encountered 400 Bad Request in `eastus`. Analyzed error metadata to identify allowed SKUs and performed a **Regional Pivot** to `eastus2`. |
| **AAD Location Mismatch** | Encountered `AlreadyExistServicePrincipalInDifferentRegion`. Resolved by performing a **Naming Rotation** (`aks-v2`) to clear the AAD identity cache. |
| **YAML Parsing Error** | Identified indentation and schema errors in the `affinity` block. Resolved by validating the Pod Spec hierarchy and using `kubectl --dry-run`. |
| **Auth Error (403)** | Resolved storage access issues by assigning the `Storage Blob Data Owner` role to the signed-in identity. |

## Deployment Commands

### Provisioning
```bash
terraform init
terraform plan -out=tfplan
terraform apply "tfplan"
```

### Connection & Deployment
```bash
az aks get-credentials --resource-group aks-v2-rg --name aks-v2-cluster
kubectl apply -f deployment-definition.yml
```

### Verification
```bash
kubectl get nodes --show-labels
kubectl get pods -o wide
kubectl get service mygame2048-svc
```

## Results
The application is accessible at the Public VIP: **20.22.167.40**.
The deployment successfully demonstrated:
1. **Immutable Infrastructure** deployment via Terraform.
2. **Dynamic Scaling** and self-healing of pod replicas.
3. **Advanced Scheduling** via Node Affinity.

---
*Created as part of a transition from Technical Support to Cloud Engineering, focusing on end-to-end ownership of cloud-native environments.*
