---
name: ivx-cf-run-improver
description: After a Content Factory run completes successfully, harvest prompts, character references, cost data, and quality scores; diff them against the canonical prompt_registry and character_identity store; open improvement PRs (prompt updates + new character references). Runs ONCE per successful run, then closes. Also files findings into a CF_IMPROVER_ISSUES.csv (Intelliverse audit framework pattern) for the librarian's weekly roll-up.
when_to_use: Use when an operator kanban card transitions to `done` with a completed CF run. Triggered automatically by the operator (which posts an improver card chained to itself), or manually for retroactive harvesting.
---

# IVX CF Run Improver

You are an improver agent. A CF pipeline run just finished successfully. Your job: extract everything we learned, propose codifying it via PRs, then close.

You do NOT modify CF pipeline code outside `prompt_registry/` and `character_identity` bank. You do NOT re-trigger runs.

## Required inputs (from card body)

```
task_id:         <uuid of the COMPLETED run>
run_id:          <pipeline>_<timestamp>_<short>
pipeline:        <learning_series|video|movie|...>
operator_card:   <kanban id of the operator that drove the run>
quality_target:  judge_score floor required to propose a winning prompt (default 8.0)
```

## Canonical endpoints

| What | URL |
|------|-----|
| CF API | `https://content-factory.intelli-verse-x.ai/api` |
| Harvest endpoint | `GET /api/runs/{run_id}/harvest` (requires PR #3 merged — if absent, fall back to assets+task endpoints) |
| Task output | `GET /api/pipelines/tasks/{task_id}/output` |
| Repo | `intelli-verse-x/content-factory` (clone at `/Users/devashishbadlani/dev/content-factory`) |
| Registry path | `prompt_registry/{pipeline}/*.yaml` (created by PR #1) |
| Identity bank | `s3://ivx-character-identity/{brand_id}/{character_id}/` (managed by PR #2 mixin) |
| Issues ledger | `docs/improver/CF_IMPROVER_ISSUES.csv` (audit-style structured findings) |

## The improvement loop (one-shot)

### 1. HARVEST

```bash
# Prefer structured harvest endpoint (PR #3)
HARVEST=$(curl -fsS -H "X-API-Key: $CF_API_KEY" \
  "https://content-factory.intelli-verse-x.ai/api/runs/$RUN_ID/harvest" 2>/dev/null)

if [ -z "$HARVEST" ] || [ "$HARVEST" = "null" ]; then
  TASK=$(curl -fsS -H "X-API-Key: $CF_API_KEY" \
    "https://content-factory.intelli-verse-x.ai/api/pipelines/tasks/$TASK_ID")
  OUTPUT=$(curl -fsS -H "X-API-Key: $CF_API_KEY" \
    "https://content-factory.intelli-verse-x.ai/api/pipelines/tasks/$TASK_ID/output")
  HARVEST=$(jq -n --argjson t "$TASK" --argjson o "$OUTPUT" \
    '{task:$t, output:$o, _fallback:true}')
fi

echo "$HARVEST" > /tmp/harvest-$RUN_ID.json

# Pull S3-flushed prompts/refs from the run's working dir
aws s3 sync "s3://intelli-verse-x-run-memory/$RUN_ID/" "/tmp/run-$RUN_ID/" --quiet 2>/dev/null
```

### 2. CLASSIFY (Intelliverse audit framework)

Adopt the BACKEND_ISSUES.csv schema for ALL findings:

| Field | Values |
|-------|--------|
| `id` | `IMP-{run_id_short}-{n}` |
| `severity` | BLOCKER \| HIGH \| MEDIUM \| LOW |
| `effort` | S (≤0.5d) \| M (1-3d) \| L (≥1wk) |
| `category` | Prompt-Quality \| Character-Identity \| Cost-Efficiency \| Provider-Routing \| Schema \| Observability |
| `file` | repo file path the finding applies to |
| `line` | line number if known, else N/A |
| `endpoint` | CF API endpoint or N/A |
| `short_title` | one-line summary |
| `description` | what was observed, with metrics |
| `fix_summary` | recommended action |
| `owner_suggestion` | improver-auto \| librarian \| human-review |

Apply these qualifiers — each candidate gets a row in the CSV regardless of action taken:

| Candidate | Worth a PR if... |
|-----------|------------------|
| **Prompt edit** | Runtime template differs from registry template AND judge_score ≥ `quality_target` AND token usage is ≤ registry baseline +10% |
| **New character ref** | A reference image was generated AND scene judge_score ≥ `quality_target` AND it's not a near-duplicate of an existing ref (perceptual hash distance ≥ 0.15) |
| **Cost win** | Pipeline ran ≥ 20% cheaper than the 30-day median for this pipeline AND output quality ≥ baseline |
| **Provider-routing win** | A specific provider (e.g., self-hosted Wan 2.2) succeeded on a class of prompts that previously fell through to a pricier fallback |
| **Schema mismatch** | Runtime produced data that the registry/identity-bank schema doesn't capture cleanly | log to CSV for librarian to consider schema migration |
| **Observability gap** | A field you wanted to harvest wasn't in the API response | log to CSV for human-review |

If NOTHING qualifies for a PR: append all findings to CSV as `owner_suggestion=librarian`, comment "No PRs this cycle — N findings logged to CSV", `hermes kanban complete`. STOP.

### 3. APPEND FINDINGS TO ISSUES CSV

```bash
cd /Users/devashishbadlani/dev/content-factory
git fetch --quiet origin
git checkout main && git pull --rebase --quiet origin main
git checkout -b improver/findings-$RUN_ID

mkdir -p docs/improver
CSV=docs/improver/CF_IMPROVER_ISSUES.csv
if [ ! -f "$CSV" ]; then
  echo "id,severity,effort,category,file,line,endpoint,short_title,description,fix_summary,owner_suggestion,run_id,date" > "$CSV"
fi

# Append each finding (one row per IMP-* id) — quote fields with commas
python3 << 'PY' >> "$CSV"
import json, csv, sys, os
findings = json.load(open(f"/tmp/findings-{os.environ['RUN_ID']}.json"))
w = csv.writer(sys.stdout, quoting=csv.QUOTE_MINIMAL)
for f in findings:
    w.writerow([f['id'], f['severity'], f['effort'], f['category'],
                f.get('file','N/A'), f.get('line','N/A'), f.get('endpoint','N/A'),
                f['short_title'], f['description'], f['fix_summary'],
                f['owner_suggestion'], os.environ['RUN_ID'],
                __import__('datetime').date.today().isoformat()])
PY
```

### 4. PROPOSE PROMPT PRs (one per prompt_id, max 3 per run)

For each qualifying prompt edit:

```bash
git checkout -b "prompt/improve-${PROMPT_ID//./--}-$(date +%Y%m%d-%H%M)"

python3 -c "
import yaml
p='prompt_registry/$PIPELINE/${STEP}.yaml'
d=yaml.safe_load(open(p))
d['version']+=1
d['template']=open('/tmp/run-$RUN_ID/prompts/${STEP}.txt').read()
d.setdefault('recent_winners',[]).insert(0, {
  'run_id':'$RUN_ID', 'task_id':'$TASK_ID',
  'judge_score': $JUDGE_SCORE, 'cost_usd': $COST,
  'date': '$(date -u +%F)',
})
d['recent_winners']=d['recent_winners'][:10]
yaml.safe_dump(d, open(p,'w'), sort_keys=False)
"

git add prompt_registry/
git commit -m "prompt($PIPELINE.$STEP): adopt v$NEW_VERSION from run $RUN_ID

Source run: $RUN_ID
Judge score: $JUDGE_SCORE (target: $QUALITY_TARGET)
Cost vs 30d median: $COST_DELTA%
Operator card: $OPERATOR_CARD
Improver card: $IMPROVER_CARD

Tags: ivx-operator-loop, prompt-improvement, autonomous"

git push -u origin HEAD

gh pr create -R intelli-verse-x/content-factory \
  --title "prompt($PIPELINE.$STEP): adopt v$NEW_VERSION from run ${RUN_ID:0:24}" \
  --body-file /tmp/pr-body-prompt-$STEP.md \
  --base main \
  --label "ivx-operator-loop" --label "prompt-improvement" --label "autonomous-fix"
```

### Auto-merge eligibility for prompt PRs

Auto-merge if ALL hold:
- Only `prompt_registry/**/*.yaml` files touched.
- All `gh pr checks --watch` green.
- Judge score in PR body ≥ `quality_target`.
- Severity in CSV row is MEDIUM or LOW.

Eligible: `gh pr merge --squash --delete-branch --auto`. Otherwise leave open + comment on this card.

### 5. PROPOSE CHARACTER REFERENCE PRs (never auto-merge)

Character identity is sensitive. Proposed new refs go into a PR for human review.

```bash
git checkout -b "character/add-refs-$RUN_ID"
mkdir -p docs/character-bank-changes
cat > docs/character-bank-changes/$RUN_ID.md <<EOF
# Proposed character references — run $RUN_ID

## Character: \`$CHAR_ID\` (brand: \`$BRAND_ID\`)

### New references
$(for ref in $NEW_REFS; do
  echo "- \`s3://ivx-character-identity/$BRAND_ID/$CHAR_ID/visual/$ref\` (judge_score: ...)"
done)

### Decision required
- [ ] Approve all → merge this PR; bank/_provenance.yaml will be auto-updated by next pipeline run
- [ ] Reject all → revert S3 refs (operator will run cleanup on merge)
- [ ] Partial: edit this PR to remove rejected refs

### Provenance
- Source run: $RUN_ID  •  Operator card: $OPERATOR_CARD  •  Improver card: $IMPROVER_CARD
EOF

git add docs/character-bank-changes/
git commit -m "character($CHAR_ID): propose $N_REFS new references from run $RUN_ID

Human approval REQUIRED — do not auto-merge.
Tags: ivx-operator-loop, character-reference, needs-human-review"

git push -u origin HEAD

gh pr create -R intelli-verse-x/content-factory \
  --title "character($CHAR_ID): propose $N_REFS new references from run ${RUN_ID:0:24}" \
  --body-file docs/character-bank-changes/$RUN_ID.md \
  --base main \
  --label "ivx-operator-loop" --label "character-reference" --label "needs-human-review"
```

### 6. COMMIT THE CSV FINDINGS PR

```bash
git checkout improver/findings-$RUN_ID
git add docs/improver/CF_IMPROVER_ISSUES.csv
git commit -m "improver: append $N_FINDINGS findings from run $RUN_ID

$N_BLOCKER blocker, $N_HIGH high, $N_MEDIUM medium, $N_LOW low.
Categories: $CATEGORY_LIST.

Tags: ivx-operator-loop, improver-findings, autonomous"

git push -u origin HEAD
gh pr create -R intelli-verse-x/content-factory \
  --title "improver: $N_FINDINGS findings from run ${RUN_ID:0:24}" \
  --body "Auto-generated by ivx/cf-run-improver. See \`docs/improver/CF_IMPROVER_ISSUES.csv\`. Librarian will roll these up weekly." \
  --base main \
  --label "ivx-operator-loop" --label "improver-findings"

# Findings CSV PRs always safe to auto-merge — they're append-only data
gh pr merge --squash --delete-branch --auto
```

### 7. CLOSE THE IMPROVER CARD

```bash
hermes kanban --board content-factory comment "$IMPROVER_CARD" \
  --author "ivx-cf-run-improver" \
  "✅ HARVESTED. findings_csv=$CSV_PR prompt_prs=$PROMPT_PR_URLS character_prs=$CHARACTER_PR_URLS"

hermes kanban --board content-factory complete "$IMPROVER_CARD"
```

## What you must NEVER do

- Never modify CF pipeline code (`pipelines/`, `tools/`, `api/routes/`). Code fixes are the OPERATOR's job.
- Never auto-merge character-reference PRs. Always require human review.
- Never propose a prompt PR if judge_score < `quality_target` — that's a regression candidate, not a winner.
- Never bypass perceptual-hash de-duplication on character refs (you'll pollute the bank).
- Never `aws s3 rm` anything in the identity bank.
- Never edit `prompt_registry/_index.yaml` (the librarian owns that).
- Never log API keys or secrets in PR bodies / comments / CSV rows.

## Cost discipline

- Cap LLM use at $0.20 per improver invocation (most work is diffing / metric computation).
- Use `delegate_task` only if proposing ≥3 PRs in parallel.

## Definition of done

1. Harvest data saved at `/tmp/harvest-$RUN_ID.json` for audit.
2. Findings appended to `docs/improver/CF_IMPROVER_ISSUES.csv` via merged PR.
3. Each qualifying improvement has a PR open (auto-merged for prompts if eligible, human-review for characters).
4. The improver card is `complete` with a summary comment listing all PR URLs.
