---
name: ivx-infra-incident-triage
description: Incident triage and RCA for IntelliVerse services. Triggers on pod
  crashes, CrashLoopBackOff, OOMKilled, service unreachable, 5xx errors, latency
  spikes, AI/LLM failures, voice pipeline issues, WebSocket disconnects, Bull queue
  failures, or any production incident. Combines aws-health-events check with
  service-specific runbooks.
metadata:
  author: intelliverse-infra
  version: "1.0.0"
  based-on: devops-agent-skills/skills/aws-health-events
  aws-services: "Amazon EKS, CloudWatch, ALB, AWS Health"
---

# IntelliVerse Incident Triage

Quick runbook for diagnosing production issues in the IntelliVerse aicart namespace.

## Step 0: Always Run First (30 seconds)

```bash
# 1. Check AWS Health events (always first per aws-health-events skill)
aws health describe-events --region us-east-1 \
  --filter '{"services":["EKS","EC2","ELASTICLOADBALANCING","VPC"],"eventStatusCodes":["open"]}'

# 2. Pod status snapshot
kubectl get pods -n aicart --sort-by='.status.containerStatuses[0].restartCount'

# 3. Recent warning events
kubectl get events -n aicart --field-selector=type=Warning --sort-by=.metadata.creationTimestamp | tail -20
```

## Decision Tree

```
Is the issue with an external URL (ai.intelli-verse-x.ai)?
  YES -> Check ALB health, then ingress, then pod
  NO  -> Is it internal service-to-service?
    YES -> Check DNS (coredns), then service endpoints, then pod
    NO  -> Is it a specific feature (voice, AI model, queue)?
      YES -> Go to Feature-Specific Runbooks below
```

---

## Runbook A: AI Service Down (intelliverse-ai)

```bash
# 1. Pod state
kubectl get pods -n aicart -l app=intelliverse-ai
kubectl describe pod -n aicart -l app=intelliverse-ai | tail -30

# 2. Logs (last 100 lines)
kubectl logs -n aicart deploy/intelliverse-ai --tail=100

# 3. SSM init container (secrets fetch failure is common)
kubectl logs -n aicart -l app=intelliverse-ai -c fetch-ssm-params

# 4. Redis connectivity (Bull queues fail without Redis)
kubectl exec -n aicart deploy/intelliverse-ai -- nc -zv ivx-redis 6379

# 5. Health endpoint
kubectl exec -n aicart deploy/intelliverse-ai -- curl -s http://localhost:3000/health
```

**Common causes:**
- SSM init container fails -> check IAM role for SSM permissions
- Redis not ready -> deploy Redis first, then AI service
- OOMKilled -> memory limit too low (increase from 2Gi to 4Gi)
- CrashLoopBackOff + "Cannot find module" -> image build failed, wrong ECR tag

---

## Runbook B: WebSocket Disconnects

WebSocket routes: `ai-host.intelli-verse-x.ai` (port 8765), `ai-voice.intelli-verse-x.ai` (port 8766)

```bash
# 1. Check sticky sessions on WS service
kubectl get svc intelliverse-ai-ws -n aicart -o yaml | grep -A10 sessionAffinity
# Must be: sessionAffinity: ClientIP, timeoutSeconds: 3600

# 2. Check ALB idle timeout (must be >= 3600s for WebSocket)
kubectl describe ingress intelliverse-ai-ingress -n aicart | grep idle-timeout

# 3. Check pod is exposing WS ports
kubectl get pods -n aicart -l app=intelliverse-ai -o jsonpath='{.items[0].spec.containers[0].ports}'
# Must include: 8765 and 8766

# 4. Test WebSocket connection (requires wscat: npm i -g wscat)
# wscat -c "wss://ai-host.intelli-verse-x.ai?token=YOUR_API_KEY"
```

---

## Runbook C: LLM / AI Model Failures

