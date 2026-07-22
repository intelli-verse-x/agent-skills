---
name: ivx-cf-sid-evals
description: >
  PASS/FAIL eval rubrics and alignment loops for Sid Orchestra. Use when the
  user says sid evals, @sid-evals, grade this, eval gate, alignment score, or
  wants to stop AI slop with evaluation gates.
---

# Sid Evals

Evals = **grades on AI work**. Start PASS/FAIL. Flip into **gates** so FAIL never ships.

## Read

`.cursor/sid-orchestra/EVALS.md` — all rubrics.

## Workflow

1. Pick rubric (Understanding / Plan / Code / Asset / Harness / Master)  
2. Generate or collect N outputs  
3. **LLM Judge** → PASS/FAIL + one-line why  
4. **Human Judge** (user) on same batch  
5. Compute **alignment %**  
6. On disagreements: user commentary → update rubric → re-batch  
7. At ≥80% alignment → hard gate in `@sid-orchestra`  

## Gate flip

```
FAIL → discard | fix | ask_user
PASS → next stage
```

## Anti-slop defaults

- Prefer PASS/FAIL over 1–10  
- Codify PASS before generating  
- No self-grading by the authoring lane  
- Hallucination checks are FAIL conditions in every rubric  

## Orchestra integration

| Stage | Rubric |
|-------|--------|
| Post-research | Understanding Eval |
| Post-plan | Plan Eval (Plan Critic) |
| Post-build | Code Eval |
| Post-generation | Asset Eval |
| Post-canary/full | Harness Eval |
| Final report | Master merge Eval |
