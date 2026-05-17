---
name: ivx-game-trailer
description: End-to-end game trailer production via the Content Factory trailer_factory pipeline — storyboard → animatic → audio → final cut with inspect-and-fix quality gate. Routes long-running work through Hermes Kanban so it survives pod restarts and exposes a multi-stage status board. Use whenever the user asks for a game trailer, gameplay video, launch teaser, App Store preview video, or any video promoting a game.
---

# Game trailer factory

The Content Factory `trailer_factory` pipeline (under
`content-factory/pipelines/games/trailer_factory/`) is a multi-stage
workflow: research → storyboard → animatic → audio direction → final
render → quality check → re-shoot loop.

Because it spans 4-8 GPU services and takes 20-90 minutes end-to-end,
this skill routes the work through Hermes Kanban so each stage is a
durable task that survives Veo / Kling / Beatoven crashes.

## When to use this skill

- User asks for a game trailer, gameplay teaser, launch video.
- User wants an iOS/Android App Store preview video.
- Trailer revision: "make the audio darker", "add a 5-second hook
  before the gameplay", "render at 9:16 too".

## Prerequisites

- MCP servers configured: `content-factory`, `content-factory-media`,
  `hermes` (for kanban orchestration), `gastown` (for assignment to
  the right rig).
- Hermes Kanban board exists: `hermes kanban board create content-factory`
  (one-time).
- Game context in S3 App Canvas (icon, hero, mascot, sound logo,
  representative screenshots).

## The workflow

1. **Gather game context.** Confirm with the user:
   - Game name + bundle ID + Steam/Apple/Google URLs (if live).
   - Target trailer length (`30s` for App Store, `60s` for YouTube,
     `15s` for TikTok / Reels / Shorts).
   - Output aspect ratios needed (`16:9`, `9:16`, `1:1` typically).
   - "Tone words" (3-5 adjectives) — feeds the AudioDirector.

2. **Create the parent kanban task** (use the `hermes` MCP):

   ```
   kanban_create(
     board="content-factory",
     assignee="trailer-director",
     workspace="dir:/Users/<you>/dev/content-factory",
     title="Game trailer: <game_name> (<length>s × <ratios>)",
     body="<paste the gathered context as YAML>"
   )
   ```

3. **Link 5 child tasks** (one per stage), each with its own
   assignee profile so different models can work each stage:

   | Stage | Assignee | Toolset |
   |---|---|---|
   | storyboard | screenwriter | `content-factory`, `firecrawl` |
   | animatic | media-producer | `content-factory-media` |
   | audio | audio-director | `content-factory-media` |
   | final-render | media-producer | `content-factory-media` |
   | qc | reviewer | `content-factory` (reads quality.py outputs) |

   Use `kanban_link(parent=..., child=...)` for each.

4. **Watch the dispatcher** spawn workers as parents complete. Tell
   the user the parent task ID so they can `kanban_show <id>`
   anytime to see live progress.

5. **On QC failure**, the reviewer comments + blocks. The dispatcher
   re-spawns the matching upstream stage with the reviewer's notes
   as additional context. Up to 2 retries by default
   (`kanban.failure_limit`).

6. **On all-done**, the parent task's last comment includes:
   - Final video S3 URLs (one per aspect ratio).
   - `quality_score` per ratio.
   - `cost_breakdown` (per-model spend).
   - Storyboard HTML link for asset-by-asset review.

## Triggering directly (single-shot, no kanban)

For experimentation or short trailers (< 15s), bypass kanban and call
the pipeline directly:

```
trigger_pipeline(
  name="trailer_factory",
  config_path="configs/pipelines/game_visuals.yaml",
  game_context={...}
)
```

You lose retry + cross-stage visibility but it's faster for iteration.

## Variants

- **App Store Preview** — 30s, 9:16 vertical, mute-friendly (captions
  burned in). Use `configs/pipelines/short_video.yaml`.
- **YouTube launch trailer** — 60-90s, 16:9, music + VO. Use
  `configs/pipelines/long_form_video.yaml`.
- **Social shorts** — 9:16, 6-15s, hook in first 1.5s. Use
  `configs/pipelines/video_shorts.yaml` or `quiz_shorts.yaml`.

## Surfacing results

Always show:
- The **storyboard.html** link first — user can A/B per shot before
  burning GPU credits on the final render.
- The **kanban thread** for the parent task — full audit trail.
- The **cost_breakdown** — game trailers can run $5-50 in compute.

## Common failures

| Error | Fix |
|---|---|
| Storyboard stage stalls > 10 min | Screenwriter model timeout. Check `delegation.model` in Hermes config — fall back to `google/gemini-flash-2.0` for storyboard, keep claude-opus for final QC. |
| Animatic shots flicker | Veo/Kling continuity bug. The `qc` stage usually catches this; if not, add `continuity_strict: true` to the trailer config. |
| Final render aspect-ratio wrong | The `aspect_ratio` field must be set on *every* shot, not just the pipeline level. Check `configs/pipelines/<name>.yaml`. |
| Music too generic | AudioDirector needs `tone_words`. Re-run with explicit `["punchy", "synth-heavy", "hopeful"]` style adjectives. |
