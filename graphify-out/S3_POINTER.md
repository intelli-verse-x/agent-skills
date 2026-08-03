# Full graph on S3 (use when MCP is unavailable)

- Report: `graphify-out/GRAPH_REPORT.md` (this folder)
- Full graph: `s3://ivx-graphify-graphs/graphs/agent-skills/graph.json`
- MCP (if p0): `https://graphify-agent-skills.intelli-verse-x.ai/mcp`
- Rebuild: `uv tool install graphifyy && graphify update . --no-cluster && graphify cluster-only . --no-viz --no-label`
- Org extract: `intelli-verse-kube-infra` workflow `graphify-extract.yml`
