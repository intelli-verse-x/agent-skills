---
name: ivx-cf-firecrawl
description: Firecrawl gives agents and pipelines fast, reliable web context with strong search, scraping, and page-interaction tools. Umbrella skill that routes to firecrawl-search, firecrawl-scrape, and firecrawl-research, and documents install, credentials, and the keyless fallback.
when_to_use: Whenever a task needs live web data — discovery via search, clean markdown from a known URL, or citation-grade research for a pipeline — and you need to pick the right Firecrawl path (CLI, API, or in-repo tool).
---

# /firecrawl

Firecrawl helps agents search first, scrape clean content, interact with live
pages when plain extraction is not enough, and produce finished deliverables
from web data.

In this repo Firecrawl is available three ways:

1. **Admin portal** — `/contentx/skills` lists every skill and includes a
   runnable Firecrawl playground (search + scrape) backed by
   `POST /api/skills/firecrawl/search` and `POST /api/skills/firecrawl/scrape`.
2. **Python tool** — `tools/research/firecrawl_research.py::FirecrawlResearcher`
   (used by `concept_to_curriculum` and the learning pipelines).
3. **CLI** — the official Firecrawl CLI for live web work in a terminal session.

## Install (CLI + skills + browser auth)

One command installs the Firecrawl CLI, the build skills, and the workflow
skills, and opens browser auth so a human can sign in or create an account:

```bash
npx -y firecrawl-cli@latest init --all --browser
```

Verify the install before doing real work:

```bash
mkdir -p .firecrawl
firecrawl --status
firecrawl scrape "https://firecrawl.dev" -o .firecrawl/install-check.md
```

Note: `.firecrawl/` is git-ignored run-local output — never commit it
(see `.cursor/ANTI_PATTERNS.md`).

## Credentials

- Set `FIRECRAWL_API_KEY=fc-...` in the environment (or the API pod's secret).
  The Python SDK (`firecrawl-py`, already in `requirements.txt`) and the
  portal endpoints pick it up automatically.
- No key? Search/scrape still work on the **keyless free tier** (rate-limited):
  the REST API at `https://api.firecrawl.dev/v2` accepts `/search`, `/scrape`,
  and `/interact` without an `Authorization` header. Crawl/map/agent require a key.
- To have a human authorize a key, send them to
  https://www.firecrawl.dev/signin?view=signup&source=agent-suggested
  or run the CLI auth flow above.

## Choose your path

| Need | Use |
|------|-----|
| Web discovery by query | `/firecrawl-search` (skills/firecrawl/search) |
| Clean markdown from a known URL | `/firecrawl-scrape` (skills/firecrawl/scrape) |
| Citation-grade research bundle for a pipeline | `/firecrawl-research` (skills/firecrawl/research) |
| Clicks/forms/login on a live page | `firecrawl interact` via the CLI |
| Bulk extraction / URL discovery | `firecrawl crawl` / `firecrawl map` via the CLI (needs API key) |
| Diagnose a failing Firecrawl job | `firecrawl ask --job <jobId>` or `POST /support/ask` |

Default flow for live web work: search → scrape → interact only when the page
needs clicks/forms/login. If a call fails, pass the failing `jobId` to
`firecrawl ask` instead of guessing.

## REST quick reference (no install needed)

Base URL `https://api.firecrawl.dev/v2`, auth header
`Authorization: Bearer fc-YOUR_API_KEY` (optional on the free tier):

- `POST /search` — discover pages by query
- `POST /scrape` — clean markdown from a single URL
- `POST /interact` — browser actions on live pages
- `POST /support/ask` — diagnose a failing call (`{ question, jobId? }`)
- `POST /support/docs-search` — "how do I…" answers grounded in Firecrawl docs

MCP: point any MCP client at `https://mcp.firecrawl.dev/v2/mcp` (keyless OK).

## Implementation

- Portal/API: `api/routes/skills.py` (`/api/skills/firecrawl/*`)
- Pipeline tool: `tools/research/firecrawl_research.py`
- Portal UI: `frontend/src/views/vimax/SkillsView.vue` (`/contentx/skills`)
