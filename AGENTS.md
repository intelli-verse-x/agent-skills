

<!-- graphify-code-memory:begin -->
## Code memory (Graphify) — use this before grepping

This repo has a live AST knowledge graph for agents. Prefer it over broad
`rg` / codebase search when the question is structural (definitions, callers,
module boundaries, “how does A reach B?”).

### MCP (primary)

| | |
|---|---|
| **URL** | `https://graphify-agent-skills.intelli-verse-x.ai/mcp` |
| **Header** | `X-API-Key: <GRAPHIFY_API_KEY>` |
| **Tools** | `query_graph`, `get_node`, `get_neighbors`, `shortest_path`, `list_prs` |

Get the key (ops; do not commit):

```bash
kubectl -n aicart get secret graphify-mcp-api-key \
  -o jsonpath='{.data.GRAPHIFY_API_KEY}' | base64 -d; echo
```

Cursor / Claude / Codex — add to MCP config:

```json
"graphify-agent-skills": {
  "type": "http",
  "url": "https://graphify-agent-skills.intelli-verse-x.ai/mcp",
  "headers": { "X-API-Key": "<GRAPHIFY_API_KEY>" }
}
```

### Agent procedure

1. Orient with `query_graph` / communities (or `graphify-out/GRAPH_REPORT.md` if present).
2. Use `shortest_path` / `get_neighbors` to find the files that matter.
3. Open only those files → edit → test.
4. Fallback to normal search for fuzzy prose. Graphify is **code DNA**, not Brand DNA / vector RAG.

### Artifacts

- S3: `s3://ivx-graphify-graphs/graphs/agent-skills/graph.json`
- CI: `.github/workflows/graphify.yml` → org extract in `intelli-verse-kube-infra`
- Org playbook: `intelli-verse-kube-infra/.agents/skills/graphify-code-memory/SKILL.md`
<!-- graphify-code-memory:end -->
