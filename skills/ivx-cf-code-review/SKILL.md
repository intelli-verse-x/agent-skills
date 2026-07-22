---
name: ivx-cf-code-review
description: Review code for quality, security, performance, and maintainability following team standards. Use when reviewing pull requests, examining code changes, or when the user asks for a code review. Triggers on diffs, PR references, or explicit review requests.
---
# Code Review Skill

## Quick Start

When reviewing code:

1. Check correctness and potential bugs
2. Verify security best practices
3. Assess readability and maintainability
4. Ensure tests are adequate
5. Check against `.cursor/ANTI_PATTERNS.md`
6. Verify compliance with `.cursor/rules/*.mdc`

## Review Checklist

- [ ] Logic is correct and handles edge cases
- [ ] No security vulnerabilities (SQL injection, XSS, etc.)
- [ ] Code follows project style conventions
- [ ] Functions are appropriately sized and focused
- [ ] Error handling is comprehensive
- [ ] Tests cover the changes adequately
- [ ] No hardcoded secrets or URLs
- [ ] Prompts use registry (not inline) for CF pipelines
- [ ] Character identity used when brand_id present
- [ ] LiteLLM proxy used for all LLM calls
- [ ] No `kubectl delete` in aicart references

## Severity Levels

- **Critical**: Must fix before merge (security, data loss, correctness)
- **Warning**: Should fix (performance, maintainability, style)
- **Suggestion**: Consider improving (naming, documentation, optimization)
- **Praise**: Good pattern worth noting (reinforce good habits)

## CF-Specific Checks

### Pipeline Code
- Prompt loaded from `prompt_registry`?
- `brand_id` + `character_id` passed to `inject_character_context`?
- Tags included for operator-loop discovery?
- No disk reads in hot loops?

### API Code
- Pydantic models for request/response?
- `HTTPException` with proper status codes?
- Business logic in service layer, not route?

### Task Store
- Atomic helpers used? (`_update_task_status`, etc.)
- No direct dict mutation on `_get_tasks()`?
- `completed` only after ALL writes?

## Providing Feedback

Format as:
- **Critical** 🚨: Must fix before merge — [explanation]
- **Warning** ⚠️: Should fix — [explanation]
- **Suggestion** 💡: Consider — [explanation]
- **Praise** ✅: Good pattern — [explanation]

## Review Process

1. **Scan**: Read the diff for overall structure
2. **Deep dive**: Check logic correctness, edge cases
3. **Standards**: Verify against rules and anti-patterns
4. **Tests**: Check coverage and quality
5. **Summary**: Write review summary with action items

## Additional Resources

- For detailed coding standards, see `.cursor/standards/coding-standards.md`
- For CF anti-patterns, see `.cursor/ANTI_PATTERNS.md`
- For security standards, see `.cursor/standards/security-standards.md`
