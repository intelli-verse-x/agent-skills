---
name: ivx-sid-orchestra
description: >
  Sid Orchestra — portable multi-agent swarm for any Cursor workspace. Run IDs,
  lock leases, plan critic, canary harness, PASS/FAIL evals, anti-hallucination.
  Use when the user says sid orchestra, @sid-orchestra, sid swarm, sid evals,
  or wants research→plan→build→review with a bus and loop. Available globally
  from ~/.cursor/skills.
---

# Sid Orchestra (global)

**One Master. Specialists. Blackboard + leases. Human gates. Evals as gates. Works in any repo.**

Personal install: `~/.cursor/skills/sid-orchestra/`  
On Windows: `C:\Users\msi\.cursor\skills\sid-orchestra\`

## Say this

| Phrase | Action |
|--------|--------|
| `sid orchestra` / `@sid-orchestra` | Full pipeline |
| `sid swarm` | Fan out (only if parallelizable) |
| `sid orchestra loop` | Arm recurring loop |
| `sid evals` / `@sid-evals` | Grade with rubrics |
| `solo` / `no swarm` | Single agent — required for sequential-only |

## Bootstrap (every new workspace — do first)

If the project is missing Sid Orchestra runtime files, **copy templates** into the workspace:

| From (personal skill) | To (project) |
|----------------------|--------------|
| `~/.cursor/skills/sid-orchestra/templates/BLACKBOARD.md` | `.cursor/sid-orchestra/BLACKBOARD.md` |
| `~/.cursor/skills/sid-orchestra/templates/LANE_LOG.md` | `.cursor/sid-orchestra/LANE_LOG.md` |
| `~/.cursor/skills/sid-orchestra/templates/EVALS.md` | `.cursor/sid-orchestra/EVALS.md` |
| `~/.cursor/skills/sid-orchestra/loops/sid-orchestra-loop.md` | `.cursor/loops/sid-orchestra-loop.md` |
| `~/.cursor/skills/sid-orchestra/agents/sid-*.md` | `.cursor/agents/sid-*.md` (optional) |

Create dirs as needed. **Do not overwrite** an existing project BLACKBOARD/LANE_LOG mid-run.

Then Read:

1. This skill  
2. Project `.cursor/loops/sid-orchestra-loop.md` (or personal `loops/` if not copied yet)  
3. Project `.cursor/sid-orchestra/BLACKBOARD.md`  
4. Project `.cursor/sid-orchestra/LANE_LOG.md`  
5. Project `.cursor/sid-orchestra/EVALS.md`  
6. Role briefs (project or personal `agents/`)  
7. Mem0 + Hindsight at intake  

## Harness adapters (any stack)

| Stack | Canary (first) | Full (after canary PASS) |
|-------|----------------|--------------------------|
| Flutter | `flutter analyze` + one focused test | `flutter test` |
| Node/TS | `npm test -- <file>` or lint scoped | full test script |
| Python | `pytest path/to/test_*.py -q` | broader pytest |
| Unknown | one smoke command Master names on BLACKBOARD | only if canary PASS |

Write chosen commands on BLACKBOARD under Harness.

---

## 0) Triage: swarm vs solo

Multi-agent can hurt sequential work by ~40–70%.  
Sequential / one-file → **`solo`**. Parallel paths → **swarm**.

Record on BLACKBOARD: `Mode: solo | swarm` + reason.

---

## Cast

| Role | Count | Job |
|------|-------|-----|
| **Master** | 1 | Intake, triage, gates, merge |
| **Research** | 1–3 | Code + web/Firecrawl; evidence-only |
| **Planning** | 1–2 | Lane cards + deps |
| **Plan Critic** | 1 | Plan Eval before build |
| **Working** | N (2–6) | Code in leased paths |
| **Generation** | 0–2 | Scaffolds / assets |
| **Review** | 1–3 | Code Eval; ≠ Working |
| **Harness** | 1–2 | Canary → full |
| **Bus** | 1 | Blackboard, 30m leases, steal stale |
| **Memory / Integration** | 0–1 | Retain / merge |

Working ≠ Review ≠ Plan Critic for the same artifact.

---

## Pipeline

```
USER → MASTER triage + bootstrap templates if needed
     → mint run_id = sid-YYYYMMDD-HHMM-slug
     → RESEARCH → Understanding Eval
     → GATE A (user)
     → PLAN → PLAN CRITIC (Plan Eval)
     → GATE B if high-risk / stuck FAIL
     → BUS leases (ttl 30m)
     → WORKING(N) + GENERATION
     → CODE EVAL + Review
     → FIX ≤2
     → CANARY → FULL harness
     → REPORT + RETAIN
```

---

## Run ID + lane log

Every Task prompt/return stamps `RUN_ID`, `LANE_ID`, `STATUS`, `EVIDENCE_PATHS`.  
Append to project `LANE_LOG.md`.  
Master **discards** claims without evidence (anti-hallucination).

---

## Lock leases

`ttl_min=30`. Bus steals when `now > expires_at` without heartbeat.  
One writer per path.

---

## Evals

Rubrics in project `EVALS.md` (from template). Skill `@sid-evals`.  
PASS/FAIL gates. FAIL → discard/rework. Target human/LLM alignment ≥80%.

---

## Anti-hallucination

Evidence or `MISSING`. No invented APIs/files. Solo for sequential. Eval gates. Blackboard contracts.

---

## Launch brief (Task tool)

```
RUN_ID: sid-...
LANE_ID: ...
ROLE: ...
GOAL: <one line>
BLACKBOARD: .cursor/sid-orchestra/BLACKBOARD.md
LANE_LOG: append stamped return
EVAL: <rubric or none>
IN SCOPE / OUT OF SCOPE / DEPS / LEASES
DONE WHEN: ...
ANTI-GUESS: If missing, say MISSING.
```

---

## Budgets

| | |
|--|--|
| Max agents / wave | 12 |
| Fix rounds | 2 |
| Default swarm | prefer 5–7 not 10 |
| Lock TTL | 30 min |

## Done criteria

Mode set · run_id · Gate A · Plan Eval PASS · leases OK · Code Eval PASS · canary then full · LANE_LOG complete · no bare claims.

## Related

- `@sid-evals`  
- Templates / agents / loop under this skill folder  
- Project runtime: `.cursor/sid-orchestra/`
