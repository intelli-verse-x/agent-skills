# Session handoff — wiring rollout status

State of the 5-step wiring plan as of this commit. Two PRs landed,
three runtime-blocked steps fully prepped.

## Done — ready to merge

| # | Step | Artifact | Status |
|---|---|---|---|
| 1 | Gap A — gastown MCP via ophis | [intelli-verse-x/gastown#7](https://github.com/intelli-verse-x/gastown/pull/7) | ✅ PR open, build green, 289 tools exported |
| 2 | Gap C — agent-skills registry | [intelli-verse-x/agent-skills](https://github.com/intelli-verse-x/agent-skills) | ✅ Repo created + seeded with 5 skills |
| 3 | Gap (Firecrawl LIVE_PROVIDER) | [intelli-verse-x/content-factory#19](https://github.com/intelli-verse-x/content-factory/pull/19) | ✅ PR open, 8/8 unit tests green |

## Prepped — runtime-blocked, one-command bring-up

| # | Step | Kit | Runtime requirement |
|---|---|---|---|
| 4 | Hermes Kanban boards + proof run | [`bringup/hermes-kanban/`](bringup/hermes-kanban/README.md) | Needs `hermes` installed + a configured model provider + Content Factory MCP servers running locally. |
| 5 | kagent eval in `content-factory` ns | [`bringup/kagent/`](bringup/kagent/README.md) | Needs `kubectl` context on the target K8s cluster + `helm` + `OPENAI_API_KEY`. |

## Why steps 4 and 5 didn't fully run

This session's runtime didn't have:
- An installed `hermes` CLI to actually create boards / profiles / queue the proof task.
- A `kubectl` context on the intelli-verse-x production cluster to run `helm upgrade --install kagent`.

Both kits are written so the next operator runs:

```bash
# Step 4
cd bringup/hermes-kanban
./scripts/install-config.sh
./scripts/create-boards.sh
./scripts/create-profiles.sh
./scripts/queue-proof-run.sh "Newton's three laws of motion" 3 en-US

# Step 5
cd bringup/kagent
export OPENAI_API_KEY=sk-...
./scripts/install.sh
# walk scripts/eval-checklist.md
```

## Follow-up beads (file once `bd` is back on PATH)

Issues are disabled on `intelli-verse-x/gastown` (it's a fork), so
these live in the PR #7 description's "Follow-ups" section + here.

**Step 1 follow-ups:**
1. Tighten `gt mcp` allowlist if Claude Desktop's tool-list payload is too large — swap `AllowCmdsContaining` for `AllowCmds` with explicit paths.
2. Add an integration test that boots `gt mcp serve` and asserts the `tools/list` shape + count band + critical inclusions/exclusions.
3. Add `gastown` to per-role MCP allowlist in `gastown/internal/hooks/mcp.go`.
4. Wire `gastown` MCP into the cross-review GitHub Action.

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
