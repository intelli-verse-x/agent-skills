

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

### Without MCP (required fallback — always works)

Use this ladder if MCP is not configured, blocked, or down:

1. **In-repo report (no network):** read `graphify-out/GRAPH_REPORT.md`
   (and `graphify-out/S3_POINTER.md` if the full graph is too large for git).
2. **S3 report / graph (AWS creds):**
   ```bash
   aws s3 cp s3://ivx-graphify-graphs/graphs/agent-skills/GRAPH_REPORT.md graphify-out/GRAPH_REPORT.md
   # optional full graph for local CLI:
   aws s3 cp s3://ivx-graphify-graphs/graphs/agent-skills/graph.json graphify-out/graph.json
   ```
3. **Local rebuild (no MCP, no cluster):**
   ```bash
   uv tool install graphifyy
   graphify update . --no-cluster
   graphify cluster-only . --no-viz --no-label
   # then read graphify-out/GRAPH_REPORT.md or: graphify path "A" "B"
   ```
4. **Last resort:** normal `rg` / IDE search / vector RAG.

### Agent procedure

1. Prefer MCP tools when connected; otherwise step through **Without MCP** above.
2. Orient → navigate → open only implicated files → edit → test.
3. Fuzzy prose / Brand DNA still uses docs + RAG — not Graphify.

### Artifacts

- In-repo: `graphify-out/GRAPH_REPORT.md`
- S3: `s3://ivx-graphify-graphs/graphs/agent-skills/graph.json`
- CI: `.github/workflows/graphify.yml` → org extract in `intelli-verse-kube-infra`
- Org playbook: `intelli-verse-kube-infra/.agents/skills/graphify-code-memory/SKILL.md`
<!-- graphify-code-memory:end -->
