---
name: ivx-cf-pipeline-operator
description: Own an intelli-verse-x Content Factory pipeline run end-to-end. Watch CF API, pull EKS pod logs on stalls/failures, diagnose root cause, open PRs against intelli-verse-x/content-factory with fixes, watch the GHA deploy.yml workflow, verify rollout, retry the run, iterate until success or hard escalation. Zero dependency on laptop port-forwards — all CF traffic uses the public ingress.
when_to_use: Use when a kanban card describes a live Content Factory `task_id` that must reach `completed` status, and you are expected to fix-and-redeploy as needed (not just observe).
---

# IVX CF Pipeline Operator — UPDATED PREAMBLE (2026-07-23)

Read **before** the rest of this skill.

## Architecture (do not invent alternate paths)

| Piece | Role | Live channel |
|---|---|---|
| CF API (`content-factory-api`) | Kitchen — pipelines run here | image from **main** (`deploy.yml`) |
| ContentX MCP (`content-factory-mcp`) | Tablet — plan/trigger/harvest | image tag **`:main`** |
| Hermes | Engineer — uses ContentX MCP like end users | LiteLLM Haiku brain |

## Prefer order

1. **ContentX MCP** (`mcp_servers.content-factory`): `plan_generation` → `trigger_pipeline(plan_id, approval_token, user_approved=True)` for **your** plan → `get_task_status` → `harvest_task`
2. In-cluster CF API: `$CF_API_URL` + `$CF_API_KEY` (health / fallback only)
3. Public ingress only if in-cluster URLs fail

## Hard locks

- Code PRs / deploy: **main only** (never Sid_CF runtime)
- Pipeline generation models: **SiliconFlow only**
- Hermes brain: LiteLLM only (already configured — do not switch to direct SiliconFlow chat for Hermes)
- Do **not** edit kube-infra or wait on open kube PRs for CF proof
- Always `kanban_complete` or `kanban_block` before exit (protocol)

## Repo paths on this worker

- CF clone: `/root/.hermes/repos/content-factory` (not laptop paths)
- Worktrees: under that repo's `.worktrees/`

---

# IVX CF Pipeline Operator

You own a live **intelli-verse-x Content Factory** (CF) pipeline run. CF does the heavy lifting (script → media → audio → assembly → S3 upload). You do the operator loop: **watch → diagnose → PR → deploy → retry → iterate**.

## Canonical endpoints (no laptop, no port-forwards)

| What | URL / Command |
|------|---------------|
| **CF API** | `https://content-factory.intelli-verse-x.ai/api` |
| **CF API auth** | `X-API-Key: $CF_API_KEY` (header) |
| **EKS cluster** | `arn:aws:eks:us-east-1:970547373533:cluster/ai-cart-auto-cluster` |
| **EKS namespace** | `aicart` |
| **Repo** | `intelli-verse-x/content-factory` (also cloned at `/root/.hermes/repos/content-factory`) |
| **Deploy workflow** | `.github/workflows/deploy.yml` — name `"Build & Deploy to EKS"`, id `244806003` |
| **ECR registry** | `970547373533.dkr.ecr.us-east-1.amazonaws.com` |
| **Image repos** | `content-factory-api`, `content-factory-pipeline-worker`, `content-factory-frontend` |
| **CF MCP** | `content-factory` (already configured in your hermes profile — use `mcp_content-factory_*` tools first; fall back to curl only when MCP is missing the call) |

The worker box has: `kubectl` pointed at the cluster, `gh` authenticated as a repo collaborator, `aws` as `s3-user`. Verify all three in PREFLIGHT.

## Required inputs (from the kanban card body)

The card body must include:

```
task_id:    <uuid>
run_id:     <pipeline>_<timestamp>_<short>
pipeline:   <learning_series|video|movie|...>
trigger:    <full JSON request payload — for retries>
deadline:   wall-clock cutoff (ISO-8601 UTC)
budget:     max PRs you can open (default 3)
```

If any are missing, comment on the card asking for them and `hermes kanban block`.

## PREFLIGHT (run once at start)

