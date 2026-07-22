---
name: ivx-cf-sid-orchestra
description: >
  Sid Orchestra — multi-agent swarm with run IDs, lock leases, plan critic,
  canary harness, PASS/FAIL evals, and anti-hallucination gates. Use when the
  user says sid orchestra, @sid-orchestra, sid swarm, sid evals, or wants
  research→plan→build→review with a communication bus and loop.
---

# Sid Orchestra

**One Master. Specialists. Blackboard + leases. Human gates. Evals as quality gates. Loop until verified.**

## Say this

| Phrase | Action |
|--------|--------|
| `sid orchestra` / `@sid-orchestra` | Full pipeline |
| `sid swarm` | Fan out (only if parallelizable) |
| `sid orchestra loop` | Arm recurring loop |
| `sid evals` | Load eval rubrics / grade a batch |
| `solo` / `no swarm` | Single agent — **required** for sequential-only |

## Read first (mandatory)

1. This skill  
2. `.cursor/loops/sid-orchestra-loop.md`  
3. `.cursor/sid-orchestra/BLACKBOARD.md`  
4. `.cursor/sid-orchestra/LANE_LOG.md`  
5. `.cursor/sid-orchestra/EVALS.md`  
6. Role briefs `.cursor/agents/sid-*.md` as needed  
7. Mem0 + Hindsight at intake  

---

## 0) Triage: swarm vs solo (anti-slop)

Research (2026): multi-agent can **hurt sequential reasoning by ~40–70%**.  
**Do not swarm** when the job is one linear thread.

| Signal | Mode |
|--------|------|
| One file / one bug / one rename / one clear sequential fix | **`solo`** — Master only |
| Parallelizable paths, research fan-out, multi-feature | **swarm** |
| Unsure | Start **solo research**, then swarm only the parallel build |

Master must write on BLACKBOARD: `Mode: solo | swarm` and why.

---

## Cast

| Role | Count | Job |
|------|-------|-----|
| **Master** | 1 | Intake, triage, gates, merge, user channel |
| **Research** | 1–3 | Code + Firecrawl/web; evidence-only |
| **Planning** | 1–2 | Lane cards + deps |
| **Plan Critic** | 1 | Eval the **plan** before build (Review-lite) |
| **Working** | N (2–6) | Code in leased paths |
| **Generation** | 0–2 | Scaffolds / assets |
| **Review** | 1–3 | Eval code; ≠ Working |
| **Harness** | 1–2 | Canary → then full tests |
| **Bus** | 1 | Blackboard, leases, re-orient |
| **Memory / Integration** | 0–1 | Retain / merge conflicts |
| **Eval Judge** | 0–1 | PASS/FAIL rubrics (can be Review) |

**Hard rule:** Working ≠ Review ≠ Plan Critic (for the same artifact).

---

## Pipeline

```
USER → MASTER triage (solo vs swarm)
     → RESEARCH (evidence paths required)
     → GATE A (user approves understanding)
     → PLANNING
     → PLAN CRITIC + plan eval (PASS/FAIL)     ← NEW
     → GATE B if high-risk or plan FAIL
     → BUS: run_id, locks+leases, LANE_LOG
     → WORKING(N) + GENERATION (parallel only)
     → CODE REVIEW + code evals (PASS/FAIL)
     → FIX ≤2
     → CANARY HARNESS                         ← NEW
     → FULL HARNESS (only if canary PASS)
     → REPORT + RETAIN + eval alignment note
```

---

## Run ID + lane log (mandatory)

On intake Master creates:

```
run_id = sid-<YYYYMMDD>-<HHMM>-<short>
```

Example: `sid-20260717-1310-streak`

Every Task prompt **and** return must stamp:

```
RUN_ID: sid-...
LANE_ID: research-01 | plan-01 | plan-critic-01 | work-ui | review-01 | harness-canary | ...
ROLE: ...
STARTED_AT: ISO-8601
ENDED_AT: ISO-8601
STATUS: ok | fail | blocked | missing
EVIDENCE_PATHS:
  - path/that/exists.dart
CLAIMS_WITHOUT_EVIDENCE: none | <list — Master discards these>
```

Append each return to `.cursor/sid-orchestra/LANE_LOG.md`.  
Master **discards** any claim with no evidence path (anti-hallucination).

---

## Lock leases (30 min TTL)

BLACKBOARD file locks use leases:

| Field | Rule |
|-------|------|
| `path` | Exact file or directory globs |
| `owner_lane` | e.g. `work-ui` |
| `leased_at` | ISO time |
| `ttl_min` | **30** default |
| `expires_at` | leased_at + ttl |

