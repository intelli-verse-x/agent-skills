---
name: ivx-mem0-cursor-memory
description: >-
  Personal long-term memory via Mem0 Platform (MCP + CLI). Use PROACTIVELY at
  the start of non-trivial tasks to search_memories before deep repo exploration,
  and after resolving non-obvious bugs to add_memory. Complements Hindsight
  (team ops bank) with user-scoped Mem0 memories. Default user_id:
  user_30dff4fab4c9. Applies across QuizVerse, web frontend, NestJS backend,
  and Nakama workspaces.
---

# Mem0 Cursor Memory

Mem0 is wired via **MCP server `mem0`** (`search_memories`, `add_memory`, etc.)
and **CLI** (`mem0 search`, `mem0 add`). Config: `~/.mem0/config.json`.
Env: `MEM0_API_KEY` (user scope).

## Quick Start

**Before non-trivial work** — prefer MCP when available:

```
search_memories(query="<plain-language restatement of task>")
```

Fallback CLI:

```bash
mem0 search "<query>"
```

**After resolving something non-obvious:**

```
add_memory(text="<concise fact>", metadata={"category": "task_learnings"})
```

Or CLI:

```bash
mem0 add "<concise fact>"
```

## Scope

| Layer | Tool | Use for |
|-------|------|---------|
| Team ops / cross-repo gotchas | Hindsight MCP | Architecture, incidents, process |
| Personal / project memory | Mem0 MCP or CLI | Preferences, session learnings, conventions |

Do both when relevant — they are complementary, not duplicates.

## Default identity

- `user_id`: `user_30dff4fab4c9` (from agent init)
- Account is **unclaimed** until human runs `mem0 init --email <email>`

## MCP tools (server: mem0)

| Tool | When |
|------|------|
| `search_memories` | Start of task, before asking user to repeat context |
| `add_memory` | After bug fix, decision, or preference learned |
| `get_memories` | List recent memories for current scope |
| `update_memory` / `delete_memory` | Fix wrong or stale entries |

Memories process asynchronously — wait 2–3s after add before searching.