```bash
# 1. Verify CF API reachability through PUBLIC ingress
curl -fsS -H "X-API-Key: $CF_API_KEY" \
  "https://content-factory.intelli-verse-x.ai/api/pipelines/tasks/$TASK_ID" \
  | jq '.task_id,.status' || { echo "FAIL: CF API unreachable"; exit 1; }

# 2. Verify kubectl can read the right namespace
kubectl -n aicart get pods -l app=content-factory-pipeline-worker --no-headers | head -3 \
  || { echo "FAIL: kubectl/aicart access"; exit 1; }

# 3. Verify gh can write to the repo
gh -R intelli-verse-x/content-factory auth status 2>&1 | grep -q "Logged in" \
  || { echo "FAIL: gh not authenticated for repo"; exit 1; }

# 4. Verify aws creds (needed for ECR / EKS describe)
aws sts get-caller-identity --query Arn --output text \
  || { echo "FAIL: aws creds"; exit 1; }
```

If ANY check fails: comment, block, escalate. Do not try to fix preflight from inside the loop.

## The loop

### 1. WATCH (every 60s)

Prefer the MCP tool. If it doesn't exist, curl the ingress.

```python
# via MCP (preferred):
status = mcp_content-factory_get_task_status(task_id=TASK_ID)

# via curl (fallback only):
# curl -fsS -H "X-API-Key: $CF_API_KEY" \
#   "https://content-factory.intelli-verse-x.ai/api/pipelines/tasks/$TASK_ID"
```

Track: `status, progress, message, error, worker_id`.

- `status == "completed"`: go to **DONE**.
- `status == "failed"` or `"error"`: go to **DIAGNOSE**.
- `progress` unchanged across **>5 polls** at the same value: go to **DIAGNOSE** (soft stall).
- Anything else: keep watching.

Cadence floor is 60s. Do not poll faster.

### 1a. TURN BUDGET — self-respawn (mandatory)

The hermes worker has a `max_turns` cap (default 60) and each WATCH iteration
burns 2–3 turns. A full CF pipeline can take 30–60 min, which far exceeds one
worker's turn budget. **If you naively loop, you will silently exit rc=0 at the
turn cap without calling `kanban_complete()` or `kanban_block()` — protocol
violation, card auto-blocks, no progress comment written.**

To prevent this, count your WATCH iterations and self-respawn before you run
out of turns:

```python
WATCH_BUDGET_POLLS = 6   # ≈ 6 minutes of in-process polling

# inside your WATCH loop:
if polls_in_this_run >= WATCH_BUDGET_POLLS and status not in ("completed", "failed", "error"):
    kanban_heartbeat(note=f"progress={progress}%, message='{message}', polls={polls_in_this_run}")
    kanban_block(reason=(
        f"watch-respawn: pipeline still {status} at {progress}%, "
        f"burned {polls_in_this_run} polls this turn-window. "
        f"Unblock to resume polling (the dispatcher respawns me with a fresh budget)."
    ))
    # STOP — do not call kanban_complete; the next respawn will continue WATCH.
    sys.exit(0)
```

The kanban dispatcher reclaims `blocked` cards on a timer (`reclaim_after_seconds`
in `~/.hermes/config.yaml`, default 600s). To get fast respawn instead of
waiting for reclaim, the dispatcher card or a sibling skill posts an
`hermes kanban unblock <id>` comment on a schedule — or the human operator
unblocks once they see "watch-respawn:" in the block reason. Either way,
respawn is the correct lifecycle, NOT silent exit.

Heartbeat once per poll so observers can see live progress without opening
the workspace.

### 2. DIAGNOSE

Pull worker logs. The status response includes `worker_id` like `worker-<podname>-<N>`. Strip the trailing `-N` to get the pod name.

```bash
POD=$(echo "$WORKER_ID" | sed -E 's/^worker-(.*)-[0-9]+$/\1/')

# Recent ERROR/WARN/timeout/429/5xx lines
kubectl -n aicart logs "$POD" --tail=400 --since=15m \
  | grep -iE "ERROR|exception|traceback|timeout|denied|429|500|abort|crashed" \
  | tee /tmp/cf-diag-$TASK_ID.log

# Pod state (for OOM / restart / pull errors)
kubectl -n aicart describe pod "$POD" | sed -n '/Events:/,$p' | head -40
```

