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
```

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
