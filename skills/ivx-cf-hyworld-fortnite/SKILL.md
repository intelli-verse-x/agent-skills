---
name: ivx-cf-hyworld-fortnite
description: >
  Content Factory HY-WorldPlay + Fortnite/UEFN map loop. Use when the user
  says @hyworld, @fortnite-map, make a 3D world / navigable scene / Creative
  island with RunPod hyworld-weights, or wants WorldPlay trajectories +
  world_scene pipeline. Enforces research → plan APPROVE → RunPod volume → generate.
---

# CF HY-World / Fortnite Map Skill

## When to use

- `@hyworld` / `@fortnite-map`
- “Make a Fortnite Creative / UEFN map with WorldPlay”
- “Generate navigable 3D world scenes on RunPod”
- “Use hyworld-weights volume for HY-World”

## When not to use

- Mesh/character-only (`character_3d`) — different pipeline
- Pure 2D SVG characters (`svg_character`)
- Cluster Wan2.2 shorts (use `@video-loop`)

## Read first

1. `tools/world/runpod_hyworld.py` — volume `8b6vk25c4i` / mount `/runpod-volume`
2. `configs/pipelines/world_scene.yaml`
3. `pipelines/games/world_scene.py`
4. Epic Creative best practices (Firecrawl): flow, POIs, fight direction, no dead ends
5. This skill’s `reference.md` — Aether Ring + hot topics

## Tool map

| Stage | Tools |
|-------|--------|
| Research | Firecrawl `firecrawl_search` / `firecrawl_scrape` (Creative trends + Epic docs) |
| RunPod | MCP `user-runpod`: `get-network-volume`, `list-pods`, `create-pod` |
| Plan | Ideate map JSON (show full plan) → wait for **APPROVE** |
| Generate | CF MCP `trigger_pipeline` **or** `POST /pipelines/world_scene` with `user_approved` |
| Poll | `get_task_status` / `list_output_files` |

### CF MCP (preferred)

```text
plan_generation(pipeline_type="world_scene", topic="...")  # if supported
→ SHOW plan → WAIT APPROVE
trigger_pipeline(
  pipeline_type="world_scene",
  topic="<approved theme>",
  quality="standard"|"high",
  platform="games",
  style="cinematic",
  audience="Creative players",
  extra_params={
    "map_mode": "fortnite_br_lite",
    "poi_count": 6,
    "generate_videos": True,
    "export_unity": True
  },
  user_approved=True
)
```

### Direct API

```bash
POST /api/pipelines/world_scene
{
  "topic": "neon storm archipelago BR-lite",
  "map_mode": "fortnite_br_lite",
  "poi_count": 6,
  "generate_videos": true,
  "export_unity": true
}
```

### Local runner (on RunPod pod with volume attached)

```bash
export WORLDPLAY_EXECUTION_MODE=runpod
# paths auto-resolve under /runpod-volume/hyworld/...
python pipelines/runner.py run \
  --config configs/pipelines/world_scene.yaml \
  --pipeline world_scene \
  --args '{"topic":"Aether Ring neon storm","map_mode":"fortnite_br_lite","poi_count":6}' \
  --local
```

## RunPod volume (required for videos)

| Field | Value |
|-------|--------|
| Name | `hyworld-weights` |
| ID | `8b6vk25c4i` |
| DC | `US-NC-1` |
| Mount | `/runpod-volume` |
| S3 endpoint | `https://s3api-us-nc-1.runpod.io` |
| Bucket | `8b6vk25c4i` |

Expected layout:

```text
/runpod-volume/hyworld/
  HY-WorldPlay/
  models/HunyuanVideo-1.5/
  models/ar_distilled_model/
```

Pod tip: use dashboard **Configure Pod with volume** if MCP `create-pod` omits `networkVolumeId`. Prefer A100 80GB / H100 for Hunyuan AR-distilled.

Env (also in `.env`):

```bash
WORLDPLAY_EXECUTION_MODE=runpod
RUNPOD_NETWORK_VOLUME_ID=8b6vk25c4i
RUNPOD_NETWORK_VOLUME_NAME=hyworld-weights
RUNPOD_DATA_CENTER=US-NC-1
RUNPOD_VOLUME_MOUNT=/runpod-volume
RUNPOD_S3_ENDPOINT=https://s3api-us-nc-1.runpod.io
RUNPOD_S3_BUCKET=8b6vk25c4i
# Optional overrides if layout differs:
# WORLDPLAY_DIR=/runpod-volume/hyworld/HY-WorldPlay
# WORLDPLAY_MODEL_PATH=/runpod-volume/hyworld/models/HunyuanVideo-1.5
# WORLDPLAY_ACTION_CKPT=/runpod-volume/hyworld/models/ar_distilled_model
```

S3 keys for the volume: set `RUNPOD_S3_ACCESS_KEY` / `RUNPOD_S3_SECRET_KEY` from the RunPod volume UI (never commit).

## Design gate (non-negotiable)

Before generate, the plan must include:

1. Layout = `circular` or `lane` + rationale  
2. Named POIs with ≥2 connections each (no dead ends)  
3. Centerpiece landmark + callout-friendly names  
4. Per-POI WorldPlay trajectories (default: establishing / flythrough / look_around)  
5. Hot-topic hooks used for flavor only (Prop Hunt, Pit, Only Up, RvB, etc.) — no IP theft  

Show the full `map_spec` JSON. Wait for user **APPROVE**.

## Acceptance

Complete only when:

1. `map_manifest.json` written under `.working_dir/world_scene/<run_id>/`  
2. If `generate_videos=true`: WorldPlay enabled **or** clear skip reason with volume path diagnosis  
3. Concept art and/or videos exist for centerpiece + POIs  
4. UEFN notes present in manifest  

## Minimal happy path

```text
1. Firecrawl research Creative trends + Epic level-design docs
2. Draft map_spec (or use Aether Ring reference) → SHOW → APPROVE
3. Ensure RunPod pod + hyworld-weights attached in US-NC-1
4. trigger_pipeline world_scene (user_approved=True)
5. Poll → deliver map_manifest + location videos + Unity packs
```

## Output contract

Always return:

- Map name + pitch  
- POI graph summary  
- Paths: `map_manifest.json`, per-location videos, Unity packs  
- RunPod volume / WorldPlay availability status  
