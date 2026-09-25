# app3 (raw manifests)

Plain Kubernetes manifests for [`traefik/whoami`](https://github.com/traefik/whoami) — same shape as [`app2/`](../app2/). Wrapped in a `kustomization.yaml` so the per-env kustomization can include this directory as a resource and patch the HTTPRoute host.

Used by ArgoCD Applications named `<branch>-app3`.

## Layout

```
app3/
├── kustomization.yaml
├── deployment.yaml
├── service.yaml
└── httproute.yaml          # Gateway API HTTPRoute (default host: app3.chetan.local)
```

See [`apps/app2/README.md`](../app2/README.md) for editing notes — the rules are identical.
