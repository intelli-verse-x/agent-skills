---
name: ivx-cf-context-bootstrap
description: Apply the Intelliverse-X-AI context-engineering pattern to a target repo (default content-factory). Runs `bootstrap_context_engineering.py` to scaffold .cursorrules + AGENT.md + AGENTS.md + .cursor/{SYSTEM_MAP, HOT_CONTEXT, ANTI_PATTERNS, DECISION_TREE, MAINTENANCE}.md + .cursor/rules/{26 commands}/RULE.md + .cursor/memory/{patterns,decisions,corrections,context-cache}.json + docs/tracking + tools/scripts/verify_context_setup.py. After bootstrap, customizes the generated files for CF (pipeline taxonomy in HOT_CONTEXT, CF anti-patterns from BACKEND_ISSUES.csv pattern, ivx-operator-loop in DECISION_TREE), then opens a PR.
when_to_use: Use ONCE per repo you want to bring under the structured agent-context regime. After bootstrap, hermes workers (operators, improvers, librarian) load context via the structured hierarchy instead of ad-hoc reading.
---

# IVX CF Context Bootstrap

You are the bootstrapper. Your job: run the Intelliverse context-engineering script against a target repo and customize the output for that repo's domain.

You do NOT design the context taxonomy — `bootstrap_context_engineering.py` already does that. You ONLY run it, then domain-customize and PR.

## Required inputs (from card body)

```
target_repo:   absolute path to the repo to bootstrap (e.g. /Users/devashishbadlani/dev/content-factory)
project_type:  one of {web, backend, mobile, unity, unreal, python-ml, rust, go, general}
                (default: auto-detect via --auto flag)
domain:        free-form domain hint (e.g. "AI content generation pipelines")
upstream:      GitHub repo slug for the PR (e.g. intelli-verse-x/content-factory)
```

## Why this matters for CF

Every hermes worker (operator, improver, librarian) currently loads its full SKILL.md each cycle. With Intelliverse's hierarchy in place:

| Worker phase | Loads instead |
|--------------|---------------|
| WATCH (operator polling) | `.cursor/HOT_CONTEXT.md` only (~3k tokens) |
| DIAGNOSE | `.cursor/DECISION_TREE.md` + `.cursor/ANTI_PATTERNS.md` (~5k tokens) |
| FIX | full skill + repo `AGENT.md` (~12k tokens) |
| DEPLOY watch | `.cursor/HOT_CONTEXT.md` + `MAINTENANCE.md` (~4k tokens) |

Estimated 40-60% reduction in per-cycle token cost across the swarm.

## The bootstrap flow

### 1. PREFLIGHT

```bash
# Source script must exist
SCRIPT=/Users/devashishbadlani/dev/Intelliverse-X-AI/bootstrap_context_engineering.py
[ -f "$SCRIPT" ] || { echo "FAIL: bootstrap script missing"; exit 1; }

# Target repo must exist, be a git repo, and have a clean working tree
[ -d "$TARGET_REPO/.git" ] || { echo "FAIL: $TARGET_REPO not a git repo"; exit 1; }
( cd "$TARGET_REPO" && [ -z "$(git status --porcelain)" ] ) \
  || { echo "FAIL: $TARGET_REPO has uncommitted changes"; exit 1; }

# Python 3 available
python3 --version || { echo "FAIL: python3 not on PATH"; exit 1; }
```

If preflight fails: comment, block, escalate.

### 2. BRANCH + RUN BOOTSTRAP

```bash
cd "$TARGET_REPO"
git fetch --quiet origin
git checkout main && git pull --rebase --quiet origin main
BR="ctx-engineering/bootstrap-$(date +%Y%m%d-%H%M)"
git checkout -b "$BR"

# Run with auto-detect + auto-confirm; takes ~5s
python3 "$SCRIPT" --target "$TARGET_REPO" --auto $([ -n "$PROJECT_TYPE" ] && echo "--type $PROJECT_TYPE")

# Verify the output
python3 tools/scripts/verify_context_setup.py
```

### 3. DOMAIN CUSTOMIZATION (this is where the value-add lives)

The bootstrap creates generic stubs. Replace them with CF-specific content:

**`.cursor/HOT_CONTEXT.md`** — list CF's hot files:
- `api/routes/pipelines.py` — pipeline dispatcher
- `pipelines/series/learning.py`, `pipelines/video.py`, `pipelines/movie.py` — top pipelines
- `tools/generators/factory.py` — provider routing
- `utils/pipeline/voice_consistency.py`, `voice_memory.py`, `run_memory.py` — memory layer
- `pipelines/base/voice_mixin.py` — voice consistency mixin

Add `## Pipeline Taxonomy` section listing all 79 pipelines grouped by media kind (learning, video, comic, music, app-store, ...).

**`.cursor/ANTI_PATTERNS.md`** — convert open BLOCKER/HIGH rows from `docs/improver/CF_IMPROVER_ISSUES.csv` (if present) into don't/do code blocks. Also add CF-specific patterns:

```python
# ❌ DON'T hardcode prompts in pipeline code
SCRIPT_PROMPT = "Write a 3-minute educational script about..."

# ✅ DO load from prompt_registry
from prompt_registry import get_prompt
SCRIPT_PROMPT = get_prompt("learning_series.script_writer", version="canonical")
```

```python
# ❌ DON'T bypass character_identity mixin when a brand_id is provided
prompt = f"Generate scene with {character_name}..."

# ✅ DO inject identity context
from utils.pipeline.character_identity import inject_character_context
prompt = inject_character_context(base_prompt, brand_id, char_id)
```

