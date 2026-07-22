---
name: ivx-infra-eks-review
description: Comprehensive EKS operational review for the IntelliVerse production cluster.
  Triggers on requests like "review our cluster", "EKS audit", "best practices check",
  "cluster health", "security review", "upgrade readiness", or "cost optimization".
  Uses the upstream eks-operation-review skill as a base, with IntelliVerse-specific
  context layered on top.
metadata:
  author: intelliverse-infra
  version: "1.0.0"
  based-on: devops-agent-skills/skills/eks-operation-review
  aws-services: "Amazon EKS, CloudWatch, CloudTrail"
---

# IntelliVerse EKS Operational Review

A production review of the IntelliVerse EKS cluster. Extends the upstream
`eks-operation-review` skill with cluster-specific context.

## Cluster Identity

| Property | Value |
|----------|-------|
| Account | 970547373533 |
| Region | us-east-1 |
| Primary Namespace | `aicart` |
| Kubernetes API | via `awslabs.eks-mcp-server` MCP |
| Workload type | AI inference, LLM proxy, voice pipeline, gaming backend |

---

## Step 1: Baseline — Current Cluster State

Run these first to establish a baseline before any deep review:

```bash
# Control plane version
aws eks describe-cluster --name <CLUSTER_NAME> --region us-east-1 \
  --query 'cluster.{version:version,platformVersion:platformVersion,status:status}'

# All nodes
kubectl get nodes -o wide

# All pods (look for non-Running)
kubectl get pods -A --field-selector=status.phase!=Running,status.phase!=Succeeded

# Known failing pods to check immediately
kubectl get pods -n aicart | grep -E 'Error|CrashLoop|Pending|OOMKilled'

# Events (warnings only)
kubectl get events -A --field-selector=type=Warning --sort-by=.metadata.creationTimestamp | tail -40
```

**Known problem pods from last audit:**
- `voice-pipeline-tts` → was in Error state (check first)
- `aws-guardduty-agent` in kube-system → was CrashLoopBackOff
- `vibe-kanban` → was CrashLoopBackOff

---

## Step 2: Critical Services Health Check

These are the core services; check them in this order:

```bash
# 1. AI core service
kubectl rollout status deploy/intelliverse-ai -n aicart
kubectl logs deploy/intelliverse-ai -n aicart --tail=50

# 2. LiteLLM gateway (all model traffic goes through here)
kubectl rollout status deploy/litellm -n aicart
kubectl logs deploy/litellm -n aicart --tail=50

# 3. Redis (required by AI service for Bull queues)
kubectl exec -n aicart deploy/intelliverse-ai -- nc -zv ivx-redis 6379 2>&1

# 4. Voice pipeline (vLLM inference)
kubectl rollout status deploy/voice-pipeline-vllm -n aicart
kubectl logs deploy/voice-pipeline-vllm -n aicart --tail=30

# 5. Nakama (game backend)
kubectl rollout status deploy/nakama -n aicart

# 6. HPA status (all)
kubectl get hpa -n aicart
```

---

## Step 3: Security Review — IntelliVerse Specifics

### 3.1 Secrets Management
- **Check**: All pods use AWS Parameter Store (SSM) init containers — NOT hard-coded env vars in YAML
- **Verify**: No secrets in `kubectl get configmap -n aicart -o yaml` output
- **Key paths**: `/codebuild/intelliverse-ai`, `/codebuild/intelliverse-mcp`

```bash
# Check for any plain-text sensitive env vars exposed in pod specs
kubectl get pods -n aicart -o json | \
  python3 -c "import sys,json; pods=json.load(sys.stdin)['items'];
[print(p['metadata']['name'], e['name'], e.get('value','[ref]'))
 for p in pods for c in p['spec'].get('containers',[])
 for e in c.get('env',[]) if any(k in e['name'] for k in ['KEY','SECRET','PASSWORD','TOKEN'])]"
```

### 3.2 RBAC
```bash
# Check for overly broad ClusterRoleBindings
kubectl get clusterrolebindings -o json | \
  python3 -c "import sys,json; data=json.load(sys.stdin);
[print(b['metadata']['name'], [s.get('name') for s in b.get('subjects',[])])
 for b in data['items'] if b['roleRef']['name']=='cluster-admin']"
```

### 3.3 Network Policies
```bash
kubectl get networkpolicies -n aicart
# If empty → HIGH finding: no pod-to-pod isolation in the AI namespace
```

