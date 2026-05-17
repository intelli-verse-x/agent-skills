---
name: ivx-k8s-gpu-rollout
description: Safely roll out or upgrade GPU sidecar services in intelli-verse-kube-infra/content-factory/ (comfyui, vllm-coder-pro, vllm-omni, musetalk, hymotion, trellis2, skyreels-v2, acestep, framepack, helios, faster-liveportrait, realesrgan, hunyuan3d, searxng, video-gen, browser-use, embedding) using kagent and the existing HPA / PDB / monitoring stack. Use whenever the user asks to deploy, upgrade, version-bump, restart, debug, or scale any GPU-backed service in the content-factory namespace.
---

# Kubernetes GPU sidecar rollout

`intelli-verse-kube-infra/content-factory/` contains ~25 GPU sidecar
services that back the Content Factory pipelines (image gen, video
gen, TTS, audio synthesis, 3D, motion, …). This skill is the safe
rollout / debug / upgrade workflow for them.

## When to use this skill

- "Upgrade comfyui to v0.3.x"
- "Why is musetalk OOMing?"
- "Roll out the new vllm-coder-pro image"
- "Scale up trellis2 — pipelines are queueing"
- "Add a new GPU service — here's the upstream repo"

## Prerequisites

- `kagent` deployed in the cluster (gives MCP tools for
  Kubernetes / Helm / Argo / Prometheus / Grafana).
- `gastown` MCP server (so the swarm can be coordinated).
- `kubectl` context pointing at the right cluster.
- Read access to `intelli-verse-kube-infra` repo.

## The workflow

### Upgrade / version-bump path

1. **Confirm the target image tag** with the user. If they don't
   know, use `firecrawl scrape <upstream-repo>/releases/latest` to
   find the newest stable tag.

2. **Diff the current vs. desired manifest** in
   `intelli-verse-kube-infra/content-factory/<service>/`:

   ```bash
   kubectl -n content-factory get deploy <service> -o yaml | grep image:
   grep "image:" intelli-verse-kube-infra/content-factory/<service>/deploy.yaml
   ```

3. **Open a PR via the gastown swarm** (do NOT kubectl apply
   directly — every change must go through the manifest repo):

   ```
   gt_sling(
     repo="intelli-verse-kube-infra",
     polecat_role="coder",
     bead_title="Bump <service> to <tag>",
     body="Upgrade content-factory/<service>/deploy.yaml from <old> to <new>."
   )
   ```

4. **After merge**, ArgoCD (if installed) or kustomize/helm sync
   applies the change. Monitor:
   - `kubectl -n content-factory rollout status deploy/<service>`
   - Grafana dashboard for the service (`monitoring.yaml` defines
     one per service).

### Debug path (service unhealthy)

1. **Get the symptom from the user** (errors, latency, OOMs).

2. **Pull the recent state** via kagent MCP tools:
   ```
   kagent_kubectl_describe(namespace="content-factory", resource="deploy/<service>")
   kagent_kubectl_logs(namespace="content-factory", pod="<pod>", lines=200)
   kagent_prometheus_query(query="rate(container_oom_events_total{pod=~'<service>.*'}[5m])")
   ```

3. **Common causes for this set of services:**
   - GPU not allocated — check `nodeSelector` /
     `tolerations` block, verify Karpenter has a GPU NodePool.
   - HPA not scaling — check `keda/` ScaledObject; the queue
     metric source may have drifted.
   - Image pull error — secret `content-factory-secrets` may have
     stale registry creds. See README "Bootstrapping / rotating".
   - PDB blocking eviction — `pdb.yaml` may have minAvailable too
     high during a single-replica rollout.

4. **Escalate via `gt escalate`** if SLO breached for > 5 min — the
   deacon will create a P0 bead and notify the on-call.

### New service path (adding a GPU sidecar)

1. **Scaffold under `content-factory/<new-service>/`:**
   - `<new-service>-deploy.yaml` (with `metadata.namespace: content-factory`)
   - `<new-service>-service.yaml` (ClusterIP)
   - `<new-service>-hpa.yaml` (queue-based via KEDA preferred)
   - `<new-service>-pdb.yaml` (minAvailable: 1 if multi-replica, 0 if singleton)
   - Add a Grafana panel entry to `monitoring.yaml`.

2. **Wire secrets via secretKeyRef from `content-factory-secrets`** —
   never put credentials in the manifest. Update the README table
   in `intelli-verse-kube-infra/content-factory/README.md` with the
   new keys consumed.

3. **Wire the Content Factory app side** in
   `~/dev/content-factory/tools/generators/` so the pipelines can
   call the new service. PR the two repos together.

## Surfacing results

Always show:
- The diff that's being applied (image tag, resource limits, env
  vars).
- The rollout strategy (`maxUnavailable`, `maxSurge`) — GPU services
  are usually single-replica so default RollingUpdate can cause
  brief outages.
- The post-rollout health check command for the user to verify.

## Safety guardrails

- **Never `kubectl apply` directly** — always via PR + ArgoCD/sync.
  Direct applies cause drift that breaks the next sync.
- **Never edit `content-factory-secrets`** in-place — the README's
  bootstrapping command must re-emit every key.
- **Always check PDB before draining** — single-replica GPU services
  with PDB minAvailable=1 will block node maintenance.
- **HPA + KEDA conflicts** — only one autoscaler per deployment.
  If both are defined, KEDA wins; HPA YAML should be deleted.

## Common failures

| Error | Fix |
|---|---|
| `0/N nodes available: insufficient nvidia.com/gpu` | No GPU NodePool ready. Check `karpenter/` for a NodePool matching the deployment's `nodeSelector`. |
| `OOMKilled` repeatedly | Bump `resources.limits.memory`. Some services (musetalk, hymotion) need 16-24 GiB even at idle. |
| Stuck in `ContainerCreating` | Usually an `ImagePullBackOff` — check `kubectl describe pod`. Could be registry creds in `content-factory-secrets`. |
| `503` from CF api hitting the service | Service URL env var in `api-deploy.yaml` is wrong; or the ClusterIP service name doesn't match what the api expects. |