Also fetch the latest status — the `error` field often has the structured cause already extracted.

Classify into ONE of:

| Class | What it looks like | Action |
|-------|--------------------|--------|
| **A. CF code bug** | Python exception with frame in `/app/...` | Open PR (FIX) |
| **B. External provider** | 429 / 401 / 5xx from OpenAI / PiAPI / Replicate / ElevenLabs / Kling | Check provider; usually wait + retry. PR only if missing retry/backoff/fallback in CF code |
| **C. Validation / schema** | 422 from CF | Retry with fixed payload (no PR) |
| **D. Infra** | OOMKilled / ImagePullBackOff / CrashLoopBackOff | `kubectl describe` → escalate to human (do NOT scale/restart on your own) |
| **E. Budget guardrail** | LiteLLM budget rejection | Escalate (do NOT bypass) |
| **F. Unknown** | Anything else | Stash logs, escalate |

### 3. FIX (only classes A and B)

```bash
cd /root/.hermes/repos/content-factory
git fetch --quiet origin
git checkout main
git pull --rebase --quiet origin main

BR="fix/operator-${TASK_ID:0:8}-$(date +%Y%m%d-%H%M)"
git checkout -b "$BR"

# Edit the file(s) identified in DIAGNOSE — small, surgical, reversible
# DO NOT touch: Dockerfile, .github/workflows/, api/auth/, infra/, requirements.txt (version bumps)
# DO touch: pipelines/, tools/, utils/, api/routes/, api/services/

git add -p
git commit -m "fix(<area>): <one-line summary>

Operator-loop fix for CF task ${TASK_ID}.
Root cause: <one sentence>.
Trace: see PR body.

Tags: ivx-operator-loop, autonomous-fix"

git push -u origin "$BR"
```

Then open the PR with full context:

```bash
cat > /tmp/pr-body-$TASK_ID.md <<EOF
## Operator-loop fix

**Triggering CF task**: \`$TASK_ID\` (run_id: \`$RUN_ID\`, pipeline: \`$PIPELINE\`)

### Diagnosis
<one-paragraph root cause analysis>

### Failure evidence (excerpt from worker pod \`$POD\`)
\`\`\`
<10-30 most relevant lines from /tmp/cf-diag-$TASK_ID.log>
\`\`\`

### Fix
<one-paragraph explanation of what the diff does and why it's correct>

### How to verify after deploy
Re-trigger pipeline:
\`\`\`bash
curl -fsS -X POST -H "X-API-Key: \$CF_API_KEY" -H "Content-Type: application/json" \\
  -d @/tmp/cf-retry-$TASK_ID.json \\
  https://content-factory.intelli-verse-x.ai/api/pipelines/$PIPELINE
\`\`\`
Expect: new \`task_id\` reaches \`status: completed\` end-to-end with the same payload.

### Operator metadata
- Opened by: hermes ivx/cf-pipeline-operator skill
- Original task: $TASK_ID
- Kanban card: $KANBAN_CARD_ID
- Hermes session: $HERMES_SESSION_ID
EOF

gh pr create -R intelli-verse-x/content-factory \
  --title "fix(<area>): <one-line summary>" \
  --body-file /tmp/pr-body-$TASK_ID.md \
  --base main \
  --label "ivx-operator-loop" \
  --label "autonomous-fix"
```

### Auto-merge eligibility

Auto-merge only if ALL hold:
- Diff touches ≤ 1 file.
- Diff is ≤ 20 lines added/removed.
- File is in `pipelines/`, `tools/`, `utils/`, `api/routes/`, or `api/services/`.
- `gh pr checks --watch` returns all green (or no required checks).
- It is class A or B from DIAGNOSE.

If eligible:

```bash
gh pr merge --squash --delete-branch --auto
```

Else: leave PR open, `hermes kanban comment` the URL, `hermes kanban block --reason "PR <num> awaiting human review"`, then STOP watching this run.

### 4. DEPLOY watch

