# Where model config lives

Read this when you need exact paths; keep `SKILL.md` lean.

## Source of truth

| Question | File |
|----------|------|
| Human-readable per-pipeline tables | `docs/LLM_MODEL_USAGE.md` |
| Live vs dead providers | `docs/PROVIDERS.md` |
| Fleet chat / image / video roles | `configs/llm_models.yaml` |
| Nickname → API id | `configs/model_catalog.yaml` |
| Per-pipeline overrides | `configs/pipelines/<name>.yaml` |
| Vision chat factory | `configs/llm_config.py` → `create_vision_chat_model()` |
| Env templates (no secrets in git) | `.env.example` |

## Common pipeline configs

| Pipeline | Config |
|----------|--------|
| Ads | `configs/pipelines/ad.yaml` |
| Viral shorts | `configs/pipelines/video_shorts.yaml` |
| Comic | `configs/pipelines/comic.yaml` |
| Blog | `configs/pipelines/blog.yaml` |
| Long-form | `configs/pipelines/long_form_video.yaml` |
| Song | `configs/pipelines/song.yaml` |
| Script → video | `configs/pipelines/script2video.yaml` |
| World / Fortnite | `configs/pipelines/world_scene.yaml` |
| Learning series | `configs/pipelines/learning_series.yaml` |

## Legend (plain → typical id)

| Plain name | Typical resolution |
|------------|-------------------|
| Qwen3-30B | `${LLM_PRIMARY}` → `Qwen/Qwen3-30B-A3B-Instruct-2507` |
| DeepSeek V4 Pro | `${LLM_PRIMARY_PRO}` / `${LLM_SF_PRIMARY_PRO}` |
| FLUX.2 Flex | `black-forest-labs/FLUX.2-flex` |
| FLUX.2 Pro | `black-forest-labs/FLUX.2-pro` |
| Wan 2.2 | `Wan-AI/Wan2.2-T2V-A14B` (+ I2V twin) |
| Qwen3-VL-8B | `Qwen/Qwen3-VL-8B-Instruct` |
| ACE-Step | `ace-step-1.5` (self-hosted when warm) |
