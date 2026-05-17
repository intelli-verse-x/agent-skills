---
name: ivx-content-factory-pipeline
description: Trigger any of the intelli-verse-x Content Factory pipelines (50+ available — learning series, movies, ads, app store screenshots, podcasts, game trailers, music videos, social shorts, etc.), poll status, and surface the produced artefacts (videos, images, captions, S3 URLs). Use this whenever the user asks to "generate", "produce", "render", "create" any video, image set, podcast, screenshot batch, ad, or other media content via Content Factory.
---

# Content Factory pipeline runner

Content Factory is the intelli-verse-x media generation backend. It
exposes ~50 named pipelines (each backed by a YAML config in
`configs/pipelines/`) via a FastMCP server on port 8001.

## When to use this skill

- User asks for video / image / audio / screenshot generation by name
  (`learning_series`, `movie`, `kids_movie`, `ad`, `ad_banners`,
  `quiz_shorts`, `podcast2video`, `documentary`, `app_store_deployer`,
  `game_marketing_audit`, `song`, `dubbing`, `world_scene`, …).
- User asks to "make content for X app" or "produce a trailer for Y".
- Status checks on a previously-triggered run (`get_task_status`).
- Listing what pipelines are available.

## Prerequisites

The MCP servers from this repo are configured in the calling client:

- `content-factory` — FastMCP at `mcp_server/server.py` (HTTP-proxies CF api)
- `content-factory-media` — FastMCP at `media_mcp_server/server.py`
  (provider-agnostic generate_image/video/tts/music/motion)

Env vars the MCP server reads: `CF_API_URL` (default `http://localhost:8001`),
`CF_API_KEY`, `DIRECTOR_URL` (default `http://localhost:8000`).

## The workflow

1. **Pick the pipeline.** If the user named one, use it. If not, ask
   for one of: learning_series, movie, kids_movie, short_movie,
   short_video, video_shorts, quiz_shorts, podcast_series,
   podcast2video, documentary, blog, ebook, song, song2musicvideo,
   beat_synced, dubbing, ad, ad_banners, app_ad_campaigns, event_promo,
   event_recap, marketing_kit, gtm_master_plan, revenue_strategy,
   game_visuals, game_sound, ivx_full_game, ivx_character_2d,
   ivx_character_3d, ivx_landing_page, world_scene, character_2d,
   character_3d, motion_library, interactive_avatar, comic, lyrics,
   legal_gen, screenshot_localizer, asc_release, aso_keywords,
   app_catalog_enricher, app_store_deployer, competitor_analysis,
   content_planner, guided_learning, short_drama, short_movie_series,
   long_form_video, script2video, video, video_shorts.

2. **Build the request body.** Every pipeline accepts a `config_path`
   (or inline `config`), an `output_dir`, and a `brand_context` /
   `game_context` block. Defaults in `configs/pipelines/<name>.yaml`.

3. **Call `trigger_<pipeline_name>` (or generic `trigger_pipeline`) on
   the `content-factory` MCP server.** It returns a `task_id`.

4. **Poll `get_task_status(task_id)` every 30s.** Status flows:
   `queued → running → done | failed | blocked`. If `blocked`, read
   the comment thread — usually a missing asset or a quality gate
   failure.

5. **Surface artefacts.** On `done`, the response includes:
   - `output_dir` (S3 or local path)
   - `artefacts[]` — list of (kind, uri) tuples
   - `quality_score` if the pipeline has a `quality.py` gate
   - `council_log` for any council-voted creative outputs

## Examples

### Learning series episode

```
trigger_learning_series(
  config_path="configs/pipelines/learning_series.yaml",
  topic="Newton's three laws of motion",
  episode_count=3,
  locale="en",
  brand_context={"brand": "QuizVerse", "audience": "ages 10-14"}
)
```

### Game trailer (one-shot)

```
trigger_ivx_full_game(
  config_path="configs/pipelines/ivx_full_game.yaml",
  game_name="Cricket VR",
  game_context={"genre": "sports", "platform": "iOS, Android, Quest"}
)
```

### App Store screenshots, all locales

```
trigger_screenshot_localizer(
  config_path="configs/pipelines/screenshot_localizer.yaml",
  app_slug="quizverse",
  locales=["en", "es", "fr", "de", "ja", "ko", "zh-Hans", "pt-BR"]
)
```

## Quality + cost guardrails

- Always confirm `brand_context` before triggering — pipelines that
  miss it produce off-brand artefacts and burn credits.
- For long-running pipelines (`learning_series` with episode_count > 5,
  any movie pipeline), prefer queuing through Hermes Kanban instead
  of polling — see the `ivx-game-trailer` skill for the pattern.
- Surface the council_log to the user when present — it shows which
  model voted for what and is the audit trail for creative choices.

## Common failures

| Error | Fix |
|---|---|
| `403 brand_context required` | The pipeline needs `brand_context.brand` and `brand_context.audience` — ask the user. |
| Stuck in `queued` > 5 min | `pipeline-worker` pod may be down. Have user run `kubectl -n content-factory get pods -l app=content-factory-pipeline-worker`. |
| `blocked: missing voice profile` | The voice referenced isn't in the brand kit. Use `list_voices` on the media MCP and pick an existing one. |
| `blocked: GPU service unreachable` | One of the GPU sidecars (comfyui/musetalk/hymotion/…) is unhealthy. Use the `ivx-k8s-gpu-rollout` skill to investigate. |
