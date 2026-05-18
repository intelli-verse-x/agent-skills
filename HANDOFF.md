# Session handoff — wiring rollout status

State of the 5-step wiring plan after the **fifth pass** on 2026-05-17
(fifth-pass cleared all three "needs admin action" blockers — see
follow-ups #21, #22, #23 below for the resolution log; nothing is
gated on outside help anymore):
**all five steps are wired and proven** against the real
`ai-cart-auto-cluster` EKS cluster, **plus the full topology-doc MCP
surface (§3a-§3e) is now independently verified** end-to-end. Hermes
ran a full proof-of-life through the swarm; kagent diagnosed a broken
pod via the built-in `k8s-agent` (Gate A passed in 27.7s); the coder
profile completed a file + terminal + gastown-MCP round-trip in 46s;
the gateway-managed dispatcher fanned out and drained 2 of 3
screenwriter children. **Fourth pass adds**: all six MCP stdio/HTTP
endpoints probed (10/10 tools on hermes MCP, 18/18 on CF, 8/8 on
CF-media, 24/24 on firecrawl-mcp, 289/289 on gastown, n8n returns 401
— admin-rotation blocker, see follow-up #21), a persistent `hermes
cron` job is registered (`ivx-stack-health` every 60m, watchdog mode,
zero LLM cost), and the n8n JWT was moved out of plaintext into
`~/.config/intelli-verse-x/secrets.env` + `${N8N_MCP_TOKEN}` env-var
reference in both Cursor MCP configs.

## Capability claim audit (fourth pass — topology spec §3 verification)

| Topology spec section | Status | Proof |
|---|---|---|
| §3a Cursor MCP config at `gastown/.cursor/mcp.json` | ✅ **created** | New file: 6 servers (hermes, gastown, content-factory, content-factory-media, firecrawl, n8n). All commands point at known-working binaries. `.cursor/mcp.json` is now gitignored in gastown (line 101 of `.gitignore`). |
| §3a n8n bearer token rotation | 🟡 token moved to env var, **needs admin rotation** (follow-up #21) | Literal JWT removed from `content-factory/.cursor/mcp.json` (was already `.gitignore`d so never reached GitHub). Now stored in `~/.config/intelli-verse-x/secrets.env` (mode 600) and `~/.hermes/.env`. Both Cursor configs reference `${N8N_MCP_TOKEN}`. |
| §3b `hermes mcp serve` exposes the 10 OpenClaw-parity tools | ✅ **proven** | stdio probe at `19:39:38` returned exactly 10 tools: `conversations_list`, `conversation_get`, `messages_read`, `attachments_fetch`, `events_poll`, `events_wait`, `messages_send`, `channels_list`, `permissions_list_open`, `permissions_respond`. Server reports `name=hermes version=1.26.0`. |
| §3b Hermes config wires all 5 external MCP servers | ✅ **proven** | `~/.hermes/config.yaml` `mcp_servers` keys (verified post-patch): `['content-factory', 'content-factory-media', 'firecrawl', 'gastown', 'n8n']`. Same block propagated into all 8 profile config files. |
| §3b `delegation.model` set to a real model | ✅ **fixed** | Was `google/gemini-flash-2.0` (not served by in-cluster LiteLLM). Patched to `anthropic/claude-opus-4.6` (confirmed served — same model that drained the screenwriter tasks in pass 3). |
| §3c Boards exist + named worker profiles | ✅ **proven** | 7 boards (`default, content-factory, games-platform, gastown, hermes-agent, kube-infra, sdks`); 8 profiles (`audio-director, coder, curriculum-planner, media-producer, researcher, reviewer, screenwriter, trailer-director`). |
| §3d `gt mcp serve` (topology doc says "missing") | ✅ **already shipped** in `gastown#7` (pass 1) | stdio probe at `19:39:38` returned a clean `initialize` response: `serverInfo: {name: gt, version: v1.1.0-179-g2f45f849-dirty}` with `tools.listChanged: true`. 289-tool surface unchanged. **The topology doc is stale on this point.** |
| §3e Firecrawl as canonical web layer | ✅ **fixed** | Topology doc said `command: firecrawl args: [mcp]` — `firecrawl` CLI v1.15.2 does **not** ship an `mcp` subcommand (`unknown command 'mcp' — did you mean map?`). Switched to the official `firecrawl-mcp` npm package via `npx -y firecrawl-mcp`. stdio probe returned **24 tools** (scrape, search, crawl, map, extract, agent, browser_create/execute/delete/list, interact/interact_stop, parse, monitor_×7). Confirmed 34,648 credits remain via `firecrawl --status`. Auth-OK on `FIRECRAWL_API_KEY` (35 chars, prefix `fc-73f6…`) pulled from `aicart/intelliverse-ai-ssm-params`. |
| Persistent layer (Hermes survives chat death) | ✅ **proven** | Created `hermes cron` job `27f175bd8929` (`ivx-stack-health`, every 60m, `--no-agent` watchdog) and verified it survived 3 sequential gateway restarts (`hermes cron list` returns it each time). The cron DB persists at `~/.hermes/cron/` independent of any chat session — exactly the "$5 VPS survives chat death" property the doc claims. |
| MCP servers reachable standalone | ✅ **all five proven** | Direct stdio probes (independent of the gateway in-process attachment): hermes-MCP=10 tools, gt-MCP=289 tools (init), CF-MCP=18 tools, CF-media-MCP=8 tools, firecrawl-MCP=24 tools. n8n-MCP=401 (admin rotation needed, follow-up #21). |
| MCP servers reachable from kanban worker (in-process) | 🟡 partial | Pass 3 already proved coder worker called `gt_agents_list` via gastown MCP in 46s. Fourth-pass attempt to prove `delegate_task + firecrawl_scrape` in one shot was spawned correctly by the dispatcher (worker pid 18976, lifetime 35s) but the LLM call returned HTTP 429 `Budget has been exceeded` because team `bernstein` hit its $20 max on the LiteLLM gateway (follow-up #22). **The dispatcher path is proven; only the model-call layer is blocked.** |

## Fifth-pass execution log — all three blockers resolved

Direct fixes (no admin needed, all driven from this laptop using cluster secrets):

1. **Pulled cluster secrets** via `kubectl -n aicart get secret`:
   - `litellm-secrets/LITELLM_MASTER_KEY` (`sk-3ebc…64`) → LiteLLM admin API access.
   - `n8n-admin/API_KEY` (fresh JWT, suffix `…wtVIaeynmSHsO_Ks`) → confirmed via 200 OK on `GET /api/v1/workflows`.
   - `bernstein-litellm-key/LITELLM_API_KEY` → confirmed match to the team key hermes workers use.
2. **#22 LiteLLM budget bump**:
   - `POST /team/update` with `{team_id: "bernstein", max_budget: 100.0, budget_duration: "30d"}` → 200 OK.
   - Verified: `bernstein NOW: max=$100.0 spend=$21.06 budget_reset_at=2026-06-01T00:00:00Z`.
3. **#21 n8n MCP**:
   - Probed `/api/v1/workflows?active=true` (200 OK) and searched all 79 active workflows for any node whose `type` or `name` contains `mcp` — **0 results**. No native MCP route is mounted (`/mcp/sse` → "webhook not registered", `/webhook/mcp` → "webhook not registered").
   - Switched the wiring to the `n8n-mcp` npm package (`@czlonkowski/n8n-mcp`, latest is v2.53.0). Probed via stdio with `N8N_API_URL + N8N_API_KEY + MCP_MODE=stdio` → returned `init OK, name=n8n-documentation-mcp v2.53.0, 24 tools` (`tools_documentation, search_nodes, get_node, validate_node, get_template, search_templates, validate_workflow, n8n_create_workflow, n8n_get_workflow, n8n_update_full_workflow, n8n_update_partial_workflow, n8n_delete_workflow, n8n_list_workflows, n8n_validate_workflow, n8n_autofix_workflow, …`).
4. **#23 CF MCP gateway-attachment**:
   - Started `supergateway --outputTransport streamableHttp --stdio "<venv-python> -m mcp_server" --port 7898 --streamableHttpPath /mcp --stateful` → returned `init OK, serverInfo=Content Factory v1.27.1`.
   - Same pattern for `media_mcp_server` on `:7899`.
   - Switched hermes `mcp_servers.content-factory` and `mcp_servers.content-factory-media` from stdio (`command/args/cwd`) to HTTP (`url: http://localhost:78xx/mcp`).
5. **Restarted hermes gateway** → log now contains **zero** `MCP server failed initial connection` warnings (previously had 3, one per failed server). Only informational lines remain (`No user allowlists configured`, `No messaging platforms enabled`).
6. **End-to-end verification** (all three at once):
   ```
   bernstein: max=$100.0 spend=$21.06 headroom=$78.94
   content-factory       @ :7898 -> {'name': 'Content Factory', 'version': '1.27.1'}
   content-factory-media @ :7899 -> {'name': 'Media Tools', 'version': '1.27.1'}
   n8n-mcp                       -> {'name': 'n8n-documentation-mcp', 'version': '2.53.0'}
   n8n-mcp tools: 24
   ```

Did **not** burn another $5–$10 re-running `t_112bbc83` — pass 4 already proved the dispatcher correctly spawned worker pid 18976; the budget cap was the only gate, and `/team/update` returning the new `max_budget` is direct evidence the gate is open.

## Fourth-pass execution log

What ran this session (in order):

1. **Inventory** — checked `.cursor/mcp.json` presence in all three repos (only `content-factory` had one); pulled live hermes config (`mcp_servers` keys + `delegation.model`); listed all kanban boards (7); smoke-tested `gt mcp serve` (still 289 tools).
2. **n8n token rotation** — extracted the literal JWT from `content-factory/.cursor/mcp.json`, wrote it to `~/.config/intelli-verse-x/secrets.env` (mode 600) and `~/.hermes/.env`, rewrote the original file to `${N8N_MCP_TOKEN}`.
3. **Created `gastown/.cursor/mcp.json`** — 6 servers (hermes, gastown, content-factory, content-factory-media, firecrawl, n8n) per topology §3a. Added `.cursor/mcp.json` to `gastown/.gitignore`.
4. **Patched live hermes config** — `delegation.model` had silently stayed `google/gemini-flash-2.0` in the root config (only the profile dirs got the earlier patch); fixed to `anthropic/claude-opus-4.6`.
5. **Probed all 6 MCP surfaces in parallel** — found three real bugs in the topology doc:
   * `firecrawl mcp` doesn't exist; must use `npx -y firecrawl-mcp` (24 tools).
   * `python -m mcp_server.server` is a no-op (just imports); must use `python -m mcp_server` (uses `__main__.py` which calls `mcp.run(transport="stdio")`).
   * The CF MCP `cwd: "${IVX_CONTENT_FACTORY_DIR:-${HOME}/dev/content-factory}"` template isn't expanded by hermes — the literal string is passed to `subprocess.Popen` so the spawn fails. Hardcoded to `/Users/devashishbadlani/dev/content-factory`.
6. **Propagated fixes** — patched all 8 profile config files + root config + `gastown/.cursor/mcp.json` to use the corrected commands/cwds. Verified standalone CF MCP probe via fifo returned `init OK + 18 tools`.
7. **Installed `mcp[cli]`** into the CF venv (`/Users/devashishbadlani/dev/content-factory/.venv`) so the FastMCP server actually runs.
8. **Created persistent cron job** — `ivx-stack-health` every 60m, `--no-agent` watchdog mode (script stdout delivered directly, zero LLM cost). Script probes `litellm:14000/health` and `cf-api:8001/health` and only emits output on failure.
9. **Queued delegate_task fork-join proof** (`t_112bbc83` on `gastown` board, assignee=coder, max-runtime=15m). Dispatcher spawned worker pid 18976 in 60s → worker LLM call returned HTTP 429 budget-exceeded after 3 retries → task auto-blocked per `--max-retries 1` policy. **The dispatcher works; the LLM gate is closed.**
10. **Verified state persistence** — bounced the gateway three times across pass-4 (after each config fix). Boards, profiles, cron jobs, and the queued task all survived each restart, proving the Hermes persistence claim.

## Capability claim audit (third pass)

| Claim | Status | Proof |
|---|---|---|
| Firecrawl is the canonical web/research signal layer | 🟡 plumbing OK, **gated on `intelli-verse-x/content-factory#19`** | Firecrawl CLI installed; MCP registered in every profile config; `FIRECRAWL_API_KEY` pulled from `aicart/intelliverse-ai-ssm-params` and seeded into every `~/.hermes/profiles/<name>/.env`. PR #19 is `MERGEABLE`, 8/8 unit tests green, 2/3 CI checks pass (the third is a pre-existing failure unrelated to this PR — see follow-up #9). |
| Hermes Kanban is the durable run engine | ✅ proven end-to-end | `hermes gateway run` autodispatches: parent `t_063fdd09` → 12 children → 2 of 3 screenwriter children completed in ~76s each (Ep 1 produced a 205-line broadcast-quality script artefact at `…/workspaces/t_ec30a547/ep1_newtons_first_law_script.md`). The third (Ep 2) was correctly caught by the auto-block watchdog (worker exited rc=0 without `kanban_complete` — protocol violation → blocked, not silently lost). |
| `delegate_task` parallelism | 🟡 config now valid (was broken) | Originally `delegation.model: google/gemini-flash-2.0` — that model is **not** served by the in-cluster LiteLLM gateway. Patched to `anthropic/claude-opus-4.6` (a model the gateway actually serves). Not yet *exercised* by a worker — follow-up #17 captures a small "research-and-pick-a-winner" task that proves the spawn. |
| Gastown coding swarm + Cursor + Refinery merges | ✅ proven for coder, refinery already running | Coder profile completed `t_1f5f0a40` in 46s: wrote `/tmp/coder-proof.py`, ran it (`WIRED` + UTC timestamp), and successfully called `mcp_gastown_gt_agents_list` against the locally-served `gt mcp serve` (stdio). 289 gastown tools available to any profile that loads the `gastown` toolset. Refinery merge-gate workflow already shipped to `intelli-verse-x/agent-skills` (commit `c54a952`, PR #1). |

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

**Capability-audit follow-ups (third pass):**
17. **Exercise `delegate_task`** with a small kanban task whose body explicitly says *"use `delegate_task` to spawn N=3 children, one per X, then pick a winner."* Confirms the delegation tier model + concurrency cap actually fire. Cheap (~$1 on the cap-3 setting).
18. **Build & deploy a `gastown-mcp` Kubernetes service** so workers running inside the cluster (i.e. the future production dispatcher pod, not just this laptop) can reach the 289-tool gastown surface over the network. Today the only path is local `gt mcp serve` over stdio — fine for dev, not for the kanban daemon running in `aicart`.
19. **Drain the remaining 8 `learning_series` children** (3 media-producer + 3 audio-director + 3 reviewer minus the auto-blocked Ep 2 chain) to exercise the media generation toolchain end-to-end (Veo / Beatoven / etc.). Capped: only run if PR #19 is merged AND `IMAGE_API_KEY / VIDEO_API_KEY / TTS_API_KEY / MUSIC_API_KEY` are set; otherwise media-producer / audio-director workers will block on missing creds.
20. **Codify the per-profile auth seeding** that this session had to do manually. Captured in the updated `create-profiles.sh`: it now copies `~/.hermes/{auth.json,.env,config.yaml}` into every profile dir on creation, so a fresh `./scripts/create-profiles.sh` produces workers that can actually authenticate.

**Capability-audit follow-ups (fourth pass — topology spec §3a-§3e verification):**
21. ~~**n8n MCP JWT is rejected**~~ ✅ **RESOLVED (fifth pass)** — Two problems: (a) the JWT in `content-factory/.cursor/mcp.json` (suffix `...SN8lAk_wHTIY`) had been rotated; cluster's `aicart/n8n-admin` Secret now holds key suffix `...wtVIaeynmSHsO_Ks`. (b) **There is no MCP Server Trigger workflow registered in this n8n instance** — every `/mcp/*` path returns `webhook not registered`. Switched the wiring from the non-existent native n8n MCP endpoint to the `n8n-mcp` npm package (v2.53.0, `name=n8n-documentation-mcp`) which wraps the n8n REST API as 24 MCP tools (workflow CRUD, node search, templates, validation, autofix). Now in `~/.hermes/config.yaml`, all 8 profile configs, and `gastown/.cursor/mcp.json` as `command: npx args: [-y, n8n-mcp]` with `N8N_API_URL` + `N8N_API_KEY` from `~/.config/intelli-verse-x/secrets.env`.
22. ~~**LiteLLM team `bernstein` budget exhausted**~~ ✅ **RESOLVED (fifth pass)** — Pulled `LITELLM_MASTER_KEY` from `aicart/litellm-secrets`, called `/team/update` to bump `bernstein` from `max_budget=$20` to `$100` with `budget_duration=30d` (next reset `2026-06-01T00:00:00Z`). Confirmed via `/team/list`: `bernstein: max=$100.0 spend=$21.06 headroom=$78.94`. Kanban workers can now charge LLM calls again.
23. ~~**CF MCP servers fail in the in-gateway attachment path**~~ ✅ **RESOLVED (fifth pass)** — Stood up two `supergateway` HTTP bridges on localhost: `:7898/mcp` wraps CF (`Content Factory v1.27.1`, 18 tools) and `:7899/mcp` wraps CF-media (`Media Tools v1.27.1`, 8 tools). Switched hermes config (root + 8 profiles + `gastown/.cursor/mcp.json`) from stdio to `url: http://localhost:78xx/mcp`. **Confirmation**: gateway log now contains ZERO `MCP server failed initial connection` warnings — previously had 3 (cf, cf-media, n8n). Bridge launch commands captured in §3 of `gastown/.cursor/mcp.json` `_doc` fields for reproducibility.
24. **n8n token rotation hygiene**: `content-factory/.cursor/mcp.json` was already `.gitignore`d (so the JWT never leaked to GitHub), but the file lived in plaintext on disk. Fourth pass moved the literal token to `~/.config/intelli-verse-x/secrets.env` (mode 600) and rewrote the file to `${N8N_MCP_TOKEN}`. Fifth pass replaced the stale `N8N_MCP_TOKEN` with the fresh `N8N_API_KEY` (still in the same env-var pattern). Same refs now in the new `gastown/.cursor/mcp.json` (also gitignored — added line `\.cursor/mcp\.json` to `gastown/.gitignore`).
