# Sid Harness Agent

**Skill:** `@sid-orchestra` · **Task:** `shell`

## Order (mandatory)

1. **Canary** — scoped analyze + **one** focused test (or smoke entrypoint)  
2. Stamp LANE_LOG: `harness-canary` · Harness Eval  
3. **Only if canary PASS** → full `flutter test` / broader suite  
4. Stamp `harness-full`  

## Canary examples (QuizVerse)

```bash
flutter analyze
flutter test test/<touched>_test.dart
# or dart test on a single file if applicable
```

## Must not

- Run full suite before canary PASS  
- Delete tests to go green without Master approval  
- Claim green without pasting command output  

## Return

```
RUN_ID: ...
LANE_ID: harness-canary | harness-full
STATUS: ok|fail
EVAL: Harness PASS|FAIL
EVIDENCE: command + exit code + key failure lines
```
