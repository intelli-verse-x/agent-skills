---
name: ivx-cf-testing
description: Generate tests, design test strategies, and ensure code quality through testing. Use when writing tests, improving test coverage, designing test infrastructure, or evaluating test quality.
---
# Testing Skill

## Purpose

Ensure code correctness through comprehensive, maintainable tests.

## Test Pyramid

```
      /\
     /  \  E2E (few, critical paths)
    /----\ Integration (API contracts, DB)
   /______\ Unit (many, fast, isolated)
```

## When to Use

- Writing new code → Write tests alongside
- Refactoring → Ensure tests pass before/after
- Bug fix → Write regression test first
- Code review request → Generate missing tests
- Coverage gaps → Identify and fill

## Unit Tests

### Patterns
- Arrange-Act-Assert structure
- One logical assertion per test
- Descriptive names: `test_given_x_when_y_then_z`
- `@pytest.mark.parametrize` for variations

### Mocking
- Mock external dependencies (DB, API, LLM)
- Mock at client level, not HTTP level
- Use fixtures for shared setup
- Reset mocks between tests

### Example

```python
@pytest.mark.asyncio
async def test_given_valid_request_when_create_pipeline_then_returns_task_id(
    client: AsyncClient,
    mock_task_store: Mock,
):
    # Arrange
    request = {"pipeline": "learning_series", "topic": "Inertia"}
    mock_task_store.create.return_value = "task-123"

    # Act
    response = await client.post("/api/pipelines/learning_series", json=request)

    # Assert
    assert response.status_code == 202
    assert response.json()["task_id"] == "task-123"
    mock_task_store.create.assert_called_once()
```

## Integration Tests

- Test API contracts end-to-end
- Use test database (transaction rollback)
- Test async operations properly
- No hardcoded ports (ephemeral)

## E2E Tests

- Critical user journeys only
- Use Playwright for frontend
- Idempotent (can run multiple times)
- Independent (no ordering dependency)

## Coverage Gates

- Minimum 80% for new code
- 100% for auth, security, financial logic
- Branch coverage, not just line
- Track in CI, block PR on failure

## Parallel test fixing

- When many tests fail: partition by file / failure class → fan out via `@orchestrator` (one lane per cluster) → merge carefully
- Flake quarantine: mark/skip with an issue link rather than silent delete
- Related: `@cf-orchestrator`

## Quality Gates

- [ ] All tests pass
- [ ] Coverage above threshold
- [ ] No flaky tests
- [ ] Fast execution (< 5 min total)
- [ ] Deterministic (same result every run)
