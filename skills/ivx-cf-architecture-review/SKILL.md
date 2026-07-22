---
name: ivx-cf-architecture-review
description: Review system architecture decisions for scalability, reliability, and maintainability. Use when designing new systems, reviewing architecture proposals, or evaluating technical designs.
---
# Architecture Review Skill

## Purpose

Ensure system designs are sound, scalable, and maintainable.

## Review Dimensions

| Dimension | Questions |
|-----------|-----------|
| Scalability | How does it handle 10x growth? |
| Reliability | What happens when components fail? |
| Maintainability | Can a new engineer understand it? |
| Performance | Are latency/throughput targets met? |
| Security | What are the attack vectors? |
| Cost | What's the $/request at scale? |
| Operability | Can we debug it at 3 AM? |

## Review Process

1. **Read**: Understand requirements and constraints
2. **Diagram**: Sketch data flow and component interactions
3. **Question**: Identify assumptions and risks
4. **Compare**: Evaluate alternatives
5. **Decide**: Document recommendation

## ADR Template

```markdown
## ADR-XXX: [Decision Title]

### Context
[What problem are we solving?]

### Decision
[What are we doing?]

### Consequences
- Positive: [...]
- Negative: [...]
- Risks: [...]

### Alternatives Considered
| Option | Pros | Cons |
|--------|------|------|
| A | [...] | [...] |
| B | [...] | [...] |

### Compliance
[How we'll verify this decision was correct]
```

## CF-Specific

- Review against `.cursor/ANTI_PATTERNS.md`
- Check operator-loop compatibility (tags, harvest)
- Verify LiteLLM routing for all LLM calls
- Ensure pipeline stages are independently replaceable
