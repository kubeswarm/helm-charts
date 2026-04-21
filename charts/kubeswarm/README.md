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

API keys are configured per-agent via `spec.infrastructure.apiKeyRef`, not through Helm values.
Create a Secret with your LLM provider keys and reference it in your SwarmAgent:

```bash
kubectl create secret generic llm-api-keys \
  --namespace default \
  --from-literal=ANTHROPIC_API_KEY=sk-ant-...
```

```yaml
apiVersion: kubeswarm.io/v1alpha1
kind: SwarmAgent
metadata:
  name: my-agent
spec:
  model: claude-sonnet-4-20250514
  prompt:
    inline: "You are a helpful assistant."
  infrastructure:
    apiKeyRef:
      name: llm-api-keys
      key: ANTHROPIC_API_KEY
```

To inject environment variables into all agent pods cluster-wide (e.g. for Ollama), use `agentExtraEnv` in Helm values.

## Values

### Core

| Value | Default | Description |
|---|---|---|
| `taskQueueURL` | `""` | Task queue URL (**required**) e.g. `redis://my-redis:6379` |
| `streamChannelURL` | `""` | SSE token streaming URL (defaults to `taskQueueURL`) |
| `spendStoreURL` | `""` | Spend tracking URL (defaults to `taskQueueURL`) |
| `costConfigmap` | `""` | ConfigMap with custom per-model pricing |

### Operator

| Value | Default | Description |
|---|---|---|
| `image.repository` | `ghcr.io/kubeswarm/kubeswarm-controller` | Controller image |
| `image.tag` | _(chart appVersion)_ | Controller image tag |
| `image.pullPolicy` | `IfNotPresent` | Controller image pull policy |
| `imagePullSecrets` | `[]` | Pull secrets for operator image |
| `replicaCount` | `1` | Controller replicas (>1 requires leader election) |
| `leaderElection.enabled` | `true` | Leader election for HA |
| `logLevel` | `""` | Operator log verbosity: debug, info, warn, error |
| `logEncoder` | `""` | Log encoder: console, json |
| `strategy` | `{}` | Deployment strategy (default: RollingUpdate) |
| `revisionHistoryLimit` | `10` | Old ReplicaSets to retain for rollback |

### Agent runtime

| Value | Default | Description |
|---|---|---|
| `agentImage` | `ghcr.io/kubeswarm/kubeswarm-runtime:0.2.0-beta.1` | Agent runtime image |
| `agentImagePullPolicy` | `Always` | Pull policy for agent pods |
| `agentImagePullSecrets` | `""` | Comma-separated pull secret names for agent pods |
| `agentExtraEnv` | `[]` | Extra env vars injected into every agent pod |

### Dashboard

| Value | Default | Description |
|---|---|---|
| `dashboard.enabled` | `false` | Enable the real-time web UI |
| `dashboard.image` | `ghcr.io/kubeswarm/dashboard:0.1.0` | Dashboard image |
| `dashboard.replicaCount` | `1` | Dashboard replicas |
| `dashboard.service.type` | `ClusterIP` | Dashboard service type |
| `dashboard.service.port` | `8090` | Dashboard service port |
| `dashboard.ingress.enabled` | `false` | Enable ingress for external access |

### Webhooks and gateway

| Value | Default | Description |
|---|---|---|
| `triggerWebhook.addr` | `":8092"` | SwarmEvent webhook listen address |
| `triggerWebhook.url` | `""` | External URL for SwarmEvent webhooks |
| `mcpGateway.addr` | `":8093"` | MCP SSE gateway listen address |
| `mcpGateway.url` | `""` | External URL of the MCP gateway |
| `admissionWebhooks.enabled` | `false` | Enable validating admission webhooks |
| `admissionWebhooks.certSecret` | `""` | TLS cert Secret for admission webhooks |
| `admissionWebhooks.caBundle` | `""` | Base64-encoded CA bundle for API server |
| `admissionWebhooks.failurePolicy` | `Ignore` | Failure policy: Ignore or Fail |

### Audit trail

