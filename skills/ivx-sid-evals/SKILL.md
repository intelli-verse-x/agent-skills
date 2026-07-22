---
name: ivx-sid-evals
description: >
  PASS/FAIL eval rubrics and alignment loops for Sid Orchestra (global). Use when
  the user says sid evals, @sid-evals, grade this, eval gate, alignment score, or
  wants to stop AI slop. Works in any workspace; bootstraps EVALS.md from
  ~/.cursor/skills/sid-orchestra/templates if missing.
---

# Sid Evals (global)

Evals = grades on AI work. Prefer **PASS/FAIL**. Flip into **gates** so FAIL never ships.

## Bootstrap

If project lacks `.cursor/sid-orchestra/EVALS.md`, copy from:

`~/.cursor/skills/sid-orchestra/templates/EVALS.md`  
→ `.cursor/sid-orchestra/EVALS.md`

Then Read that file for all rubrics.

## Workflow

1. Pick rubric (Understanding / Plan / Code / Asset / Harness / Master)  
2. Collect N outputs  
3. LLM Judge → PASS/FAIL + one-line why  
4. Human Judge on same batch  
5. Alignment % = agree / total  
6. Mismatches → improve rubric → re-batch  
7. At ≥80% alignment → hard gate with `@sid-orchestra`  

## Gate flip

```
FAIL → discard | fix | ask_user
PASS → next stage
```

## Orchestra stages

| Stage | Rubric |
|-------|--------|
| Post-research | Understanding Eval |
| Post-plan | Plan Eval |
| Post-build | Code Eval |
| Post-generation | Asset Eval |
| Post-canary/full | Harness Eval |
| Final report | Master merge Eval |

## Related

`@sid-orchestra` · `~/.cursor/skills/sid-orchestra/`
