---
name: ivx-cf-refactoring
description: Safely refactor code to improve structure without changing behavior. Use when cleaning up code, extracting components, or modernizing patterns.
---
# Refactoring Skill

## Purpose

Improve code structure while preserving behavior.

## When to Refactor

- Code duplication (DRY violations)
- Functions > 50 lines
- Classes with > 5 responsibilities
- Deep nesting (> 3 levels)
- Magic numbers / strings
- Outdated patterns

## Safety Rules

1. **Tests pass before** → Refactor → **Tests pass after**
2. One refactoring at a time
3. Small, reviewable commits
4. Never refactor and change behavior in same commit
5. Use IDE automated refactorings when possible

## Common Refactorings

| Smell | Refactoring |
|-------|------------|
| Long function | Extract function |
| Duplicate code | Extract helper / mixin |
| Large class | Extract class / compose |
| Feature envy | Move method |
| Magic values | Named constants |
| Deep nesting | Early returns / guard clauses |
| String typing | Enum / dataclass |

## CF-Specific

- Extract pipeline logic to `pipelines/base/` mixins
- Move prompts to `prompt_registry/`
- Use `inject_character_context()` instead of manual context
- Replace print with structured logging
- Use atomic task store helpers

## Process

1. Ensure tests cover the code
2. Make one refactoring
3. Run tests
4. Commit
5. Repeat

## Quality Gates

- [ ] All tests pass
- [ ] No behavior change
- [ ] Coverage maintained or improved
- [ ] Reviewed by peer
- [ ] Performance not degraded (benchmark if critical)
