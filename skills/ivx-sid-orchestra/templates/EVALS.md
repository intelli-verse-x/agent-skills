# Sid Orchestra Evals

> Grade AI work to stop slop. Prefer **PASS/FAIL**. Use as **gates**, not just report cards.  
> Skill: `@sid-evals` · Wired into `@sid-orchestra`.

## How to use evals here

1. **Write rubric** (what PASS means) before generating  
2. **LLM Judge** grades outputs with PASS/FAIL + 1-line reason  
3. **Human Judge** (you) grades a sample batch the same way  
4. **Alignment %** = agree / total  
5. On mismatches: feed commentary → **improve rubric** → re-batch  
6. Target alignment ≥ **80%** before trusting the gate alone  
7. **Flip to gate:** FAIL → discard/regenerate/rework — never ship  

Optional channel habit: paste each judged artifact for Sid to mark PASS/FAIL (like `#runneth-evals`).

---

## Global anti-slop / anti-hallucination checks

Any lane FAIL if:

- [ ] Claims a file/API/path that does not exist (`MISSING` not used)  
- [ ] No `EVIDENCE_PATHS` for factual claims  
- [ ] Expands past Gate A scope  
- [ ] Dead UI / placeholder left as “done”  
- [ ] Invents QuizVerse brand facts not in `accounts-quizverse` / repo  

---

## 1) Understanding Eval (after Research)

| # | Criterion | PASS if |
|---|-----------|---------|
| U1 | Goal restated in ≤3 bullets | Clear, matches user |
| U2 | Assumptions listed | Explicit, not hidden |
| U3 | Out of scope listed | Prevents gold-plating |
| U4 | Open questions ≤5 | Actionable |
| U5 | Evidence paths for repo claims | Real paths or `MISSING` |

**FAIL** → more research or Gate A clarification.  
**PASS** → present Gate A to user.

---

## 2) Plan Eval (Plan Critic — before build)

| # | Criterion | PASS if |
|---|-----------|---------|
| P1 | Lanes cover Gate A goal | No orphan requirements |
| P2 | Worker paths **non-overlapping** | No dual writers |
| P3 | Sequential work not faked as parallel | Dep edges correct |
| P4 | Each lane has testable DONE WHEN | Harness can verify |
| P5 | Risks flagged (auth/pay/schema) | Gate B triggered if needed |
| P6 | Mode correct | Solo jobs not over-swarmed |
| P7 | Eval hooks named | Which rubric each wave uses |

**FAIL** → Planning revises (≤2) or ask user.  
**PASS** → Bus locks + build.

---

## 3) Code Eval (after Working / with Review)

| # | Criterion | PASS if |
|---|-----------|---------|
| C1 | Only leased paths changed | Diff ⊆ locks |
| C2 | Compiles / analyzes clean on canary | No new errors in scope |
| C3 | Matches contracts on BLACKBOARD | No freestyle API |
| C4 | Zero dead UI in touched screens | Project rule |
| C5 | Evidence: files listed + how to verify | Runnable steps |
| C6 | No secrets committed | — |

Plus Review scorecard: any **BLOCKER** ⇒ Code Eval **FAIL**.

---

## 4) Asset / copy / mascot Eval (Generation)

| # | Criterion | PASS if |
|---|-----------|---------|
| A1 | Brand voice (`accounts-quizverse`) | On-brand |
| A2 | Space theme tokens respected | No random purple candy |
| A3 | Mascot inputs match `qv-rive-mascot` table | Named inputs only |
| A4 | No placeholder lorem as final | — |

---

## 5) Harness Eval

| # | Criterion | PASS if |
|---|-----------|---------|
| H1 | Canary command green | Logged in LANE_LOG |
| H2 | Full suite only after canary PASS | Order respected |
| H3 | Failures cited with path:line | Not vague |

---

## 6) Master merge Eval (final report)

| # | Criterion | PASS if |
|---|-----------|---------|
| M1 | All lanes in LANE_LOG stamped | run_id consistent |
| M2 | Hallucinated claims removed | — |
| M3 | Next steps honest | BLOCKED if blocked |
| M4 | Memory retain for non-obvious lessons | When applicable |

---

## Alignment worksheet (human vs LLM judge)

| Artifact id | LLM | Human | Agree? | Commentary |
|-------------|-----|-------|--------|------------|
| | PASS/FAIL | PASS/FAIL | Y/N | |

```
alignment = agree_count / row_count
```

Improve rubric until alignment ≥ 0.80, then keep as hard gate.

---

## Gate flip (automation rule)

```
if eval == FAIL:
  do not merge to "done"
  route: regenerate | fix | ask_user
if eval == PASS:
  allow next pipeline stage
```

Master enforces this. Workers do not self-PASS their own Code Eval.
