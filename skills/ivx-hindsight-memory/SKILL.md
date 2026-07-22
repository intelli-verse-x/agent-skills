---
name: ivx-hindsight-memory
description: >-
  Shared long-term memory for IntelliVerse-X agents and Cursor sessions, backed
  by the "hindsight" MCP server. Stores root causes, gotchas, decisions, and
  process rules learned once so they never have to be re-explained or
  re-discovered. Use PROACTIVELY at the start of any non-trivial task (bug
  investigation, "why is X happening", error triage, unfamiliar area of a
  repo, or anything that smells like "we've probably hit this before") by
  calling recall BEFORE reading the repo from scratch or asking the user to
  restate context. Also use after solving something non-obvious to write the
  lesson back with retain/sync_retain, and applies across every workspace
  (QuizVerse Unity, Quizverse-web-frontend, Intelliverse-X-AI, nakama,
  intelli-verse-kube-infra).
---

# Hindsight Memory

Shared brain across all agents/repos. One MCP server (`hindsight`), tool names
below have no server prefix in this doc — call them as-is via the MCP tool
interface for server `hindsight` (or `user-hindsight`, depending on how the
client namespaces it).

## Quick Start

**At the start of any task that isn't trivially simple** — before deep-diving
into the codebase, before asking the user clarifying questions they may have
already answered before, before debugging an error from scratch — call:

```
recall(query="<plain-language restatement of the task/problem>")
```

- Phrase the query naturally, in your own words — recall is semantic, not
  keyword search. You don't need to guess how the fact was originally worded.
- If recall returns relevant hits, use them directly. State briefly what you
  found ("Hindsight has a note on this: ...") and skip redundant exploration.
- If recall returns nothing useful, proceed with normal investigation
  (reading code, running commands, asking the user) as you would anyway.

**Do this silently and by default** — don't ask the user for permission to
check memory first, and don't announce the tool name; just fold the result
into your answer naturally.

## When to Recall (trigger scenarios)

- Investigating an error, crash, or "why is X broken/404/failing" question
- Starting work in an unfamiliar module, service, or repo area
- About to ask the user for context/background that might already be recorded
  (architecture decisions, past incidents, env quirks, naming conventions)
- Before repeating a large repo read/explore pass "from the start" — check if
  someone already mapped this territory
- Any task that feels like it could be a recurring/known issue

## When to Retain (write facts back)

After you (or the user) resolve something non-obvious, persist it so nobody
re-solves it:

- Root cause of a bug, especially non-obvious ones
- A gotcha / footgun (e.g. "API X silently drops unknown fields")
- An architecture or process decision and its rationale
- A workaround for a broken/flaky external dependency
- A newly learned project convention or naming rule

Use `sync_retain` (blocks until stored, safe default) or `retain` (async, fine
for fire-and-forget):

```
sync_retain(
  content="<the fact, self-contained — include what/why/when so it reads standalone later>",
  context="<short label, e.g. 'quizverse gotcha', 'nakama infra', 'frontend api contract'>",
  tags=["project:<slug>"]  # omit for cross-project/org-wide facts
)
```

Valid `project:<slug>` values: `quizverse-unity`, `quizverse-frontend`,
`backend-ai`, `nakama`, `kube-infra`.

Before retaining, do a quick `recall` on the same fact — if it's already
there, use `update_memory` to correct/extend it instead of creating a
near-duplicate. (This dedupe + tagging convention is also enforced bank-side
via a directive named "Retain quality bar", so it applies to every agent
hitting this bank, not just Cursor sessions.)

Skip retaining: pure scratch/session chatter, anything only relevant to the
current chat, or facts already confirmed present via `recall`. Never retain
secrets, API keys, passwords, or tokens.

## Other Useful Tools

- `reflect(query=...)` — ask for synthesized analysis/reasoning across
  memories rather than a raw fact list. Use when the question needs judgment
  ("what's our overall approach to X"), not just lookup.
- `list_memories(q=...)` — direct browse/search without relevance ranking,
  useful for auditing what's stored on a topic.
- `update_memory` / `invalidate_memory` — correct or retire a fact that turns
  out to be wrong or outdated (don't just retain a contradicting fact on top).

## Troubleshooting

- If the `hindsight` MCP tools aren't available (server disconnected, needs
  auth, or times out): don't block the task on it. Note it briefly and
  continue with normal investigation — memory lookup is an accelerator, not a
  hard dependency.
- If a call fails with an auth error, that's a server-side/token issue — flag
  it to the user rather than retrying repeatedly.
- Read-only tools (`recall`, `reflect`, `list_*`, `get_*`) and `retain`/
  `sync_retain` are auto-approved in `mcp.json`, so they run without a
  confirmation prompt. Destructive tools (`delete_*`, `clear_*`,
  `invalidate_memory`, `update_*`) are intentionally left out of
  auto-approve — expect (and respect) a confirmation prompt for those.

## Notes

- Verified end-to-end (2026-07-09): `recall("why is the quizverse article
  page giving a 404?")` correctly surfaces the seeded fact about Sanity
  `blogPost` vs `post` types. Bank currently holds 77+ facts across infra,
  LLM ops, process rules, and app-specific gotchas.
- This is a shared, cross-team memory — never retain secrets, credentials, or
  anything a client/user isolation rule would forbid sharing.
