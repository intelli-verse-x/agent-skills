# Session handoff — wiring rollout status

State of the 5-step wiring plan after the merge pass on 2026-05-17:
**PR #7 is merged**, kagent kit fixed for the real cluster, two
operational steps still need user-side runtime.

## Merged / done

| # | Step | Artifact | Status |
|---|---|---|---|
| 1 | Gap A — gastown MCP via ophis | [intelli-verse-x/gastown#7](https://github.com/intelli-verse-x/gastown/pull/7) | ✅ **MERGED** (squash `2f45f849`); 289 tools exported by `gt mcp tools`; CI: Lint/Windows/cross-review green, two pre-existing failures (see follow-up #9) |
| 2 | Gap C — agent-skills registry | [intelli-verse-x/agent-skills](https://github.com/intelli-verse-x/agent-skills) | ✅ Repo created + seeded with 5 skills + bringup kits |
| 5b | kagent kit ns fix | this repo | ✅ `CF_NAMESPACE` parameterized (default `content-factory`, set `=aicart` for `ai-cart-auto-cluster`); install.sh validates ns existence before applying RBAC |

## Open

| # | Step | Artifact | Status |
|---|---|---|---|
| 3 | Gap — Firecrawl LIVE_PROVIDER in CF | [intelli-verse-x/content-factory#19](https://github.com/intelli-verse-x/content-factory/pull/19) | 🟡 PR open, mergeable, 8/8 unit tests green — needs review + merge before Hermes proof-run exercises new signals |

## Prepped — runtime-blocked, one-command bring-up

| # | Step | Kit | Runtime requirement |
|---|---|---|---|
| 4 | Hermes Kanban boards + proof run | [`bringup/hermes-kanban/`](bringup/hermes-kanban/README.md) | Run on the box that already hosts Hermes (this session's laptop does not). Needs Hermes with a configured model provider, `FIRECRAWL_API_KEY` for the new live signals, and PR #19 merged so the queued `learning_series.yaml` actually exercises the Firecrawl LIVE_PROVIDER. |
| 5 | kagent eval | [`bringup/kagent/`](bringup/kagent/README.md) | `kubectl` context on the target cluster (verified — current cluster is `arn:aws:eks:us-east-1:...:cluster/ai-cart-auto-cluster`) + `helm` + `OPENAI_API_KEY` exported. Use `CF_NAMESPACE=aicart` on this cluster. |

## Why steps 4 and 5 weren't run autonomously

**Step 4 (Hermes Kanban)** — this session's laptop is not the Hermes
host. There is no `hermes` binary on PATH, no `~/.hermes/config.yaml`,
no local model provider key, and no local Content Factory API server.
Installing Hermes here would create a *new* swarm instance disconnected
from the real one, queue boards/profiles only against this fresh
instance, and the proof-run would fail because:
- the Content Factory API the dispatcher targets is in-cluster (svc
  `content-factory-api` in ns `aicart`), not reachable on `localhost`;
- `FIRECRAWL_API_KEY` is not exported in this shell;
- PR #19 (Firecrawl LIVE_PROVIDER) has not yet merged, so even with
  the key the new code path would not be exercised.

The right place to run the four scripts is whichever existing operator
box already runs the Hermes dispatcher — they ship one-shot.

**Step 5 (kagent)** — kubectl context, helm, cluster reachability
are all verified. Missing only `OPENAI_API_KEY` in the shell env. The
namespace mismatch (kit defaulted to `content-factory` but this cluster
uses `aicart`) is fixed in commit `527b16c` of this repo.

Run, once the key is available, with:

```bash
# Step 4 — on the Hermes operator box
cd bringup/hermes-kanban
./scripts/install-config.sh
./scripts/create-boards.sh
./scripts/create-profiles.sh
./scripts/queue-proof-run.sh "Newton's three laws of motion" 3 en-US

# Step 5 — on the operator box with kubectl + helm
cd bringup/kagent
export OPENAI_API_KEY=sk-...
CF_NAMESPACE=aicart ./scripts/install.sh   # intelli-verse-x EKS
# (or just `./scripts/install.sh` for clusters where the ns is literally `content-factory`)
# then walk scripts/eval-checklist.md
```

## Follow-up beads (file once `bd` is back on PATH)

Issues are disabled on `intelli-verse-x/gastown` (it's a fork), so
these live in the PR #7 description's "Follow-ups" section + here.

**Step 1 follow-ups:**
1. Tighten `gt mcp` allowlist if Claude Desktop's tool-list payload is too large — swap `AllowCmdsContaining` for `AllowCmds` with explicit paths.
2. Add an integration test that boots `gt mcp serve` and asserts the `tools/list` shape + count band + critical inclusions/exclusions.
3. Add `gastown` to per-role MCP allowlist in `gastown/internal/hooks/mcp.go`.
4. Wire `gastown` MCP into the cross-review GitHub Action.
9. Fix `internal/cmd.TestSyncTargetUnchanged` — failing on `main` (verified via `git checkout main && go test -run TestSyncTargetUnchanged ./internal/cmd/`). Pre-dates PR #7, blocking the `Test` and `Integration Tests` checks for every PR until it's repaired. Looks like an environmental sync target check that no longer matches expectations.

**Step 3 follow-ups:**
5. Call `install_live_provider()` once on `pipeline-worker` startup.
6. Redis cache layer keyed on `(niche, locale, query)` with 6-12h TTL.
7. Surface per-source signal mix in `IdeationBrief.signals` metadata.
8. Update `pipelines/CONTENT_FACTORY.md` "Live ASO signals" section.

**Step 4 follow-ups (after first kanban run):**
9. Capture failure modes and tighten `kanban.failure_limit`.
10. Add a daily `hermes cron` to run `learning_series` for QuizVerse and auto-publish via Postiz.

**Step 5 follow-ups (after 2-week eval):**
11. If green, PR `intelli-verse-kube-infra` to move kagent to `kagent-system` namespace with cluster-wide RBAC.
12. Promote the 3 eval agents to production CRDs under `bringup/kagent/production/`.
