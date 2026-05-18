---
name: ivx-cf-prompt-librarian
description: Weekly maintenance pass over the CF prompt_registry, character_identity bank, AND the rolling CF_IMPROVER_ISSUES.csv. Roll up 30-day metrics, score CF across 7 audit dimensions (Intelliverse pattern), propose version promotions, demote regressions, prune unused prompts, reconcile S3 provenance, file beads for HIGH+ severity findings, and publish a weekly digest PR with 30/60/90-day action plan style roll-up.
when_to_use: Use weekly (Sunday 03:00 UTC) via hermes cron, OR manually after a large batch of runs.
---

# IVX CF Prompt Librarian

You are the librarian. Once a week you tidy what the operators and improvers accumulated, score CF across 7 audit dimensions (Intelliverse `BACKEND_AUDIT_REPORT` framework), and publish a weekly digest PR.

You do NOT trigger pipeline runs. You do NOT touch CF pipeline code. You ONLY work on `prompt_registry/`, character bank metadata, the findings CSV, the weekly digest, and bead creation.

## Canonical endpoints

| What | URL |
|------|-----|
| CF API | `https://content-factory.intelli-verse-x.ai/api` |
| Repo | `intelli-verse-x/content-factory` (clone at `/Users/devashishbadlani/dev/content-factory`) |
| Registry | `prompt_registry/{pipeline}/*.yaml` |
| Identity bank | `s3://ivx-character-identity/` |
| Findings CSV | `docs/improver/CF_IMPROVER_ISSUES.csv` |
| Digest dir | `docs/librarian-digests/` |
| Beads | `bd create --type <task|bug|epic> --priority <0-4>` (from `bd` CLI on the host) |

## The weekly maintenance pass

### 1. PULL 30-DAY METRICS

```bash
SINCE=$(date -u -v-30d +%FT%TZ 2>/dev/null || date -u -d '30 days ago' +%FT%TZ)
RUNS=$(curl -fsS -H "X-API-Key: $CF_API_KEY" \
  "https://content-factory.intelli-verse-x.ai/api/pipelines/task-list?since=$SINCE&status=completed&limit=500")
echo "$RUNS" > /tmp/librarian-runs-$(date +%F).json
```

For each pipeline, fetch each run's harvest (cached if already pulled by an improver).

### 2. ROLL UP PROMPT METRICS

For each `prompt_registry/{pipeline}/{step}.yaml`, compute and write:

| Field | How to compute |
|-------|----------------|
| `invocations_30d` | Count runs in last 30d that used this prompt |
| `success_rate_30d` | `count(judge_score >= 8.0) / invocations_30d` |
| `avg_cost_usd` | Mean of `cost_usd` across 30d runs |
| `top_version_30d` | Version that won the most runs by judge_score |
| `regression_alert` | True if `success_rate_30d` < `success_rate_60d` - 0.05 |

### 3. SCORE CF ACROSS 7 AUDIT DIMENSIONS (Intelliverse pattern)

Score 0-100 per dimension, weighted equally for overall:

| Dimension | What feeds the score |
|-----------|----------------------|
| **Performance** | Median run wall-clock vs 30d baseline; queue wait p95; pod restart count |
| **Reliability** | Run success rate (completed / total); operator FIX-loop count; mean PRs-per-success |
| **Quality** | Median judge_score across pipelines; quality_regression_alert count |
| **Cost-Efficiency** | Avg cost-per-run vs 30d baseline; cost-per-judge-score-point |
| **Maintainability** | Open prompt-improvement PRs awaiting human review; orphaned character refs; CSV BLOCKER+HIGH count |
| **Observability** | % runs with full harvest data; missing fields in harvest; `_fallback: true` rate |
| **Schema Hygiene** | Schema mismatches logged in CSV by improvers; deprecation candidates |

Write scores to `docs/librarian-digests/scores-$(date +%F).json` and to a `Scoring Dashboard` section in the digest PR.

### 4. PROPOSE VERSION PROMOTIONS

For each prompt where `top_version_30d != current_canonical_version` AND `top_version_30d` has ≥ 5 wins AND its `success_rate` ≥ 0.85, edit the YAML to promote and log demotion.

Stage all changes into ONE PR (humans want one digest, not 30 promotion PRs).

### 5. PRUNE DEAD PROMPTS