**`.cursor/DECISION_TREE.md`** — add the ivx-operator-loop flow:

```
CF Pipeline Run
    │
    ▼
  WATCH (60s poll)
    │
    ▼
┌─────────────────┐
│ status?         │
└────────┬────────┘
         │
    ┌────┼────┬───────────┐
    │    │    │           │
completed failed stalled (>5 polls no progress)
    │    │    │           │
    ▼    ▼    ▼           ▼
  Improver  DIAGNOSE   DIAGNOSE
    │       │           │
    ▼       ▼           ▼
   DONE   classify     classify
          (A-F)        (A-F)
            │           │
            ├─ A/B →  FIX → DEPLOY → RETRY → WATCH
            ├─ C   →  RETRY with fixed payload
            ├─ D   →  ESCALATE (infra)
            ├─ E   →  ESCALATE (budget)
            └─ F   →  ESCALATE (unknown)
```

**`AGENT.md`** — fill out the File Registry with CF's actual top 30 files. Add Pipeline Taxonomy section. Add `## Operator Loop Integration` section explaining how the ivx-operator-loop swarm reads/writes to this repo.

**`.cursor/MAINTENANCE.md`** — adapt the weekly checklist:
- Weekly: review `docs/librarian-digests/<latest>.md`, triage CSV CSV BLOCKER+HIGH rows.
- Before release: run librarian on-demand to confirm `regression_alert == false`.
- Monthly: prune `prompt_registry/_archive/`, review `usage_log.jsonl` for cold characters.

### 4. ADD CF-SPECIFIC COMMANDS

Add 3 new rule files under `.cursor/rules/`:

- `.cursor/rules/operator-loop/RULE.md` — references the ivx/cf-pipeline-operator skill, explains how to manually queue an operator card.
- `.cursor/rules/improver/RULE.md` — explains how to run a retroactive improver pass on a past run.
- `.cursor/rules/librarian/RULE.md` — explains how to trigger the librarian on-demand (outside the weekly cron).

### 5. COMMIT + PR

```bash
git add .cursor/ .cursorrules .cursorignore AGENT.md AGENTS.md docs/tracking/ tools/scripts/verify_context_setup.py

git commit -m "context-engineering: bootstrap Intelliverse-X-AI agent context pattern

Adopts the structured context-engineering hierarchy from intelli-verse-x/Intelliverse-X-AI:
- .cursorrules + AGENT.md + AGENTS.md
- .cursor/{SYSTEM_MAP, HOT_CONTEXT, ANTI_PATTERNS, DECISION_TREE, MAINTENANCE}.md
- .cursor/rules/{core, context-router, plan, implement, review, qa, bugfixing, readiness, release, agentmd, refactor, perf, cleanup, test, doc, bughunt, api, deps, security, localize, migrate, onboard, dashboard, workreport, sessionlog}/RULE.md
- .cursor/rules/{operator-loop, improver, librarian}/RULE.md (CF-specific)
- .cursor/memory/{patterns, decisions, corrections, context-cache}.json
- docs/tracking/{BUGS, TASKS}.md
- tools/scripts/verify_context_setup.py

Customized for CF:
- HOT_CONTEXT lists 30 most-edited files + pipeline taxonomy
- ANTI_PATTERNS includes CF-specific don't/do (prompt_registry, character_identity)
- DECISION_TREE codifies the ivx-operator-loop flow
- AGENT.md File Registry + Operator Loop Integration section
- MAINTENANCE.md weekly checklist references librarian digests

Why: hermes workers (operator, improver, librarian) currently load full SKILL.md each cycle. With this hierarchy, they load HOT_CONTEXT (~3k tokens) for WATCH, DECISION_TREE+ANTI_PATTERNS (~5k) for DIAGNOSE, full only for FIX. Estimated 40-60% token reduction across the swarm.

Source: intelli-verse-x/Intelliverse-X-AI/bootstrap_context_engineering.py v2.0.0

Tags: ivx-operator-loop, context-engineering, autonomous"

git push -u origin HEAD

gh pr create -R "$UPSTREAM" \
  --title "context-engineering: bootstrap Intelliverse-X-AI agent context pattern" \
  --body-file /tmp/ctx-bootstrap-pr-body.md \
  --base main \
  --label "ivx-operator-loop" --label "context-engineering"

# Do NOT auto-merge — this is foundational, deserves human eyes
```

### 6. CLOSE THE BOOTSTRAP CARD

```bash
hermes kanban --board content-factory comment "$BOOTSTRAP_CARD" \
  --author "ivx-cf-context-bootstrap" \
  "✅ BOOTSTRAPPED $TARGET_REPO. PR: $PR_URL. Operators/improvers/librarian can load via the new hierarchy on next invocation (no skill code change needed — they already check for AGENT.md and .cursor/HOT_CONTEXT.md preferentially)."

hermes kanban --board content-factory complete "$BOOTSTRAP_CARD"
```

## What you must NEVER do

- Never bootstrap a repo with a dirty working tree (you'll mix unrelated changes).
- Never run bootstrap_context_engineering.py against `intelli-verse-x/Intelliverse-X-AI` itself (it's the source — never touch).
- Never auto-merge the bootstrap PR (it touches dozens of files and humans need to skim them).
- Never delete pre-existing `AGENT.md` / `AGENTS.md` files — back them up to `AGENT.md.pre-bootstrap.bak` first.

## Definition of done

1. `tools/scripts/verify_context_setup.py` returns 0 (all required files present).
2. PR open on the target repo with the bootstrap diff + CF-specific customizations.
3. Bootstrap card `complete` with PR URL.
