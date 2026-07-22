---
name: ivx-cf-debug-skills
description: >
  Easy debugging skill pack for Content Factory. Use when the user says debug
  skills, @debug-skills, something is broken, failed pipeline, or bug pack.
  Auto-loads systematic-debugging, cf-orchestrator, debugging-loop, and
  bug-fixing workflow.
---

# Debug Skills Pack

Say **`debug skills`** / **`@debug-skills`** → load CF bug-hunt stack.

## Auto-load (Read all, then act)

1. `.cursor/skills/systematic-debugging/SKILL.md`
2. `.cursor/skills/cf-orchestrator/SKILL.md`
3. `.cursor/loops/debugging-loop.md`
4. `.cursor/workflows/bug-fixing.md`

Say: `Loaded pack: debug → systematic-debugging, cf-orchestrator, debugging-loop, bug-fixing`.

## Flow reminder

Classify A–F → reproduce → isolate → fix (≤200 lines, allowed paths) → verify → update `docs/tracking/BUGS.md`. No `kubectl delete`. Triage STOP for human APPROVE on D/E/F or prod retry.
