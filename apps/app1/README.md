# app1 (Helm chart)

A production-style Helm chart demonstrating:

- A Deployment + Service + Gateway API `HTTPRoute` for a stateless app (kuard).
- Two ConfigMaps (env-style and file-style).
- Two `ExternalSecret` resources that pull from AWS Secrets Manager via ESO + a cluster-wide `ClusterSecretStore` named `aws-secretsmanager`.

Used by ArgoCD Applications named `<branch>-app1` (one per environment). Each Application reads `environments/<branch>/app1/values.yaml` and renders this chart with those values into namespace `<branch>`.

## Layout

```
app1/
├── Chart.yaml
├── values.yaml                          # default values (overridden per env)
└── templates/
    ├── deployment.yaml
    ├── service.yaml
    ├── httproute.yaml                   # Gateway API HTTPRoute (parentRef: main-gateway)
    ├── configmap-env.yaml
    ├── configmap-file.yaml
    └── external-secrets/
        ├── external-secret-env.yaml     # references ClusterSecretStore: aws-secretsmanager
        └── external-secret-file.yaml
```

## Gateway API Routing

The app is exposed using Kubernetes Gateway API (`gateway.networking.k8s.io/v1` `HTTPRoute`).
Traffic is routed via Traefik Gateway `main-gateway` located in the `default` namespace.

## Per-env values

Per-environment values are written to `environments/<branch>/app1/values.yaml` by CI ([.github/templates/app1/values.yaml.tpl](../../.github/templates/app1/values.yaml.tpl)). The values that vary per env are:

- `httproute.host` → `app1.<branch>.chetan.local` (or `app1.chetan.local` for `main`)
- `configEnv.ENVIRONMENT` / `configEnv.BRANCH` → derived from branch name
