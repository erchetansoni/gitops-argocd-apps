# .github/

CI for this repository. Two workflows handle the entire branch → environment lifecycle:

| Workflow | Trigger | What it does |
|---|---|---|
| [workflows/deploy.yml](workflows/deploy.yml) | `push` to any branch | Render an env folder for the branch with Gateway API HTTPRoutes and commit it to `main` |
| [workflows/cleanup.yml](workflows/cleanup.yml) | `delete` branch event | Remove that env's folder from `main` |

Together they implement: *push branch → env appears, delete branch → env disappears*. ArgoCD's root ApplicationSet does the rest.

## Files

```
.github/
├── workflows/
│   ├── deploy.yml          # on push: render + commit + push
│   └── cleanup.yml         # on delete: rm folder + commit + push
├── scripts/
│   └── render-env.sh       # envsubst over .tpl files; writes to environments/<branch>/
└── templates/
    ├── app1/
    │   ├── kustomization.yaml.tpl   # references chart directly (chartHome: ../../../apps)
    │   └── values.yaml.tpl          # per-env Helm values with HTTPRoute
    ├── app2/kustomization.yaml.tpl  # raw manifests + HTTPRoute host patch
    └── app3/kustomization.yaml.tpl  # raw manifests + HTTPRoute host patch
```

## Required GitHub Actions secret

| Secret | Scope | Why |
|---|---|---|
| `GITOPS_TOKEN` | `Contents: Read & Write` on `erchetansoni/test` | The deploy and cleanup workflows commit to the `main` branch |

Set under repository **Settings → Secrets and variables → Actions → Repository secrets**.

## Branch validation

Both workflows skip any branch name containing `/` (so `feature/foo`, `bug/x`, `hotfix/y` never trigger anything). `cleanup.yml` additionally refuses to wipe `environments/main` from a delete event as a safety guard.

## Render flow (deploy.yml)

```
1. Resolve branch (skip if contains '/')
2. Map: branch → environment, namespace, host_prefix
3. Checkout source repo branch (templates + apps)
4. Checkout GitOps repo main branch (token: GITOPS_TOKEN)
5. render-env.sh: envsubst .tpl files → environments/<branch>/
6. Commit and push to main, message: "ci(<branch>): sync from <sha> [skip ci]"
```
