# Sid Orchestra Blackboard

> Bus + Master own this file. Workers read before coding. Locks use **30 min leases**.

## Meta

| Field | Value |
|-------|-------|
| **run_id** | _(unset)_ |
| **mode** | _(solo \| swarm)_ |
| **mode_reason** | _(why)_ |
| **Status** | IDLE |
| **Goal** | _(unset)_ |
| **Gate A** | pending |
| **Gate B** | n/a |
| **Plan Eval** | pending |
| **Code Eval** | pending |
| **Updated** | _(unset)_ |

## Approved understanding

_(after Gate A)_

- Goal:
- Assumptions:
- Out of scope:
- User constraints:

## Open questions

1. …

## Dependency graph

```
Research → GateA → Plan → PlanCritic → [Work || Gen] → Review → Fix → Canary → FullHarness → Done
```

## File locks (leases)

| Path | Owner lane | leased_at | ttl_min | expires_at | Status |
|------|------------|-----------|---------|------------|--------|
| — | — | — | 30 | — | free |

**Bus:** if `now > expires_at` and no heartbeat → **steal** (free or reassign).  
Workers: heartbeat by refreshing `leased_at` while still writing.

## Lanes

| Lane_ID | Role | Status | Eval | Notes |
|---------|------|--------|------|-------|
| — | — | — | — | — |

## Contracts (APIs / models / events)

_(Workers must not break)_

## Review scorecard summary

| Severity | Count | Top items |
|----------|-------|-----------|
| BLOCKER | 0 | |
| MAJOR | 0 | |
| MINOR | 0 | |

## Harness

| Check | Result | Log ref |
|-------|--------|---------|
| Canary | — | |
| Full `flutter test` | — | _(only after canary PASS)_ |
| smoke | — | |

## Eval alignment (optional)

| Rubric | LLM/Human alignment | Last batch |
|--------|---------------------|------------|
| Plan | — | |
| Code | — | |

## Bus notes / re-orients

- …