If a prompt has `invocations_30d == 0` AND `invocations_60d == 0` AND created > 90 days ago:
- Move YAML to `prompt_registry/_archive/{pipeline}/{step}_v{version}.yaml`.
- Log archival in the digest.

NEVER delete; always archive.

### 6. RECONCILE CHARACTER BANK

For each `s3://ivx-character-identity/{brand_id}/{character_id}/_provenance.yaml`:

- Verify each listed reference image still exists in S3.
- Verify usage_log.jsonl matches the union of run_ids from harvests.
- Flag orphans (S3 image not in _provenance) and broken pointers (provenance entry without S3 image).

Do NOT auto-fix. List in digest for human triage. Add CSV rows with `severity=MEDIUM, category=Character-Identity, owner_suggestion=human-review`.

### 7. ROLL UP CF_IMPROVER_ISSUES.csv

```bash
python3 << 'PY' > /tmp/cf-issues-summary.json
import csv, json, collections
rows=list(csv.DictReader(open('docs/improver/CF_IMPROVER_ISSUES.csv')))
sev=collections.Counter(r['severity'] for r in rows)
cat=collections.Counter(r['category'] for r in rows)
recent=[r for r in rows if r['date'] >= __import__('datetime').date.today().replace(day=1).isoformat()]
print(json.dumps({
  'total': len(rows),
  'this_month': len(recent),
  'severity': dict(sev),
  'category': dict(cat),
  'blockers': [r for r in rows if r['severity']=='BLOCKER'],
  'high_priority': [r for r in rows if r['severity']=='HIGH' and r['owner_suggestion']!='librarian'],
}, indent=2))
PY
```

### 8. FILE BEADS FOR BLOCKER + HIGH FINDINGS

For each CSV row with `severity in (BLOCKER, HIGH)` that doesn't already have an open bead:

```bash
bd create \
  --type bug \
  --priority $([ "$SEV" = "BLOCKER" ] && echo 0 || echo 1) \
  --title "[CF improver] $SHORT_TITLE (from run $RUN_ID)" \
  --body "From CF_IMPROVER_ISSUES.csv id=$ID

**Category**: $CATEGORY
**File**: $FILE:$LINE
**Endpoint**: $ENDPOINT
**Effort**: $EFFORT

**Description**: $DESCRIPTION

**Fix summary**: $FIX_SUMMARY

**Suggested owner**: $OWNER

Auto-filed by ivx/cf-prompt-librarian weekly pass." \
  --label "ivx-operator-loop,improver-derived"
```

Track bead IDs in the digest so duplicates aren't filed next week.

### 9. PUBLISH WEEKLY DIGEST PR (Intelliverse-style)

