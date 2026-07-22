---
name: ivx-cf-contentx-pipeline-dev
description: >-
  Develop Content Factory pipelines. Live paths only: pipelines/, api/routes/,
  configs/pipelines/, pipeline_registry.py. Prefer .cursor/workflows/new-pipeline.md
  and docs/STRUCTURE.md. Do NOT use src/contentx/ or singular config/pipelines/.
---

# ContentX Pipeline Development

> **Path truth (2026-07-15):** New pipelines go in `pipelines/<group>/<name>.py`,
> configs in `configs/pipelines/`, routes in `api/routes/`.  
> **Do not** create `src/contentx/pipelines/…`. See `docs/STRUCTURE.md` and
> `.cursor/workflows/new-pipeline.md`.

## Pipeline Architecture

All pipelines follow the same layered structure:

```
Pipeline Run
  ├── Orchestrator (application layer)
  │   ├── Validates input
  │   ├── Selects models
  │   └── Manages budget
  ├── Stage Executor (domain layer)
  │   ├── Script generation
  │   ├── Asset generation
  │   ├── Assembly
  │   └── Post-processing
  └── Output Manager
      ├── Saves to out/runs/{date}/{run_id}/
      ├── Generates manifest.json
      └── Triggers Firecrawl validation
```

## Creating a New Pipeline

### 1. Define Pipeline Config

Add under `configs/pipelines/` (not singular `config/`):

```yaml
# configs/pipelines/my_pipeline.yaml
pipeline_type: my_pipeline
working_dir: .working_dir/my_pipeline
description: Brief description
# category: video | marketing | education | music | interactive
llm:
  primary:
    model: ${LLM_PRIMARY}
    model_provider: ${LLM_PRIMARY_PROVIDER}
budget:
  max_cost_usd: 5.00
  alert_threshold: 0.8
```

### 2. Implement Pipeline Class

```python
# pipelines/social/my_pipeline.py  (pick a real group: ads/, social/, content/, …)
from pipelines.base import BasePipeline  # or the mixin your group already uses

class MyPipeline(BasePipeline):
    """Custom video pipeline."""

    config_key = "my_pipeline"

    async def execute(self, request):
        # Stage 1: Generate script
        script = await self.llm.generate(
            prompt=self.load_prompt("script", request),
            model=self.config.models.default_llm,
        )

        # Stage 2: Generate visuals (parallel)
        visuals = await self.gather([
            self.image.generate(scene.model_dump())
            for scene in script.scenes
        ])

        # Stage 3: Assemble
        video = await self.assemble(script, visuals)

        return {
            "output_path": video.path,
            "manifest": self.generate_manifest(),
            "cost": self.cost_tracker.total,
        }
```

### 3. Add Tests

```python
# tests/pipelines/test_my_pipeline.py
import pytest
from pipelines.social.my_pipeline import MyPipeline

@pytest.fixture
def pipeline():
    return MyPipeline(config=mock_config())

async def test_execute_success(pipeline):
    result = await pipeline.execute(mock_request())
    assert result["output_path"]
    assert result["cost"] > 0

async def test_budget_exceeded(pipeline):
    pipeline.config.budget.max_cost_usd = 0.01
    with pytest.raises(Exception):
        await pipeline.execute(mock_request())
```

### 4. Register Pipeline

Add an entry to root `pipeline_registry.py` `REGISTRY` (not `src/contentx/…`):

```python
"my_pipeline": {
    "class_path": "pipelines.social.my_pipeline.MyPipeline",
    "config": "my_pipeline.yaml",
    "config_dir": "pipelines",
    "topic_arg": "idea",
    "category": "video",
    "desc": "Brief description",
    "output": "MP4",
    "required": ["topic", "platform", "style", "audience"],
},
```

Also add a POST route under `api/routes/` when the pipeline is API-triggered. See `.cursor/workflows/new-pipeline.md`.

## Pipeline Best Practices

### Model Selection
- Use `configs/model_catalog.yaml` for model definitions
- Always provide fallback models
- Cache model responses when possible

### Cost Management
- Track cost per stage
- Fail fast if budget exceeded
- Alert at 80% threshold

### Error Handling
```python
# Prefer FastAPI HTTPException at the route boundary; raise typed errors in pipelines.
class MyPipelineError(Exception):
    def __init__(self, run_id: str, stage: str, details: dict):
        self.run_id = run_id
        self.stage = stage
        self.details = details
        super().__init__(f"Stage {stage} failed for run {run_id}")
```

### Output Structure
```
out/runs/2026/07/06/{run_id}/
├── manifest.json       # Run metadata
├── final.mp4          # Final output
├── assets/            # Individual files
│   ├── frames/
│   ├── audio/
│   └── clips/
├── variants/          # A/B variants
└── reports/
    ├── cost.json
    └── qa.json
```

## Pipeline Categories

| Category | Use Case | Example Pipelines |
|----------|----------|-------------------|
| `video` | Long/short form video | movie, series, shorts, music_video |
| `marketing` | Ads & growth | ad_campaign, aso_content, brand_story |
| `education` | Learning content | course, quiz_series, flashcards |
| `music` | Audio generation | song, soundtrack, jingle |
| `interactive` | Games/avatars | story_game, avatar_chat, visual_novel |

## Common Patterns

### Parallel Generation
```python
# Run independent stages in parallel
results = await asyncio.gather(
    self.generate_visuals(),
    self.generate_audio(),
    self.generate_subtitles(),
)
```

### Retry with Fallback
```python
# Try primary model, fallback on failure
for model in [primary, fallback, emergency]:
    try:
        return await self.llm.generate(prompt, model=model)
    except ModelUnavailableError:
        continue
raise AllModelsFailedError()
```

### Streaming Output
```python
# Stream progress to client
async for progress in pipeline.execute_streaming(request):
    await websocket.send_json({
        "stage": progress.stage,
        "percent": progress.percent,
        "preview_url": progress.preview_url,
    })
```

## Validation

Every pipeline must pass:
- [ ] Unit tests >80% coverage
- [ ] Integration test with mock APIs
- [ ] Cost estimation test
- [ ] Firecrawl content validation
- [ ] Output manifest validation