LiteLLM is the gateway for ALL model traffic (Qwen, Kimi, Claude).

```bash
# 1. LiteLLM pod + logs
kubectl get pods -n aicart -l app=litellm
kubectl logs -n aicart deploy/litellm --tail=100

# 2. vLLM (Qwen inference) status
kubectl get pods -n aicart -l app=voice-pipeline-vllm
kubectl logs -n aicart deploy/voice-pipeline-vllm --tail=50

# 3. LiteLLM config (model definitions)
kubectl get configmap litellm-config -n aicart -o yaml

# 4. Check model routing in LiteLLM UI (if accessible)
# Open-WebUI is the frontend: kubectl port-forward svc/open-webui 3000:80 -n aicart
```

**Model routing:**
- `qwen3-30b` -> vLLM pod (GPU node, Qwen3-30B-A3B-AWQ)
- `qwen3-8b`  -> vLLM pod (Qwen/Qwen3-8B)
- `kimi-k2`   -> external API (api.moonshot.cn) — check API key if failing
- `claude-*`  -> AWS Bedrock (check IAM role + region)

---

## Runbook D: Voice Pipeline Failures

Services: `voice-pipeline-vllm` (inference), `voice-pipeline-tts` (Kokoro), `piper-tts`, `voice-pipeline-stt`

```bash
# Full voice pipeline pod status
kubectl get pods -n aicart | grep voice
kubectl get pods -n aicart | grep -E 'kokoro|piper|tts|stt'

# Logs per service
kubectl logs -n aicart deploy/voice-pipeline-tts --tail=50
kubectl logs -n aicart deploy/voice-pipeline-stt --tail=50
```

**voice-pipeline-tts was in Error state at last audit:**
```bash
kubectl describe pod -n aicart -l app=voice-pipeline-tts | grep -A20 "Events:"
# Check: ImagePullBackOff, OOMKilled, config error, GPU not available
```

---

## Runbook E: Bull Queue Failures

Queues: `daily-quiz`, `weekly-quiz`, `fortune`, `emoji`, `card-render`

```bash
# Redis connectivity check
kubectl exec -n aicart deploy/intelliverse-ai -- redis-cli -h ivx-redis ping

# Queue stats via Redis
kubectl exec -n aicart deploy/intelliverse-ai -- redis-cli -h ivx-redis keys "bull:*" | head -20

# If stuck jobs, flush queue (careful in production):
# kubectl exec -n aicart deploy/intelliverse-ai -- redis-cli -h ivx-redis del "bull:daily-quiz:wait"
```

---

## Runbook F: Nakama Game Backend Issues

```bash
kubectl get pods -n aicart -l app=nakama
kubectl logs -n aicart deploy/nakama --tail=100

# Nakama console (port-forward)
kubectl port-forward svc/nakama 7351:7351 -n aicart
# Then open http://localhost:7351
```

---

## Runbook G: n8n Workflow Automation Issues

```bash
kubectl get pods -n aicart -l app=n8n
kubectl logs -n aicart deploy/n8n --tail=50
kubectl port-forward svc/n8n 5678:5678 -n aicart
# Then open http://localhost:5678
```

---

## Escalation Checklist

- [ ] AWS Health shows no service disruption for EKS/EC2/ALB
- [ ] Pod is Running (not Error/CrashLoopBackOff)
- [ ] SSM secrets fetched successfully (init container logs clean)
- [ ] Redis accessible from AI service pod
- [ ] ALB health checks passing (200 on /health endpoint)
- [ ] No OOMKilled events in last 30 minutes
- [ ] LiteLLM config has correct API keys for external models
- [ ] DNS resolves correctly for internal service URLs

---

## References

- Upstream: `devops-agent-skills/skills/aws-health-events/SKILL.md`
- Architecture: `DEPLOYMENT_CHANGES_JAN_2026.md`
- Quick commands: `DEVELOPER_QUICK_REFERENCE.md`