**Bus steals stale locks:** if `now > expires_at` and lane not heartbeat-updated, Bus reassigns or frees.  
Workers must **heartbeat** (touch `leased_at`) every wave or when still writing.  
One writer per path. Conflict → pause both → Integration/Master.

---

## Plan critic (before build)

After Planning, launch **Plan Critic** (not the planner):

- Rubric: `.cursor/sid-orchestra/EVALS.md` → **Plan Eval**  
- PASS → Bus arms locks + build wave  
- FAIL → Planning revises (≤2) or Gate B to user  

Checks: path non-overlap, deps sound, sequential edges not parallelized, done-when testable, scope ≤ Gate A.

---

## Canary harness → full harness

1. **Canary (required first)**  
   - `dart analyze` on touched packages / `flutter analyze` scoped if possible  
   - **One** focused test file or `flutter test test/<relevant>_test.dart`  
   - Or compile/smoke the changed feature entrypoint  
2. **Full** `flutter test` / broader suite **only if canary PASS**  
3. Canary FAIL → Fix wave; do **not** burn full suite  

---

## Evals (stop slop)

Full rubrics: `.cursor/sid-orchestra/EVALS.md` and skill `@sid-evals`.

**Rules:**

1. Prefer **PASS/FAIL** (not 1–10) for gates  
2. Codify what PASS means before generating  
3. LLM Judge grades → optional Human Judge → **alignment %**  
4. Mismatches → improve rubric → re-batch  
5. **Flip to gate:** discard / rework any output that FAILs  

**Gates in this orchestra:**

| Gate | Eval | On FAIL |
|------|------|---------|
| After Research | Understanding Eval | More research / ask user |
| After Plan | Plan Eval (Plan Critic) | Revise plan |
| After Build | Code Eval + Review scorecard | Fix ≤2 |
| After Gen assets | Asset/Copy Eval | Regenerate |
| After Harness | Harness Eval | Fix or BLOCKED |

---

## Anti-hallucination (reduce agent fiction)

1. **Evidence or MISSING** — no path → claim dropped  
2. **No invented APIs/files** — say `MISSING:` explicitly  
3. **Quotes from repo** for architectural claims when possible  
4. **Eval gates** throw away failing generations  
5. **Solo for sequential** — fewer agents inventing conflicts  
6. **Blackboard contracts** — Workers implement contracts, not vibes  
7. **Discard unaudited peer claims** in Master merge  

---

## Launch protocol (Task tool)

```
RUN_ID: sid-...
LANE_ID: ...
ROLE: ...
GOAL: <one line>
BLACKBOARD: .cursor/sid-orchestra/BLACKBOARD.md
LANE_LOG: append stamped return to .cursor/sid-orchestra/LANE_LOG.md
EVAL: <rubric name from EVALS.md or none>
IN SCOPE: <exact paths>
OUT OF SCOPE: <forbidden>
DEPS: <lanes or none>
LEASES: <paths you will lock>
DONE WHEN:
  - [ ] ...
RETURN: RUN_ID, LANE_ID, STATUS, evidence paths, blockers, eval PASS/FAIL if judged
ANTI-GUESS: Do not invent files. If missing, say MISSING.
```

---

## Swarm size (swarm mode only)

| Job | Agents excl. Master |
|-----|---------------------|
| Small parallel feature | 5–6 |
| Medium | 7–9 |
| Large port | ≤12 |

Default QuizVerse: Research(2)+Plan(1)+PlanCritic(1)+Work(3)+Review(2)+Harness(1)+Bus(1).

---

## Approval gates

**Gate A — Understanding** (non-trivial): goal, assumptions, out-of-scope, ≤5 questions → **Approve to plan?**  
**Gate B — Plan**: high-risk **or** Plan Eval FAIL after 2 revises → **Approve to build?**

---

## Review scorecard + eval

BLOCKER / MAJOR / MINOR / NIT + overall Code Eval **PASS/FAIL**.  
No BLOCKERs **and** Code Eval PASS → Canary.

---

## Done criteria

- [ ] Mode solo|swarm recorded  
- [ ] `run_id` set; LANE_LOG has every lane  
- [ ] Gate A approved (or skip)  
- [ ] Plan Eval PASS  
- [ ] Leases respected / stale stolen  
- [ ] Code Eval PASS; no BLOCKERs  
- [ ] Canary PASS then full harness (or documented skip)  
- [ ] Master report + memory retain  
- [ ] Hallucinated claims discarded  

## Related

- Loop · Blackboard · Lane log · Evals  
- `@sid-evals` · `@qv-skill-router`  
- Agents: `.cursor/agents/sid-*.md`
