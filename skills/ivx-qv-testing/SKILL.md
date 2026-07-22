---
name: ivx-qv-testing
description: Write unit tests, run QA checks, and validate game functionality in QuizVerse.
version: "1.0"
---

## When to Use
"test", "unit test", "coverage", "QA", "quality", "verify", "regression"

## Test Structure
```
Assets/_QuizVerse/Tests/
├── EditMode/  → pure logic tests (NUnit)
└── PlayMode/ → integration tests (UnityTest)
```

## Conventions
- Test class: `[ClassName]Tests.cs`
- Test method: `[MethodName]_[Scenario]_[Expected]`
- Arrange-Act-Assert pattern
- Mock external dependencies (Nakama, Photon)

## MCP Test Commands
```
run_tests(mode="EditMode")                    → all edit mode
run_tests(mode="PlayMode")                    → all play mode
run_tests(test_names=["MyTest"])              → specific test
get_test_job(job_id="...", wait_timeout=60)   → poll results
```

## Context Files (load only if needed)
- Unit test workflow: `.agents/workflows/test.md`
- Full QA: `.agents/workflows/qa.md`
- Game testing: `.agents/workflows/gametest.md`
- Persona: `.agents/personas/qa-engineer.md`
