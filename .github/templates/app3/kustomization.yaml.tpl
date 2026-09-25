apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: ${NAMESPACE}

resources:
  - ../../../apps/app3

patches:
  - target:
      group: gateway.networking.k8s.io
      version: v1
      kind: HTTPRoute
      name: app3-httproute
    patch: |-
      - op: replace
        path: /spec/hostnames/0
        value: ${APP3_HOST}

labels:
  - includeSelectors: false
    pairs:
      app: app3
      environment: ${ENVIRONMENT}
      branch: ${BRANCH}
