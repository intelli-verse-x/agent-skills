---
name: ivx-cf-person-ml
description: >
  ML / research person pack for Content Factory. Use when the user says person ml,
  @person-ml, ML person, research scientist person, or LLM researcher person.
  Auto-loads ml-research-engineer, llm-researcher, ai-research-scientist plus
  experiment-tracking, evaluation, cf-llm-model-usage.
---

# Person: ML / Research

Say **`person ml`** / **`@person-ml`**.

## Auto-load

1. `.cursor/agents/ml-research-engineer.md`
2. `.cursor/agents/llm-researcher.md`
3. `.cursor/agents/ai-research-scientist.md`
4. `.cursor/skills/experiment-tracking/SKILL.md`
5. `.cursor/skills/evaluation/SKILL.md`
6. `.cursor/skills/cf-llm-model-usage/SKILL.md`

LLM calls via LiteLLM proxy only.

Say: `Loaded person: ml → ml-research-engineer, llm-researcher, ai-research-scientist + experiment-tracking, evaluation, cf-llm-model-usage`.
