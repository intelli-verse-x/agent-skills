---
name: firecrawl-search
description: Discover pages on the live web by query using Firecrawl search, returning ranked results with titles, URLs, and snippets (optionally full-page content). The entry point for any web task where you don't yet have a URL.
when_to_use: Start of any live-web task — competitor scans, fact discovery, finding sources before a /research run, or locating the right page to hand to /firecrawl-scrape.
---

# /firecrawl-search

Search the web through Firecrawl and get back ranked results ready for
scraping or citation.

## Usage

```bash
# CLI
firecrawl search "history of trivia game shows" --limit 6

# Portal API (works keyless on the free tier, rate-limited)
curl -X POST "$CF_API/api/skills/firecrawl/search" \
  -H 'Content-Type: application/json' \
  -d '{"query": "history of trivia game shows", "limit": 6}'
```

## What it does

1. Sends the query to Firecrawl `/v2/search` (SDK when `FIRECRAWL_API_KEY` is
   set, keyless REST otherwise).
2. Normalizes results to `{title, url, description}` rows.
3. Hand promising URLs to `/firecrawl-scrape` for full markdown, or to
   `tools/research/firecrawl_research.py` for citation bundles.

## When NOT to use

- You already have the exact URL — go straight to `/firecrawl-scrape`.
- You need trusted-domain, persisted research for a brand — use `/research`
  (pipelines/research/topic.py), which stores wiki_sources rows.

## Examples

```bash
firecrawl search "best AI video production companies 2026" --limit 10
```

## Implementation

`api/routes/skills.py::firecrawl_search` and the Firecrawl CLI.
