# intelli-verse-x / agent-skills

Cross-agent [Agent Skills](https://agentskills.io) registry for the
intelli-verse-x ecosystem. Build a skill once, use it from Cursor,
Claude Code, Codex, GitHub Copilot, Hermes Agent, and any other client
that implements the open standard.

## Why

Today, skills are scattered across `.cursor/skills/`, `.claude/skills/`,
`~/.hermes/skills/`, `~/.codex/skills/` in every repo. The
`agentskills.io` Dec 2025 standard fixes that — one folder format,
progressive disclosure (discovery → activation → execution), every
client knows how to load it.

This repo is the single canonical place where our org-specific skills
live. Every consumer pulls it in as a git submodule and symlinks the
right subfolders.

## Skills

| Skill | What it does | Used by |
|---|---|---|
| [`ivx-content-factory-pipeline`](skills/ivx-content-factory-pipeline/) | Trigger any of the 50+ Content Factory pipelines, poll status, surface artefacts | Cursor, Claude Code, Hermes |
| [`ivx-aso-brief`](skills/ivx-aso-brief/) | Run the App Store / Play Store ASO intel pipeline with live Firecrawl signals and council voting | Cursor, Hermes |
| [`ivx-game-trailer`](skills/ivx-game-trailer/) | End-to-end game trailer (storyboard → animatic → audio → final) via Content Factory | Cursor, Hermes |
| [`ivx-k8s-gpu-rollout`](skills/ivx-k8s-gpu-rollout/) | Safe rollout of GPU sidecar manifests in `intelli-verse-kube-infra/content-factory/` (comfyui, vllm-coder-pro, musetalk, …) via kagent | Cursor, kagent, Hermes |
| [`ivx-gastown-sling`](skills/ivx-gastown-sling/) | Dispatch coding work across the gastown swarm — pick a polecat, sling a bead, monitor convoy | Cursor, Hermes, Mayor |
| [`ivx-cf-run-dispatcher`](skills/ivx-cf-run-dispatcher/) | Trigger a CF pipeline run via public API + post an operator kanban card so a swarm worker drives it to completion | Hermes (cron, webhooks) |
| [`ivx-cf-pipeline-operator`](skills/ivx-cf-pipeline-operator/) | Own a CF run end-to-end: watch API, pull EKS pod logs on stalls, diagnose, open fix PRs, watch deploy, retry, iterate until success | Hermes (1 worker per active run) |
| [`ivx-cf-run-improver`](skills/ivx-cf-run-improver/) | After a CF run completes, harvest prompts/characters/cost/quality, diff vs registry, open prompt + character PRs, file improver CSV row | Hermes (1 worker per completed run) |
| [`ivx-cf-prompt-librarian`](skills/ivx-cf-prompt-librarian/) | Weekly maintenance: 30-day metric roll-up, 7-dimension audit score, version promotions, registry pruning, weekly digest PR with 30/60/90-day plan | Hermes (weekly cron, Sun 03:00 UTC) |
| [`ivx-cf-context-bootstrap`](skills/ivx-cf-context-bootstrap/) | Apply Intelliverse-X-AI context-engineering pattern to a target repo: `.cursorrules` + `AGENT.md` + `.cursor/{HOT_CONTEXT,ANTI_PATTERNS,DECISION_TREE,...}.md` + 26 command rules | Hermes, Cursor (one-shot per repo) |

## Format

Each skill is a folder with at minimum a `SKILL.md` file (front-matter
metadata + instructions). Optional `scripts/`, `references/`,
`assets/`. Full spec: <https://agentskills.io/specification>.

```
skills/<skill-name>/
├── SKILL.md          # required: front-matter (name, description) + instructions
├── scripts/          # optional: executable helpers
├── references/       # optional: docs the agent loads on demand
└── assets/           # optional: templates, prompts, schemas
```

Progressive disclosure: clients load only `name` + `description` at
discovery; they read the full `SKILL.md` only when a task matches; they
execute `scripts/` only when the instructions call for them.

## Consumer wiring

Add this repo as a submodule and symlink (or copy) the skills you want
to expose in each consumer:

### Cursor

```bash
git submodule add https://github.com/intelli-verse-x/agent-skills .skills-registry
ln -s ../.skills-registry/skills/ivx-content-factory-pipeline .cursor/skills/
ln -s ../.skills-registry/skills/ivx-aso-brief                 .cursor/skills/
# ... etc per repo
```

### Claude Code

```bash
ln -s ../.skills-registry/skills/ivx-gastown-sling .claude/skills/
```

### Hermes Agent

Drop or symlink under `~/.hermes/skills/`. Hermes reads
`SKILL.md` directly from any subfolder there.

### Codex

```bash
ln -s /Users/<you>/dev/intelli-verse-x-agent-skills/skills/* ~/.codex/skills/
```

## Adding a new skill

1. `mkdir skills/<your-skill>`
2. Write `SKILL.md` with `---` front-matter (at minimum `name` and
   `description`). The description is what every client uses for
   discovery — make it specific and trigger-word-rich.
3. Add scripts / references / assets as needed.
4. PR with a quick "use case" line in the table above.
5. After merge, consumers pull `git submodule update --remote` to pick
   it up.

## Standard

Built against the open `agentskills.io` v1 specification. Compatible
clients (per [agentskills.io/clients](https://agentskills.io/clients)):
Claude Code, OpenAI Codex, GitHub Copilot, Cursor, Hermes Agent, Junie,
Factory, Qodo, Mistral Vibe, Mux, Autohand, Laravel Boost.

## License

MIT — copy, adapt, share.

<!-- pr-review-agent smoke test 2026-07-10 -->
