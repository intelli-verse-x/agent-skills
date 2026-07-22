---
name: ivx-cf-growth-calendar
description: >
  ContentX Growth Calendar — plan the Mon–Sun content week from today for
  QuizVerse, Redlight, Last to Live, and IntelliVerse games. Use when the user
  says @cf-growth-calendar, @cf-content-calendar, content calendar, week plan,
  growth calendar, or multi-brand launch ladder (comic→anime→game).
---

# ContentX Growth Calendar (`@cf-growth-calendar`)

**One pipeline. One skill.** No date-hardcoded calendar scripts.

| Layer | Name |
|-------|------|
| Product | ContentX Growth Calendar |
| Pipeline | `content_week_calendar` |
| Alias | `@cf-content-calendar` → this skill |

## In plain English

1. Hit the pipeline with today’s date (or a date you choose).
2. It plans **Monday–Sunday** (if you hit it on Sat/Sun, it plans **next** week).
3. You get the **ops table HTML** (same bar as IVX market week): peaks · viral % · skills/loops · revenue · publish-where · cite loop per row.
4. Optional fancy page: `*-detail.html` (click grid + Copy description) via `html_render.py`.
5. You **APPROVE**, then make media with `@video-loop` / comic / audiobook / playable.
6. Use `/loop 30m` to watch long jobs.

Primary HTML: `pipelines/growth/calendar_lib/ops_plan_html.py`  
Detail HTML: `pipelines/growth/calendar_lib/html_render.py`

## Run

```bash
python -m pipelines.runner run \
  --config configs/pipelines/content_week_calendar.yaml \
  --args '{"brand_id":"quizverse"}'

# Or explicit date / launch ladder
python -m pipelines.runner run \
  --config configs/pipelines/content_week_calendar.yaml \
  --args '{"as_of":"2026-07-20","week_mode":"launch_ladder","launch_app_id":"last-to-live","ladder_phase":1}'
```

Also: `python -m pipelines.growth.content_week_calendar --brand-id quizverse`

Outputs: `.working_dir/calendars/content_week/<run_id>/content-week-calendar-<week_start>.{html,json}` + `why_stopped.json` + SOUL copy.

## Week modes

| Mode | Args | Meaning |
|------|------|---------|
| `brand_focus` | `brand_id` (+ `app_id`) | Whole week one brand (default QuizVerse) — **brand-native titles/hooks** |
| `portfolio` | `portfolio_ids: ["quizverse","red-light","last-to-live","intelli-verse-x",…]` | Rotate brands by day; QuizVerse can appear twice as hero; `intelli-verse-x` = house awareness |
| `launch_ladder` | `launch_app_id` + `ladder_phase` 0–5 | IP comic→anime→game with phase notes |

Brand arcs live in `pipelines/growth/calendar_lib/brand_arcs.py` (QuizVerse · Redlight · Last to Live · brain games).

### Council + Firecrawl (ops)

- **Council:** timeouts / ESCALATE → `council_degraded` (non-blocking). Citation ≥9.5 is the ship gate. Skip with `CF_CALENDAR_SKIP_COUNCIL=true`. Timeout wall: `CF_CALENDAR_COUNCIL_TIMEOUT_S` (default 45).
- **Firecrawl:** when `FIRECRAWL_API_KEY` is set, live cites are **merged** into every slot (plus KB bank facts). Without the key → bank-only (`validation_status=degraded`).
- **Lifecycle (peaking):** Firecrawl titles/snippets → `ASCENDING` / `PEAKING` / `DECLINING` / `UNKNOWN` via `calendar_lib/lifecycle.py` → `score_virality`. Advisory only (organic hero vs 24–48h/paid vs evergreen). Bank-only → `UNKNOWN` (not fake ASCENDING). Citation ≥9.5 still ships the plan.

## Always deliver like AutoCurio June bar

**Gold reference (UX + depth):**  
https://intelli-verse-x-media.s3.us-east-1.amazonaws.com/content-calendar/autocurio-youtube-june-2026.html  

Code checklist: `pipelines/growth/calendar_lib/deliverable_bar.py` (`enrich_slot_to_bar`, `pack_gap_report`).

Every calendar HTML/JSON pack MUST include (or explicit N/A):

| Pack section | Meaning |
|--------------|---------|
| Hero funnel | How channel drives installs / KPI |
| Cast / brand lock | Mascot + voice consistency |
| Tool stack (cited) | How to make each format |
| Pipeline / loop coverage | `@video-loop`, comic, audiobook, … |
| Cross-platform playbook | One master → YT/IG/TT/X/comic shelves |
| Virality rules (data) | 30–60s, hook ≤3s, keyword-in-title, peaks |
| Per-slot script pack | Shot list + **copy-ready description** + pinned comment + store links |
| ContentX cite loop | why_created · verifiable facts · loop · why_stopped · feedback · why_it_would_work |
| Ads + pricing (Revenue/audio) | Google keywords + Plus $9.99/$49.99 · CPI/LTV |
| Evidence | Firecrawl and/or KB URLs |

