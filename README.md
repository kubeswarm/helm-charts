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

| Chart | Description |
|---|---|
| [kubeswarm](charts/kubeswarm/) | Kubernetes operator for running AI agents in production |

## Quick install

```bash
# 1. Install the operator (no API key required)
helm install kubeswarm kubeswarm/kubeswarm \
  --namespace kubeswarm-system --create-namespace

# 2. Add your LLM API key via a Kubernetes Secret
kubectl create secret generic my-kubeswarm-secrets \
  --namespace kubeswarm-system \
  --from-literal=ANTHROPIC_API_KEY=sk-ant-...
# or for OpenAI / compatible endpoint (Ollama, vLLM, etc.):
kubectl create secret generic my-kubeswarm-secrets \
  --namespace kubeswarm-system \
  --from-literal=OPENAI_API_KEY=sk-... \
  --from-literal=OPENAI_BASE_URL=http://ollama.ollama.svc:11434/v1

# 3. Point the chart at the secret
helm upgrade kubeswarm kubeswarm/kubeswarm \
  --namespace kubeswarm-system \
  --set apiKeys.existingSecret=my-kubeswarm-secrets
```

## Key values - kubeswarm

| Value | Default | Description |
|---|---|---|
| `replicaCount` | `1` | Number of operator replicas (>1 requires `leaderElection.enabled=true`) |
| `image.repository` | `ghcr.io/kubeswarm/kubeswarm-controller` | Operator image |
| `image.tag` | _(chart appVersion)_ | Operator image tag |
| `agentImage` | `ghcr.io/kubeswarm/kubeswarm-runtime:0.1.0-alpha.2` | Agent pod image |
| `agentImagePullPolicy` | `Always` | Pull policy for agent pods |
| `taskQueueURL` | `""` | Task queue URL (**required** - e.g. `redis://my-redis:6379`) |
| `streamChannelURL` | `""` | Redis URL for SSE token streaming (defaults to `taskQueueURL`) |
| `spendStoreURL` | `""` | Redis URL for spend tracking (defaults to `taskQueueURL`) |
| `apiKeys.anthropicApiKey` | `""` | Anthropic API key (injected into all agent pods) |
| `apiKeys.openaiApiKey` | `""` | OpenAI API key (injected into all agent pods) |
| `apiKeys.existingSecret` | `""` | Use an existing Secret instead of creating one |
| `agentExtraEnv` | `[]` | Extra env vars forwarded to all agent pods |
| `dashboard.enabled` | `false` | Deploy the dashboard web UI |
| `dashboard.image` | `ghcr.io/kubeswarm/dashboard:0.1.0` | Dashboard image |
| `leaderElection.enabled` | `true` | Enable leader election (required for `replicaCount>1`) |
| `triggerWebhook.url` | `""` | External URL of the SwarmEvent webhook server |
| `admissionWebhooks.enabled` | `false` | Enable validating webhooks for inline prompt size guardrails |
| `otel.endpoint` | `""` | OTLP collector endpoint for metrics and traces |
| `keda.enabled` | `false` | Document that KEDA is installed (operator detects at runtime) |

Full values reference: [charts/kubeswarm/values.yaml](./charts/kubeswarm/values.yaml)

## Production checklist

- Always use `apiKeys.existingSecret` - never pass API keys via `--set`
- Set `taskQueueURL` to a managed Redis (ElastiCache, Memorystore, etc.)
- Set `replicaCount=2` with `leaderElection.enabled=true`
- Set `triggerWebhook.url` to an externally reachable URL for `SwarmEvent` webhooks
- Configure `otel.endpoint` for observability

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md).

## Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](./CODE_OF_CONDUCT.md).

## License

Apache 2.0 - see [LICENSE](LICENSE).
