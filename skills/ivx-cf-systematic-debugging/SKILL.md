---
name: ivx-cf-systematic-debugging
description: >-
  Bridges general systematic debugging (isolate, bisect, flake control) to
  Content Factory operator paths — debugging-loop, bug-fixing A–F, pipeline
  logs, and optional human APPROVE before merge/retry. Use when investigating
  bugs, failed pipeline tasks, flaky tests, or when the user says @bugfixing.
---

# Systematic Debugging

Bridge skill: classic debugging discipline + CF’s real operator loops. Prefer CF paths over inventing new runbooks.

## Route here first (CF truth)

| Path | Role |
|------|------|
| `.cursor/loops/debugging-loop.md` | Reproduce → isolate → hypothesize → fix → verify → prevent |
| `.cursor/workflows/bug-fixing.md` | Surgical fix flow + **A–F** classification |
| `@bugfixing` (AGENTS.md) | Command entry → debugging-loop + bug-fixing |

## Orchestra-inspired pattern

```text
Failing evidence
    → Identify failing step (pipeline stage / test / deploy)
    → Classify cause (A–F)
    → Route to fixer lane (code / payload / wait / escalate)
    → Optional triage STOP → human APPROVE before merge or prod retry
```

1. **Identify failing step** — exact error, `task_id` / `run_id`, stage name
2. **Classify cause** — use A–F (below)
3. **Route fixer lane** — one owner; no shotgun refactors
4. **Triage STOP (optional)** — for D/E/F or prod retry/merge: show plan, wait for user **APPROVE**

## A–F classification (from bug-fixing)

| Class | Name | Action |
|-------|------|--------|
| A | CF Code Bug | Fix → deploy → retry |
| B | External Provider | Wait + retry |
| C | Validation | Retry with fixed payload |
| D | Infra (OOM) | Escalate — **no kubectl delete** |
| E | Budget Guardrail | Escalate |
| F | Unknown | Stash logs + escalate |

## CF tools (prefer these)

- MCP / API: `get_task_status`, `get_pipeline_log`, `harvest_task`
- Logs/metrics: CloudWatch (via EKS MCP when needed)
- Memory: known patterns in improver CSV / BUGS.md

**Do not** `kubectl delete` pods for OOM/infra — escalate (class D).

## External systematic pointers (keep short)

| Technique | When |
|-----------|------|
| Isolate | Minimal repro; change one variable |
| Bisect | Regression → `git bisect` / half-eliminate |
| Flaky tests | Quarantine signal vs fix race; retry once, then root-cause |
| 5 Whys | After fix — prevent class of bug |

Mix with CF **operator-loop**: classify → act within authority → document.

## Agent checklist

- [ ] Reproduction + failing step named
- [ ] Class A–F assigned
- [ ] Used `get_task_status` / `get_pipeline_log` / harvest when pipeline-related
- [ ] Fix ≤ 200 lines; no-touch zones respected
- [ ] Regression test or monitoring note
- [ ] Human APPROVE if D/E/F or prod merge/retry needs it
- [ ] Update `docs/tracking/BUGS.md` when fixed

## Related

- `.cursor/loops/debugging-loop.md`
- `.cursor/workflows/bug-fixing.md`
- `.cursor/skills/testing/SKILL.md` (flaky / regression tests)
- AGENTS.md `@bugfixing`