IVX multi-channel weeks: `scripts/custom/ivx_market_week/build_plan.py` (same ops table via `render_ops_plan_table`).

### Sid Orchestra hard gate (every delivery)

Before calling a calendar “done”, grade **Calendar Pack Eval** in `.cursor/sid-orchestra/EVALS.md` §7 (CAL1–CAL12).  
FAIL → fix/regenerate. Do not upload to S3 as done on FAIL.

### HTML UX (ship checklist)

Open `content-week-calendar-<week_start>.html` or `ivx-market-week-*.html` (ops table) and confirm:

1. Columns: Day · Channel · Title · **Who+why** · Peaks · Viral % (modeled) · Skills · **Make prompt** · **Validate** · **Eval cases** · Revenue · Publish · Cite  
2. Every row has targeting (WHO / PAIN / WHY), paste-ready Cursor prompt + deep `video_prompt`, validate-after-make, E1… eval cases  
3. Publish homes in **plain English** (AutoCurio YouTube, X…) — **zero** `postiz_keys` / `youtube_*` keys / JSON blobs  
4. Firecrawl lifecycle when key present; unique `why_it_would_work` per slot  
5. Ship media only when validate + all eval cases PASS (human)

Optional: `*-detail.html` for click-grid + Copy description.

## What every slot includes

- Plain English blurb · Views **or** Revenue goal  
- Deep cohort + **SOUL ref** + soul_check (open SOUL and validate)  
- Where to post (Postiz IDs) · US ET + India IST · why that time  
- How to market · Google + TikTok campaigns with **why** (esp. audiobook $)  
- Funnel stage LEAD→…→ANALYTICS  
- Money guess low/mid/high + assumptions ($4.50/30d LTV, CPI ~$1.20)  
- ≥2 verified facts · why_created · why_stopped · feedback · why_it_would_work  
- `skill_chain` including `/loop`, `/whatdoweknow`, `@accounts-*`, make loop, Firecrawl, Postiz  
- `cursor_prompt_world_class` paste block  
- **AutoCurio bar:** `duration_s`, `seo_keyword_first_40`, `script_or_shot_list`, `youtube_description`, `pinned_comment`, `spoken_cta`, `store_links`, `viral_chance_pct`, `country_peak_timing`, `publish_where`, `skills_and_loops`  

## World-class make loop (after APPROVE)

| Format | Make with |
|--------|-----------|
| Short / anime cut | `@video-loop` / `@cf-video-loop` |
| Comic | `trigger_pipeline` `comic` |
| Audiobook | `concept_to_audiobook` |
| Playable | `playable_ad` |
| Ads / launch | `ad` / `marketing_kit` |

Always: brand skill → research/Firecrawl → APPROVE → **make** → **validate with all skills** → Postiz.

### After make (required)

1. `@contentx-firecrawl-validation` — cite check  
2. `@cf-creative-marketing` — craft rules  
3. `@visual-evaluation` + `@style-consistency` — look / brand lock  
4. `@video-loop` acceptance ≥80 (shorts) or format checklist  
5. `@evaluation` — pack ≥9.5 or REVISE (max 3 loops)  
6. Only then `plan_social_post` → APPROVE → schedule  

Related: `@cf-creative-marketing`, `docs/CREATIVE_MARKETING_PLAYBOOK.md`, `@contentx-firecrawl-validation`, `@orchestrator`.

## Brands

Load before generate: `@accounts-quizverse` · `@accounts-red-light` · `@accounts-fifth-element` · `@accounts-toba-tech`  
Games: `app_id` like `last-to-live`, `hyperrunx`, … under `intelli-verse-x`.

## Done-when

- ≥12 slots · all 4 formats · ≥10 YouTube + ≥10 other platform posts (multi-post)  
- Citation score ≥9.5 · `why_stopped.json` present  
- Council artifact (or degraded flag)  
- Learnings via `learning_loop` → S3 when enabled  
- HTML readable without opening JSON  
- **`deliverable_bar.pack_sections_missing` empty** (or documented N/A) vs AutoCurio June bar  
- Every slot has copy-ready description + script outline + cite-loop fields  

## Anti-patterns

- No date-hardcoded `build_*_jul*.py` (deleted — use this pipeline)  
- No phantom `src/contentx/`  
- No passwords in calendar artifacts  
- No auto-generate / auto-publish without APPROVE  
