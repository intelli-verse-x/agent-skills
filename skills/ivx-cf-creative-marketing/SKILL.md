---
name: ivx-cf-creative-marketing
description: >
  Generic Content Factory creative marketing playbook — rules, Firecrawl research
  + cite validation, ideation, funnel jobs, creative craft (≤3s hook), skill chains,
  and publish flow. Brand-agnostic. Use when the user says @creative-marketing,
  creative marketing, marketing rules, campaign research, content ideas, validate
  marketing claims, growth marketing loop, multi-channel marketing, or asks which
  skills to use for marketing (not a single brand calendar).
---

# CF Creative Marketing (generic)

**Brand-agnostic.** Pass `brand_id` / load `accounts-*` only when a brand is named.
Layman guide + evidence URLs: `docs/CREATIVE_MARKETING_PLAYBOOK.md`

## When to use

- Marketing rules / research / ideas / “what skills?”
- Multi-channel plans (Social · SEO · Ads · ASO · retention)
- Fact-check marketing claims before publish
- Before any Growth Calendar or campaign pack

## When not to use

- Pipeline code → `@contentx-pipeline-dev`
- Single video QA only → `@video-loop` (still use this skill’s craft rules)
- Brand voice only → `accounts-*`
- Infra → `@deploy`

## Read first

1. This skill + `docs/CREATIVE_MARKETING_PLAYBOOK.md` (evidence bank at bottom)
2. `@contentx-firecrawl-validation` for cite protocol
3. `SOUL.md` / brand SOUL for cohorts — never invent audiences
4. If brand named → `accounts-<slug>`
5. Optional calendar depth → `scripts/calendar/CONTENTX_GROWTH_CALENDAR_REQUIREMENTS.md`

---

## Marketing rules (always)

1. Funnel job: `LEAD → ASO → DOWNLOAD → BUY → RETENTION → ANALYTICS`
2. One primary KPI: **Views** or **Revenue**
3. Where publish + how market (organic / SEO / GEO / ads / newsletter / schedule)
4. **Cite or cut** — Firecrawl/KB URL for hard claims; else `ASSUMPTION`
5. Pack score ≥ **9.5** or explicit REVISE; emit why_created / why_it_would_work / why_stopped
6. One master → many surfaces; strip foreign watermarks before Instagram
7. Batch schedule after human APPROVE (Postiz when wired)
8. No secrets in artifacts
9. No “boss” pack names
10. Taste gate — generic AI sludge without brand proof → rewrite
11. **Paid after organic proof** — boost winners only
12. Social-as-search — keywords in captions/titles (TikTok + YouTube Shorts)

---

## Creative craft (enforce on shorts/reels)

| Must | Detail |
|------|--------|
| Hook ≤3s | Problem / claim / visual first — no “hey guys” |
| Length | Prefer 15–60s for LEAD shorts; series for longer |
| Captions | On-screen text (muted viewing) |
| Plan | Storyboard / script before generate |
| Native | Platform-specific: watch-time (TT), no watermark (IG), SEO title (YT), don’t spam Shorts |
| Trends | On-brand spin only |

Evidence: Teleprompter Pro short-form guide; Miraflow Shorts 2026; Hootsuite 2026 trends — see playbook evidence bank.

---

## Firecrawl research + validate (mandatory for claims)

### Research

```text
1. Clarify goal, funnel job, region, format
2. /whatdoweknow if brand
3. firecrawl_search / research_topic / trending_ideas
4. Build evidence bank: {fact, url, funnel_why}
5. Soft-fail → degraded (no invented URLs)
```

### Validate before publish

```text
1. Extract hard claims from copy/script/calendar slots
2. search_web / firecrawl_search each claim
3. firecrawl_scrape best URL — confirm support
4. Attach cites; drop or ASSUMPTION unsupported claims
5. plan_social_post(..., validate_with_firecrawl=True) when scheduling
6. Ads/playables: verified listing claims only when available
```

**Pass:** every hard claim has a live supporting URL or labeled ASSUMPTION.  
**Tools:** Firecrawl MCP · CF `research_topic` / `search_web` / `scrape_url` · `@contentx-firecrawl-validation`

Do **not** invent a `FirecrawlValidator` class or `src/contentx/` paths. Use live helpers only.

---

## Ideas loop

```text
1. /ideate or brainstorm from evidence bank
2. Dedup (/last30days)
3. Rank: funnel · cites · cost · reuse · hook strength
4. Fill 9 answers per top idea
5. /save leftovers
```

| # | Question |
|---|----------|
| 1 | Where publish? |
| 2 | How market? |
| 3 | Verified facts (URLs)? |
| 4 | Paid angle (usually after organic)? |
| 5 | Views or Revenue? |
| 6 | Funnel stage? |
| 7 | Pricing / offer? |
| 8 | Cohort (SOUL)? |
| 9 | brand_id or `unscoped`? |

---

## End-to-end

```text
RESEARCH → IDEATE → BRIEF → STYLE LOCK → PRODUCE → VALIDATE → SCHEDULE → LEARN → PAID BOOST
```

| Stage | Skills / tools |
|-------|----------------|
| Research | Firecrawl · `/research` · `@contentx-firecrawl-validation` |
| Ideate | `/ideate` · `@creative-ai-director` |
| Brief | `@storyboarding` · `/rewrite` |
| Style | `accounts-*` · `@style-consistency` |
| Produce | `@video-loop` · `@image-generation` · `@voice-generation` |
| Validate | Firecrawl cite gate · `@visual-evaluation` · video-acceptance ≥80 |
| Schedule | `plan_social_post` → APPROVE → `schedule_social_post` |
| Learn | `/last30days` · `/save` |
| Paid | Boost organic winners only (Ads UI / Spark — not Postiz secrets) |

Big jobs: `@orchestrator` + `@cf-orchestrator`.

---

## Skill menu (short)

**`/`:** whatdoweknow · ideate · research · rewrite · repurpose · last30days · save · brand · character  

**`@`:** cf-creative-marketing · contentx-firecrawl-validation · cf-video-loop · storyboarding · style-consistency · creative-ai-director · cf-growth-calendar · cf-llm-model-usage · accounts-* · evaluation  

**Personas:** creative-ai-director · ai-product-manager · prompt-engineer · orchestrator  

**Features:** light JSON/memory packs — not Feast.

---

## Done-when

- [ ] Funnel job + primary KPI
- [ ] Evidence bank with real URLs (or ASSUMPTION)
- [ ] Hard claims passed Firecrawl validate gate
- [ ] Top ideas have 9 answers
- [ ] Craft rules applied (hook/captions/length) for video
- [ ] Brand skill only if brand in scope
- [ ] Human APPROVE before generate and before schedule
- [ ] Paid only after organic signal (or explicit N/A)
- [ ] Score / why_stopped if shipping a pack

## Anti-patterns

- Invented stats / phantom `src/contentx/` validators
- Skip Firecrawl “to go faster”
- Paid before organic
- IG with TikTok watermark
- Generic AI sludge / no hook
- Silent publish
- Brand-hardcoded when user asked generic
