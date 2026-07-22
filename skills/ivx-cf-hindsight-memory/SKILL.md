---
name: ivx-cf-hindsight-memory
description: >-
  Shared IntelliVerse-X long-term memory via Hindsight MCP. Recall before deep
  repo exploration; sync_retain after non-obvious fixes, decisions, and
  process rules. Use for content-factory, kube-infra, QuizVerse, Nakama.
  Triggers: hindsight, team memory, retain, recall, root cause, gotcha,
  continuous memory save, "we've hit this before".
---

# Hindsight Memory (Content Factory)

Shared team brain. MCP server: `hindsight` (or `user-hindsight`).

## Quick Start

**Before non-trivial work** (silent — fold results in, don't announce tools):

```
recall(query="<plain-language restatement of the task/problem>")
```

**After resolving something durable:**

```
sync_retain(
  content="<self-contained fact: what / why / when>",
  context="content-factory <area>",
  tags=["project:content-factory"]
)
```

Use `retain` only for fire-and-forget; prefer `sync_retain`.

## Project Tags

| Tag | When |
|-----|------|
| `project:content-factory` | CF pipelines, MCP, LiteLLM, prompts, accounts |
| `project:kube-infra` | EKS, aicart, Helm, deployments |
| `project:quizverse-unity` | QuizVerse Unity |
| `project:quizverse-frontend` | QuizVerse web |
| `project:backend-ai` | NestJS / AI API |
| `project:nakama` | Nakama |

Omit tags only for true org-wide facts.

## What to Retain

- Root causes (especially non-obvious)
- Gotchas / footguns
- Architecture or process decisions + rationale
- Workarounds for flaky providers
- New CF conventions (prompt registry, LiteLLM, character_identity, task store)

**Never retain:** secrets, credentials, tokens, raw logs with PII, chat noise.

## Continuous Save Cadence

1. **Start** — `recall` before exploring from scratch
2. **Dedupe** — `recall` the candidate fact; if present, `update_memory` instead of duplicate retain
3. **Milestone / end** — `sync_retain` one distilled outcome per resolved issue

## Other Tools

| Tool | When |
|------|------|
| `reflect(query=...)` | Synthesized judgment across memories |
| `list_memories(q=...)` | Browse/audit |
| `update_memory` / `invalidate_memory` | Correct or retire stale facts |

## Failure Mode

If Hindsight MCP is disconnected or auth fails: note once, continue the task. Memory is an accelerator, not a blocker. Do not retry auth in a loop.
