# 🚀 GitOps Workload Applications & Multi-Environment Manifests

[![Kubernetes](https://img.shields.io/badge/Kubernetes-Workloads-blue?logo=kubernetes)](https://kubernetes.io/)
[![Argo CD](https://img.shields.io/badge/Argo_CD-Managed-orange?logo=argo)](https://argo-cd.readthedocs.io/)
[![Gateway API](https://img.shields.io/badge/Gateway_API-HTTPRoute-326CE5?logo=kubernetes)](https://gateway-api.sigs.k8s.io/)

This repository (**`erchetansoni/gitops-argocd-apps`**) is the application delivery repository watched by Argo CD. It contains application microservice Helm charts, Kubernetes manifests, and environment-specific overlays (`main`, `dev`, etc.).

Cluster infrastructure, ingress, Gateway API controller, and Argo CD itself are managed in the companion repository:  
👉 **[`erchetansoni/gitops-argocd-infra`](https://github.com/erchetansoni/gitops-argocd-infra)**

---

## 📂 Repository Layout

```
gitops-argocd-apps/
├── apps/                         # Base application definitions & Helm charts
│   ├── app1/                     # Full-featured microservice Helm chart
│   ├── app2/                     # go-httpbin testing service
│   ├── app3/                     # Whoami / demo request echo service
│   └── README.md                 # Detailed documentation on apps
│
├── environments/                 # Per-environment deployment overlays
│   ├── main/                     # Production / Main environment overlays
│   │   ├── app1/                 # Kustomize overlay for app1 (app1.chetan.local)
│   │   ├── app2/                 # Kustomize overlay for app2 (app2.chetan.local)
│   │   └── app3/                 # Kustomize overlay for app3 (app3.chetan.local)
│   │
│   ├── dev/                      # Development branch environment overlays
│   │   ├── app1/                 # Kustomize overlay for app1 (app1.dev.chetan.local)
│   │   ├── app2/                 # Kustomize overlay for app2 (app2.dev.chetan.local)
│   │   └── app3/                 # Kustomize overlay for app3 (app3.dev.chetan.local)
│   │
│   └── README.md                 # Guide to environments and overlays
└── README.md                     # Root documentation
```

---

## 🛠️ Applications Overview

| Application | Technology | Purpose | Subdomain (Main) | Subdomain (Dev) |
| :--- | :--- | :--- | :--- | :--- |
| **`app1`** | Helm Chart | Sample demo web application with ConfigMap and environment configuration | `https://app1.chetan.local` | `https://app1.dev.chetan.local` |
| **`app2`** | Raw Manifests | HTTP Request & Response Service (`mccutchen/go-httpbin`) | `https://app2.chetan.local` | `https://app2.dev.chetan.local` |
| **`app3`** | Raw Manifests | Echo & Container Inspection Service (`traefik/whoami` / `kuar`) | `https://app3.chetan.local` | `https://app3.dev.chetan.local` |

---

## ⚙️ How Argo CD Syncs This Repository

The root **ApplicationSet** (`branch-environments`) running in the infrastructure cluster watches this repository using a **Matrix Generator**:

$$\text{Environments (environments/*)} \times \text{Apps (app1, app2, app3)}$$

1. **Auto-Discovery**:
   Whenever a new environment directory is added (e.g. `environments/dev`), Argo CD automatically detects it.
2. **Namespace Isolation**:
   Apps in `environments/main/` deploy to the `main` namespace. Apps in `environments/dev/` deploy to the `dev` namespace.
3. **Gateway Routing**:
   Each application exposes an `HTTPRoute` attached to `main-gateway`. Traefik routes traffic according to the hostnames:
   * **Main Environment**: `*.chetan.local` (e.g., `app1.chetan.local`)
   * **Branch Environments**: `*.<branch>.chetan.local` (e.g., `app1.dev.chetan.local`)

---

## ➕ How to Add a New Environment (e.g. `staging`)

To spin up a complete set of applications for a new branch or stage:

1. Create a new folder inside `environments/`:
   ```bash
   cp -r environments/dev environments/staging
   ```
2. Update the hostnames in the `kustomization.yaml` or `values.yaml` files inside `environments/staging/*/`:
   * Change `*.dev.chetan.local` to `*.staging.chetan.local`.
3. Commit and push:
   ```bash
   git add environments/staging
   git commit -m "feat: add staging environment"
   git push origin main
   ```
4. **Argo CD automatically discovers `environments/staging/`**, creates the `staging` namespace, and deploys `staging-app1`, `staging-app2`, and `staging-app3`!

---

## 🤝 Companion Repository

For the Kubernetes cluster provisioning, Traefik Gateway API Controller, and Argo CD platform manifests, see:  
👉 **[`erchetansoni/gitops-argocd-infra`](https://github.com/erchetansoni/gitops-argocd-infra)**
