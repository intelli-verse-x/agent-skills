# Hermes Kanban — multi-board bring-up + proof run

This kit creates one Hermes Kanban board per intelli-verse-x fork and
queues a real `learning_series.yaml` Content Factory pipeline run as
the proof of life.

Prereqs:

- Hermes installed (`curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash`).
- `~/.hermes/config.yaml` has at least one model provider configured (`hermes setup`).
- Content Factory MCP servers in `~/.hermes/config.yaml` (see `config-fragment.yaml` in this directory).
- `FIRECRAWL_API_KEY` exported (for the live ASO signals — see content-factory PR #19).

Steps:

```bash
# 1. Merge config fragment into ~/.hermes/config.yaml
./scripts/install-config.sh

# 2. Create one board per fork
./scripts/create-boards.sh

# 3. Create the named worker profiles
./scripts/create-profiles.sh

# 4. Queue the proof-of-life: learning_series for QuizVerse
./scripts/queue-proof-run.sh

# 5. Watch it execute
hermes kanban tail --board content-factory
tail -F ~/.hermes/logs/gateway.log | grep dispatcher
```

### Auto-dispatch of kanban cards: who does it?

Hermes >= 0.13.x runs an **embedded kanban dispatcher inside the
gateway** when `kanban.dispatch_in_gateway: true` (the default). If
you've run `hermes gateway install` once (the gateway is the
`ai.hermes.gateway` launchd service), card auto-claim is already
on — cards posted by `hermes cron`, webhooks, or `gt mail` get picked
up every `kanban.dispatch_interval_seconds` (default 30s) without any
manual `hermes chat -q work kanban task <id>` invocations.

Verify with:

```bash
tail -F ~/.hermes/logs/gateway.log | grep dispatcher
# Expect: "kanban dispatcher: embedded in gateway (interval=30.0s)"
# Followed by per-tick lines like:
#   "kanban dispatcher [content-factory]: spawned=1 reclaimed=0 ..."
```

### When you need a STANDALONE dispatch daemon (rare)

`scripts/install-worker-launchd.sh` installs a separate
`ai.hermes.kanban-daemon` launchd service that does the same thing
the gateway's embedded dispatcher does. Use it ONLY when:

- You set `kanban.dispatch_in_gateway: false` on purpose (process
  isolation, debugging).
- You're on a headless box without the GUI gateway.
- You need a higher per-tick spawn cap than the gateway provides.

The script refuses to install (exit 2) if it detects the gateway is
running with the embedded dispatcher — installing both would race for
card claims. Use `--force` to override.

```bash
./scripts/install-worker-launchd.sh             # refuses if gateway running
./scripts/install-worker-launchd.sh --force     # install anyway
./scripts/install-worker-launchd.sh --uninstall # bootout + remove plist
```

### EKS production deployment (no laptop dep)

The launchd path above is the **laptop bridge**. For the
cluster-resident equivalent (no laptop at all), see
[`intelli-verse-kube-infra/hermes-worker/`](https://github.com/intelli-verse-x/intelli-verse-kube-infra/tree/main/hermes-worker)
which runs `hermes kanban daemon` inside an EKS Deployment in
`aicart`. The two install paths are intentionally analogous: same
command, same flags, different supervisor (launchd vs. kubelet).

Boards created:

| Board | For repo | Use |
|---|---|---|
| `gastown` | intelli-verse-x/gastown | Swarm runtime work |
| `hermes-agent` | intelli-verse-x/hermes-agent | Hermes itself |
| `content-factory` | intelli-verse-x/content-factory | Pipeline runs |
| `kube-infra` | intelli-verse-x/intelli-verse-kube-infra | K8s manifests |
| `games-platform` | intelli-verse-x/intelliverse-x-games-platform-2 | Backend |
| `sdks` | intelli-verse-x/Intelli-verse-X-* | All SDK forks (one task per repo via tenant) |

Worker profiles created (under `~/.hermes/profiles/`):

| Profile | Toolset | Used by |
|---|---|---|
| `coder` | terminal, file, git, content-factory, firecrawl | Implementation work |
| `reviewer` | terminal, file, content-factory | QC gates |
| `researcher` | web, firecrawl | Research / triage |
| `screenwriter` | content-factory, firecrawl | Series + trailer scripting |
| `media-producer` | content-factory-media | Render fan-out |
| `audio-director` | content-factory-media | Tone + music |
| `trailer-director` | content-factory, firecrawl | Game trailer orchestration |
| `curriculum-planner` | content-factory, firecrawl | Learning series planning |
