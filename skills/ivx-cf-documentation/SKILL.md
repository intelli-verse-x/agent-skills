---
name: ivx-cf-documentation
description: Generate developer documentation, API docs, and technical specifications. Use when writing docs, generating docstrings, or creating API references.
---
# Documentation Skill

## Purpose

Create clear, accurate, maintainable documentation.

## Types

| Type | Audience | Example |
|------|----------|---------|
| API docs | Developers | OpenAPI spec |
| README | New contributors | Setup, architecture |
| ADRs | Engineers | Decision records |
| Runbooks | Operators | Incident response |
| User guides | End users | Feature documentation |

## Principles

1. **Audience-aware**: Write for the reader, not yourself
2. **Runnable examples**: All code examples must work
3. **Current**: Update docs with code changes
4. **Searchable**: Clear headings, cross-references
5. **Concise**: Every sentence earns its place

## Docstring Format (Google Style)

```python
def process_video(
    video_path: str,
    output_format: str = "mp4",
) -> str:
    """Process a video file and return the output path.

    Args:
        video_path: Path to input video file.
        output_format: Desired output format. Defaults to "mp4".

    Returns:
        Path to processed video file.

    Raises:
        FileNotFoundError: If video_path does not exist.
        ValueError: If output_format is unsupported.
    """
```

## CF-Specific

- Pipeline docs: Input/output schema, example requests
- API docs: Auto-generated from FastAPI + examples
- Agent docs: Persona descriptions, when to invoke
- Skill docs: Purpose, inputs, outputs, examples

## Voice & tone (project technical writing)

- Pragmatic developer-to-developer; no AI-isms or hedging
- Match existing project voice in `AGENT.md` / `docs/`
- Apply when writing READMEs, ADRs, and docstrings

## Quality Gates

- [ ] All public APIs documented
- [ ] Examples are runnable
- [ ] No broken links
- [ ] Screenshots/code current with latest version
- [ ] README has quick start section
