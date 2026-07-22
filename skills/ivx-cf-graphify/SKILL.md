---
name: ivx-cf-graphify
description: >
  Content Factory Graphify wrapper. Use for codebase map, “where does X live”,
  how modules connect, architecture orientation, or when graphify.mdc applies.
  Query graphify-out/ before grepping or reading giant markdown brains.
  Does not replace Mem0, Hindsight, or product Memory Service RAG.
---

# CF Graphify (repo navigation graph)

## Point

Laser-sharp **code/docs structure** via a local knowledge graph — not brand RAG.

| Layer | Tool | Use for |
|-------|------|---------|
| Repo map | **Graphify** (`graphify-out/`) | Where code lives, dependency paths |
| Personal memory | Mem0 | Preferences / session learnings |
| Team memory | Hindsight | Cross-repo ops gotchas |
| Product RAG | Memory Service / `query_memory` | Brand/app content recall |

## Windows note

In PowerShell the leading `/` is a path separator. Use:

```powershell
graphify .
graphify query "where does pipeline memory inject context?"
graphify path "memory_client" "context_builder"
graphify explain "TaskStore"
graphify update .
```

Not `/graphify .`.

## When to load

- “Where does X live?” / “How is Y connected?”
- Multi-file orientation before coding
- Avoid stuffing `AGENT.md` / full SYSTEM_MAP into context
- Always-on rule `.cursor/rules/graphify.mdc` already requires query-first

## Workflow

1. If `graphify-out/graph.json` is missing → `graphify extract . --code-only --no-label` (AST, no API key).
2. Ask the graph first:
   - `graphify query "<question>"`
   - `graphify path "<A>" "<B>"`
   - `graphify explain "<concept>"`
3. Open only the few files the graph cites (Read/Grep for edit/debug).
4. After code edits: `graphify update .` (AST-only; post-commit hook also runs).
5. After big doc/brain edits: `graphify update .` (or re-extract with docs when an LLM backend is configured).

## Artifacts

```
graphify-out/
├── graph.json       # query target (commit; rebuild via extract --code-only)
├── GRAPH_REPORT.md  # architecture highlights (commit)
├── graph.html       # interactive view — local only when >5k nodes (~35MB); gitignored
├── cache/           # AST cache — gitignored; rebuild fills it
└── cost.json        # local only — gitignored
```

Full HTML: set `GRAPHIFY_VIZ_NODE_LIMIT=40000` then `graphify cluster-only . --no-label` (do not commit the HTML).

Noise exclusion: `.graphifyignore` (`.working_dir/`, `out/`, `node_modules/`, …).

## Done-when

- [ ] Ran at least one `graphify query` / `path` / `explain` before broad exploration
- [ ] Did not replace Mem0/Hindsight/Memory Service with Graphify
- [ ] Cited real paths from the graph (no invented `src/`)
- [ ] After meaningful code changes, graph left current (`update` or hook)

## Related

- Always-on: `.cursor/rules/graphify.mdc`
- Packs: `@cf-skill-router` → “graphify / codebase map”
- Upstream: https://github.com/Graphify-Labs/graphify (PyPI: `graphifyy`)
