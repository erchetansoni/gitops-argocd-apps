# environments/

This directory contains the **per-environment Kustomize overlays** deployed by Argo CD's matrix ApplicationSet.

---

## Architecture

```
environments/
├── main/                         # Production / Main environment (Namespace: main)
│   ├── app1/                     # Inflates apps/app1 Helm chart with main values.yaml
│   ├── app2/                     # Patches apps/app2 with hostname: app2.chetan.local
│   └── app3/                     # Patches apps/app3 with hostname: app3.chetan.local
│
├── dev/                          # Development environment (Namespace: dev)
│   ├── app1/                     # Inflates apps/app1 Helm chart with dev values.yaml
│   ├── app2/                     # Patches apps/app2 with hostname: app2.dev.chetan.local
│   └── app3/                     # Patches apps/app3 with hostname: app3.dev.chetan.local
└── README.md                     # Documentation
```

---

## How Each Application Is Configured

### 1. `app1` (Helm Chart Overlay)
`app1` uses Kustomize's native Helm inflation feature:
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: main

helmGlobals:
  chartHome: ../../../apps

helmCharts:
  - name: app1
    releaseName: app1
    valuesFile: values.yaml
    namespace: main
```
Environment-specific settings (such as `httproute.host`, replica count, and configuration) are declared cleanly in that environment's local `values.yaml`.

### 2. `app2` & `app3` (Raw Manifest Overlays with Patches)
`app2` and `app3` reference base manifests in `../../../apps/` and use standard JSON 6902 patches to customize the Gateway API `HTTPRoute` hostname for that environment:
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: dev

resources:
  - ../../../apps/app2

patches:
  - target:
      group: gateway.networking.k8s.io
      version: v1
      kind: HTTPRoute
      name: app2-httproute
    patch: |-
      - op: replace
        path: /spec/hostnames/0
        value: app2.dev.chetan.local
```

---

## Environment Subdomain Standard

| Environment | Subdomain Pattern | Example | TLS Certificate SAN |
| :--- | :--- | :--- | :--- |
| **`main`** | `<app>.chetan.local` | `app1.chetan.local` | `*.chetan.local` |
| **`dev`** | `<app>.dev.chetan.local` | `app1.dev.chetan.local` | `*.dev.chetan.local` |
| **`staging`** | `<app>.staging.chetan.local` | `app1.staging.chetan.local` | `*.staging.chetan.local` |
| **`test`** | `<app>.test.chetan.local` | `app1.test.chetan.local` | `*.test.chetan.local` |