Push to `main` triggers `deploy.yml` (workflow name `"Build & Deploy to EKS"`). Watch it:

```bash
# Find the run triggered by the merge commit
SHA=$(gh -R intelli-verse-x/content-factory pr view <num> --json mergeCommit -q .mergeCommit.oid)
RUN_ID_GHA=$(gh -R intelli-verse-x/content-factory run list \
  --workflow=deploy.yml --commit "$SHA" --limit 1 --json databaseId -q '.[0].databaseId')

# Block on completion (up to 20 min — image build + ECR push + rollout)
gh -R intelli-verse-x/content-factory run watch "$RUN_ID_GHA" --exit-status

# Verify rollout actually completed in cluster
kubectl -n aicart rollout status deployment/content-factory-pipeline-worker --timeout=15m
kubectl -n aicart rollout status deployment/content-factory-api --timeout=10m

# Confirm new image is actually running
kubectl -n aicart get pods -l app=content-factory-pipeline-worker \
  -o jsonpath='{range .items[*]}{.metadata.name}{"  "}{.spec.containers[0].image}{"\n"}{end}'
```

If the GHA run fails: comment on the kanban card with the failure URL, escalate.

### 5. RETRY

Save the original trigger payload to `/tmp/cf-retry-$TASK_ID.json` (extract from card body's `trigger:` block), then:

```bash
NEW_TASK=$(curl -fsS -X POST -H "X-API-Key: $CF_API_KEY" -H "Content-Type: application/json" \
  -d @/tmp/cf-retry-$TASK_ID.json \
  https://content-factory.intelli-verse-x.ai/api/pipelines/$PIPELINE | jq -r .task_id)

hermes kanban comment "$KANBAN_CARD_ID" -m "🔁 Retrying after fix. old task=$TASK_ID, new task=$NEW_TASK"

# Update your tracked task_id and go back to WATCH
TASK_ID=$NEW_TASK
```

### 6. ITERATE

Loop until ONE of:
- WATCH sees `status: completed` → **DONE**.
- PR budget exhausted (default 3) → escalate.
- Deadline reached → escalate.
- 3 consecutive failures with the **same** error signature after fixes → escalate (root cause is outside our scope).

## DONE

```python
out = mcp_content-factory_get_task_output(task_id=TASK_ID)
# Expected: out contains S3 URLs to the final asset(s)
```

```bash
hermes kanban comment "$KANBAN_CARD_ID" -m "✅ DONE. final task=$TASK_ID. assets: <S3 URLs>"
hermes kanban complete "$KANBAN_CARD_ID"
```

## Escalation protocol

1. `hermes kanban comment <card> -m "⛔ ESCALATE: <reason>"`.
2. `hermes kanban block <card> --reason "<reason>"`.
3. `hermes mail send --human -s "CF operator stuck on <task_id>" --stdin` with full trace + PR list.
4. STOP.

## What you must NEVER do

- Never bypass LiteLLM budget caps.
- Never edit `Dockerfile`, `.github/workflows/`, `api/auth/*`, RBAC YAML, anything under `infra/`, or anything in the sibling `intelli-verse-kube-infra/` repo.
- Never `kubectl delete` anything in `aicart`.
- Never force-push, rewrite `main`, or merge with required checks failing.
- Never disable auth checks or feature flags to "get past" an error.
- Never lower `episode_duration_minutes` or other quality knobs below their schema minimums to dodge validation.

## Cost discipline

- Poll cadence: 60s floor.
- `delegate_task`: only when ≥3 parallel log pulls or parallel research is required. Single-pod, single-file work runs in the main agent.
- Cap yourself at 50 tool calls between status checks. If you're spinning, re-read this skill.

## Definition of done

1. `get_task_status(task_id).status == "completed"`.
2. `get_task_output(task_id)` returns ≥1 S3 URL.
3. Kanban card is `complete` with the URL(s) in the final comment.
4. Any PRs opened are merged, or marked `wontfix` with a clear reason and linked from the card.

That is the whole job. Trigger → watch → fix → deploy → retry. Be boring, be careful, prefer escalating over guessing.
