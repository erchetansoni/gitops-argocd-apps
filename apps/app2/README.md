# app2 (raw manifests)

Plain Kubernetes manifests — Deployment + Service + Gateway API `HTTPRoute` for [`mccutchen/go-httpbin`](https://github.com/mccutchen/go-httpbin), wrapped in a `kustomization.yaml` so other kustomizations can reference this directory.

Used by ArgoCD Applications named `<branch>-app2`. The per-env kustomization at `environments/<branch>/app2/`:

1. Pulls these manifests in via `resources: ../../../apps/app2`.
2. Sets the namespace.
3. Patches the HTTPRoute host: `app2.chetan.local` → `app2.<branch>.chetan.local`.

## Layout

```
app2/
├── kustomization.yaml      # required so this dir can appear as a `resources:` entry
├── deployment.yaml
├── service.yaml
└── httproute.yaml          # Gateway API HTTPRoute (default host app2.chetan.local; per-env host patched via Kustomize)
```

## Editing rules

Edit any of the manifests freely. The default `app2.chetan.local` host stays here — env-specific hosts come from the kustomization patch in [.github/templates/app2/kustomization.yaml.tpl](../../.github/templates/app2/kustomization.yaml.tpl).
