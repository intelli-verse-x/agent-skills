---
name: firecrawl-research
description: Build a citation-grade ResearchBundle for a concept and its sub-concepts using Firecrawl search (with Perplexity cross-checking), where every fact carries at least one fetched CitationRef and primary sources (.edu/.gov/Wikipedia) are ranked first.
when_to_use: A learning/curriculum pipeline needs grounded facts with real citations — concept_to_curriculum, exam_prep_bundle, playable_flashcard_deck — or any task where an LLM must not invent URLs.
---

# /firecrawl-research

Fan out Firecrawl searches across a concept's sub-concepts and return a
`ResearchBundle` where every fact is backed by fetched citations.

## Usage

```bash
python - <<'EOF'
import asyncio
from tools.research.firecrawl_research import FirecrawlResearcher

async def main():
    r = FirecrawlResearcher()  # reads FIRECRAWL_API_KEY from env
    bundle = await r.research_concept(
        concept="photosynthesis",
        sub_concepts=["light reactions", "Calvin cycle", "chlorophyll"],
    )
    print(bundle.total_citations, "citations,",
          bundle.primary_source_ratio, "primary ratio")

asyncio.run(main())
EOF
```

## What it does

1. 1-2 Firecrawl search queries per sub-concept (concurrent, thread-wrapped).
2. Perplexity Sonar cross-check when a client is provided.
3. Dedups by URL/domain, ranks primary sources (.edu, .gov, Wikipedia,
   Britannica, peer-reviewed publishers) first.
4. Packages the strongest snippet as the canonical fact — never lets the LLM
   author a URL.

## When NOT to use

- Brand-scoped persisted research (wiki_sources/wiki_synthesis rows) — use
  `/research` (pipelines/research/topic.py) instead.
- One-off page content — `/firecrawl-scrape` is cheaper.

## Implementation

`tools/research/firecrawl_research.py::FirecrawlResearcher`, consumed by
`pipelines/learning/concept_to_curriculum.py` and related learning pipelines.