### 3.4 WebSocket Security
- ALB idle timeout must be ≥3600s for WebSocket routes (ports 8765/8766)
- Sticky sessions required on `intelliverse-ai-ws` service (`sessionAffinity: ClientIP`)

```bash
kubectl get svc intelliverse-ai-ws -n aicart -o yaml | grep -A5 sessionAffinity
```

---

## Step 4: Reliability Review

### 4.1 Pod Disruption Budgets
```bash
kubectl get pdb -A
# Required: pdb.yaml should be applied; verify AI service PDB exists
```

### 4.2 Resource Requests/Limits
```bash
kubectl top pods -n aicart --sort-by=memory
kubectl get pods -n aicart -o json | \
  python3 -c "import sys,json; pods=json.load(sys.stdin)['items'];
[print(p['metadata']['name'], 'NO LIMITS') for p in pods
 for c in p['spec'].get('containers',[])
 if not c.get('resources',{}).get('limits')]"
```

**Expected resource profiles:**
| Service | CPU Request | CPU Limit | Memory Request | Memory Limit |
|---------|-------------|-----------|----------------|--------------|
| intelliverse-ai | 250m | 1000m | 512Mi | 2Gi |
| admin-management | 200m | 1000m | 512Mi | 1536Mi |
| mcp-server | 200m | 1000m | 256Mi | 1Gi |
| redis (ivx) | 100m | 500m | 128Mi | 512Mi |
| voice-pipeline-vllm | GPU-bound | GPU-bound | 8Gi+ | varies |

### 4.3 Multi-AZ Distribution
```bash
kubectl get nodes --label-columns topology.kubernetes.io/zone
kubectl get pods -n aicart -o wide | awk '{print $NF}' | sort | uniq -c
# Goal: workloads spread across ≥2 AZs
```

### 4.4 Health Probes
```bash
kubectl get deploy -n aicart -o json | \
  python3 -c "import sys,json; data=json.load(sys.stdin);
[print(d['metadata']['name'],'MISSING PROBE')
 for d in data['items']
 for c in d['spec']['template']['spec']['containers']
 if not c.get('livenessProbe') or not c.get('readinessProbe')]"
```

---

## Step 5: Cost Optimization

### 5.1 GPU Node Utilization
```bash
# Check GPU nodes (voice-pipeline-vllm runs on GPU instances)
kubectl get nodes -l node.kubernetes.io/instance-type --show-labels | grep -i gpu
kubectl top nodes | grep -i gpu
```
- If GPU utilization <30% → consider scale-down schedule or right-sizing

### 5.2 Idle/Zero-Replica Deployments
```bash
kubectl get deploy -n aicart -o json | \
  python3 -c "import sys,json; data=json.load(sys.stdin);
[print(d['metadata']['name'], 'replicas=0')
 for d in data['items'] if d['spec']['replicas']==0]"
```

### 5.3 Storage
```bash
kubectl get pvc -A
kubectl get pv
# gp2 PVs → migrate to gp3 for ~20% savings
```

---

## Step 6: Generate Report

Artifact: `eks-review-intelliverse-prod-<YYYY-MM-DD>.md`

### Report Structure

```
# EKS Review — intelliverse-prod
Account: 970547373533 | Region: us-east-1 | Date: <DATE> | K8s: <VERSION>

## Executive Summary
- Overall: ✅/⚠️/❌
- Findings: X CRITICAL, Y HIGH, Z MEDIUM, W LOW

## Critical Services Status
[Table: service, replicas, status, last restart, notes]

## Security Findings
[Findings table: #, finding, severity, current state, recommendation]

## Reliability Findings
[Same format]

## Cost Optimization
[Savings table: item, current cost indicator, recommendation, est. savings]

## Known Issues (from last audit)
- voice-pipeline-tts Error state — root cause + fix
- aws-guardduty-agent CrashLoopBackOff — root cause + fix
- vibe-kanban CrashLoopBackOff — root cause + fix

## Next Steps
Immediate (24-48h): [CRITICAL items]
This week: [HIGH items]
This month: [MEDIUM items]
```

---

## References

- Upstream skill: `devops-agent-skills/skills/eks-operation-review/SKILL.md`
- EKS Best Practices: https://docs.aws.amazon.com/eks/latest/best-practices/introduction.html
- Developer Quick Reference: `DEVELOPER_QUICK_REFERENCE.md`
- Architecture: `DEPLOYMENT_CHANGES_JAN_2026.md`