| Value | Default | Description |
|---|---|---|
| `auditLog.mode` | `"off"` | Audit verbosity: off, actions, verbose |
| `auditLog.sink` | `stdout` | Output backend: stdout, redis, webhook |
| `auditLog.redisURL` | `""` | Redis URL (required when sink=redis) |
| `auditLog.webhookURL` | `""` | Webhook URL (required when sink=webhook) |
| `auditLog.maxStreamLen` | `100000` | Max Redis stream entries per namespace |
| `auditLog.maxDetailBytes` | `8192` | Max size for detail fields before truncation |
| `auditLog.redact` | _(see values.yaml)_ | Glob patterns for field redaction |

### Observability

| Value | Default | Description |
|---|---|---|
| `otel.endpoint` | `""` | OTLP collector endpoint |
| `metrics.enabled` | `false` | Expose /metrics on port 8080 |
| `metrics.port` | `8080` | Metrics port |
| `serviceMonitor.enabled` | `false` | Create Prometheus ServiceMonitor |
| `serviceMonitor.interval` | `30s` | Scrape interval |

### Networking

| Value | Default | Description |
|---|---|---|
| `service.type` | `ClusterIP` | Operator service type |
| `service.port` | `8092` | Operator service port |
| `networkPolicy.enabled` | `false` | Enable NetworkPolicy for operator pod |

### CRDs

| Value | Default | Description |
|---|---|---|
| `crds.install` | `true` | Install and upgrade CRDs with the chart. Set `false` for GitOps |

### Pod configuration

| Value | Default | Description |
|---|---|---|
| `resources.requests.cpu` | `10m` | Operator CPU request |
| `resources.requests.memory` | `64Mi` | Operator memory request |
| `resources.limits.cpu` | `500m` | Operator CPU limit |
| `resources.limits.memory` | `128Mi` | Operator memory limit |
| `goMemLimit` | `""` | GOMEMLIMIT for the operator Go runtime |
| `podSecurityContext.runAsNonRoot` | `true` | Run as non-root user |
| `nodeSelector` | `{}` | Node selector |
| `tolerations` | `[]` | Tolerations |
| `affinity` | `{}` | Affinity rules |
| `priorityClassName` | `""` | Priority class for operator pod |
| `podDisruptionBudget.enabled` | `false` | Enable PDB (meaningful when replicas > 1) |
| `topologySpreadConstraints` | `[]` | Topology spread for multi-replica |
| `extraEnv` | `[]` | Extra env vars for operator pod |
| `extraEnvFrom` | `[]` | Mount env vars from ConfigMaps or Secrets |
| `extraVolumes` | `[]` | Additional volumes for operator pod |
| `extraVolumeMounts` | `[]` | Additional volume mounts for operator pod |

### KEDA

| Value | Default | Description |
|---|---|---|
| `keda.enabled` | `false` | Informational: KEDA expected in cluster. Operator detects KEDA at runtime |

## CRDs installed

| CRD | Description |
|---|---|
| SwarmAgent | LLM agent with model, tools, guardrails, and autoscaling |
| SwarmTeam | Multi-agent team with three modes: pipeline (DAG), dynamic (delegate), or routed (LLM dispatch) |
| SwarmRun | Single execution of a pipeline with full audit trail |
| SwarmBudget | Token spend limits with hard-stop enforcement |
| SwarmEvent | Cron, webhook, and chain triggers |
| SwarmRegistry | Agent capability discovery and routing |
| SwarmMemory | Vector memory store reference (pgvector, Qdrant) |
| SwarmSettings | Namespace-level defaults for config and policy |
| SwarmNotify | Notification channels (Slack, webhook) |
| SwarmPolicy | Platform-level guardrails enforced on all SwarmAgents in a namespace |

## Production checklist

- Configure `taskQueueURL` to a managed Redis (ElastiCache, Memorystore, etc.)
- Create API key Secrets per namespace and reference via `spec.infrastructure.apiKeyRef`
- Set `replicaCount=2` with `leaderElection.enabled=true`
- Configure `otel.endpoint` for observability
- Set `triggerWebhook.url` for external event triggers
- Enable `admissionWebhooks` for prompt-size guardrails
- Enable `metrics` and `serviceMonitor` for Prometheus monitoring
- Set `auditLog.mode=actions` with a dedicated Redis sink for compliance

## Documentation

Full documentation at [docs.kubeswarm.io](https://docs.kubeswarm.io).

## License

Apache 2.0
