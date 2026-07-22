---
name: ivx-cf-pipeline-orchestration
description: Design and implement multi-step pipeline orchestration for AI content generation. Use when building new pipelines, adding pipeline steps, or optimizing pipeline execution flow.
---
# Pipeline Orchestration Skill

## Purpose

Build robust, scalable, observable pipelines for AI content generation.

## Pipeline Architecture

```
Input → Validation → Stage 1 → Stage 2 → ... → Stage N → Output
              ↓           ↓              ↓         ↓
           Callbacks  Checkpoints   Retries   Harvest
```

## Stage Design

Each stage must have:
- **Input**: Typed, validated schema
- **Output**: Typed schema, written to `output_path`
- **Error handling**: Retry with backoff, dead letter queue
- **Checkpoint**: Save state after completion
- **Metrics**: Duration, success/failure, cost

## CF Pipeline Pattern

```python
# pipelines/<group>/<name>.py
from pipelines.base import VoiceMixin, BrandMixin

class MyPipeline(VoiceMixin, BrandMixin):
    async def run(self, task_id, request):
        # 1. Validate input
        # 2. Load prompts from registry
        # 3. Execute stages
        # 4. Write outputs to output_path
        # 5. Update task status
        pass
```

## Retry Strategy

| Failure | Retry | Backoff | Max |
|---------|-------|---------|-----|
| Transient (network) | Yes | Exponential | 5 |
| Validation | No | — | — |
| Rate limit | Yes | Exponential + jitter | 10 |
| OOM / infra | No | Escalate | — |

## Parallelism

- Independent stages run in parallel (asyncio.gather)
- Dependent stages run sequentially
- Fan-out for batch operations
- Rate limit external API calls

## Memory Management

- Large blobs in `output_path/`, not `task["result"]`
- Clean up temp files after stage completion
- Stream large files when possible
- Monitor memory per worker

## Observability

- Log: start/end of each stage with duration
- Metric: stage duration histogram
- Trace: OpenTelemetry span per stage
- Alert: stage failure rate > 1%

## Quality Gates

- [ ] Each stage has defined input/output
- [ ] Retry policy documented
- [ ] Error cases handled gracefully
- [ ] Output written before status update
- [ ] Cost tracked per pipeline run
- [ ] Tests mock all external calls
