---
name: ivx-cf-contentx-firecrawl-validation
description: >-
  Validates Content Factory generated content using Firecrawl for fact-checking,
  citation verification, SEO analysis, and trend alignment. STATUS: do NOT use
  src/contentx/ paths — real helpers live under tools/, utils/, scripts/ops/,
  configs/. Use when generating blogs, ads, scripts, or when the user mentions
  validation, fact-checking, SEO, or content quality.
---

# ContentX Firecrawl Validation Protocol

> **STATUS: PATH TRUTH (2026-07-15) — NOT EXECUTED as `src/contentx/`.**  
> There is **no** `src/contentx/` and **no** singular `config/app/`.  
> Do **not** create validators under phantom layout paths.  
> Use live trees below (see `docs/STRUCTURE.md`).

## Live paths (use these)

| Role | Real path |
|------|-----------|
| Research / cite helper | `tools/research/firecrawl_research.py` |
| Fresh research util | `utils/pipeline/fresh_research.py` |
| Topic / trend CLI | `scripts/ops/firecrawl_topic_validator.py` |
| Pipeline Firecrawl knobs | `configs/pipelines/` (e.g. `concept_to_curriculum.yaml`, `app_catalog_enricher.yaml`) |
| Env key | `FIRECRAWL_API_KEY` (root `.env`) |
| MCP | Firecrawl MCP tools (`firecrawl_search`, `firecrawl_scrape`, …) |

Example snippets below are **patterns only** — wire them to the live modules above, not `src/contentx/…`.

## Purpose

Use Firecrawl to validate generated content before publishing:
1. **Factual accuracy** — Are claims supported by sources?
2. **Citation integrity** — Do cited URLs support the claims?
3. **SEO optimization** — Are titles, descriptions, keywords competitive?
4. **Trend alignment** — Is content relevant to current trends?

## Architecture

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Content   │────▶│  Firecrawl  │────▶│  Validation │
│   Generated │     │  MCP Server │     │  Report     │
└─────────────┘     └─────────────┘     └─────────────┘
                     │
                     ▼
              ┌─────────────┐
              │  Web Sources│
              │  (live data)│
              └─────────────┘
```

## Validation Triggers

| Event | Validation Type | Auto-Action on Fail |
|-------|-----------------|---------------------|
| Blog pipeline completes | Cite check + SEO score | Quarantine → human review |
| Ad campaign generated | Competitor ad analysis | Flag for revision |
| Learning series published | Fact-check key claims | Append correction notice |
| Script contains URLs | Live URL validation | Replace broken links |
| Trending topic used | Re-trend check (<24h) | Refresh topic data |

## Implementation

### Basic Validator

```python
# PATTERN ONLY — prefer tools/research/firecrawl_research.py
# and utils/pipeline/fresh_research.py (do NOT create src/contentx/…)
from firecrawl import FirecrawlApp
# Live imports: from tools.research.firecrawl_research import … 
# or utils.pipeline.fresh_research helpers — not contentx.domain.*

class FirecrawlValidator:
    """Validates generated content against live web sources."""

    def __init__(self, api_key: str):
        self.client = FirecrawlApp(api_key=api_key)

    async def validate_citations(
        self,
        content: str,
        citations: list[str],
    ) -> ValidationResult:
        """Check that citations support the claims made."""
        results = []
        for url in citations:
            scraped = await self.client.scrape_url(url)
            relevance = await self._score_relevance(content, scraped)
            results.append({"url": url, "score": relevance})

        avg_score = sum(r["score"] for r in results) / len(results)
        passed = avg_score >= 0.7

        return ValidationResult(
            passed=passed,
            score=avg_score,
            details=results,
            action="approve" if passed else "quarantine",
        )
```

### SEO Validation

```python
async def validate_seo(
    self,
    title: str,
    description: str,
    keywords: list[str],
    competitor_urls: list[str],
) -> ValidationResult:
    """Compare SEO metadata against top-ranking competitors."""
    competitor_data = [
        await self.client.scrape_url(url)
        for url in competitor_urls
    ]

    # Analyze competitor titles, descriptions, headers
    analysis = {
        "title_length": len(title),
        "description_length": len(description),
        "keyword_density": self._calculate_keyword_density(content, keywords),
        "competitor_avg_title_length": statistics.mean(
            len(c.title) for c in competitor_data
        ),
    }

    score = self._calculate_seo_score(analysis)
    return ValidationResult(
        passed=score >= 0.75,
        score=score,
        details=analysis,
        action="approve" if score >= 0.75 else "revise",
    )
```

### Trend Validation

```python
async def validate_trend(
    self,
    topic: str,
    max_age_hours: int = 24,
) -> ValidationResult:
    """Verify trending topic is still relevant."""
    search_results = await self.client.search(
        query=topic,
        time_range="day",
    )

    # Check recency and volume
    is_trending = any(
        result.published_within(hours=max_age_hours)
        for result in search_results
    )

    return ValidationResult(
        passed=is_trending,
        score=1.0 if is_trending else 0.0,
        details={"articles_found": len(search_results)},
        action="approve" if is_trending else "refresh_topic",
    )
```

## Integration with Pipelines

```python
# In pipeline execute method
async def execute(self, request):
    # Generate content
    content = await self.generate(request)

    # Validate
    validator = FirecrawlValidator(api_key=settings.firecrawl_api_key)

    citation_check = await validator.validate_citations(
        content=content.text,
        citations=content.citations,
    )

    seo_check = await validator.validate_seo(
        title=content.title,
        description=content.description,
        keywords=content.keywords,
        competitor_urls=request.competitor_urls,
    )

    # Decide action
    if not all([citation_check.passed, seo_check.passed]):
        await self.quarantine(content, reports=[citation_check, seo_check])
        raise ContentValidationError("Validation failed")

    return content
```

## CLI Commands

```bash
# Validate a specific output
make validate out=./out/runs/2026/07/06/abc123/final.md

# Validate all pending outputs
make validate-pending

# Refresh trend data
make refresh-trends

# Full content audit
make content-audit
```

## Configuration

```yaml
# PATTERN — live knobs live under configs/pipelines/*.yaml
# e.g. configs/pipelines/concept_to_curriculum.yaml (firecrawl: …)
#      configs/pipelines/app_catalog_enricher.yaml (firecrawl_api_key: ${FIRECRAWL_API_KEY})
# Do NOT use singular config/app/default.yaml (does not exist).
firecrawl:
  api_key: ${FIRECRAWL_API_KEY}
  validation:
    citation:
      min_score: 0.7
      required_fields: [url, title, published_date]
    seo:
      min_score: 0.75
      competitor_count: 3
    trend:
      max_age_hours: 24
      search_results_count: 10
```

## Best Practices

1. **Always validate before publish** — No exceptions
2. **Cache results** — Don't re-validate unchanged content
3. **Graceful degradation** — If Firecrawl is down, queue for later review
4. **Human oversight** — Quarantined content goes to human review queue
5. **Audit trail** — Log all validation results for compliance
