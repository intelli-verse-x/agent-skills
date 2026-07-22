---
name: ivx-ams-sales-pipeline
description: >-
  Turn anonymous website visitors into qualified pipeline: RB2B routing, deal
  resurrection, trigger prospecting, and ICP learning from win/loss. Use for
  visitor-to-pipeline, dead deal revive, or ICP optimization.
metadata:
  source: https://github.com/ericosiu/ai-marketing-skills
  upstream_dir: sales-pipeline
  install: cursor-personal
---

## Cursor install notes

- Skill root: this folder (scripts + references live here).
- Vendor source: `~/.cursor/skills/_vendor/ai-marketing-skills/` (git pull to update).
- Telemetry is optional; skip `telemetry/*.py` unless you opt in.
- Run Python from this skill directory so relative paths resolve.
- Prefer `python` on Windows if `python3` is missing.

# AI Sales Pipeline

## Working directory

```bash
cd ~/.cursor/skills/ams-sales-pipeline
# Windows: cd $env:USERPROFILE\.cursor\skills\ams-sales-pipeline
```

Complete AI-powered sales pipeline automation: website visitor identification → intent scoring → suppression → campaign routing → dead deal resurrection → trigger prospecting → self-learning ICP optimization.

## When to Use

Use this skill when:
- Setting up automated outbound from website visitor identification (RB2B)
- Running suppression checks before cold outreach
- Routing leads to the right cold email campaigns
- Reviving closed-lost deals from HubSpot
- Finding companies showing buying signals (new hires, funding, job postings)
- Analyzing prospect approve/reject patterns to improve ICP targeting

## Tools

### RB2B Pipeline (visitor → outbound)

| Script | Purpose | Key Command |
|--------|---------|-------------|
| `rb2b_webhook_ingest.py` | Webhook server + intent scoring | `python3 rb2b_webhook_ingest.py --serve --port 4100` |
| `rb2b_suppression_pipeline.py` | 5-layer suppression checks | `python3 rb2b_suppression_pipeline.py --email user@example.com` |
| `rb2b_instantly_router.py` | Full pipeline: score → suppress → route → enroll | `python3 rb2b_instantly_router.py --serve --port 4100` |

### Deal Intelligence

| Script | Purpose | Key Command |
|--------|---------|-------------|
| `deal_resurrector.py` | 3-layer dead deal revival (time decay + POC expansion + champion tracking) | `python3 deal_resurrector.py --top 10 --dry-run` |
| `trigger_prospector.py` | Web signal monitoring (new hires, funding, agency searches) | `python3 trigger_prospector.py --days 7 --top 15` |
| `icp_learning_analyzer.py` | Learn from approve/reject decisions, recommend ICP changes | `python3 icp_learning_analyzer.py` |

## Configuration

All scripts use environment variables for API keys and configuration. Copy `.env.example` to `.env` and fill in your values.

### Required Environment Variables

- `HUBSPOT_API_KEY` — HubSpot private app token (Deal Resurrector, Suppression)
- `INSTANTLY_API_KEY` — Instantly API key (Router, Suppression)
- `BRAVE_API_KEY` — Brave Search API key (Trigger Prospector)
- `DATABASE_URL` — PostgreSQL connection string (ICP Analyzer only)

### Key Customization Points

- **Intent scoring**: Edit `PAGE_INTENT_SCORES` dict in webhook_ingest to match your URL patterns
- **Agency detection**: Edit `AGENCY_KEYWORDS_*` in router for your market
- **Loss reason scoring**: Edit `LOSS_REASON_BONUS` in deal_resurrector for your close reasons
- **Signal queries**: Edit `SEARCH_QUERIES` in trigger_prospector for your target market
- **Campaign routing**: Edit `data/campaigns.json` with your Instantly campaign UUIDs

## Data Flow

```
RB2B Webhook → Ingest (score) → Suppress (5 layers) → Route (classify) → Instantly
HubSpot CRM  → Deal Resurrector (score + draft emails) → Review Queue
Brave Search → Trigger Prospector (score + enrich) → Outreach Queue
Prospect DB  → ICP Analyzer (learn patterns) → Filter Recommendations
```

## Dependencies

- Python 3.9+
- `requests` (for HubSpot API)
- `psycopg2-binary` (for ICP Analyzer only)
- No other external dependencies — scripts use stdlib HTTP server and urllib
