---
name: ivx-infra-litellm-ops
description: LiteLLM AI gateway operations for IntelliVerse. Use when managing LLM
  models, updating model routing, checking model availability, investigating AI inference
  failures, adjusting Qwen/Kimi/Claude/vLLM configurations, or monitoring LLM costs
  via Langfuse.
metadata:
  author: intelliverse-infra
  version: "1.0.0"
  aws-services: "Amazon EKS, Amazon Bedrock"
---

# IntelliVerse LiteLLM Operations

Manages the LiteLLM AI proxy and all LLM model infrastructure in the `aicart` namespace.

## Architecture

```
Clients (Unity, Web, n8n, AI Service)
       |
       v
LiteLLM Proxy (litellm.aicart.svc.cluster.local)
       |
  +----|-------------------------------+
  |    |                               |
  v    v                               v
vLLM (GPU)    External APIs      AWS Bedrock
Qwen3-30B     Kimi K2.6          Claude Sonnet 4.5
Qwen3-8B      Moonshot-v1-auto   Claude Haiku 4.5
              Moonshot-v1-8k     Claude Fable 5
       |
       v
Langfuse (tracing/observability)
```

---

## Model Inventory

| Model Alias | Provider | Backend | GPU Required | Notes |
|-------------|----------|---------|-------------|-------|
| `qwen3-30b` | Self-hosted | vLLM pod | Yes (A10G/A100) | Qwen3-30B-A3B-AWQ |
| `qwen3-8b` | Self-hosted | vLLM pod | Yes | Qwen/Qwen3-8B |
| `kimi-k2` | Moonshot API | External | No | api.moonshot.cn |
| `moonshot-auto` | Moonshot API | External | No | moonshot-v1-auto |
| `claude-sonnet` | AWS Bedrock | Internal | No | us-east-1 |
| `claude-haiku` | AWS Bedrock | Internal | No | us-east-1 |
| `claude-fable` | AWS Bedrock | Internal | No | us-east-1 |

---

## Step 1: Check LiteLLM Health

```bash
# Pod status
kubectl get pods -n aicart -l app=litellm

# Logs
kubectl logs -n aicart deploy/litellm --tail=100

# Health endpoint (port-forward if needed)
kubectl port-forward svc/litellm 4000:4000 -n aicart
curl http://localhost:4000/health
curl http://localhost:4000/models  # list all registered models
```

---

## Step 2: Check vLLM (Self-Hosted Models)

```bash
# vLLM inference pods
kubectl get pods -n aicart | grep vllm

# Logs
kubectl logs -n aicart deploy/voice-pipeline-vllm --tail=100

# GPU utilization on vLLM node
kubectl top nodes
kubectl describe node <GPU_NODE> | grep -A20 "Allocated resources"

# Test vLLM directly (if port-forwarded)
kubectl port-forward svc/voice-pipeline-vllm 8000:8000 -n aicart
curl http://localhost:8000/v1/models
curl -X POST http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"Qwen/Qwen3-30B-A3B-AWQ","messages":[{"role":"user","content":"ping"}],"max_tokens":10}'
```

---

## Step 3: Update LiteLLM Config

The config lives in a ConfigMap. To update model routing:

```bash
# View current config
kubectl get configmap litellm-config -n aicart -o yaml

# Edit (opens in editor)
kubectl edit configmap litellm-config -n aicart

# After editing, restart LiteLLM to pick up changes
kubectl rollout restart deploy/litellm -n aicart
kubectl rollout status deploy/litellm -n aicart
```

---

## Step 4: Add a New Model

To add a new model to LiteLLM:

1. Edit the `litellm-config` ConfigMap
2. Add under `model_list`:

For AWS Bedrock model:
```yaml
- model_name: new-model-alias
  litellm_params:
    model: bedrock/anthropic.claude-3-5-sonnet-20240620-v1:0
    aws_region_name: us-east-1
```

For external API:
```yaml
- model_name: new-api-model
  litellm_params:
    model: openai/gpt-4o
    api_key: os.environ/OPENAI_API_KEY
    api_base: https://api.openai.com/v1
```

3. Ensure API keys are in the litellm Secret (NOT in ConfigMap):
```bash
kubectl get secret litellm-secrets -n aicart -o yaml
kubectl edit secret litellm-secrets -n aicart  # base64 encode new values
```

4. Restart LiteLLM: `kubectl rollout restart deploy/litellm -n aicart`

---

## Step 5: Langfuse Observability

Langfuse tracks all LLM requests, costs, and traces.

```bash
# Langfuse pod
kubectl get pods -n aicart -l app=langfuse

# Access Langfuse UI
kubectl port-forward svc/langfuse 3000:3000 -n aicart
# Open http://localhost:3000
```

Key Langfuse checks:
- Model usage breakdown (which model is called most)
- Token costs per model
- Error rates per model
- Latency P50/P95/P99

---

## Step 6: OpenWebUI Frontend

OpenWebUI is the chat UI for internal LLM access.

```bash
kubectl get pods -n aicart -l app=open-webui
kubectl logs -n aicart deploy/open-webui --tail=50

# Access UI
kubectl port-forward svc/open-webui 8080:80 -n aicart
# Open http://localhost:8080
```

---

## Common Issues

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| Model returns 502 | vLLM pod not ready / OOM | Restart vLLM, check GPU node memory |
| `model not found` | Model not in litellm-config | Add to ConfigMap, restart LiteLLM |
| Kimi/Moonshot 401 | API key expired | Update `MOONSHOT_API_KEY` in secret |
| Bedrock 403 | IAM role missing Bedrock permissions | Add `bedrock:InvokeModel` to pod role |
| High latency on Qwen-30B | GPU contention | Scale vLLM to 2 replicas (if GPU available) |
| LiteLLM restarts repeatedly | Bad config YAML | Check config syntax: `kubectl logs deploy/litellm -n aicart` |

---

## Cost Monitoring

```bash
# Token usage via Langfuse API or port-forward
# Also check AWS Bedrock cost explorer
aws ce get-cost-and-usage \
  --time-period Start=$(date -d "30 days ago" +%Y-%m-%d),End=$(date +%Y-%m-%d) \
  --granularity MONTHLY \
  --filter '{"Dimensions":{"Key":"SERVICE","Values":["Amazon Bedrock"]}}' \
  --metrics UnblendedCost
```

---

## References

- LiteLLM docs: https://docs.litellm.ai/docs/
- AWS Bedrock models: https://docs.aws.amazon.com/bedrock/latest/userguide/models-supported.html
- vLLM docs: https://docs.vllm.ai/
- Langfuse: https://langfuse.com/docs
