---
name: ivx-aso-brief
description: Run the App Store / Play Store ASO (App Store Optimization) intel pipeline with live Firecrawl-backed signals and weighted LLM council voting. Produces an IdeationBrief with hooks, taglines, captions, screenshot prompts, and a fully-audited council log. Use whenever the user asks to "research keywords", "audit ASO", "analyse competitors", "brief screenshots", "optimise listing", "track app", or to produce App Store creative for an existing or new app.
---

# ASO ideation + screenshot brief

Wraps `content-factory/pipelines/aso/` + `pipelines/intel/ideate.py`
into an actionable workflow. The brief becomes the input to the
`ivx-content-factory-pipeline` skill (specifically
`trigger_screenshot_localizer` or `trigger_app_store_deployer`).

## When to use this skill

- User mentions an app by name + Apple/Google listing concerns.
- "What keywords should we target for X?"
- "Compare us against competitors Y and Z."
- "Generate App Store screenshots for the new release."
- "Audit our listing for app `<bundle-id>`."

## Prerequisites

- `content-factory` MCP server reachable.
- `firecrawl` MCP server configured (this skill uses Firecrawl as the
  live ASO signal source — see `pipelines/aso/signals_provider.py`
  `LIVE_PROVIDER` slot, which is wired to Firecrawl after PR for Gap C
  lands).
- For council voting: `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`,
  `GOOGLE_API_KEY` (any one is enough — missing keys fall back to a
  deterministic local heuristic, flagged in the council_log).

## The workflow

1. **Establish the app.** Ask for App Store URL or Play Store URL.
   Derive bundle ID and locale.

2. **Pull live signals via Firecrawl** (already wired into
   `signals_provider.py::LIVE_PROVIDER`):
   - SERP snapshot for the tracked keywords
   - Top 10 competitor listings (title, subtitle, screenshots,
     reviews snippet)
   - Listing audit (missing localizations, short subtitle, stale
     build, low review volume)

3. **Trigger the ideation pipeline:**

   ```
   trigger_aso_keywords(
     config_path="configs/pipelines/aso_keywords.yaml",
     app_url="<store URL>",
     locales=["en-US","es-MX","ja"]
   )
   ```

   Or for the full brief:

   ```
   trigger_competitor_analysis(
     config_path="configs/pipelines/competitor_analysis.yaml",
     app_url="<store URL>",
     competitors=["<url1>","<url2>","<url3>"]
   )
   ```

4. **Read the resulting `IdeationBrief`** (returned in the task
   response under `artefacts.ideation_json`):
   - `feature_inventory` — features merged from app metadata + GitHub
     + Figma + signals.
   - `hooks`, `taglines`, `screen_captions` — council-elected.
   - `image_prompts` — 2 flavours per slot per locale
     (pastel_design_sheet + ui_close_up_dark) with captions
     pre-injected.
   - `signals` — weighted ASO signals (the why behind each ranking).
   - `council_log` — every voter's score + rationale per candidate.

5. **Hand off to the screenshot renderer:**

   ```
   trigger_screenshot_localizer(
     config_path="configs/pipelines/screenshot_localizer.yaml",
     ideation_brief="<task_id of step 4>",
     locales=["en-US","es-MX","ja"]
   )
   ```

   Output: `screenshots/<locale>/*.png` (A/B variants per slot) and
   `storyboard.html` (interactive switcher).

## Surfacing results

Always show the user:

1. **The council_log table** — model, vote, score, one-line rationale.
   This is the audit trail for the creative choice and is the single
   most useful signal for the user to trust the output.
2. **The image_prompts** with locale-specific captions filled in,
   before kicking off rendering — gives the user a chance to course-
   correct before burning GPU credits.
3. **The signals delta** vs. the last run — "your `quiz` keyword
   rank moved from #14 to #8 last week" is far more actionable than
   raw numbers.

## Quality + safety

- Always disclose when a council vote was a deterministic fallback
  (missing API key) — flagged in council_log per voter.
- Never trigger `app_store_deployer` (which pushes a listing change
  via App Store Connect) without explicit user confirmation showing
  the diff.
- If Firecrawl returns 0 signals, the brief still builds against the
  curated baseline — call that out in the response so the user knows
  the brief is generic, not data-driven.

## Common failures

| Error | Fix |
|---|---|
| `LIVE_PROVIDER not installed` | Call `install_live_provider(remote_url=os.environ['ASO_INTEL_URL'])` once on pipeline-worker startup. After Gap C PR lands, Firecrawl provider is auto-installed. |
| Council unanimous fallback | Every voter's API key is missing. Configure at least one of OPENAI/ANTHROPIC/GOOGLE keys in `content-factory-secrets`. |
| Screenshot render OOM | The image model is gpt-image-1 which needs ~4GB. Check the `comfyui` HPA in `intelli-verse-kube-infra/content-factory/hpa.yaml`. |
