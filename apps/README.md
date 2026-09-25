# apps/

The application source code and manifests deployed to Kubernetes via Argo CD and Kubernetes Gateway API (`HTTPRoute`).

## Contents

| Folder | Type | Gateway API / Manifest Details |
|---|---|---|
| [app1/](app1/) | Helm chart | Deployment + ClusterIP Service + Gateway API `HTTPRoute` (`main-gateway`) + ConfigMaps + ExternalSecrets via ESO |
| [app2/](app2/) | Raw Kubernetes manifests | `deployment.yaml` + `service.yaml` + `httproute.yaml` + `kustomization.yaml` (`mccutchen/go-httpbin`) |
| [app3/](app3/) | Raw Kubernetes manifests | `deployment.yaml` + `service.yaml` + `httproute.yaml` + `kustomization.yaml` (`traefik/whoami`) |

## Routing Architecture (Kubernetes Gateway API)

All apps are exposed through Traefik Gateway Controller using Kubernetes Gateway API `HTTPRoute` resources attached to the cluster `main-gateway` in namespace `default`:

- **Gateway:** `main-gateway` in namespace `default`
- **Gateway Class:** `traefik`
- **Domain Pattern:** `*.chetan.local` (HTTPS terminate via `domain-certificate-tls-secret` and HTTP on port 80)
- **App Routes:**
  - `app1.<branch>.chetan.local` (or `app1.chetan.local` for `main`)
  - `app2.<branch>.chetan.local` (or `app2.chetan.local` for `main`)
  - `app3.<branch>.chetan.local` (or `app3.chetan.local` for `main`)

## How they're consumed

For each branch/environment, CI generates one `kustomization.yaml` per app at `environments/<branch>/<app>/` in this repo:

```
environments/<branch>/app1/kustomization.yaml
  └── helmGlobals.chartHome: ../../../apps  →  apps/app1/

environments/<branch>/app2/kustomization.yaml
  └── resources: ../../../apps/app2         →  apps/app2/

environments/<branch>/app3/kustomization.yaml
  └── resources: ../../../apps/app3         →  apps/app3/
```