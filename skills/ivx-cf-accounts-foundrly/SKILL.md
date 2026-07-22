---
name: ivx-cf-accounts-foundrly
description: Content Factory account guide for Foundrly (AI co-founder for small business). Use when the user mentions Foundrly, foundrly, AI co-founder, business plan generator, small business launch, or foundrly.intelli-verse-x.ai.
when_to_use: Any content-factory work for Foundrly — LinkedIn posts, shorts, blog, ads, founder education, or copilot marketing. Load before ideate/rewrite/generate steps.
---

# Foundrly — Content Factory Account

**Brand slug:** `foundrly`  
**Tagline:** Your AI Co-Founder — From Idea to Open for Business  
**Site:** https://foundrly.intelli-verse-x.ai  
**App / game id:** `foundrly`

## Account type

B2B SaaS utility — founder acquisition and activation. Primary conversion is starting a business plan / signing up for the copilot. **Not** a neighborhood discovery app.

## Key S3 paths

- `agent-assets/brands/foundrly/brand_entity.json` — canonical brand pack (AI co-founder narrative)
- `agent-assets/brands/foundrly/learnings.json` — brand run lessons
- `agent-assets/brands/foundrly/Logo.png` — logo asset
- `agent-assets/games/foundrly/app_canvas.json` — app canvas (voice, audience, directives)
- `agent-assets/games/foundrly/game.json` — game metadata

## Voice and positioning

- **Archetype:** Supportive expert co-founder — practical, direct, optimistic
- **Personality:** supportive-expert | Confident, supportive, ambitious
- **Primary emotion:** Confidence (replacing founder anxiety)
- **Hook pattern:** Name the founder pain → show the next concrete step → CTA to build
- **Relatability:** Speak founder-to-founder; never consultant jargon without a plain-English translation

## What Foundrly is (always say this)

An **AI co-founder** that walks small-business founders from raw idea to running business: business plans, branding, go-to-market, pricing, and day-to-day operating guidance. Consultant-grade help at software prices.

## What Foundrly is NOT (never say)

- Neighborhood discovery / "score local" / hyper-local commerce platform
- Get-rich-quick or guaranteed success
- A replacement for accountants or lawyers

## Audience

| Segment | Who | Pain | Desire |
|---------|-----|------|--------|
| Aspiring founders | Side-hustlers, first-time founders | Don't know where to start | A working business plan |
| Early-stage SMB | Solo operators 22–55 | Can't afford advisors | Co-founder-level sounding board |
| Time-poor builders | Mobile + desktop web | Analysis paralysis | One clear next step |

**Markets:** US, CA, UK, AU, IN | **Languages:** en

---

## Visual identity

| Token | Hex | Use |
|-------|-----|-----|
| Foundrly blue | `#2563EB` | Primary brand, CTAs, accent bar |
| Slate dark | `#0F172A` | Backgrounds, headlines |
| Amber accent | `#F59E0B` | Highlights, urgency |
| Off-white | `#F8FAFC` | Canvas, cards |

**Style:** Clean modern SaaS — confident blues, generous whitespace, founder-desk photography, simple line illustrations. **Font:** Inter.

**Thumbnail / cover:** Bold headline + founder imagery + Foundrly blue accent bar.

---

## Content pillars

1. How to start a small business with AI
2. AI business plan walkthroughs
3. Founder stories and launch diaries
4. Go-to-market and first-customer playbooks

## Platform priority

| Platform | Priority | Formats | Cadence |
|----------|----------|---------|---------|
| LinkedIn | High | posts | 3×/week |
| YouTube | Medium | shorts, long_form | 2×/week |
| Instagram | Medium | reels, posts | 3×/week |

**Primary CTA:** Start building with your AI co-founder  
**CTA URL:** https://foundrly.intelli-verse-x.ai

---

## Messaging DO / DON'T

**DO:** co-founder, next step, launch, your business, business plan, go-to-market, plain language, concrete action at the end.

**DON'T:** get rich quick, guaranteed success, replace your accountant/lawyer, neighborhood discovery, score local, mint-and-charcoal local-commerce story.

**Hashtags:** `#foundrly` `#aicofounder` `#smallbusiness` `#startup` `#entrepreneur`

---

## Preferred pipelines

| Format | Pipeline |
|--------|----------|
| LinkedIn / blog posts | `blog`, `ad_banners` |
| Shorts / Reels | `viral_shorts` |
| Product demos | screen-capture + motion graphics style |
| Founder education | `learning_series` |

## Pipeline directives (from canvas)

- **Video style:** screen-capture + motion graphics
- **Pacing:** snappy
- **Soundtrack:** upbeat corporate / lo-fi focus
- **Ad tone:** Encouraging, practical, founder-to-founder
- **Logo placement:** bottom-right

---

## Persona: Foundrly copilot

- **Character id:** `foundrly-copilot`
- **Role:** AI co-founder hero (abstract mark, not a cartoon mascot)
- **Voice:** Warm expert — always ends with one clear action
- **Catchphrase:** Here's your next step.

---

## Workflow

```bash
# 1. Load brand context (MCP)
load_generation_context(brand_id="foundrly", app_id="foundrly", pipeline_kind="viral_shorts")

# 2. Plan generation
plan_generation(brand_id="foundrly", app_id="foundrly", pipeline_type="viral_shorts", topic="AI business plan in 5 minutes")

# 3. Generate with brand colors + founder tone
trigger_pipeline(
  pipeline_type="viral_shorts",
  topic="From blank page to business plan — your AI co-founder",
  style="Foundrly SaaS: #2563EB blue, #0F172A slate, Inter, founder desk, blue accent bar",
  extra_params={"brand_id": "foundrly", "app_id": "foundrly"}
)
```

## Default topics

- ai business plan generator
- how to start a small business with ai
- ai co-founder for startups