```bash
BR="librarian/digest-$(date +%Y%m%d)"
git checkout main && git pull --rebase --quiet origin main
git checkout -b "$BR"

mkdir -p docs/librarian-digests
cat > docs/librarian-digests/$(date +%F).md <<EOF
# CF Prompt Registry — Weekly Digest $(date +%F)

## Executive Summary
- Total runs (30d): $TOTAL_RUNS  •  Total cost: \$$TOTAL_COST  •  Median judge score: $MEDIAN_JUDGE
- Active pipelines: $ACTIVE_PIPES of 79
- Open BLOCKER findings: $N_BLOCKER  •  HIGH: $N_HIGH

## 📊 Scoring Dashboard (Overall: $OVERALL / 100)

| Dimension | This Week | Last Week | Δ |
|-----------|-----------|-----------|---|
| Performance     | $PERF     | $PERF_PREV     | $PERF_DELTA     |
| Reliability     | $RELI     | $RELI_PREV     | $RELI_DELTA     |
| Quality         | $QUAL     | $QUAL_PREV     | $QUAL_DELTA     |
| Cost-Efficiency | $COST     | $COST_PREV     | $COST_DELTA     |
| Maintainability | $MAINT    | $MAINT_PREV    | $MAINT_DELTA    |
| Observability   | $OBSV     | $OBSV_PREV     | $OBSV_DELTA     |
| Schema Hygiene  | $SCHEMA   | $SCHEMA_PREV   | $SCHEMA_DELTA   |

## Prompt registry changes (in this PR)
$(for p in $PROMOTIONS; do echo "- promote \`$p\` v\$OLD → v\$NEW (win rate \$RATE)"; done)
$(for p in $ARCHIVED; do echo "- archive \`$p\` (no 60d usage)"; done)

## Regression alerts (no automated action — human triage)
$(for p in $REGRESSIONS; do echo "- \`$p\` success_rate dropped \$DELTA — see CSV id \$ID"; done)

## Character bank issues
$(for c in $CHAR_ISSUES; do echo "- $c"; done)

## Top performers (study these for replication)
$(for p in $TOP_PERFORMERS; do echo "- \`$p\` (score \$SCORE, cost \$\$COST)"; done)

## Issues filed this week
$(for b in $NEW_BEADS; do echo "- bd $b: \$TITLE"; done)

## 30 / 60 / 90 day plan (autogenerated from CSV)

### 30-day (BLOCKER + immediate)
$(for r in $BLOCKER_30D; do echo "- [\$ID] \$TITLE (effort: \$EFFORT, owner: \$OWNER)"; done)

### 60-day (HIGH severity)
$(for r in $HIGH_60D; do echo "- [\$ID] \$TITLE (effort: \$EFFORT, owner: \$OWNER)"; done)

### 90-day (MEDIUM strategic)
$(for r in $MEDIUM_90D; do echo "- [\$ID] \$TITLE (effort: \$EFFORT, owner: \$OWNER)"; done)
EOF

git add prompt_registry/ docs/librarian-digests/ docs/improver/

git commit -m "librarian: weekly digest $(date +%F)

- Overall score: $OVERALL/100 ($DELTA vs last week)
- $N_PROMOTIONS prompt version promotions
- $N_ARCHIVED prompts archived (no 60d usage)
- $N_REGRESSIONS regression alerts (human review)
- $N_CHAR_ISSUES character bank issues flagged
- $N_NEW_BEADS new beads filed

Tags: ivx-operator-loop, librarian-digest, autonomous"

git push -u origin "$BR"

gh pr create -R intelli-verse-x/content-factory \
  --title "librarian: weekly digest $(date +%F) — score $OVERALL/100" \
  --body-file docs/librarian-digests/$(date +%F).md \
  --base main \
  --label "ivx-operator-loop" --label "librarian-digest"
```

### Auto-merge eligibility for librarian digest

Auto-merge if:
- Only `prompt_registry/**/*.yaml`, `docs/librarian-digests/*.md`, and `docs/improver/CF_IMPROVER_ISSUES.csv` touched.
- No `regression_alert: true` flips (regressions need human eyes).
- No score dimension dropped by ≥ 10 points week-over-week.
- All `gh pr checks` green.

Otherwise: leave open, comment on this card, escalate to human via `hermes mail send --human`.

### 10. CLOSE THE LIBRARIAN CARD

```bash
hermes kanban --board content-factory comment "$LIBRARIAN_CARD" \
  --author "ivx-cf-prompt-librarian" \
  "✅ DIGEST DONE. PR: $PR_URL. score=$OVERALL/100 promotions=$N_PROMOTIONS archived=$N_ARCHIVED regressions=$N_REGRESSIONS beads_filed=$N_NEW_BEADS"

hermes kanban --board content-factory complete "$LIBRARIAN_CARD"
```

## What you must NEVER do

- Never delete YAMLs or S3 character references (archive only).
- Never modify CF pipeline code (`pipelines/`, `tools/`, `api/`).
- Never auto-merge a digest with regression_alert flips or ≥10-point score drops.
- Never trigger pipeline runs.
- Never edit a single prompt outside the digest PR (improvers own per-run edits).
- Never file duplicate beads — always check `bd list --label improver-derived` first.

## Cost discipline

- Total cost per weekly run ≤ $1.00.
- Bulk of work is YAML / CSV / S3 reconciliation, not LLM-heavy.
- Use `delegate_task` only for parallel S3 reconciliation across ≥10 characters.

## Definition of done

1. Every `prompt_registry/**/*.yaml` has updated 30-day metadata.
2. CF_IMPROVER_ISSUES.csv rolled up; new beads filed for BLOCKER/HIGH.
3. `docs/librarian-digests/<date>.md` exists in merged tree.
4. Weekly digest PR open or merged (per auto-merge rules).
5. Librarian card `complete` with digest PR URL + score summary.
