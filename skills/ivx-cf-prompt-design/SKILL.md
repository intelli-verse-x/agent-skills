---
name: ivx-cf-prompt-design
description: Design, optimize, and evaluate LLM prompts for content generation and agent behavior. Use when creating prompt templates, optimizing existing prompts, or building prompt registries.
---
# Prompt Design Skill

## Purpose

Create prompts that are clear, effective, reproducible, and maintainable.

## Prompt Structure

```markdown
## Role
You are a [specific role]. You [context and constraints].

## Task
[Specific, imperative instruction]

## Input
[Format and content of input]

## Constraints
- MUST: [hard requirements]
- MUST NOT: [prohibitions]
- FORMAT: [output structure]

## Examples
[2-3 few-shot examples]

## Output
[Exact output format, schema, or template]
```

## Principles

1. **Specificity**: Precise instructions beat vague ones
2. **Examples**: Few-shot examples for complex tasks
3. **Constraints**: Explicit boundaries (do/don't)
4. **Format**: Structured output specification
5. **Brevity**: Every token should earn its place

## CF Prompt Registry

### File Structure
```
prompt_registry/
├── _index.yaml          # Prompt catalog + versions
├── _schema.json         # Validation schema
└── learning_series/
    ├── script_writer.yaml
    ├── visual_director.yaml
    └── voice_selector.yaml
```

### YAML Format
```yaml
id: learning_series.script_writer
version: "1.2.0"
description: "Writes educational scripts for learning series"
template: |
  You are an educational script writer. Write a {minutes}-minute script about {topic}...
variables:
  - name: minutes
    type: int
    min: 1
    max: 60
  - name: topic
    type: str
```

### Code Usage
```python
from prompt_registry import get_prompt_or_default

INLINE_FALLBACK = "Write a {minutes}-minute script about {topic}..."
template = get_prompt_or_default("learning_series.script_writer", default=INLINE_FALLBACK)
prompt = template.format(minutes=5, topic="Inertia")
```

## Optimization

1. **A/B Test**: Version A vs B on eval dataset
2. **Tokens**: Compress without losing clarity
3. **Position**: Important instructions at start and end
4. **Context**: Reference external docs by ID, don't inline

## Anti-Patterns

- ❌ Hardcoded in Python strings
- ❌ Reading from disk in hot loops
- ❌ > 4000 tokens without compression
- ❌ Vague: "be creative"
- ❌ Mixing system and user content

## Evaluation

- Success rate on eval set
- Token usage per call
- Latency (time to first token)
- Human rating (1-5 scale)
