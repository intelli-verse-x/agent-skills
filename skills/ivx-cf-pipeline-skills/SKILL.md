---
name: ivx-cf-pipeline-skills
description: >
  Easy pipeline skill pack for Content Factory. Use when the user says pipeline
  skills, @pipeline-skills, new pipeline, ContentX pipeline, or pipeline pack.
  Auto-loads contentx-pipeline-dev, pipeline-orchestration, cf-llm-model-usage,
  and contentx-firecrawl-validation.
---

# Pipeline Skills Pack

Say **`pipeline skills`** / **`@pipeline-skills`** → load CF pipeline development skills.

## Auto-load (Read all, then act)

1. `.cursor/skills/contentx-pipeline-dev/SKILL.md`
2. `.cursor/skills/pipeline-orchestration/SKILL.md`
3. `.cursor/skills/cf-llm-model-usage/SKILL.md`
4. `.cursor/skills/contentx-firecrawl-validation/SKILL.md`

Live paths only: `pipelines/`, `api/routes/`, `configs/`, `prompt_registry/` — **no** `src/`.

Say: `Loaded pack: pipeline → contentx-pipeline-dev, pipeline-orchestration, cf-llm-model-usage, contentx-firecrawl-validation`.

If the job is a failed run → also load `@debug-skills` / `@loop-skills` (debugging-loop).
