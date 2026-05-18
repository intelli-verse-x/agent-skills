---
name: ivx-cf-run-dispatcher
description: Trigger a Content Factory pipeline run via the public API, capture the task_id, then immediately post an operator kanban card on the `content-factory` board so a `ivx/cf-pipeline-operator` worker drives it to completion. Use one dispatcher card per pipeline-kind per trigger (cron / webhook / manual).
when_to_use: Use when you need to start a CF pipeline run AND ensure a swarm operator is watching it from t=0. Called from a hermes cron job, a webhook handler, or a one-off `hermes kanban create` invocation.
---

# IVX CF Run Dispatcher

You are the dispatcher for a single pipeline kind. Your job: trigger one CF pipeline run, then hand off to an operator.

You do NOT watch the run yourself. You do NOT diagnose failures. You ONLY trigger and hand off.

## Required inputs (from card body)

```
pipeline:   <learning_series|video|movie|...>    # required
payload:    <full JSON request body>              # required
deadline:   ISO-8601 UTC for operator             # required
budget:     max PRs operator can open (default 3) # optional
tags:       extra tags to add to the CF run       # optional
```

## Canonical endpoints

| What | URL |
|------|-----|
| CF API | `https://content-factory.intelli-verse-x.ai/api` |
| Auth | `X-API-Key: $CF_API_KEY` (already in your `~/.hermes/.env`) |
| Trigger path | `POST /api/pipelines/{pipeline}` |
| Task lookup | `GET  /api/pipelines/tasks/{task_id}`  ← NOT `/api/tasks/{id}` or `/api/pipelines/runs/{id}` (both 404) |
| OpenAPI spec | `GET  /openapi` (returns JSON; NOT `/openapi.json`, that returns the UI HTML) |
| Queue status | `GET  /api/pipelines/queue/status` (may return 500 transiently — do NOT treat as a hard preflight failure) |

## The dispatch flow (one-shot, no loop)

### 1. PREFLIGHT

```bash
# Verify the pipeline endpoint exists (avoids 404 on dispatch).
# IMPORTANT: the spec lives at /openapi (NOT /openapi.json — that returns the SPA HTML).
curl -fsS -H "X-API-Key: $CF_API_KEY" \
  "https://content-factory.intelli-verse-x.ai/openapi" \
  | jq -e ".paths[\"/api/pipelines/$PIPELINE\"].post" >/dev/null \
  || { echo "FAIL: pipeline $PIPELINE not in CF API"; exit 1; }

# Verify we can auth. /api/pipelines/queue/status flakes with 500 occasionally,
# so the canonical auth probe is the openapi fetch above + a HEAD on the trigger.
curl -fsS -o /dev/null -w "%{http_code}" \
  -H "X-API-Key: $CF_API_KEY" \
  -X OPTIONS "https://content-factory.intelli-verse-x.ai/api/pipelines/$PIPELINE" \
  | grep -qE "^[234]" \
  || { echo "FAIL: CF API auth or service down"; exit 1; }
```

If preflight fails: comment on this dispatcher card with the failure, `hermes kanban block`, escalate. Do NOT trigger.

### 2. TRIGGER

```bash
# Always include "ivx-operator-loop" + "auto-dispatched" in tags so the swarm can find these runs later
PAYLOAD=$(jq '. + {tags: ((.tags // []) + ["ivx-operator-loop","auto-dispatched"])}' <<< "$ORIGINAL_PAYLOAD")

RESP=$(curl -fsS -X POST \
  -H "X-API-Key: $CF_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  "https://content-factory.intelli-verse-x.ai/api/pipelines/$PIPELINE")

TASK_ID=$(jq -r '.task_id' <<< "$RESP")
RUN_ID=$(jq -r '.output_path // .run_id // ""' <<< "$RESP" | sed 's|.*/||')

[ -z "$TASK_ID" ] || [ "$TASK_ID" = "null" ] && { echo "FAIL: no task_id in $RESP"; exit 1; }
```

### 3. POST THE OPERATOR CARD

```bash
cat > /tmp/operator-card-body.md <<EOF
You are operating a LIVE Content Factory pipeline run dispatched by the auto-dispatcher.

## Required inputs
- **task_id**: \`$TASK_ID\`
- **run_id**: \`$RUN_ID\`
- **pipeline**: \`$PIPELINE\`
- **deadline**: \`$DEADLINE\`
- **budget**: max $BUDGET PRs against \`intelli-verse-x/content-factory\`
- **trigger** (original POST payload for retries):

\`\`\`json
$PAYLOAD
\`\`\`

## Your skill
Load \`ivx/cf-pipeline-operator\` (\`~/.hermes/skills/ivx/cf-pipeline-operator/SKILL.md\`) and follow it exactly.

## On success
Post a follow-on Improver card chained to this one with the completed task_id/run_id so \`ivx/cf-run-improver\` can harvest learnings.

## Dispatcher provenance
- Dispatched by: \`ivx/cf-run-dispatcher\`
- Dispatcher card: \`$DISPATCHER_CARD_ID\`
- Triggered at: \`$(date -u +%FT%TZ)\`
EOF

OPERATOR_CARD_ID=$(hermes kanban --board content-factory create \
  --assignee default \
  --priority 1 \
  --skill "ivx/cf-pipeline-operator" \
  --body "$(cat /tmp/operator-card-body.md)" \
  --json \
  "Operate CF $PIPELINE run ${TASK_ID:0:8} -> completion" \
  | jq -r .id)

echo "operator card: $OPERATOR_CARD_ID"
```

### 4. COMMENT ON THIS DISPATCHER CARD + COMPLETE

```bash
hermes kanban --board content-factory comment "$DISPATCHER_CARD_ID" \
  --author "ivx-cf-run-dispatcher" \
  "✅ DISPATCHED. task_id=$TASK_ID, run_id=$RUN_ID, operator_card=$OPERATOR_CARD_ID. Handing off; this card closing."

hermes kanban --board content-factory complete "$DISPATCHER_CARD_ID"
```

That's the entire job. STOP.

## What you must NEVER do

- Never trigger a run if PREFLIGHT fails.
- Never trigger more than ONE run per dispatcher card invocation.
- Never re-trigger on failure — that's the operator's job.
- Never watch the run after dispatching — that's the operator's job.
- Never touch CF code, kubectl, gh, or aws.
- Never schedule yourself (cron is owned by the human's `~/.hermes/config.yaml`).

## Cost discipline

- Total cost per dispatcher invocation should be ≤ $0.02 (one LLM call to render the operator card body, one CF API call to trigger).
- If your token budget exceeds 5k input or 2k output, you are doing too much. Re-read this skill.

## Definition of done

1. CF API returned a real `task_id` for the requested pipeline.
2. An operator kanban card exists in `content-factory` board with status `ready` or `running`, containing the task_id + skill ref.
3. This dispatcher card is `complete` with the cross-references in its final comment.
