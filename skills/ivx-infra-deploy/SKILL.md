---
name: ivx-infra-deploy
description: Deployment runbook for IntelliVerse Kubernetes services. Use when
  deploying a new service, updating an existing deployment, rolling back, applying
  manifests, updating images, scaling, or managing namespaces in the aicart cluster.
metadata:
  author: intelliverse-infra
  version: "1.0.0"
  aws-services: "Amazon EKS, Amazon ECR"
---

# IntelliVerse Deployment Runbook

Standard procedure for deploying and managing services in the `aicart` namespace.

## Pre-Deployment Checklist

- [ ] ECR image built and pushed (`aws ecr get-login-password | docker login ...`)
- [ ] Parameter Store secrets configured for this service
- [ ] DNS records in Route 53 (if new external endpoint)
- [ ] ACM certificate valid for new subdomain
- [ ] `redis/` deployed and ready (if service uses Bull queues)

---

## Deploy Order (MANDATORY for new environments)

```bash
# 1. Redis FIRST (AI service and others depend on it)
kubectl apply -f redis/
kubectl rollout status deploy/ivx-redis -n aicart

# 2. PodDisruptionBudgets
kubectl apply -f pdb.yaml

# 3. Core AI service
kubectl apply -f intelli-verse-ai/
kubectl rollout status deploy/intelliverse-ai -n aicart

# 4. MCP Server
kubectl apply -f mcp-server/
kubectl rollout status deploy/intelliverse-mcp -n aicart

# 5. Platform services (any order after above)
kubectl apply -f admin-management/
kubectl apply -f user-auth/
kubectl apply -f intelliverse-user-backend/
kubectl apply -f intelli-verse-payment/

# 6. AI/LLM services
kubectl apply -f litellm/
kubectl apply -f open-webui/
kubectl apply -f voice-pipeline/

# 7. Supporting services
kubectl apply -f langfuse/
kubectl apply -f nakama/
kubectl apply -f n8n/
```

---

## Update Existing Deployment (Image Update)

```bash
# Option A: Update image tag directly
kubectl set image deploy/<SERVICE_NAME> <CONTAINER_NAME>=<ECR_URI>:<NEW_TAG> -n aicart
kubectl rollout status deploy/<SERVICE_NAME> -n aicart

# Option B: Apply updated YAML
kubectl apply -f <service-folder>/
kubectl rollout status deploy/<SERVICE_NAME> -n aicart

# Verify new pods are running the correct image
kubectl get pods -n aicart -l app=<SERVICE_NAME> -o jsonpath='{.items[*].spec.containers[0].image}'
```

---

## Rollback

```bash
# Roll back to previous version
kubectl rollout undo deploy/<SERVICE_NAME> -n aicart
kubectl rollout status deploy/<SERVICE_NAME> -n aicart

# Roll back to specific revision
kubectl rollout history deploy/<SERVICE_NAME> -n aicart
kubectl rollout undo deploy/<SERVICE_NAME> --to-revision=<N> -n aicart
```

---

## Deploy a New Service

### Step 1: Create namespace (if needed)
```bash
# IntelliVerse uses single namespace: aicart
# Most new services go here
kubectl get ns aicart  # should already exist
```

### Step 2: Required manifest files for a new service
```
<service-name>/
+-- deploy.yaml         # Deployment (replicas, image, resources, probes)
+-- service.yaml        # Service (ClusterIP or LoadBalancer)
+-- ingress.yaml        # Ingress (if external access needed)
+-- configmap.yaml      # Non-secret config (optional)
```

### Step 3: Secret management pattern
Use AWS Parameter Store + init container (same as intelliverse-ai):
```yaml
initContainers:
- name: fetch-ssm-params
  image: amazon/aws-cli:latest
  command: ["/bin/sh", "-c"]
  args:
  - |
    aws ssm get-parameter --name /codebuild/<SERVICE_NAME> --with-decryption \
      --query Parameter.Value --output text > /shared/env.json
  volumeMounts:
  - name: shared-config
    mountPath: /shared
```

### Step 4: Apply and verify
```bash
kubectl apply -f <service-name>/
kubectl get pods -n aicart -l app=<SERVICE_NAME>
kubectl logs -n aicart -l app=<SERVICE_NAME> --tail=50
curl https://<SUBDOMAIN>.intelli-verse-x.ai/health
```

---

## Scaling

```bash
# Manual scale
kubectl scale deploy/<SERVICE_NAME> --replicas=3 -n aicart

# Check HPA (auto-scaling)
kubectl get hpa -n aicart
kubectl describe hpa <HPA_NAME> -n aicart

# Add HPA for a service
kubectl autoscale deploy/<SERVICE_NAME> --min=2 --max=10 --cpu-percent=70 -n aicart
```

---

## ECR Image Push (Quick Reference)

```bash
# Login
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin 970547373533.dkr.ecr.us-east-1.amazonaws.com

# Build & push
docker build -t <service-name> .
docker tag <service-name>:latest 970547373533.dkr.ecr.us-east-1.amazonaws.com/<service-name>:latest
docker push 970547373333.dkr.ecr.us-east-1.amazonaws.com/<service-name>:latest
```

---

## Ingress Patterns

### Standard HTTPS ingress (ALB)
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/certificate-arn: <ACM_CERT_ARN>
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS":443}]'
```

### WebSocket ingress (must add idle-timeout)
```yaml
annotations:
  alb.ingress.kubernetes.io/load-balancer-attributes: idle_timeout.timeout_seconds=3600
  alb.ingress.kubernetes.io/target-group-attributes: stickiness.enabled=true,stickiness.lb_cookie.duration_seconds=3600
```

---

## Post-Deployment Verification

```bash
# 1. All pods running
kubectl get pods -n aicart | grep -v Running | grep -v Completed

# 2. No warning events
kubectl get events -n aicart --field-selector=type=Warning | tail -10

# 3. Health endpoint
curl -f https://ai.intelli-verse-x.ai/health
curl -f https://mcp.intelli-verse-x.ai/health

# 4. HPA active and not at max
kubectl get hpa -n aicart

# 5. Logs clean
kubectl logs -n aicart deploy/<SERVICE_NAME> --since=5m
```

---

## References

- Developer Quick Reference: `DEVELOPER_QUICK_REFERENCE.md`
- Full deployment guide: `DEPLOYMENT_CHANGES_JAN_2026.md`
- Ingress examples: `api-host-ingress.yaml`, `apis-ingress.yaml`
- ECR account: 970547373533
