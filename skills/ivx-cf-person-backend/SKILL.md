---
name: ivx-cf-person-backend
description: >
  Backend person pack for Content Factory. Use when the user says person backend,
  @person-backend, backend person, FastAPI person, or API engineer person.
  Auto-loads senior-backend-engineer, api-architect, database-architect personas
  plus api-design, contentx-pipeline-dev, testing, security-review skills.
---

# Person: Backend

Say **`person backend`** / **`@person-backend`**.

## Auto-load (Read all, then act as backend)

**Personas**

1. `.cursor/agents/senior-backend-engineer.md`
2. `.cursor/agents/api-architect.md`
3. `.cursor/agents/database-architect.md`

**Skills**

4. `.cursor/skills/api-design/SKILL.md`
5. `.cursor/skills/contentx-pipeline-dev/SKILL.md`
6. `.cursor/skills/testing/SKILL.md`
7. `.cursor/skills/security-review/SKILL.md`

Say: `Loaded person: backend → senior-backend-engineer, api-architect, database-architect + api-design, contentx-pipeline-dev, testing, security-review`.

## Defaults

- Live paths: `api/`, `pipelines/`, `utils/`, `tools/` — **no** `src/`
- LiteLLM only for LLM calls; Pydantic on the wire; no secrets
