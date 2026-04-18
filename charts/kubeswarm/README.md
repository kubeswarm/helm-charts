# kubeswarm

Kubernetes operator that manages LLM agents as first-class resources. Define agents in YAML, connect MCP tools, compose multi-agent pipelines, and deploy with `kubectl apply`.

**No vendor lock-in.** Swap any LLM provider, queue backend, vector store, or artifact storage. The operator bundles nothing - bring your own infrastructure.

**Security enforced by default.** Non-root pods, read-only filesystem, tool allow/deny lists, MCP auth at admission. Not optional.

**Hard budget enforcement.** Token limits with hard stops. Tasks rejected, not warned.

## Install

```bash
helm repo add kubeswarm https://kubeswarm.github.io/helm-charts
helm repo update

helm install kubeswarm kubeswarm/kubeswarm \
  --namespace kubeswarm-system --create-namespace \
  --set taskQueueURL=redis://my-redis:6379
```

## Configure API keys

```bash
kubectl create secret generic my-llm-keys \
  --namespace kubeswarm-system \
  --from-literal=ANTHROPIC_API_KEY=sk-ant-...

helm upgrade kubeswarm kubeswarm/kubeswarm \
  --namespace kubeswarm-system \
  --set apiKeys.existingSecret=my-llm-keys \
  --set taskQueueURL=redis://my-redis:6379
```

## Values

| Value | Default | Description |
|---|---|---|
| `taskQueueURL` | `""` | Task queue URL (**required**) e.g. `redis://my-redis:6379` |
| `image.repository` | `ghcr.io/kubeswarm/kubeswarm-controller` | Controller image |
| `image.tag` | _(chart appVersion)_ | Controller image tag |
| `agentImage` | `ghcr.io/kubeswarm/kubeswarm-runtime` | Agent runtime image |
| `agentImagePullPolicy` | `Always` | Pull policy for agent pods |
| `apiKeys.existingSecret` | `""` | Existing Secret with LLM API keys |
| `apiKeys.anthropicApiKey` | `""` | Anthropic API key (use `existingSecret` instead) |
| `apiKeys.openaiApiKey` | `""` | OpenAI API key (use `existingSecret` instead) |
| `replicaCount` | `1` | Controller replicas (>1 requires leader election) |
| `leaderElection.enabled` | `true` | Leader election for HA |
| `streamChannelURL` | `""` | SSE token streaming URL (defaults to `taskQueueURL`) |
| `spendStoreURL` | `""` | Spend tracking URL (defaults to `taskQueueURL`) |
| `triggerWebhook.url` | `""` | External URL for SwarmEvent webhooks |
| `admissionWebhooks.enabled` | `false` | Enable validating admission webhooks |
| `otel.endpoint` | `""` | OTLP collector endpoint |
| `agentExtraEnv` | `[]` | Extra env vars for all agent pods |
| `crds.install` | `true` | Install and upgrade CRDs with the chart. Set `false` when managing CRDs via GitOps |

## CRDs installed

| CRD | Description |
|---|---|
| SwarmAgent | LLM agent with model, tools, guardrails, and autoscaling |
| SwarmTeam | Multi-agent pipeline (DAG, sequential, or LLM-routed) |
| SwarmRun | Single execution of a pipeline with full audit trail |
| SwarmBudget | Token spend limits with hard-stop enforcement |
| SwarmEvent | Cron, webhook, and chain triggers |
| SwarmRegistry | Agent capability discovery and routing |
| SwarmMemory | Vector memory store reference (pgvector, Qdrant) |
| SwarmSettings | Namespace-level defaults for config and policy |
| SwarmNotify | Notification channels (Slack, webhook) |
| SwarmPolicy | Platform-level guardrails enforced on all SwarmAgents in a namespace |

## Production checklist

- Use `apiKeys.existingSecret` - never pass keys via `--set`
- Set `taskQueueURL` to a managed Redis (ElastiCache, Memorystore, etc.)
- Set `replicaCount=2` with `leaderElection.enabled=true`
- Configure `otel.endpoint` for observability
- Set `triggerWebhook.url` for external event triggers

## Documentation

Full documentation at [docs.kubeswarm.io](https://docs.kubeswarm.io).

## License

Apache 2.0
