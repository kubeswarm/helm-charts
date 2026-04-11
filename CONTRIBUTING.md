# Contributing to kubeswarm Helm Charts

Thank you for your interest in contributing. This document covers how to work on the Helm charts, validate changes and submit a PR.

## Before you start

- **Open an issue first** for any non-trivial change (new chart, new value, breaking default change). Bug fixes and docs can go straight to a PR.

## Prerequisites

| Tool         | Version  |
|--------------|----------|
| Helm         | 3.15+    |
| helm-docs    | 1.14+    |
| ct (chart-testing) | 3.11+ |

```bash
brew install helm helm-docs chart-testing
```

## Repository layout

```
charts/
  kubeswarm/
    Chart.yaml        # Chart metadata and version
    values.yaml       # Default values - the source of truth
    values.local.yaml # Local/kind overrides (not shipped)
    templates/        # Kubernetes manifests (Go templates)
    README.md         # Generated - do not edit directly
```

## Making changes

### Adding or changing a value

1. Add the field to `values.yaml` with a sensible default and an inline comment explaining what it does.
2. Use the value in the relevant template file under `templates/`.
3. If the value controls a new resource, create a new template file (e.g., `templates/myresource.yaml`) rather than adding to an existing one.
4. Update `README.md`'s values table manually if `helm-docs` is not generating it automatically.

### Adding a template

- Wrap optional resources in `{{- if .Values.featureFlag }}` so they are off by default.
- Use `{{ include "kubeswarm.fullname" . }}` for resource names - never hardcode.
- Labels must include the standard `helm.sh/chart`, `app.kubernetes.io/name`, `app.kubernetes.io/instance` and `app.kubernetes.io/managed-by` labels (already in `_helpers.tpl`).

### Bumping the chart version

- Bump `version` in `Chart.yaml` for any change to templates or default values.
- Bump `appVersion` only when the default operator image tag changes.
- Follow [Semantic Versioning](https://semver.org/): breaking default changes → major, new opt-in features → minor, bug fixes → patch.

## Validating changes

```bash
# Lint the chart
helm lint charts/kubeswarm

# Lint with non-default values
helm lint charts/kubeswarm -f charts/kubeswarm/values.local.yaml

# Render templates locally (dry-run)
helm template kubeswarm charts/kubeswarm --namespace kubeswarm-system

# Run chart-testing lint (validates schema, version bump, etc.)
ct lint --charts charts/kubeswarm
```

## Security practices

- **No secrets in `values.yaml` defaults** - default values for `apiKeys.anthropicApiKey`, `apiKeys.openaiApiKey` and similar fields must be empty string (`""`). Never ship a non-empty key default.
- **Prefer `existingSecret`** - the recommended production path is `apiKeys.existingSecret`; document this clearly in any values that accept keys inline.
- **No `latest` image tags in defaults** - `image.tag` and `agentImage` must reference a pinned version tag (e.g., `0.1.0`), never `latest`.
- **RBAC least privilege** - ClusterRole and Role rules must grant only the verbs and resources actually required. Do not use `*` wildcards.
- **No `hostPath` or `hostNetwork`** - templates must not expose host filesystem paths or host networking unless there is an explicit, documented reason and it is disabled by default.
- **Validate with `helm lint`** before every commit - CI blocks on lint failures.

## Branch naming

Name your branch with one of these prefixes - a GitHub Action will automatically label the PR:

| Prefix | Label | Example |
| --- | --- | --- |
| `feat/` | `feat` | `feat/add-networkpolicy-toggle` |
| `fix/` | `bug` | `fix/redis-pvc-size-default` |
| `docs/` | `docs` | `docs/update-values-table` |
| `chore/` | `chore` | `chore/bump-operator-version` |

## Commit messages

Use [Conventional Commits](https://www.conventionalcommits.org/). The prefix must match the branch prefix:

```
<type>: <short description>
```

Allowed types: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`, `ci`

Keep the first line under 72 characters. Add a body for non-obvious changes.

## Submitting a pull request

1. Fork the repo and create a branch from `main` using the naming convention above.
2. Make your changes and validate with `helm lint` and `helm template`.
3. Bump `version` in `Chart.yaml` (required - CI checks this).
4. Open a PR against `main` with a description of what changed and why.

We use **Rebase and merge** to keep a linear history on `main`.

## Reporting bugs

Open a [GitHub issue](https://github.com/kubeswarm/helm-charts/issues/new) with:

- Chart version (`helm list -n kubeswarm-system`)
- Kubernetes version (`kubectl version`)
- The `helm install` / `helm upgrade` command used (redact any `--set apiKeys.*` values)
- Relevant pod events or logs

## Security vulnerabilities

Please do **not** open a public issue for security vulnerabilities. Email the maintainers directly (see the repository's security policy).

## License

By contributing, you agree that your contributions will be licensed under the [Apache 2.0 License](./LICENSE).
