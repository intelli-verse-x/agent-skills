---
name: firecrawl-scrape
description: Extract clean, LLM-ready markdown from a single known URL using Firecrawl scrape. Handles JS-rendered pages and strips nav/boilerplate so the content can go straight into prompts or artifacts.
when_to_use: You already have a URL (from /firecrawl-search, a user, or a pipeline) and need its content as clean markdown — pricing pages, docs, articles, competitor pages.
---

# /firecrawl-scrape

Scrape one URL into clean markdown.

## Usage

```bash
# CLI
firecrawl scrape "https://firecrawl.dev" -o .firecrawl/firecrawl-home.md

# Portal API (works keyless on the free tier, rate-limited)
curl -X POST "$CF_API/api/skills/firecrawl/scrape" \
  -H 'Content-Type: application/json' \
  -d '{"url": "https://firecrawl.dev"}'
```

## What it does

1. Fetches and renders the page through Firecrawl `/v2/scrape`.
2. Returns `{markdown, metadata}` — title, description, source URL.
3. Save outputs under `.firecrawl/` (git-ignored) when working locally.

## When NOT to use

- The page needs clicks, forms, or login first — use `firecrawl interact`.
- You need many pages from one site — use `firecrawl crawl` (API key required).

## Examples

```bash
firecrawl scrape "https://www.anthropic.com/pricing" -o .firecrawl/anthropic-pricing.md
```

## Implementation

`api/routes/skills.py::firecrawl_scrape` and the Firecrawl CLI.
