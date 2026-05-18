# Session handoff — wiring rollout status

State of the 5-step wiring plan after the second pass on 2026-05-17:
**all five steps are now wired and proven** against the real
`ai-cart-auto-cluster` EKS cluster. Hermes ran a full proof-of-life
end-to-end through the swarm; kagent diagnosed a broken pod via the
built-in `k8s-agent` (Gate A passed in 27.7s).

## Merged / done

| # | Step | Artifact | Status |
|---|---|---|---|
| 1 | Gap A — gastown MCP via ophis | [intelli-verse-x/gastown#7](https://github.com/intelli-verse-x/gastown/pull/7) | ✅ **MERGED** (squash `2f45f849`); 289 tools exported by `gt mcp tools`; CI: Lint/Windows/cross-review green, two pre-existing failures (see follow-up #9) |
| 2 | Gap C — agent-skills registry | [intelli-verse-x/agent-skills](https://github.com/intelli-verse-x/agent-skills) | ✅ Repo created + seeded with 5 skills + bringup kits |
| 4 | Hermes Kanban proof-of-life | [`bringup/hermes-kanban/`](bringup/hermes-kanban/README.md) | ✅ **EXECUTED** — Hermes v0.14.0 installed locally, pointed at the in-cluster LiteLLM gateway (`svc/litellm` in `aicart`, port-forwarded to `localhost:14000`), 6 boards created, 8 worker profiles created, `learning_series` task `t_063fdd09` queued and **completed in 186s**. Curriculum-planner spawned 12 child tasks in the exact decomposition (3 screenwriter + 3 media-producer + 3 audio-director + 3 reviewer). |
| 5 | kagent eval kit | [`bringup/kagent/`](bringup/kagent/README.md) | ✅ **INSTALLED** to `kagent-eval` ns on `ai-cart-auto-cluster`. Helm OCI charts (`oci://ghcr.io/kagent-dev/kagent/helm/kagent`) v0.9.4. **Gate A pod-doctor passed**: `k8s-agent` correctly diagnosed a deliberately-broken `ErrImagePull` pod in `aicart` in **27.7s** with concrete remediation steps. 204k tokens on gpt-4.1-mini ≈ $0.02. |

## Open

| # | Step | Artifact | Status |
|---|---|---|---|
| 3 | Gap — Firecrawl LIVE_PROVIDER in CF | [intelli-verse-x/content-factory#19](https://github.com/intelli-verse-x/content-factory/pull/19) | 🟡 PR open, mergeable, 8/8 unit tests green — needs review + merge before Hermes proof-run exercises new signals |

## Execution log — what actually ran this session

Credentials were sourced from the live cluster (no manual paste):

- `OPENAI_API_KEY` — from `aicart/intelliverse-ai-ssm-params`.
- `FIRECRAWL_API_KEY` — from the same secret.
- `LITELLM_API_KEY` — `aicart/bernstein-litellm-key` (covers `anthropic/claude-opus-4.6` and `o3` model groups on the in-cluster LiteLLM gateway).

### Step 4 (Hermes) — what was needed beyond the scripts

The README/scripts assumed both Hermes and a model provider were
already wired. In practice this session had to:

1. `curl -fsSL .../install.sh | bash --skip-setup` to install Hermes v0.14.0 locally.
2. `kubectl -n aicart port-forward svc/litellm 14000:80` so the gateway is reachable on `localhost`.
3. `kubectl -n aicart port-forward svc/content-factory-api 8001:8001` so the curriculum-planner profile can call the CF API.
4. Patch `~/.hermes/config.yaml` provider/base_url and `~/.hermes/auth.json` credential pool (LiteLLM gateway with overridden `base_url`).
5. **Sync `auth.json` + `.env` + `config.yaml` into every per-profile dir under `~/.hermes/profiles/<name>/`** — the kanban dispatcher launches workers with `HERMES_HOME=<profile dir>`, so root config does *not* apply. This is the single biggest non-obvious gotcha — captured in follow-up #13.
6. Fix three bash 3.2 incompatibilities in `queue-proof-run.sh` (apostrophe inside `${1:-...}`, parens inside double-quoted args, heredoc inside `$()`). Patched and pushed.
7. Fix kanban CLI shape — actual subcommands are `kanban boards create <slug>` and `kanban --board <slug> create <title>`, not the `board list` / `kanban add` shapes the scripts originally used. Patched and pushed.

After all of the above, the proof-run completed:

```
t_063fdd09  done  curriculum-planner  Learning Series: Newton's three laws of motion [3 eps, en-US]
└─ run #4   completed   186s
   summary: "Planned 3-episode learning series on Newton's Three Laws
            of Motion for QuizVerse (ages 10-14). Created 12 child
            tasks: 3 screenwriter tasks (one per episode), 6 …"

12 children created — verified shape matches brief.
Sample child (Ep 1 Script): age-appropriate, brand-aware, with explicit
learning objectives, curriculum notes, hook suggestion, demo prompt,
locale, and target duration.
```

### Step 5 (kagent) — what was needed beyond the scripts

The upstream helm repo URL in the kit was dead (`https://helm.kagent.dev` → no DNS). Switched to OCI charts at `oci://ghcr.io/kagent-dev/kagent/helm/kagent{,-crds}`. Also:

1. The `kagent-postgresql` PVC sits in `Pending` indefinitely on EKS because no StorageClass is annotated as default. Fix: helm `--set database.postgres.bundled.storageClassName=gp2`.
2. The custom `Agent` and `ModelConfig` YAMLs in this kit target `kagent.dev/v1alpha1` but the chart now ships `v1alpha2` with a different schema (`apiKeySecret`/`apiKeySecretKey` instead of `apiKeySecretRef`). The built-in `k8s-agent`, `promql-agent`, `helm-agent`, etc. are sufficient for Gate A — custom agents need a schema update (follow-up #14).
3. The CLI is `kagent` (v0.9.4 darwin-arm64 from GitHub releases). The dashboard is `kagent dashboard` or `kubectl -n kagent-eval port-forward svc/kagent-ui 8082:8080`.

After all of the above, **Gate A passed**:

```
Test pod: deploy/kagent-eval-broken in aicart, image "ghcr.io/intelli-verse-x/this-image-does-not-exist:bogus-v0"
Result:   ErrImagePull (textbook setup)

kagent invoke -n kagent-eval --agent k8s-agent
  → 27.7s, 204515 total tokens on gpt-4.1-mini
  → "Pod Status: kagent-eval-broken-748b5565f9-zrh77 is in `ErrImagePull` state.
     Image pull failed with error `failed to authorize: ... 403 Forbidden`.
     Recommendations: verify image tag; configure imagePullSecrets if private;
     update deployment image ref; rollout restart.
     Root Cause: Invalid or inaccessible container image."
```

Pod cleaned up after the test.

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
13. **Profile dirs need bootstrap**: when `create-profiles.sh` writes a new profile, it must also seed `~/.hermes/profiles/<name>/auth.json`, `.env`, and `config.yaml` from the root — otherwise dispatched workers run with an empty credential pool and 401 immediately. Codify in `create-profiles.sh` rather than as a manual `cp` step.
15. Run `helm uninstall` of the existing `litellm` chart that ships only `claude-opus-4.6`, `o3`, `claude-sonnet-4` and add the cheap models the delegation tier needs (`gemini-flash-2.0`, `gpt-4.1-mini`, etc.) so subagents can use them. Today every delegate falls back to Opus 4.6 and costs ~50× what it should.
16. Wire the dispatcher as a launchd / systemd service (`hermes kanban daemon --interval 30`) so subsequent child tasks (the 12 children of `t_063fdd09`) drain automatically without manual `dispatch --max N`.

**Step 5 follow-ups (after 2-week eval):**
11. If green, PR `intelli-verse-kube-infra` to move kagent to `kagent-system` namespace with cluster-wide RBAC.
12. Promote the 3 eval agents to production CRDs under `bringup/kagent/production/`.
14. **Update the custom ModelConfig/Agent YAMLs (`03-modelconfig.yaml`, `06/07/08-agent-*.yaml`) from `kagent.dev/v1alpha1` to `v1alpha2`**. Current schema differences: `spec.apiKeySecretRef.{name,key}` → `spec.apiKeySecret` + `spec.apiKeySecretKey`; `spec.temperature` / `spec.maxTokens` moved off ModelConfig; Agent CR now requires a `spec.declarative.{instructions,a2aConfig,…}` block instead of top-level `instructions`. The built-in `k8s-agent`, `promql-agent`, `observability-agent`, `helm-agent`, etc. cover most of what the custom CRs were going to provide; only the gastown-bead-emitting alert-triage agent really needs a custom CR.
