# kagent — evaluation kit for the Content Factory namespace

This kit is a **scoped evaluation** of [kagent](https://github.com/kagent-dev/kagent) (CNCF, Apache 2.0) before rolling cluster-wide. It only touches the Content Factory namespace (default `content-factory`, set `CF_NAMESPACE=aicart` for the intelli-verse-x EKS cluster) and a single `kagent-eval` namespace for kagent's own controller / engine / UI.

We use it for:

- Pod + HPA + KEDA debugging for the 25 GPU sidecars.
- Helm release diffs.
- Argo rollout decisions.
- Prometheus alert triage.

## What you get

| Resource | What |
|---|---|
| `01-namespace-eval.yaml` | Dedicated `kagent-eval` namespace + RBAC scoped to `content-factory` only |
| `02-openai-secret.yaml` | Template for the `OPENAI_API_KEY` secret kagent needs |
| `03-modelconfig.yaml` | `ModelConfig` CR — defaults to `gpt-4.1-mini` (cheap), swap to claude/gemini as you like |
| `04-toolserver-prometheus.yaml` | `ToolServer` CR pointing at the existing in-cluster Prometheus |
| `05-toolserver-grafana.yaml` | `ToolServer` CR pointing at Grafana |
| `06-agent-cf-pod-doctor.yaml` | `Agent` CR — pod troubleshooting agent scoped to `content-factory` ns |
| `07-agent-cf-gpu-rollout.yaml` | `Agent` CR — version-bump / rollout agent for the 25 GPU sidecars |
| `08-agent-cf-alert-triage.yaml` | `Agent` CR — Prometheus alert triage, routes via `gt escalate` |
| `scripts/install.sh` | One-shot installer (Helm chart + CRDs + the manifests above) |
| `scripts/eval-checklist.md` | Manual eval checklist + go/no-go criteria |
| `scripts/uninstall.sh` | Clean teardown — leaves `content-factory` untouched |

## Prereqs

- `kubectl` context pointing at the target cluster.
- `helm` 3.x.
- `OPENAI_API_KEY` (or any other supported provider key) in your shell env.
- RBAC to create Namespaces, CRDs, ServiceAccounts, Roles.

## Bring-up

```bash
export OPENAI_API_KEY=sk-...

# Default cluster (namespace 'content-factory'):
./scripts/install.sh

# intelli-verse-x EKS cluster (ai-cart-auto-cluster):
CF_NAMESPACE=aicart ./scripts/install.sh
```

The installer fails fast if `${CF_NAMESPACE}` does not exist in the
current `kubectl` context, so you cannot accidentally bind RBAC to a
non-existent namespace.

The installer:
1. Creates the `kagent-eval` namespace.
2. Adds the kagent Helm repo.
3. Installs kagent (controller, engine, UI) into `kagent-eval`.
4. Applies the secret + ModelConfig + ToolServers + 3 Agents.
5. Prints the port-forward command for the UI.

## Eval checklist

Walk `scripts/eval-checklist.md` over 1-2 weeks. Hard go/no-go gates:

- Pod-doctor agent correctly diagnoses a deliberately-broken `comfyui` pod (image:bogus) within 60s.
- GPU-rollout agent opens a PR against `intelli-verse-kube-infra` (via `gastown` MCP) when asked to bump `comfyui` to a new tag, without touching any other manifests.
- Alert-triage agent correctly identifies a deliberately-fired Prometheus alert and emits `gt escalate --severity=medium` on the right bead.
- Zero unexpected writes outside the `content-factory` namespace (verified by RBAC audit log).
- Total cost over the 2-week eval ≤ $25 in model spend.

## Rollout decision

If all gates pass, file a PR against `intelli-verse-kube-infra` to:
1. Move kagent into its own namespace (`kagent-system`).
2. Expand RBAC to all `intelli-verse-x` namespaces.
3. Promote the 3 eval agents to "production" with stricter `ResourceQuota`.

If gates fail, capture the failure mode in this README, uninstall, and pick a replacement from the [Maxim 2026 MCP Gateway list](https://www.getmaxim.ai/articles/best-open-source-mcp-gateways-in-2026/) (Microsoft MCP Gateway is the next-best K8s-native option).

## Sources

- kagent quickstart: <https://kagent.dev/docs/kagent/getting-started/quickstart>
- kagent core concepts (Agent / ModelConfig / ToolServer CRs): <https://kagent.dev/docs>
- Repo: <https://github.com/kagent-dev/kagent>
