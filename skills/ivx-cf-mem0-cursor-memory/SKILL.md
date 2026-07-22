---
name: ivx-cf-mem0-cursor-memory
description: >-
  Personal long-term memory via Mem0 (MCP + CLI) for Content Factory sessions.
  Use PROACTIVELY at task start to search_memories, and after decisions/bugfixes
  to add_memory. Complements Hindsight (team bank). Default user_id:
  user_30dff4fab4c9. Triggers: mem0, personal memory, session learnings,
  preferences, "remember this", continuous memory save.
---

# Mem0 Cursor Memory (Content Factory)

Personal, user-scoped memory. Prefer MCP server `mem0`; fall back to CLI.

## Quick Start

**Before non-trivial work:**

```
search_memories(query="<plain-language restatement of task>")
```

CLI fallback:

```bash
mem0 search "<query>"
```

**After a decision, bugfix, preference, or session milestone:**

```
add_memory(text="<concise standalone fact>", metadata={"category": "task_learnings", "project": "content-factory"})
```

CLI:

```bash
mem0 add "<concise fact>"
```

## What to Save (Mem0)

| Save | Skip |
|------|------|
| User preferences & conventions | Secrets, API keys, tokens |
| Session decisions & why | Raw chat transcripts |
| Pipeline/account gotchas you hit | Duplicate facts already found |
| Working calendar / account focus | Transient "trying X next" chatter |

## Continuous Save Cadence

1. **Start** — `search_memories` once with the task restated
2. **Milestone** — after each non-obvious fix, architecture choice, or user preference
3. **End of meaningful work** — one distilled summary of what changed and why

Wait 2–3s after `add_memory` before searching again (async indexing).

## Identity

- Default `user_id`: `user_30dff4fab4c9`
- Env: `MEM0_API_KEY`; config: `~/.mem0/config.json`

## Layer Split

| Layer | Tool | Use for |
|-------|------|---------|
| Personal / preferences | **Mem0** | Your conventions, session learnings |
| Team / ops / incidents | **Hindsight** | Shared gotchas, architecture, process |

Do both when relevant — not duplicates of the same sentence.

## Tools (MCP `mem0`)

| Tool | When |
|------|------|
| `search_memories` | Task start |
| `add_memory` | After learnings |
| `get_memories` | Audit recent |
| `update_memory` / `delete_memory` | Fix stale entries |
