---
name: ivx-content-factory
description: How to use ContentX MCP (content-factory) from Hermes — plan → approve → trigger → poll → harvest. Prefer MCP over curl. Use whenever generating / hardening / proving any Content Factory pipeline.
version: 2.0.0
metadata:
  hermes:
    tags: [content-factory, video, image, audio, mcp, generation, main]
    related_skills: [ivx-content-factory-pipeline, ivx-cf-pipeline-operator, ivx-stack-tour]
---

# Content Factory — Hermes playbook (UPDATED 2026-07-23)

## Standing rules (read first)

1. **ContentX MCP is required** for live pipeline work. Server id: `content-factory`
   (already in `~/.hermes/config.yaml` as `mcp_servers.content-factory`).
2. **Prefer MCP tools over curl.** Use CF API only for health or when an MCP tool is missing.
3. **Runtime ships from `main` only.** Never target Sid_CF for deploy / MCP image / live proof.
4. **Pipeline generation = SiliconFlow only** (SF chat + FLUX / Wan nicknames). Do not route
   pipeline models through Gemini/OpenAI/etc. Hermes *brain* stays on LiteLLM Claude — that is fine.
5. **Always end with `kanban_complete` or `kanban_block`.** Silent exit = protocol violation.
6. **Cost cap** on rock-solid cards: USD 5 unless the card says otherwise.

## MCP server (one primary)

| MCP server | When to use |
|---|---|
| `content-factory` | **All** pipeline plan / trigger / status / harvest. Same path end users use. |
| `admin-mcp` | Org tools (documenso, ga4, …) — **not** for CF pipelines. |

There is **no** `content-factory-media` server on Hermes. Do not invent it.

Env already wired:

- `CF_MCP_URL=http://content-factory-mcp.aicart.svc.cluster.local:8005/mcp`
- `CF_API_URL=http://content-factory-api.aicart.svc.cluster.local:8001`
- `CF_API_KEY` (= automation key) for MCP `X-API-Key` header

In-cluster URLs beat public ingress while you run inside the worker pod.

## Required generate job order

```
1) research_topic (optional)
2) plan_generation(pipeline=..., params=...)
   → SHOW plan_id + approval_token in a kanban comment
3) trigger_pipeline(
     plan_id=...,
     approval_token=<from that plan>,
     user_approved=True   # only for YOUR plan from this session (Hermes operator proof)
   )
4) get_task_status(task_id) every 60–90s
5) harvest_task(task_id) when completed
6) kanban_complete with task_id + harvest URLs
```

**Never** call `trigger_pipeline` without a fresh `plan_id` from `plan_generation`.
**Never** set `user_approved=True` for someone else's plan.

Useful tools (names may be prefixed by Hermes MCP bridge):

- `list_available_pipelines`
- `plan_generation`
- `trigger_pipeline`
- `get_task_status` / `wait_for_task`
- `harvest_task`
- `estimate_cost`
- `get_pipeline_log` on failure

## Common rock-solid pipelines

| Pipeline | Notes |
|---|---|
| `app_catalog_enricher` / `app_catalog_enrich` | Catalog enrich; SF only |
| `app_growth_council` | Growth council; SF only |
| `ad_banners` | Banner pack; SF only |
| `script2image` | Script → stills; needs `script` |
| `social_carousel` | Carousel slides; gates on hook/cta + 1080² PNGs |

## Fallback curl (health / missing MCP only)

```bash
curl -fsS -H "X-API-Key: $CF_API_KEY" "$CF_API_URL/health"
curl -fsS -H "X-API-Key: $CF_API_KEY" \
  "$CF_API_URL/api/pipelines/tasks/$TASK_ID"
```

Public ingress (`https://content-factory.intelli-verse-x.ai`) is optional backup only.

## Fail discipline

- Pipeline fails twice with same signature → `kanban_block` with evidence, do not loop burn.
- Protocol: every worker exit must call `kanban_complete` or `kanban_block`.
- Watch budget: after ~6 status polls still running → `kanban_block` with `watch-respawn:` so dispatcher can respawn (do not silent-exit).

## What NOT to do

- Do not use Sid_CF branch / `:sid-cf` image as the live channel.
- Do not hardcode provider SDKs; CF routes via LiteLLM / SF config already on main.
- Do not pull S3 media into context — link URLs only.
- Do not edit `Dockerfile*`, `.github/workflows/`, `api/auth/`, `infra/`, or kube-infra.

## If ContentX MCP HTTP fails (Hermes image)

If `hermes mcp test content-factory` says `streamable_http is not available`,
**do not block forever**. Fall back to in-cluster CF API (same kitchen):

```bash
# health
curl -fsS -H "X-API-Key: $CF_API_KEY" "$CF_API_URL/health"

# trigger pipeline directly (no plan gate when MCP unavailable)
curl -fsS -X POST -H "X-API-Key: $CF_API_KEY" -H "Content-Type: application/json" \
  -d '{"script":"A red apple on a white table. Hook text APPLE. CTA Try QuizVerse.","num_images":1}' \
  "$CF_API_URL/api/pipelines/script2image"

# poll
curl -fsS -H "X-API-Key: $CF_API_KEY" "$CF_API_URL/api/pipelines/tasks/$TASK_ID"

# harvest (when completed)
curl -fsS -H "X-API-Key: $CF_API_KEY" "$CF_API_URL/api/pipelines/tasks/$TASK_ID/harvest"
```

Comment on the card: `MCP_HTTP_UNAVAILABLE � used CF API fallback`.
Still prove live on **main**. Prefer MCP again once hermes-worker image upgrades `mcp` package.
