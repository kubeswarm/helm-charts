<p align="center">
  <img src="https://assets.kubeswarm.io/logo.svg" width="200" alt="kubeswarm">
</p>

<h3 align="center">kubeswarm - helm charts</h3>

<p align="center">
  <a href="https://github.com/kubeswarm/helm-charts/actions/workflows/lint.yml"><img src="https://github.com/kubeswarm/helm-charts/actions/workflows/lint.yml/badge.svg" alt="CI"></a>
  <a href="https://artifacthub.io/packages/search?repo=kubeswarm"><img src="https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/kubeswarm" alt="Artifact Hub"></a>
  <a href="./LICENSE"><img src="https://img.shields.io/badge/license-Apache%202.0-blue.svg" alt="License"></a>
</p>

Helm charts for [kubeswarm](https://github.com/kubeswarm/kubeswarm) - AI agents as Kubernetes-native resources.

Full documentation at **[docs.kubeswarm.io](https://docs.kubeswarm.io)**.

## Prerequisites

- Kubernetes 1.35+
- Helm 3.16+

## Add the repo

```bash
helm repo add kubeswarm https://kubeswarm.github.io/helm-charts
helm repo update
```

## Charts

| Chart | Description | Docs |
|---|---|---|
| [kubeswarm](charts/kubeswarm/) | Kubernetes operator for running AI agents in production | [charts/kubeswarm/README.md](charts/kubeswarm/README.md) |

Installation, values reference, CRD list, and production checklist live in the chart README: [charts/kubeswarm/README.md](charts/kubeswarm/README.md). That is also what [Artifact Hub](https://artifacthub.io/packages/search?repo=kubeswarm) renders on the chart landing page.

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md).

## Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](./CODE_OF_CONDUCT.md).

## License

Apache 2.0 - see [LICENSE](LICENSE).
